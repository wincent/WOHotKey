// WOHotKeyClass.h
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

#import <Carbon/Carbon.h>

#define WO_HOT_KEY_DICT_CODE        @"HotKeyCode"

#define WO_HOT_KEY_DICT_MODIFIERS   @"HotKeyModifiers"

/*
 First revision based on the key codes table at:
    <http://utopia.knoware.nl/users/eprebel/Macintosh/KeyCodes/>
 Results checked against Apple's "iGetKeys" sample code:
    <http://developer.apple.com/samplecode/iGetKeys/iGetKeys.html>
 Final, authoritative version (matching US keylayout) using info from:
    <http://www.mactech.com/articles/mactech/Vol.04/04.12/Macinkeys/>
*/
enum {
    kAKeyVirtualKeyCode                     = 0x0000,
    kSKeyVirtualKeyCode                     = 0x0001,
    kDKeyVirtualKeyCode                     = 0x0002,
    kFKeyVirtualKeyCode                     = 0x0003,
    kHKeyVirtualKeyCode                     = 0x0004,
    kGKeyVirtualKeyCode                     = 0x0005,
    kZKeyVirtualKeyCode                     = 0x0006,
    kXKeyVirtualKeyCode                     = 0x0007,
    kCKeyVirtualKeyCode                     = 0x0008,
    kVKeyVirtualKeyCode                     = 0x0009,
    kSectionKeyVirtualKeyCode               = 0x000a,
    kBKeyVirtualKeyCode                     = 0x000b,
    kQKeyVirtualKeyCode                     = 0x000c,
    kWKeyVirtualKeyCode                     = 0x000d,
    kEKeyVirtualKeyCode                     = 0x000e,
    kRKeyVirtualKeyCode                     = 0x000f,
    kYKeyVirtualKeyCode                     = 0x0010,
    kTKeyVirtualKeyCode                     = 0x0011,
    k1KeyVirtualKeyCode                     = 0x0012,
    k2KeyVirtualKeyCode                     = 0x0013,
    k3KeyVirtualKeyCode                     = 0x0014,
    k4KeyVirtualKeyCode                     = 0x0015,
    k6KeyVirtualKeyCode                     = 0x0016,
    k5KeyVirtualKeyCode                     = 0x0017,
    kEqualsKeyVirtualKeyCode                = 0x0018,
    k9KeyVirtualKeyCode                     = 0x0019,
    k7KeyVirtualKeyCode                     = 0x001a,
    kMinusKeyVirtualKeyCode                 = 0x001b,
    k8KeyVirtualKeyCode                     = 0x001c,
    k0KeyVirtualKeyCode                     = 0x001d,
    kRightBracketKeyVirtualKeyCode          = 0x001e,
    kOKeyVirtualKeyCode                     = 0x001f,
    kUKeyVirtualKeyCode                     = 0x0020,
    kLeftBracketKeyVirtualKeyCode           = 0x0021,
    kIKeyVirtualKeyCode                     = 0x0022,
    kPKeyVirtualKeyCode                     = 0x0023,
    kReturnKeyVirtualKeyCode                = 0x0024,   /* matches iGetKeys */
    kLKeyVirtualKeyCode                     = 0x0025,
    kJKeyVirtualKeyCode                     = 0x0026,
    kSingleQuoteKeyVirtualKeyCode           = 0x0027,
    kKKeyVirtualKeyCode                     = 0x0028,
    kSemicolonKeyVirtualKeyCode             = 0x0029,
    kBackSlashKeyVirtualKeyCode             = 0x002a,
    kCommaKeyVirtualKeyCode                 = 0x002b,
    kForwardSlashKeyVirtualKeyCode          = 0x002c,
    kNKeyVirtualKeyCode                     = 0x002d,
    kMKeyVirtualKeyCode                     = 0x002e,
    kPeriodKeyVirtualKeyCode                = 0x002f,
    kTabKeyVirtualKeyCode                   = 0x0030,   /* matches iGetKeys */
    kSpaceKeyVirtualKeyCode                 = 0x0031,
    kBackTickKeyVirtualKeyCode              = 0x0032,   /* ? */
    kBackspaceKeyVirtualKeyCode             = 0x0033,   /* matches iGetKeys */
    kEnterKeyVirtualKeyCode                 = 0x0034,   /* ? */
    kEscapeKeyVirtualKeyCode                = 0x0035,   /* matches iGetKeys */
    /* Not set                                0x0036 */
    kCommandKeyVirtualKeyCode               = 0x0037,   /* matches iGetKeys */
    kShiftKeyVirtualKeyCode                 = 0x0038,   /* matches iGetKeys */
    kCapsLockKeyVirtualKeyCode              = 0x0039,   /* matches iGetKeys */
    kOptionKeyVirtualKeyCode                = 0x003a,   /* matches iGetKeys */
    kControlKeyVirtualKeyCode               = 0x003b,   /* matches iGetKeys */
    kRightShiftKeyVirtualKeyCode            = 0x003c,   /* never sent? */
    kRightOptionKeyVirtualKeyCode           = 0x003d,   /* never sent? */
    kRightControlKeyVirtualKeyCode          = 0x003e,   /* never sent? */
    kFNKeyVirtualKeyCode                    = 0x003f,   /* empirical! */
    /* Not set                                0x0040 */
    kKeyPadPeriodKeyVirtualKeyCode          = 0x0041,
    kKeyPadRightArrowKeyVirtualKeyCode      = 0x0042,
    kKeyPadAsteriskKeyVirtualKeyCode        = 0x0043,
    /* Not set                                0x0044 */
    kKeyPadPlusKeyVirtualKeyCode            = 0x0045,
    kKeyPadLeftArrowKeyVirtualKeyCode       = 0x0046,
    kKeyPadClearKeyVirtualKeyCode           = 0x0047,
    kKeyPadDownArrowKeyVirtualKeyCode       = 0x0048,
    /* Not set                                0x0049 */
    /* Not set                                0x004a */
    kKeyPadForwardSlashKeyVirtualKeyCode    = 0x004b,
    kKeyPadEnterKeyVirtualKeyCode           = 0x004c,   /* matches iGetKeys */
    kKeyPadUpArrowKeyVirtualKeyCode         = 0x004d,
    kKeyPadMinusKeyVirtualKeyCode           = 0x004e,
    /* Not set                                0x004f */
    /* Not set                                0x0050 */
    kKeyPadEqualsKeyVirtualKeyCode          = 0x0051,
    kKeyPad0KeyVirtualKeyCode               = 0x0052,
    kKeyPad1KeyVirtualKeyCode               = 0x0053,
    kKeyPad2KeyVirtualKeyCode               = 0x0054,
    kKeyPad3KeyVirtualKeyCode               = 0x0055,
    kKeyPad4KeyVirtualKeyCode               = 0x0056,
    kKeyPad5KeyVirtualKeyCode               = 0x0057,
    kKeyPad6KeyVirtualKeyCode               = 0x0058,
    kKeyPad7KeyVirtualKeyCode               = 0x0059,
    /* Not sent                               0x005a */
    kKeyPad8KeyVirtualKeyCode               = 0x005b,
    kKeyPad9KeyVirtualKeyCode               = 0x005c,
    /* Not sent                               0x005d */
    /* Not sent                               0x005e */
    /* Not sent                               0x005f */
    kF5KeyVirtualKeyCode                    = 0x0060,
    kF6KeyVirtualKeyCode                    = 0x0061,
    kF7KeyVirtualKeyCode                    = 0x0062,
    kF3KeyVirtualKeyCode                    = 0x0063,
    kF8KeyVirtualKeyCode                    = 0x0064,
    kF9KeyVirtualKeyCode                    = 0x0065,
    /* Not sent                               0x0066 */
    kF11KeyVirtualKeyCode                   = 0x0067,
    /* Not sent                               0x0068 */
    kF13KeyVirtualKeyCode                   = 0x0069,
    kF16KeyVirtualKeyCode                   = 0x006a,   /* empirical */
    kF14KeyVirtualKeyCode                   = 0x006b,
    /* Not sent                               0x006c */
    kF10KeyVirtualKeyCode                   = 0x006d,
    /* Not sent                               0x006e */
    kF12KeyVirtualKeyCode                   = 0x006f,
    /* Not sent                               0x0070 */
    kF15KeyVirtualKeyCode                   = 0x0071,
    kHelpKeyVirtualKeyCode                  = 0x0072,
    kHomeKeyVirtualKeyCode                  = 0x0073,   /* matches iGetKeys */
    kPageUpKeyVirtualKeyCode                = 0x0074,   /* matches iGetKeys */
    kDeleteKeyVirtualKeyCode                = 0x0075,   /* matches iGetKeys */
    kF4KeyVirtualKeyCode                    = 0x0076,
    kEndKeyVirtualKeyCode                   = 0x0077,   /* <rdar://73733481/> */
    kF2KeyVirtualKeyCode                    = 0x0078,
    kPageDownKeyVirtualKeyCode              = 0x0079,   /* matches iGetKeys */
    kF1KeyVirtualKeyCode                    = 0x007a,
    kLeftArrowKeyVirtualKeyCode             = 0x007b,   /* matches iGetKeys */
    kRightArrowKeyVirtualKeyCode            = 0x007c,   /* matches iGetKeys */
    kDownArrowKeyVirtualKeyCode             = 0x007d,   /* matches iGetKeys */
    kUpArrowKeyVirtualKeyCode               = 0x007e,   /* matches iGetKeys */
    kPowerKeyVirtualKeyCode                 = 0x007f
};

