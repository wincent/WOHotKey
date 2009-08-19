// WOHotKey.m
// WOHotKey
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

// TODO: for clarity should name the different kinds of modifier (Carbon, Cocoa, Quartz)
// we now have three types of modifier:
//      UInt32 (Carbon)
//      unsigned int (Cocoa, Tiger)
//      CGEventFlags (Quartz, uint64_t)
// to distinguish these really need to clean up all the method names so that the word "modifiers" is prefixed as follows:
//      carbonModifiers
//      cocoaModifiers
//      quartzModifiers

// class header
#import "WOHotKeyClass.h"

// other headers
#import "WOHotKeyLocalizations.h"

@interface WOHotKey ()

// helper method: returns nil on failure
+ (NSString *)stringUsingUchrResourceForKeyCode:(unsigned short)keyCode modifiers:(UInt32)modifiers;

// helper method: disambiguates strings returned from uchr or KCHR resources
+ (NSString *)_stringByReplacingAmbiguousCharactersInString:(NSString *)aString keyCode:(unsigned short)key;

// convenience macro used in preparing _WONSUnicodes table
#define WO_UNICODE_AND_STRING(k, s) s, [NSString stringWithFormat:@"%C", k]

// convenience macro used in preparing _WOUSKeyCodes/_WONonPrintingASCII tables
#define WO_KEYCODE_AND_STRING(k, s) s, [NSNumber numberWithInt:k]

// conversion table: NS Unicodes (0xF700–0xF8FF) to printable glyphs
+ (NSDictionary *)_WONSUnicodes;        // keys are NSStrings

// conversion table: Non-printing ASCII to printable glyphs
+ (NSDictionary *)_WONonPrintingASCII;  // keys are NSNumbers

// conversion table: default US keyboard keycodes to printable glyphs
+ (NSDictionary *)_WOUSKeyCodes;        // keys are NSNumbers

- (BOOL)isFalseFunctionKey;

+ (BOOL)isFalseFunctionKeyCode:(UInt32)keyCode;

@end

@implementation WOHotKey

#pragma mark Class variables

// TODO: initialize these dictionaries in a thread-safe manner (using WO_LOAD)
static NSDictionary *_WONSUnicodes          = nil;
static NSDictionary *_WONonPrintingASCII    = nil;
static NSDictionary *_WOUSKeyCodes          = nil;
static BOOL         _WOThrowsIfNoModifiers  = NO;

#pragma mark Class methods

+ (BOOL)throwsIfNoModifiers
{
    return _WOThrowsIfNoModifiers;
}

+ (void)setThrowsIfNoModifiers:(BOOL)flag
{
    _WOThrowsIfNoModifiers = flag;
}

+ (UInt32)carbonModifiersFromCocoa:(unsigned int)modifiers
{
    static UInt32 table[8][2] = {
#ifdef WO_ALLOW_CAPS_LOCK_AS_MODIFIER
        {NSAlphaShiftKeyMask,   alphaLock},
#else /* NOT WO_ALLOW_CAPS_LOCK_AS_MODIFIER */
        {NSAlphaShiftKeyMask,   0},
#endif /* NOT WO_ALLOW_CAPS_LOCK_AS_MODIFIER */
        {NSShiftKeyMask,        shiftKey},
        {NSControlKeyMask,      controlKey},
        {NSAlternateKeyMask,    optionKey},
        {NSCommandKeyMask,      cmdKey},
        {NSNumericPadKeyMask,   kEventKeyModifierNumLockMask},
        {NSHelpKeyMask,         0}, /* Carbon help key mask unknown! */
        {NSFunctionKeyMask,     kEventKeyModifierFnMask}
    };

    UInt32 returnValue = 0;
    for (unsigned i = 0, max = 8; i < max; i++)
        if (modifiers & table[i][0])
            returnValue += table[i][1];
    return returnValue;
}

+ (unsigned int)cocoaModifiersFromQuartz:(CGEventFlags)modifiers
{
    static CGEventFlags table[8][2] = {
#ifdef WO_ALLOW_CAPS_LOCK_AS_MODIFIER
        {kCGEventFlagMaskAlphaShift,    NSAlphaShiftKeyMask},
#else /* NOT WO_ALLOW_CAPS_LOCK_AS_MODIFIER */
        {kCGEventFlagMaskAlphaShift,    0},
#endif /* NOT WO_ALLOW_CAPS_LOCK_AS_MODIFIER */
        {kCGEventFlagMaskShift,         NSShiftKeyMask},
        {kCGEventFlagMaskControl,       NSControlKeyMask},
        {kCGEventFlagMaskAlternate,     NSAlternateKeyMask},
        {kCGEventFlagMaskCommand,       NSCommandKeyMask},
        {kCGEventFlagMaskNumericPad,    NSNumericPadKeyMask},
        {kCGEventFlagMaskHelp,          NSHelpKeyMask},
        {kCGEventFlagMaskSecondaryFn,   NSFunctionKeyMask}
    };

    UInt32 returnValue = 0;
    for (unsigned i = 0, max = 8; i < max; i++)
        if (modifiers & table[i][0])
            returnValue += table[i][1];
    return returnValue;
}

// return human-readable string showing key (no modifiers) for the key code
+ (NSString *)keyStringForKeyCode:(unsigned short)keyCode
{
    return [self keyStringForKeyCode:keyCode modifiers:0];
}