#pragma mark Unicode to NSString convenience macros

/*! all of these guaranteed to work for Lucida Grande; more info here <http://www.unicode.org/Public/MAPPINGS/VENDORS/APPLE/KEYBOARD.TXT> */

// single-character glyphs
#define WO_SECTION_KEY_GLYPH        [NSString stringWithFormat:@"%C", 0x00a7]
#define WO_LEFT_ARROW_KEY_GLYPH     [NSString stringWithFormat:@"%C", 0x2190]
#define WO_UP_ARROW_KEY_GLYPH       [NSString stringWithFormat:@"%C", 0x2191]
#define WO_RIGHT_ARROW_KEY_GLYPH    [NSString stringWithFormat:@"%C", 0x2192]
#define WO_DOWN_ARROW_KEY_GLYPH     [NSString stringWithFormat:@"%C", 0x2193]
#define WO_HOME_KEY_GLYPH           [NSString stringWithFormat:@"%C", 0x2196]
#define WO_END_KEY_GLYPH            [NSString stringWithFormat:@"%C", 0x2198]
#define WO_RETURN_KEY_GLYPH         [NSString stringWithFormat:@"%C", 0x21a9]
#define WO_PAGE_UP_KEY_GLYPH        [NSString stringWithFormat:@"%C", 0x21de]
#define WO_PAGE_DOWN_KEY_GLYPH      [NSString stringWithFormat:@"%C", 0x21df]
#define WO_TAB_KEY_GLYPH            [NSString stringWithFormat:@"%C", 0x21e5]
#define WO_SHIFT_KEY_GLYPH          [NSString stringWithFormat:@"%C", 0x21e7]
#define WO_CAPS_LOCK_KEY_GLYPH      [NSString stringWithFormat:@"%C", 0x21ea]
#define WO_CONTROL_KEY_GLYPH        [NSString stringWithFormat:@"%C", 0x2303]
#define WO_COMMAND_KEY_GLYPH        [NSString stringWithFormat:@"%C", 0x2318]
#define WO_ENTER_KEY_GLYPH          [NSString stringWithFormat:@"%C", 0x2324]
#define WO_OPTION_KEY_GLYPH         [NSString stringWithFormat:@"%C", 0x2325]
#define WO_DELETE_KEY_GLYPH         [NSString stringWithFormat:@"%C", 0x2326]
#define WO_CLEAR_KEY_GLYPH          [NSString stringWithFormat:@"%C", 0x2327]
#define WO_BACKSPACE_KEY_GLYPH      [NSString stringWithFormat:@"%C", 0x232b]
#define WO_POWER_KEY_GLYPH          [NSString stringWithFormat:@"%C", 0x233d]
#define WO_ESC_KEY_GLYPH            [NSString stringWithFormat:@"%C", 0x238b]