// return human-readable string showing key (no modifiers) for the key code
+ (NSString *)keyStringForKeyCode:(unsigned short)keyCode modifiers:(UInt32)modifiers
{
    NSString *returnString = [self stringUsingUchrResourceForKeyCode:keyCode modifiers:modifiers];
    if (returnString)   // handle ambiguous keys: Function Keys, "Esc", "Clear"
        returnString = [self _stringByReplacingAmbiguousCharactersInString:returnString keyCode:keyCode];
    else                // fallback to US-only keymap
        returnString = [self keyStringForKeyCodeUsingUSKeyboardLayout:keyCode];

    return returnString;
}

// helper method: returns nil on failure
+ (NSString *)stringUsingUchrResourceForKeyCode:(unsigned short)keyCode modifiers:(UInt32)modifiers
{
    NSString            *returnString   = nil;

    // determine current keyboard layout and try to get uchr resource
    TISInputSourceRef   sourceRef       = TISCopyCurrentKeyboardLayoutInputSource();
    CFDataRef           uchrData        = (CFDataRef)TISGetInputSourceProperty(sourceRef, kTISPropertyUnicodeKeyLayoutData);
    if (uchrData == NULL) return nil;           // no uchr resource, bail
    UCKeyboardLayout    *uchr           = (UCKeyboardLayout *)CFDataGetBytePtr(uchrData);
    UInt32              deadKeyState    = 0;    // must be initialized to zero
    UniChar             buffer[8];              // docs: "rare to get more than 4"
    UniCharCount        length;                 // actual string length returned

    OSStatus err = UCKeyTranslate(uchr,
                                  keyCode,
                                  kUCKeyActionDown,              // don't bother
                                  modifiers,
                                  LMGetKbdType(),
                                  kUCKeyTranslateNoDeadKeysMask, // don't bother
                                  &deadKeyState,
                                  8,
                                  &length,
                                  buffer);

    if ((err == noErr) && (length > 0)) // successfully translated key code
    {
        returnString = [[NSString alloc] initWithCharacters:buffer length:length];

        // double check for non-printing characters, and remove them
        NSNumber *key       = [NSNumber numberWithInt:buffer[0]];
        NSString *revised   = [[self _WONonPrintingASCII] objectForKey:key];

        if ((length == 1) && revised)
            returnString = revised;
        else
            returnString = [returnString uppercaseString];
    }
    return returnString;
}

// helper method: disambiguates strings returned from uchr or KCHR resources
+ (NSString *)_stringByReplacingAmbiguousCharactersInString:(NSString *)aString keyCode:(unsigned short)key
{
    if ([aString length] == 1)
    {
        // In "Inside Macintosh" Apple concedes that the virtual key codes are
        // not hardware independent 100% of the time, but what else can we do?
        // Fortunately, some of these codes are hardwired into Apple's iGetKeys
        // sample code (supposedly internationalization friendly), so it must be
        // fairly safe.

        UniChar testChar = [aString characterAtIndex:0];

        // all function keys return the same code!
        if (testChar == kFunctionKeyCharCode)
        {
            switch (key)
            {
                case kF1KeyVirtualKeyCode:  aString = @"F1";    break;
                case kF2KeyVirtualKeyCode:  aString = @"F2";    break;
                case kF3KeyVirtualKeyCode:  aString = @"F3";    break;
                case kF4KeyVirtualKeyCode:  aString = @"F4";    break;
                case kF5KeyVirtualKeyCode:  aString = @"F5";    break;
                case kF6KeyVirtualKeyCode:  aString = @"F6";    break;
                case kF7KeyVirtualKeyCode:  aString = @"F7";    break;
                case kF8KeyVirtualKeyCode:  aString = @"F8";    break;
                case kF9KeyVirtualKeyCode:  aString = @"F9";    break;
                case kF10KeyVirtualKeyCode: aString = @"F10";   break;
                case kF11KeyVirtualKeyCode: aString = @"F11";   break;
                case kF12KeyVirtualKeyCode: aString = @"F12";   break;
                case kF13KeyVirtualKeyCode: aString = @"F13";   break;
                case kF14KeyVirtualKeyCode: aString = @"F14";   break;
                case kF15KeyVirtualKeyCode: aString = @"F15";   break;
                case kF16KeyVirtualKeyCode: aString = @"F16";   break;
                default:                    aString = _WO_UNKNOWN;
            }
        }
        else if ((testChar == kEscapeCharCode) &&       // "ESC" reports 0x1b
                 (key == kEscapeKeyVirtualKeyCode))
            aString = WO_ESC_KEY_GLYPH;
        else if ((testChar == kClearCharCode) &&        // but so does "Clear"
                 (key == kKeyPadClearKeyVirtualKeyCode))
            aString = WO_CLEAR_KEY_GLYPH;
    }
    return aString;
}

// return human-readable string showing modifiers (Cocoa modifiers)
+ (NSString *)modifierStringForModifiers:(int)modifiers keyCode:(unsigned short)keyCode
{
    NSMutableString *tempString = [NSMutableString string];

#ifdef WO_ALLOW_CAPS_LOCK_AS_MODIFIER
    // Caps Lock always farthest to the left
    if (modifiers & NSAlphaShiftKeyMask)
        [tempString appendString:WO_CAPS_LOCK_KEY_GLYPH];
#endif /* WO_ALLOW_CAPS_LOCK_AS_MODIFIER */

    // output these glpyhs in the same order as Cocoa
    if (modifiers & NSControlKeyMask)
        [tempString appendString:WO_CONTROL_KEY_GLYPH];
    if (modifiers & NSAlternateKeyMask)
        [tempString appendString:WO_OPTION_KEY_GLYPH];
    if (modifiers & NSShiftKeyMask)
        [tempString appendString:WO_SHIFT_KEY_GLYPH];
    if (modifiers & NSCommandKeyMask)
        [tempString appendString:WO_COMMAND_KEY_GLYPH];

    if (modifiers & NSFunctionKeyMask)
    {
        if (![self isFalseFunctionKeyCode:keyCode])             // this is not (F1-F15, cursor keys etc)
            [tempString appendString:_WO_FN_KEY_WITH_HYPHEN];
    }

    // always on the far right
    if (modifiers & NSNumericPadKeyMask)
        [tempString appendString:_WO_PAD];

    // I don't have a help key on this keyboard!
//    if (modifiers & NSHelpKeyMask)
//        NSLog(@"NSHelpKeyMask");

    return [NSString stringWithString:tempString]; // return immutable string
}