// one composite-character glyph
#define WO_HELP_KEY_GLYPH   [NSString stringWithFormat:@"%C%C", 0x003f, 0x20dd]

/*!

@class      WOHotKey

@abstract   Encapsulation for Hot Key key code and modifier combinations.

@coclass    WOApplication

@discussion The WOHotKey class encapsulates a key code and modifier combination. It can provide an NSDictionary representation of that combination, as well as take an appropriately formed NSDictionary as a basis for initialization (thus providing a simple mechanism for moving WOHotKey objects in and out of NSUserDefaults).

In addition, the class provides instance variables and accessors that can be used to encapsulate the Carbon EventHotKeyRef returned when a Hot Key combination is registrered with the system (using RegisterEventHotKey). An @link isEqual: isEqual: @/link method is provided to aid in the detection of conflicting conmbinations. The WOApplication class in this framework automatically takes advantage of these facilities when registering Hot Keys.

*/
@interface WOHotKey : NSObject { // can no longer use WOObject (in WOCommon)

    /*! The key code that is passed to the Carbon RegisterEventHotKey call. */
    UInt32          hotKeyCode;

    //! The modifiers code that is passed to the Carbon RegisterEventHotKey call.
    //! Carbon uses a UInt32 value but Quartz uses a larger uint64_t type.
    //! For maximum compatibility this instance variable uses the larger type.
    CGEventFlags    hotKeyModifiers;

}