// return human-readable string showing modifiers (Cocoa modifiers)
+ (NSString *)modifierStringForModifiers:(int)modifiers
{
    NSMutableString *tempString = [NSMutableString string];

#ifdef WO_ALLOW_CAPS_LOCK_AS_MODIFIER
    // Caps Lock always farthest to the left
    if (modifiers & NSAlphaShiftKeyMask)
        [tempString appendString:WO_CAPS_LOCK_KEY_GLYPH];
#endif /* WO_ALLOW_CAPS_LOCK_AS_MODIFIER */

    // output these glpyhs in the same order as Cocoa
    if (modifiers & NSControlKeyMask)
        [tempString appendString:WO_CONTROL_KEY_GLYPH];
    if (modifiers & NSAlternateKeyMask)
        [tempString appendString:WO_OPTION_KEY_GLYPH];
    if (modifiers & NSShiftKeyMask)
        [tempString appendString:WO_SHIFT_KEY_GLYPH];
    if (modifiers & NSCommandKeyMask)
        [tempString appendString:WO_COMMAND_KEY_GLYPH];

    // always show "fn" (screening for F1-F15 etc is not possible without a keycode)
    if (modifiers & NSFunctionKeyMask)
    {
        // use hyphen only if necessary (for visual separation from "Pad-")
        if (modifiers & NSNumericPadKeyMask)
            [tempString appendString:_WO_FN_KEY_WITH_HYPHEN];
        else
            [tempString appendString:_WO_FN_KEY];
    }

    // always on the far right: should never get here, see header docs
    if (modifiers & NSNumericPadKeyMask)
        [tempString appendString:_WO_PAD];

    // I don't have a help key on this keyboard!
//    if (modifiers & NSHelpKeyMask)
//        NSLog(@"NSHelpKeyMask");

    return [NSString stringWithString:tempString]; // return immutable string
}

// return human-readable string showing key + modifiers (Cocoa modifiers)
+ (NSString *)stringForKeyCode:(unsigned short)keyCode modifiers:(int)modifiers
{
    // some inefficiency: these methods will both call uchr/KCHR methods
    NSString *modifierString    = [self modifierStringForModifiers:modifiers keyCode:keyCode];
    NSString *keyString         = [self keyStringForKeyCode:keyCode];

    return [NSString stringWithFormat:@"%@%@", modifierString, keyString];
}

// return human-readable string showing key (no modifiers) for the event
+ (NSString *)keyStringForEvent:(NSEvent *)theEvent
{
    // preconditions
    if (!theEvent) return nil;
    NSParameterAssert([theEvent isKindOfClass:[NSEvent class]]);
    NSEventType type = [theEvent type];
    NSParameterAssert(type == NSKeyDown || type == NSKeyUp);

    int keyCode = [theEvent keyCode];
    return [self keyStringForKeyCode:keyCode];

#ifdef WO_USE_COCOA_KEYCODE_TO_CHARACTER_CONVERSION_METHODS
    // these Cooca methods not used because Cocoa doesn't ignore the shift key
    NSString *characters = [theEvent charactersIgnoringModifiers];

    if ([characters length] == 1)
    {
        NSString *returnString = nil;

        // handle special cases considered by NS to be "Function keys"
        if (returnString = [[self _WONSUnicodes] objectForKey:characters])
            return returnString;

        // handle Cocoa bug where Backspace (0x08) is reported as (0x7f)
        if (([characters characterAtIndex:0] == kDeleteCharCode) && ([theEvent keyCode] == kBackspaceKeyVirtualKeyCode))
            return WO_BACKSPACE_KEY_GLYPH;

        // handle non-visible characters
        NSNumber *key = [NSNumber numberWithInt:[characters characterAtIndex:0]];
        if (returnString = [[self _WONonPrintingASCII] objectForKey:key])
            return returnString;
    }

    // handle "dead keys" (empty string) by forwarding to other method
    if ([characters isEqualToString:@""])
        return [self keyStringForKeyCode:[theEvent keyCode]];

    // otherwise, just trust that Cocoa did a good job
    return [characters uppercaseString];
#endif /* WO_USE_COCOA_KEYCODE_TO_CHARACTER_CONVERSION_METHODS */
}

// return human-readable string showing modifiers for the event
+ (NSString *)modifierStringForEvent:(NSEvent *)theEvent
{
    NSString *returnString;

    // preconditions
    if (!theEvent) return nil;
    NSParameterAssert([theEvent isKindOfClass:[NSEvent class]]);
    NSEventType type = [theEvent type];
    NSParameterAssert(type == NSKeyDown || type == NSKeyUp || type == NSFlagsChanged);

    if (type == NSFlagsChanged)
        returnString = [self modifierStringForModifiers:[theEvent modifierFlags]];
    else
        returnString = [self modifierStringForModifiers:[theEvent modifierFlags] keyCode:[theEvent keyCode]];

    return returnString;
}

// return human-readable string showing modifiers and key for the event
+ (NSString *)stringForEvent:(NSEvent *)theEvent
{
    // preconditions
    if (!theEvent) return nil;
    NSParameterAssert([theEvent isKindOfClass:[NSEvent class]]);
    NSEventType type = [theEvent type];
    NSParameterAssert(type == NSKeyDown || type == NSKeyUp);

    return [self stringForKeyCode:[theEvent keyCode] modifiers:[theEvent modifierFlags]];
}

#pragma mark Private methods

// prepare conversion table: NS Unicodes (0xF700–0xF8FF) to printable glyphs
+ (NSDictionary *)_WONSUnicodes
{
    if (!_WONSUnicodes) // lazy initialization
    {
        // TODO: replace this macro with WO_DICTIONARY, WO_STRING (more transparent)
        _WONSUnicodes = [[NSDictionary alloc] initWithObjectsAndKeys:
            WO_UNICODE_AND_STRING(NSUpArrowFunctionKey,         WO_UP_ARROW_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSDownArrowFunctionKey,       WO_DOWN_ARROW_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSLeftArrowFunctionKey,       WO_LEFT_ARROW_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSRightArrowFunctionKey,      WO_RIGHT_ARROW_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSF1FunctionKey,              @"F1"),
            WO_UNICODE_AND_STRING(NSF2FunctionKey,              @"F2"),
            WO_UNICODE_AND_STRING(NSF3FunctionKey,              @"F3"),
            WO_UNICODE_AND_STRING(NSF4FunctionKey,              @"F4"),
            WO_UNICODE_AND_STRING(NSF5FunctionKey,              @"F5"),
            WO_UNICODE_AND_STRING(NSF6FunctionKey,              @"F6"),
            WO_UNICODE_AND_STRING(NSF7FunctionKey,              @"F7"),
            WO_UNICODE_AND_STRING(NSF8FunctionKey,              @"F8"),
            WO_UNICODE_AND_STRING(NSF9FunctionKey,              @"F9"),
            WO_UNICODE_AND_STRING(NSF10FunctionKey,             @"F10"),
            WO_UNICODE_AND_STRING(NSF11FunctionKey,             @"F11"),
            WO_UNICODE_AND_STRING(NSF12FunctionKey,             @"F12"),
            WO_UNICODE_AND_STRING(NSF13FunctionKey,             @"F13"),
            WO_UNICODE_AND_STRING(NSF14FunctionKey,             @"F14"),
            WO_UNICODE_AND_STRING(NSF15FunctionKey,             @"F15"),
            WO_UNICODE_AND_STRING(NSF16FunctionKey,             @"F16"),
            WO_UNICODE_AND_STRING(NSF17FunctionKey,             @"F17"),
            WO_UNICODE_AND_STRING(NSF18FunctionKey,             @"F18"),
            WO_UNICODE_AND_STRING(NSF19FunctionKey,             @"F19"),
            WO_UNICODE_AND_STRING(NSF20FunctionKey,             @"F20"),
            WO_UNICODE_AND_STRING(NSF21FunctionKey,             @"F21"),
            WO_UNICODE_AND_STRING(NSF22FunctionKey,             @"F22"),
            WO_UNICODE_AND_STRING(NSF23FunctionKey,             @"F23"),
            WO_UNICODE_AND_STRING(NSF24FunctionKey,             @"F24"),
            WO_UNICODE_AND_STRING(NSF25FunctionKey,             @"F25"),
            WO_UNICODE_AND_STRING(NSF26FunctionKey,             @"F26"),
            WO_UNICODE_AND_STRING(NSF27FunctionKey,             @"F27"),
            WO_UNICODE_AND_STRING(NSF28FunctionKey,             @"F28"),
            WO_UNICODE_AND_STRING(NSF29FunctionKey,             @"F29"),
            WO_UNICODE_AND_STRING(NSF30FunctionKey,             @"F30"),
            WO_UNICODE_AND_STRING(NSF31FunctionKey,             @"F31"),
            WO_UNICODE_AND_STRING(NSF32FunctionKey,             @"F32"),
            WO_UNICODE_AND_STRING(NSF33FunctionKey,             @"F33"),
            WO_UNICODE_AND_STRING(NSF34FunctionKey,             @"F34"),
            WO_UNICODE_AND_STRING(NSF35FunctionKey,             @"F35"),
            WO_UNICODE_AND_STRING(NSInsertFunctionKey,          _WO_INSERT),
            WO_UNICODE_AND_STRING(NSDeleteFunctionKey,          WO_DELETE_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSHomeFunctionKey,            WO_HOME_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSBeginFunctionKey,           _WO_BEGIN),
            WO_UNICODE_AND_STRING(NSEndFunctionKey,             WO_END_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSPageUpFunctionKey,          WO_PAGE_UP_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSPageDownFunctionKey,        WO_PAGE_DOWN_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSPrintScreenFunctionKey,     _WO_PRINT_SCREEN),
            WO_UNICODE_AND_STRING(NSScrollLockFunctionKey,      _WO_SCROLL_LOCK),
            WO_UNICODE_AND_STRING(NSPauseFunctionKey,           _WO_PAUSE),
            WO_UNICODE_AND_STRING(NSSysReqFunctionKey,          _WO_SYSTEM_REQUEST),
            WO_UNICODE_AND_STRING(NSBreakFunctionKey,           _WO_BREAK),
            WO_UNICODE_AND_STRING(NSResetFunctionKey,           _WO_RESET),
            WO_UNICODE_AND_STRING(NSStopFunctionKey,            _WO_STOP),
            WO_UNICODE_AND_STRING(NSMenuFunctionKey,            _WO_MENU),
            WO_UNICODE_AND_STRING(NSUserFunctionKey,            _WO_USER),
            WO_UNICODE_AND_STRING(NSSystemFunctionKey,          _WO_SYSTEM),
            WO_UNICODE_AND_STRING(NSPrintFunctionKey,           _WO_PRINT),
            WO_UNICODE_AND_STRING(NSClearLineFunctionKey,       WO_CLEAR_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSClearDisplayFunctionKey,    _WO_CLEAR),
            WO_UNICODE_AND_STRING(NSInsertLineFunctionKey,      _WO_INSERT_LINE),
            WO_UNICODE_AND_STRING(NSDeleteLineFunctionKey,      _WO_DELETE_LINE),
            WO_UNICODE_AND_STRING(NSInsertCharFunctionKey,      _WO_INSERT_CHAR),
            WO_UNICODE_AND_STRING(NSDeleteCharFunctionKey,      _WO_DELETE_CHAR),
            WO_UNICODE_AND_STRING(NSPrevFunctionKey,            _WO_PREVIOUS),
            WO_UNICODE_AND_STRING(NSNextFunctionKey,            _WO_NEXT),
            WO_UNICODE_AND_STRING(NSSelectFunctionKey,          _WO_SELECT),
            WO_UNICODE_AND_STRING(NSExecuteFunctionKey,         _WO_EXECUTE),
            WO_UNICODE_AND_STRING(NSUndoFunctionKey,            _WO_UNDO),
            WO_UNICODE_AND_STRING(NSRedoFunctionKey,            _WO_REDO),
            WO_UNICODE_AND_STRING(NSFindFunctionKey,            _WO_FIND),
            WO_UNICODE_AND_STRING(NSHelpFunctionKey,            WO_HELP_KEY_GLYPH),
            WO_UNICODE_AND_STRING(NSModeSwitchFunctionKey,      _WO_MODE_SWITCH),
            nil];
    }
    return _WONSUnicodes;
}