#pragma mark Class methods

/*! With the introduction of Panther, Apple made it possible to register modifierless hot keys. As this could produce undesired side effects, the WOHotKey class can throw exceptions if an attempt is made to register a modifierless hot key using the @link registerWithKeyCode:modifiers: registerWithKeyCode:modifiers: @/link method. This returns a BOOL indicating whether exceptions will be thrown. By default, exceptions are not thrown. See @link setThrowsIfNoModifiers: setThrowsIfNoModifiers: @/link. */
+ (BOOL)throwsIfNoModifiers;

+ (void)setThrowsIfNoModifiers:(BOOL)flag;

// converting Cocoa and Carbon codes etc
+ (UInt32)carbonModifiersFromCocoa:(unsigned int)modifiers;

//! Converts to Carbon (32 bit) from Quartz (64 bit) modifiers.
+ (unsigned int)cocoaModifiersFromQuartz:(CGEventFlags)modifiers;

// hardware independent, international key mapping methods:

// return human-readable string showing key (no modifiers) for the key code
+ (NSString *)keyStringForKeyCode:(unsigned short)keyCode;

/*! Return human-readable string showing key (no modifiers) for the key code, but taking into consideration what how the modifiers may change the appearance of the string. */
+ (NSString *)keyStringForKeyCode:(unsigned short)keyCode modifiers:(UInt32)modifiers;

/*!
    @abstract   Return human-readable string showing modifiers (Cocoa modifiers)
    @discussion Unlike @link modifierStringForModifiers: modifierStringForModifiers: @/link, this method takes into account the keyCode parameter in determining whether to include the "fn-" modifier in the returned string. If Cocoa reports that the NSFunctionKeyMask applies, "fn-" will only be included in the returned string if keyCode is for a key other than the F-Keys (F1 to F15). The order of the modifiers returned by this method matches that in Apple applications, namely: Caps Lock, Control, Option, Shift, Command, "fn-", "Pad-" (for the numeric keypad). In Apple's key binding interfaces they do not display Caps Lock, "fn-", or "Pad-", but they are included here for precision and completeness.
 */
+ (NSString *)modifierStringForModifiers:(int)modifiers keyCode:(unsigned short)keyCode;

/*!
    @abstract   Return human-readable string showing modifiers (Cocoa modifiers)
    @discussion As per @link modifierStringForModifiers:keyCode: modifierStringForModifiers:keyCode: @/link, but does not consider the keyCode (if any) that might accompany the event which triggered the invocation of this message. As such, it always returns "fn" whenever the NSFunctionKeyMask is detected. A trailing "-" is never added to "fn" (with the exception noted below) because it is presumed that if a keyDown or keyUp event had occurred then the corresponding keyCode information would be available and the @link modifierStringForModifiers:keyCode: modifierStringForModifiers:keyCode: @/link method would have been called instead. Note that if the programmer calls this method during a keyDown or keyUp event (the only circumstances under which an NSNumericPadKeyMask can be produced), then this method will add a hyphen between "fn" and "Pad" as appropriate for visual separation, although this should never occur in practice (the programmer should be calling @link modifierStringForModifiers:keyCode: modifierStringForModifiers:keyCode: @/link instead).  The main application of this method is providing intermediary descriptive strings when called from the flagsChanged: method of NSView and its subclasses.
 */
+ (NSString *)modifierStringForModifiers:(int)modifiers;

// return human-readable string showing key + modifiers (Cocoa modifiers)
+ (NSString *)stringForKeyCode:(unsigned short)keyCode modifiers:(int)modifiers;