// prepare conversion table: Non-printing ASCII to printable glyphs
+ (NSDictionary *)_WONonPrintingASCII
{
    // handle non-visible ASCII codes returned by uchr and KCHR
    // <http://developer.apple.com/documentation/mac/Text/Text-516.html>

    if (!_WONonPrintingASCII) // lazy initialization
    {
        _WONonPrintingASCII = [[NSDictionary alloc] initWithObjectsAndKeys:
            WO_KEYCODE_AND_STRING(0x0001, WO_HOME_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x0003, WO_ENTER_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x0004, WO_END_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x0005, WO_HELP_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x0008, WO_BACKSPACE_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x0009, WO_TAB_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x000b, WO_PAGE_UP_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x000c, WO_PAGE_DOWN_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x000d, WO_RETURN_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x001b, WO_ESC_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x001c, WO_LEFT_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x001d, WO_RIGHT_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x001e, WO_UP_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x001f, WO_DOWN_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(0x0020, _WO_SPACE),
            WO_KEYCODE_AND_STRING(0x007f, WO_DELETE_KEY_GLYPH),
            nil];
    }
    return _WONonPrintingASCII;
}

+ (NSString *)keyStringForKeyCodeUsingUSKeyboardLayout:(unsigned short)keyCode
{
    NSString *glyph = [[self _WOUSKeyCodes] objectForKey:[NSNumber numberWithInt:keyCode]];
    return (glyph ? glyph : _WO_UNKNOWN);
}

// prepare conversion table: default US keyboard keycodes to printable glyphs
+ (NSDictionary *)_WOUSKeyCodes
{
    if (!_WOUSKeyCodes) // lazy initialization
    {
        _WOUSKeyCodes = [[NSDictionary alloc] initWithObjectsAndKeys:
            WO_KEYCODE_AND_STRING(kAKeyVirtualKeyCode,                  @"A"),
            WO_KEYCODE_AND_STRING(kSKeyVirtualKeyCode,                  @"S"),
            WO_KEYCODE_AND_STRING(kDKeyVirtualKeyCode,                  @"D"),
            WO_KEYCODE_AND_STRING(kFKeyVirtualKeyCode,                  @"F"),
            WO_KEYCODE_AND_STRING(kHKeyVirtualKeyCode,                  @"H"),
            WO_KEYCODE_AND_STRING(kGKeyVirtualKeyCode,                  @"G"),
            WO_KEYCODE_AND_STRING(kZKeyVirtualKeyCode,                  @"Z"),
            WO_KEYCODE_AND_STRING(kXKeyVirtualKeyCode,                  @"X"),
            WO_KEYCODE_AND_STRING(kCKeyVirtualKeyCode,                  @"C"),
            WO_KEYCODE_AND_STRING(kVKeyVirtualKeyCode,                  @"V"),
            WO_KEYCODE_AND_STRING(kSectionKeyVirtualKeyCode,            WO_SECTION_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kBKeyVirtualKeyCode,                  @"B"),
            WO_KEYCODE_AND_STRING(kQKeyVirtualKeyCode,                  @"Q"),
            WO_KEYCODE_AND_STRING(kWKeyVirtualKeyCode,                  @"W"),
            WO_KEYCODE_AND_STRING(kEKeyVirtualKeyCode,                  @"E"),
            WO_KEYCODE_AND_STRING(kRKeyVirtualKeyCode,                  @"R"),
            WO_KEYCODE_AND_STRING(kYKeyVirtualKeyCode,                  @"Y"),
            WO_KEYCODE_AND_STRING(kTKeyVirtualKeyCode,                  @"T"),
            WO_KEYCODE_AND_STRING(k1KeyVirtualKeyCode,                  @"1"),
            WO_KEYCODE_AND_STRING(k2KeyVirtualKeyCode,                  @"2"),
            WO_KEYCODE_AND_STRING(k3KeyVirtualKeyCode,                  @"3"),
            WO_KEYCODE_AND_STRING(k4KeyVirtualKeyCode,                  @"4"),
            WO_KEYCODE_AND_STRING(k6KeyVirtualKeyCode,                  @"6"),
            WO_KEYCODE_AND_STRING(k5KeyVirtualKeyCode,                  @"5"),
            WO_KEYCODE_AND_STRING(kEqualsKeyVirtualKeyCode,             @"="),
            WO_KEYCODE_AND_STRING(k9KeyVirtualKeyCode,                  @"9"),
            WO_KEYCODE_AND_STRING(k7KeyVirtualKeyCode,                  @"7"),
            WO_KEYCODE_AND_STRING(kMinusKeyVirtualKeyCode,              @"-"),
            WO_KEYCODE_AND_STRING(k8KeyVirtualKeyCode,                  @"8"),
            WO_KEYCODE_AND_STRING(k0KeyVirtualKeyCode,                  @"0"),
            WO_KEYCODE_AND_STRING(kRightBracketKeyVirtualKeyCode,       @"]"),
            WO_KEYCODE_AND_STRING(kOKeyVirtualKeyCode,                  @"O"),
            WO_KEYCODE_AND_STRING(kUKeyVirtualKeyCode,                  @"U"),
            WO_KEYCODE_AND_STRING(kLeftBracketKeyVirtualKeyCode,        @"["),
            WO_KEYCODE_AND_STRING(kIKeyVirtualKeyCode,                  @"I"),
            WO_KEYCODE_AND_STRING(kPKeyVirtualKeyCode,                  @"P"),
            WO_KEYCODE_AND_STRING(kReturnKeyVirtualKeyCode,             WO_RETURN_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kLKeyVirtualKeyCode,                  @"L"),
            WO_KEYCODE_AND_STRING(kJKeyVirtualKeyCode,                  @"J"),
            WO_KEYCODE_AND_STRING(kSingleQuoteKeyVirtualKeyCode,        @"'"),
            WO_KEYCODE_AND_STRING(kKKeyVirtualKeyCode,                  @"K"),
            WO_KEYCODE_AND_STRING(kSemicolonKeyVirtualKeyCode,          @";"),
            WO_KEYCODE_AND_STRING(kBackSlashKeyVirtualKeyCode,          @"\\"),
            WO_KEYCODE_AND_STRING(kCommaKeyVirtualKeyCode,              @","),
            WO_KEYCODE_AND_STRING(kForwardSlashKeyVirtualKeyCode,       @"/"),
            WO_KEYCODE_AND_STRING(kNKeyVirtualKeyCode,                  @"N"),
            WO_KEYCODE_AND_STRING(kMKeyVirtualKeyCode,                  @"M"),
            WO_KEYCODE_AND_STRING(kPeriodKeyVirtualKeyCode,             @"."),
            WO_KEYCODE_AND_STRING(kTabKeyVirtualKeyCode,                WO_TAB_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kSpaceKeyVirtualKeyCode,              _WO_SPACE),
            WO_KEYCODE_AND_STRING(kBackTickKeyVirtualKeyCode,           @"`"),
            WO_KEYCODE_AND_STRING(kBackspaceKeyVirtualKeyCode,          WO_BACKSPACE_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kEnterKeyVirtualKeyCode,              WO_ENTER_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kEscapeKeyVirtualKeyCode,             WO_ESC_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kCommandKeyVirtualKeyCode,            WO_COMMAND_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kShiftKeyVirtualKeyCode,              WO_SHIFT_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kCapsLockKeyVirtualKeyCode,           WO_CAPS_LOCK_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kOptionKeyVirtualKeyCode,             WO_OPTION_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kControlKeyVirtualKeyCode,            WO_CONTROL_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kRightShiftKeyVirtualKeyCode,         WO_SHIFT_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kRightOptionKeyVirtualKeyCode,        WO_OPTION_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kRightControlKeyVirtualKeyCode,       WO_CONTROL_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kFNKeyVirtualKeyCode,                 @"fn"),
            WO_KEYCODE_AND_STRING(kKeyPadPeriodKeyVirtualKeyCode,       @"."),
            WO_KEYCODE_AND_STRING(kKeyPadRightArrowKeyVirtualKeyCode,   WO_RIGHT_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kKeyPadAsteriskKeyVirtualKeyCode,     @"*"),
            WO_KEYCODE_AND_STRING(kKeyPadPlusKeyVirtualKeyCode,         @"+"),
            WO_KEYCODE_AND_STRING(kKeyPadLeftArrowKeyVirtualKeyCode,    WO_LEFT_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kKeyPadClearKeyVirtualKeyCode,        WO_CLEAR_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kKeyPadDownArrowKeyVirtualKeyCode,    WO_DOWN_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kKeyPadForwardSlashKeyVirtualKeyCode, @"/"),
            WO_KEYCODE_AND_STRING(kKeyPadEnterKeyVirtualKeyCode,        WO_ENTER_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kKeyPadUpArrowKeyVirtualKeyCode,      WO_UP_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kKeyPadMinusKeyVirtualKeyCode,        @"-"),
            WO_KEYCODE_AND_STRING(kKeyPadEqualsKeyVirtualKeyCode,       @"="),
            WO_KEYCODE_AND_STRING(kKeyPad0KeyVirtualKeyCode,            @"0"),
            WO_KEYCODE_AND_STRING(kKeyPad1KeyVirtualKeyCode,            @"1"),
            WO_KEYCODE_AND_STRING(kKeyPad2KeyVirtualKeyCode,            @"2"),
            WO_KEYCODE_AND_STRING(kKeyPad3KeyVirtualKeyCode,            @"3"),
            WO_KEYCODE_AND_STRING(kKeyPad4KeyVirtualKeyCode,            @"4"),
            WO_KEYCODE_AND_STRING(kKeyPad5KeyVirtualKeyCode,            @"5"),
            WO_KEYCODE_AND_STRING(kKeyPad6KeyVirtualKeyCode,            @"6"),
            WO_KEYCODE_AND_STRING(kKeyPad7KeyVirtualKeyCode,            @"7"),
            WO_KEYCODE_AND_STRING(kKeyPad8KeyVirtualKeyCode,            @"8"),
            WO_KEYCODE_AND_STRING(kKeyPad9KeyVirtualKeyCode,            @"9"),
            WO_KEYCODE_AND_STRING(kF5KeyVirtualKeyCode,                 @"F5"),
            WO_KEYCODE_AND_STRING(kF6KeyVirtualKeyCode,                 @"F6"),
            WO_KEYCODE_AND_STRING(kF7KeyVirtualKeyCode,                 @"F7"),
            WO_KEYCODE_AND_STRING(kF3KeyVirtualKeyCode,                 @"F3"),
            WO_KEYCODE_AND_STRING(kF8KeyVirtualKeyCode,                 @"F8"),
            WO_KEYCODE_AND_STRING(kF9KeyVirtualKeyCode,                 @"F9"),
            WO_KEYCODE_AND_STRING(kF11KeyVirtualKeyCode,                @"F11"),
            WO_KEYCODE_AND_STRING(kF13KeyVirtualKeyCode,                @"F13"),
            WO_KEYCODE_AND_STRING(kF14KeyVirtualKeyCode,                @"F14"),
            WO_KEYCODE_AND_STRING(kF10KeyVirtualKeyCode,                @"F10"),
            WO_KEYCODE_AND_STRING(kF12KeyVirtualKeyCode,                @"F12"),
            WO_KEYCODE_AND_STRING(kF15KeyVirtualKeyCode,                @"F15"),
            WO_KEYCODE_AND_STRING(kHelpKeyVirtualKeyCode,               WO_HELP_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kHomeKeyVirtualKeyCode,               WO_HOME_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kPageUpKeyVirtualKeyCode,             WO_PAGE_UP_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kDeleteKeyVirtualKeyCode,             WO_DELETE_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kF4KeyVirtualKeyCode,                 @"F4"),
            WO_KEYCODE_AND_STRING(kEndKeyVirtualKeyCode,                WO_END_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kF2KeyVirtualKeyCode,                 @"F2"),
            WO_KEYCODE_AND_STRING(kPageDownKeyVirtualKeyCode,           WO_PAGE_DOWN_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kF1KeyVirtualKeyCode,                 @"F1"),
            WO_KEYCODE_AND_STRING(kLeftArrowKeyVirtualKeyCode,          WO_LEFT_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kRightArrowKeyVirtualKeyCode,         WO_RIGHT_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kDownArrowKeyVirtualKeyCode,          WO_DOWN_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kUpArrowKeyVirtualKeyCode,            WO_UP_ARROW_KEY_GLYPH),
            WO_KEYCODE_AND_STRING(kPowerKeyVirtualKeyCode,              WO_POWER_KEY_GLYPH),
            nil];
    }
    return _WOUSKeyCodes;
}

#pragma mark Instance methods

- (id)initWithKeyCode:(UInt32)keyCode modifiers:(CGEventFlags)modifiers
{
    if ((self = [super init]))
    {
        self->hotKeyCode        = keyCode;
        self->hotKeyModifiers   = modifiers;
        [self normalize];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[WOHotKey allocWithZone:zone] initWithKeyCode:[self hotKeyCode] modifiers:[self hotKeyModifiers]];
}

+ (id)hotKeyWithDictionary:(NSDictionary *)aDictionary
{
    return [[self alloc] initWithDictionary:aDictionary];
}

+ (id)hotKeyWithKeyCode:(UInt32)keyCode modifiers:(CGEventFlags)modifiers
{
    return [[self alloc] initWithKeyCode:keyCode modifiers:modifiers];
}

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
    // BUG: if aDictionary is nil or returns nil for either key, results are undefined
    return [self initWithKeyCode:[[aDictionary objectForKey:WO_HOT_KEY_DICT_CODE] intValue]
                       modifiers:[[aDictionary objectForKey:WO_HOT_KEY_DICT_MODIFIERS] intValue]];
}

// programmer-centric description of receiver, suitable for logging/debugging
- (NSString *)description
{
    return [NSString stringWithFormat:
        @"<%@ %#x> {hotKeyCode = %d, hotKeyModifiers = %d, "
        @"stringRepresentation = \"%@\"}",
        NSStringFromClass([self class]),
        self,
        [self hotKeyCode],
        [self hotKeyModifiers],
        [self stringRepresentation]];
}

// user-centric representation of receiver, suitable for display in interface
- (NSString *)stringRepresentation
{
    return [WOHotKey stringForKeyCode:[self hotKeyCode] modifiers:[self hotKeyModifiers]];
}

- (unsigned)hash
{
    // <http://cocoadev.com/index.pl?HashingAndEquality>
    return ([self hotKeyCode] ^ [self hotKeyModifiers]);
}

- (BOOL)isEqual:(id)anObject
{
    if (self == anObject) return YES;

    if ([anObject isKindOfClass:[WOHotKey class]])
    {
        if (([self hotKeyCode] == [anObject hotKeyCode]) && ([self hotKeyModifiers] == [anObject hotKeyModifiers]))
            return YES;
    }
    return NO;
}

// ensure that the NSFunctionKeyMask does not apply to the function keys and other obvious candidates (arrow keys)
// TODO: need to find out what this does on a PowerBook keyboard with a real "FN" key
- (void)normalize
{
    if ([self isFalseFunctionKey])
    {
        CGEventFlags modifiers = [self hotKeyModifiers];
        if (modifiers & NSFunctionKeyMask)
            [self setHotKeyModifiers:(modifiers & (~NSFunctionKeyMask))];
    }
}