/*!
    @abstract   Return human-readable string showing key (no modifiers) for the event
    @discussion Due to limitations in Cocoa (it doesn't ignore the shift key when returning the character representation for a key press), this method just forwards to @link keyStringForKeyCode: keyStringForKeyCode: @/link. If the WO_USE_COCOA_KEYCODE_TO_CHARACTER_CONVERSION_METHODS is defined at compile time then the method will rely on Cocoa's limited conversion capabilities, although it still may forward to @link keyStringForKeyCode: keyStringForKeyCode: @/link if the user presses a "dead key".
 */
+ (NSString *)keyStringForEvent:(NSEvent *)theEvent;

// return human-readable string showing modifiers for the event
+ (NSString *)modifierStringForEvent:(NSEvent *)theEvent;

// return human-readable string showing modifiers and key for the event
+ (NSString *)stringForEvent:(NSEvent *)theEvent;

// fallback method (hardcoded default US keyboard layout only)
+ (NSString *)keyStringForKeyCodeUsingUSKeyboardLayout:(unsigned short)keyCode;

+ (id)hotKeyWithDictionary:(NSDictionary *)aDictionary;

+ (id)hotKeyWithKeyCode:(UInt32)keyCode modifiers:(CGEventFlags)modifiers;

#pragma mark Instance methods

/*!
@method     initWithKeyCode:modifiers:
@abstract   Initialize the receiver based on the specified key code and modifiers.
@discussion This is the designated intializer. If you merely wish to create a new, empty WOHotKey object and you do not have a specific key code/modifier pair prepared, use the standard -init method.
 Calls the normalize method.
*/
- (id)initWithKeyCode:(UInt32)keyCode modifiers:(CGEventFlags)modifiers;

/*!
@method     initWithDictionary:
@abstract   Initialize the receiver based on the contents of the supplied NSDictionary.
@discussion A convenience method for initializing a new WOHotKey object based on the contents of an NSDictionary. The WOHotKey class provides a @link dictionaryRepresentation dictionaryRepresentation @/link method for obtaining such a representation from an existing object. Such NSDictionary objects can easily be stored in and retrieved from the NSUserDefaults system.
*/
- (id)initWithDictionary:(NSDictionary *)aDictionary;

/*!
@method     description
@abstract   Provide human-readable description of the receiver
@discussion Provides a human-readable description of the receiver, showing the receiver's key code, modifiers, whether it is registered, and a compact string representation obtained by calling @link stringRepresentation stringRepresentation @/link. This is a programmer-centric description of the receiver, suitable for logging or debugging purposes.
 */
- (NSString *)description;

/*!
@abstract   Provide a human-readable NSString representation of the receiver, showing the receivers modifiers in symbolic/abbreviated form followed by the key name
@discussion This method calls the @link stringForKeyCode:modifiers: stringForKeyCode:modifiers: @/link class method. This is a user-centric representation, suitable for display in the user interface.
@result     An NSString representation of the receiver
*/
- (NSString *)stringRepresentation;

/*!
@method     isEqual:
@abstract   Compare an object with the receiver for equality.
@discussion Two WOHotKey objects are considered equal if they share the same hotKeyCode and hotKeyModifiers. The other instance variables are internally managed and are not considered in the isEqual comparison.
@param      anObject The object to be compared to the receiver.
@result     Returns YES if the specified object is considered equal to the receiver, NO otherwise.

*/
- (BOOL)isEqual:(id)anObject;

//! If the receiver's key code corresponds to one of the function keys, F1 through F16, its modifier flags are normalized by ensuring that the NSFunctionKeyMask bit is not set.
- (void)normalize;

/*! Returns an NSEvent identical (or least a very close approximation) to that which would be produced if the user were to press the receiver's hot key combination. */
- (NSEvent *)pressEvent;

/*! Returns an NSEvent identical (or least a very close approximation) to that which would be produced if the user were to release the receiver's hot key combination. */
- (NSEvent *)releaseEvent;

/*! Returns an NSEvent identical (or least a very close approximation) to that which would be produced if the user were to press (or release) the receiver's hot key combination. The event type depends on the type parameter, which must be either NSKeyDown or NSKeyUp. */
- (NSEvent *)eventWithType:(NSEventType)type;

#pragma mark -
#pragma mark Serialization methods

- (NSDictionary *)dictionaryRepresentation;

#pragma mark -
#pragma mark Accessors

- (UInt32)hotKeyCode;
- (void)setHotKeyCode:(UInt32)aCode;

- (CGEventFlags)hotKeyModifiers;
- (void)setHotKeyModifiers:(CGEventFlags)modifiers;

@end