- (BOOL)isFalseFunctionKey
{
    return [WOHotKey isFalseFunctionKeyCode:[self hotKeyCode]];
}

+ (BOOL)isFalseFunctionKeyCode:(UInt32)keyCode
{
    return ((keyCode == kF1KeyVirtualKeyCode)           ||  (keyCode == kF2KeyVirtualKeyCode)           ||
            (keyCode == kF3KeyVirtualKeyCode)           ||  (keyCode == kF4KeyVirtualKeyCode)           ||
            (keyCode == kF5KeyVirtualKeyCode)           ||  (keyCode == kF6KeyVirtualKeyCode)           ||
            (keyCode == kF7KeyVirtualKeyCode)           ||  (keyCode == kF8KeyVirtualKeyCode)           ||
            (keyCode == kF9KeyVirtualKeyCode)           ||  (keyCode == kF10KeyVirtualKeyCode)          ||
            (keyCode == kF11KeyVirtualKeyCode)          ||  (keyCode == kF12KeyVirtualKeyCode)          ||
            (keyCode == kF13KeyVirtualKeyCode)          ||  (keyCode == kF14KeyVirtualKeyCode)          ||
            (keyCode == kF15KeyVirtualKeyCode)          ||  (keyCode == kF16KeyVirtualKeyCode)          ||
            (keyCode == kHelpKeyVirtualKeyCode)         ||  (keyCode == kPageUpKeyVirtualKeyCode)       ||
            (keyCode == kHomeKeyVirtualKeyCode)         ||  (keyCode == kDeleteKeyVirtualKeyCode)       ||
            (keyCode == kPageDownKeyVirtualKeyCode)     ||  (keyCode == kEndKeyVirtualKeyCode)          ||
            (keyCode == kLeftArrowKeyVirtualKeyCode)    ||  (keyCode == kUpArrowKeyVirtualKeyCode)      ||
            (keyCode == kDownArrowKeyVirtualKeyCode)    ||  (keyCode == kRightArrowKeyVirtualKeyCode)) ? YES : NO;
}

- (NSEvent *)pressEvent
{
    return [self eventWithType:NSKeyDown];
}

- (NSEvent *)releaseEvent
{
    return [self eventWithType:NSKeyUp];
}

- (NSEvent *)eventWithType:(NSEventType)type
{
    NSPoint     location        = NSZeroPoint;
    NSWindow    *window         = nil;
    int         windowNumber    = 0;
    if ((window = [[NSApplication sharedApplication] keyWindow]))
    {
        location        = [window mouseLocationOutsideOfEventStream];
        windowNumber    = [window windowNumber];
    }

    return [NSEvent keyEventWithType:type
                            location:location
                       modifierFlags:hotKeyModifiers
                           timestamp:(NSTimeInterval)GetCurrentEventTime()
                        windowNumber:windowNumber
                             context:[NSGraphicsContext currentContext]
                          characters:[WOHotKey keyStringForKeyCode:hotKeyCode modifiers:hotKeyModifiers]
         charactersIgnoringModifiers:[WOHotKey keyStringForKeyCode:hotKeyCode]
                           isARepeat:NO
                             keyCode:hotKeyCode];
}

#pragma mark -
#pragma mark Serialization methods

- (NSDictionary *)dictionaryRepresentation
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:[self hotKeyCode]],         WO_HOT_KEY_DICT_CODE,
        [NSNumber numberWithInt:[self hotKeyModifiers]],    WO_HOT_KEY_DICT_MODIFIERS,
        nil];
}

#pragma mark -
#pragma mark Conversion methods

// methods for converting to/from Cocoa/Carbon/Unicode reps (split into separate file as a category if it gets too big)

#pragma mark -
#pragma mark Accessor methods

- (UInt32)hotKeyCode
{
    return hotKeyCode;
}

- (void)setHotKeyCode:(UInt32)aCode
{
    hotKeyCode = aCode;
}

- (CGEventFlags)hotKeyModifiers
{
    return hotKeyModifiers;
}

- (void)setHotKeyModifiers:(CGEventFlags)modifiers
{
    hotKeyModifiers = modifiers;
}

#ifdef WO_DEBUG /* don't even compile unit tests in deployment builds */
//+ (void)unitTest
//{
//    // should complain if sent a non-NSEvent
//    WO_TEST_EXCEPTION([self keyStringForEvent:
//        (NSEvent *)[NSNumber numberWithInt:32]]);
//    WO_TEST_EXCEPTION([self modifierStringForEvent:
//        (NSEvent *)[NSNumber numberWithInt:32]]);
//    WO_TEST_EXCEPTION([self stringForEvent:
//        (NSEvent *)[NSNumber numberWithInt:32]]);
//
//    // should return nil if we pass nil
//    WO_TEST_NIL([self keyStringForEvent:nil]);
//    WO_TEST_NIL([self modifierStringForEvent:nil]);
//    WO_TEST_NIL([self stringForEvent:nil]);
//}
#endif /* DEBUG */

@end