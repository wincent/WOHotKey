// WOHotKeyCaptureTextView.m
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

// class headers
#import "WOHotKeyCaptureTextView.h"

// system headers
#import <objc/objc-runtime.h>       /* objc_msgSend() */

// framework headers
#import "WOHotKeyLocalizations.h"
#import "WOHotKeyManager.h"
#import "WOHotKeyClass.h"

@interface WOHotKeyCaptureTextView (_private)

// convenience method invokes setEnabled and setToolTip on plus button
- (void)updatePlusButtonEnabled:(BOOL)enabled;

// convenience method invokes setEnabled and setToolTip on minus button
- (void)updateMinusButtonEnabled:(BOOL)enabled;

// get range of hot key objects that corresponds to the passed text selection
- (NSRange)_combinationsForTextRange:(NSRange)selectedText;

// counterpart method to _combinationsForTextRange:
- (NSRange)_textRangeForCombinations:(NSRange)selectedCombinations;

// as per _textRangeForCombinations: but includes left and right-most separators
- (NSRange)_textRangeForCombinationsAndSeparators:(NSRange)selectedCombinations;

// sends NO to setHidden, adding buttons to view if necessary
- (void)showButtons;

// sends YES to setHidden, but does not remove buttons from view
- (void)hideButtons;

- (NSRect)plusButtonRect;
- (NSRect)minusButtonRect;
- (NSRect)tickButtonRect;

@end

@implementation WOHotKeyCaptureTextView

// override designated initializer
- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)aTextContainer
{
    self = [super initWithFrame:frameRect textContainer:aTextContainer];

    NSBundle *bundle    = [NSBundle bundleForClass:[WOHotKeyCaptureTextView class]];
    NSString *path      = [bundle pathForImageResource:@"PlusTextField"];
    plusButtonImage     = [[NSImage alloc] initWithContentsOfFile:path];
    path                = [bundle pathForImageResource:@"MinusTextField"];
    minusButtonImage    = [[NSImage alloc] initWithContentsOfFile:path];
    path                = [bundle pathForImageResource:@"TickTextField"];
    tickButtonImage     = [[NSImage alloc] initWithContentsOfFile:path];
    hotKeys             = [[NSMutableArray alloc] initWithCapacity:1];

    [self setToolTip:_WO_FIELD_EDITOR_TOOL_TIP];

    return self;
}

// refuse to be drag recipient
- (NSArray *)acceptableDragTypes
{
    return nil;
}

// refuse to be drag source
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationNone;
}

// stop ghosted image from being displayed when user attempts to initiate drag
- (BOOL)dragSelectionWithEvent:(NSEvent *)event offset:(NSSize)mouseOffset slideBack:(BOOL)slideBack
{
    return NO;
}

// suppress contextual menu
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    return nil;
}

// disable copy/cut/paste etc
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    NSArray *menuItemsToDisable =
        [NSArray arrayWithObjects:
            @"print:",
            @"cut:",
            @"copy:",
            @"paste:",
            @"delete:",
            @"selectAll:",
            @"performFindPanelAction:",         // "Find...", "Find Next" etc
            @"centerSelectionInVisibleArea:",   // "Jump to Selection"
            @"showGuessPanel:",                 // "Spelling..."
            @"checkSpelling:",
            @"toggleContinuousSpellChecking:",  // "Check Spelling as You Type"
            nil];

    NSString *action = NSStringFromSelector([menuItem action]);

    if ([menuItemsToDisable containsObject:action]) return NO;

    return [super validateMenuItem:menuItem];
}

- (BOOL)becomeFirstResponder
{
    // docs say that super (NSTextView) always returns YES
    BOOL returnValue = [super becomeFirstResponder];

    if (returnValue)
    {
        [self showButtons];

        // is hot key handling on?
        WOHotKeyManager *manager = [WOHotKeyManager defaultManager];
        handlesHotKeyEvents = [manager handlesHotKeyEvents];

        // deactivate hot key handling while field editor is first responder
        if (handlesHotKeyEvents)
            [manager setHandlesHotKeyEvents:NO];
    }

    return returnValue;
}

- (void)showButtons
{
    if (!plusButton && !minusButton && !tickButton)
    {
        // add plus button to view
        plusButton = [[NSButton alloc] initWithFrame:[self plusButtonRect]];
        [plusButton     setImage:plusButtonImage];
        [plusButton     setImagePosition:NSImageOnly];
        [plusButton     setBordered:NO];
        [plusButton     setAction:@selector(buttonPressed:)];
        [plusButton     setTarget:self];
        [self           addSubview:plusButton];

        // add minus button to view
        minusButton = [[NSButton alloc] initWithFrame:[self minusButtonRect]];
        [minusButton    setImage:minusButtonImage];
        [minusButton    setImagePosition:NSImageOnly];
        [minusButton    setBordered:NO];
        [minusButton    setAction:@selector(buttonPressed:)];
        [minusButton    setTarget:self];
        [self           addSubview:minusButton];

        // add tick button to view
        tickButton = [[NSButton alloc] initWithFrame:[self tickButtonRect]];
        [tickButton     setImage:tickButtonImage];
        [tickButton     setImagePosition:NSImageOnly];
        [tickButton     setBordered:NO];
        [tickButton     setAction:@selector(buttonPressed:)];
        [tickButton     setTarget:self];
        [tickButton     setToolTip:
            _WO_TICK_BUTTON_TOOL_TIP];
        [self           addSubview:tickButton];
    }

    BOOL enabled = ([hotKeys count] > 0);
    [self updatePlusButtonEnabled:enabled];
    [self updateMinusButtonEnabled:enabled];

    [tickButton     setEnabled:YES];

    if ([plusButton     isHidden]) [plusButton  setHidden:NO];
    if ([minusButton    isHidden]) [minusButton setHidden:NO];
    if ([tickButton     isHidden]) [tickButton  setHidden:NO];
}

- (void)hideButtons
{
    if (plusButton && minusButton)
    {
        if (![plusButton isHidden]) [plusButton   setHidden:YES];
        if (![minusButton isHidden]) [minusButton  setHidden:YES];
    }
}

- (void)updatePlusButtonEnabled:(BOOL)enabled
{
    [plusButton setEnabled:enabled];
    if (enabled)
        [plusButton     setToolTip:_WO_PLUS_BUTTON_TOOL_TIP];
    else
        [plusButton     setToolTip:_WO_GHOSTED_PLUS_BUTTON_TOOL_TIP];
}

- (void)updateMinusButtonEnabled:(BOOL)enabled
{
    [minusButton setEnabled:enabled];
    if (enabled)
        [minusButton    setToolTip:_WO_MINUS_BUTTON_TOOL_TIP];
    else
        [minusButton    setToolTip:_WO_GHOSTED_MINUS_BUTTON_TOOL_TIP];
}

// this message received if self (the field editor) is first responder
- (void)resignKeyWindow
{
    SEL resignKeyWindow = @selector(resignKeyWindow);

    if ([[self superclass] instancesRespondToSelector:resignKeyWindow])
    {
        // [super resignKeyWindow] causes "may not respond" compiler warnings
        // but can't use [super performSelector:] (messages self, infinite loop)
        struct objc_super       superStructure;
        superStructure.receiver = self;
        superStructure.class    = [self superclass];

        (void)objc_msgSendSuper(&superStructure, resignKeyWindow);
    }

    (void)[[self window] makeFirstResponder:nil];
}

- (BOOL)resignFirstResponder
{
    // order here is important: things break if we call super first

    // remove any "null" entry (should be a maximum of 1)
    unsigned nullObject = [hotKeys indexOfObject:[NSNull null]];

    if (nullObject != NSNotFound)
    {
        NSRange deleteText = [self _textRangeForCombinationsAndSeparators:
            NSMakeRange(nullObject, 1)];

        [self setSelectedRange:deleteText];
        [self setMarkedText:@"" selectedRange:deleteText];
        [self unmarkText];

        [hotKeys removeObjectAtIndex:nullObject];

        if ([hotKeys count] == 0) // no more hot keys in this field editor
        {
            // no need for a minus button (no combos to remove)
            [self updateMinusButtonEnabled:NO];

            // no need for plus button either (flashing cursor instead)
            [self updatePlusButtonEnabled:NO];
        }
        else // at least one more hot key still left in field editor
            [self updatePlusButtonEnabled:YES];
    }
    [self hideButtons];

    // turn hot key handling back on (if it was previously on)
    if (handlesHotKeyEvents)
        [[WOHotKeyManager defaultManager] setHandlesHotKeyEvents:handlesHotKeyEvents];

    return [super resignFirstResponder]; // should return YES
}

- (void)buttonPressed:(id)sender
{
    if (sender == plusButton)
    {
        [self updatePlusButtonEnabled:NO]; // can only add one combo at a time

        // insert placeholder at end of array
        [hotKeys insertObject:[NSNull null] atIndex:[hotKeys count]];

        NSRange endRange = NSMakeRange([[self string] length], 0);

        // insert separator and (blank placeholder place) in field editor
        NSString *separatorAndPlaceholder =
            [NSString stringWithFormat:@", %C", 0x00a0]; // "NO-BREAK SPACE"

        [self setSelectedRange:endRange];
        [self setMarkedText:separatorAndPlaceholder selectedRange:endRange];
        [self unmarkText];

        // select the (blank) placeholder space
        [self setSelectedRange:NSMakeRange(endRange.location + 2, 1)];
    }
    else if (sender == minusButton)
    {
        NSRange selectedRange  = [self selectedRange];

        if (NSEqualRanges(selectedRange, NSMakeRange(NSNotFound, 0)))
            // minus button shouldn't be enabled if there is no selected text
            [NSException raise:NSInternalInconsistencyException
                        format:@"Internal inconsistency in -[%@ %@]",
                NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        else
        {

            NSRange deleteCombos = [self _combinationsForTextRange:selectedRange];
            NSRange deleteText   =
                [self _textRangeForCombinationsAndSeparators:deleteCombos];

            [self setSelectedRange:deleteText];
            [self setMarkedText:@"" selectedRange:deleteText];
            [self unmarkText];

            [hotKeys removeObjectsInRange:deleteCombos];

            if ([hotKeys count] == 0) // no more hot keys in this field editor
            {
                // no need for a minus button (no combos to remove)
                [self updateMinusButtonEnabled:NO];
                // no need for plus button either (flashing cursor instead)
                [self updatePlusButtonEnabled:NO];
            }
            else // at least one more hot key still left in field editor
            {
                [self updatePlusButtonEnabled:YES];

                // select previous hot key combo
                unsigned int previousLocation =
                    (deleteCombos.location > 0) ?
                    (deleteCombos.location - 1) : 0;

                NSRange selectedCombination = NSMakeRange(previousLocation, 1);
                NSRange selectedText =
                    [self _textRangeForCombinations:selectedCombination];

                [self setSelectedRange:selectedText];
            }
        }
    }
    else if (sender == tickButton)
    {
        [[self window] makeFirstResponder:[[self window] initialFirstResponder]];
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent isARepeat]) return;   // ignore repeat events

    unsigned short  keyCode                 = [theEvent keyCode];
    unsigned int    flags                   = [theEvent modifierFlags] & 0xffff0000;    // ignore lower 16 bits (device-dependent)
    WOHotKey        *hotKey                 = [[WOHotKey alloc] initWithKeyCode:keyCode modifiers:flags];
    NSString        *stringRepresentation   = [hotKey stringRepresentation];
    NSRange         deleteCombinations      = NSMakeRange(0, 0);
    NSRange         selectedRange           = [self selectedRange];

    // if selected text is present, replace it
    if (!NSEqualRanges(selectedRange, NSMakeRange(0, 0)))
    {
        // if replacing selection, replace all objects in range
        deleteCombinations  = [self _combinationsForTextRange:selectedRange];

        [self setMarkedText:stringRepresentation selectedRange:selectedRange];
        [self unmarkText];
        [self setSelectedRange:NSMakeRange(selectedRange.location,
                                           [stringRepresentation length])];

        [hotKeys replaceObjectsInRange:deleteCombinations
                  withObjectsFromArray:[NSArray arrayWithObject:hotKey]];
    }
    else // no selected text (only occurs when field empty)
    {
        [self insertText:stringRepresentation];
        [hotKeys insertObject:hotKey atIndex:0];
    }

    // check for duplicate WOHotKey object(s) in array
    unsigned count = [hotKeys count];
    unsigned i;

    for (i = count; i > 0; i--) // step backwards, discarding along the way
    {
        id testObject = [hotKeys objectAtIndex:(i - 1)];
        if ((testObject != hotKey) && [hotKey isEqual:testObject])
        {
            // duplicate found, modify string representation and selection
            NSRange deleteRange = [self _textRangeForCombinationsAndSeparators:
                NSMakeRange((i - 1), 1)];

            [self setSelectedRange:deleteRange];
            [self setMarkedText:@"" selectedRange:deleteRange];
            [self unmarkText];

            // remove old entry from array
            [hotKeys removeObjectAtIndex:(i - 1)];
            if ((i - 1) < deleteCombinations.location)
                // move "insertion" point if necessary
                deleteCombinations.location--;

            // strictly speaking, there should never be more than one duplicate
            // but continue scanning in case user has meddled with preferences
        }
    }

    // always select the just-added combination
    [self setSelectedRange:[self _textRangeForCombinations:
        NSMakeRange(deleteCombinations.location, 1)]];

    [self updatePlusButtonEnabled:YES];
    [self updateMinusButtonEnabled:YES];
}

// get range of hot key objects that corresponds to the passed text selection
- (NSRange)_combinationsForTextRange:(NSRange)selectedText
{
    // This routine "rounds up". Example:
    //      "Combo1, Combo2, Combo3, Combo4, Combo5"
    // If passed a range of "ombo2", returns a range of {1, 1}
    // If passed a range of "ombo3, C", returns a range of {1, 2}
    // If passed a range of ",", returns range for preceding combo
    // If passed a range of " ", returns range for following combo
    // If passed a range of " Combo2", returns a range of {1, 1}
    // If passed a range of ", Combo2", returns a range of {0, 2}

    NSRange returnRange = NSMakeRange(0, 0);

    // abort if supplied non-existent range
    if (selectedText.location == NSNotFound)
        return returnRange;

    NSString *string = [self string];

     // if no string, probably just tabbed/clicked into empty field
    if (!string || ([string length] == 0))
        return returnRange;

    // handle case where user clicks to the right of all hot keys
    if (selectedText.location >= [string length])
        return returnRange;

    // special case, if space is left-most character, nudge selection right
    if ([string characterAtIndex:selectedText.location] == 0x0020)
    {
        selectedText.location   += 1;
        selectedText.length     -= 1;
    }

    // perform "rounding" to the left if necessary
    if (selectedText.location != 0)
    {
        // scanners can't search backwards, so search character by character
        unsigned i;
        for (i = selectedText.location; i > 0; i--)
        {
            if ([string characterAtIndex:i] == 0x0020) // space found
            {
                if ([string characterAtIndex:(i - 1)] == 0x002c) // comma found
                {
                    selectedText.length     += (selectedText.location - i - 1);
                    selectedText.location   = i + 1;
                    break;
                }
                else // can only get here due to a programming error
                    [NSException raise:NSInternalInconsistencyException
                                format:@"Internal inconsistency in -[%@ %@]",
                        NSStringFromClass([self class]),
                        NSStringFromSelector(_cmd)];
            }
        }

        if (i == 0) // scanned all the way to start without finding separator
        {
            selectedText.length     += selectedText.location;
            selectedText.location   = 0;
        }
    }

    // perform "rounding" to the right if necessary
    NSScanner *scanner = [NSScanner scannerWithString:string];

    if ((selectedText.location + selectedText.length) != [string length])
    {
        [scanner setScanLocation:(selectedText.location + selectedText.length)];

        // scan up to separator or end of string, which ever comes first
        if ([scanner scanUpToString:@", " intoString:nil])
        {
            selectedText.length =
                [scanner scanLocation] - selectedText.location;
        }
    }

    // get range for corresponding combinations
    [scanner setScanLocation:0]; // reset scanner
    returnRange.location    = 0;
    returnRange.length      = 0;
    unsigned    count       = 0; // combinations scanned

    while (![scanner isAtEnd])
    {
        // scan up to separator or end of string, whichever comes first
        if ([scanner scanUpToString:@", " intoString:nil]) // found a combo
        {
            count++;

            // check to see if at the end of selected combo
            if ([scanner scanLocation] ==
                (selectedText.location + selectedText.length))
            {
                returnRange.length  = count - returnRange.location;
                break; // no need to keep scanning
            }

            // scan past separator if it is present
            [scanner scanString:@", " intoString:nil];

            // check to see if at the beginning of selected combo
            if ([scanner scanLocation] == selectedText.location)
            {
                returnRange.location    = count;

                // if the last key combo is a single letter, could have hit end
                if ([scanner isAtEnd] &&
                    ([string length] == selectedText.location + 1))
                {
                    returnRange.length = count - returnRange.location + 1;
                }
            }
        }
    }

    return returnRange;
}

// counterpart method to _combinationsForTextRange:
- (NSRange)_textRangeForCombinations:(NSRange)selectedCombinations
{
    // The range for each combination does not include the left-most and
    // right-most separators. For example, in the list here:
    //      "Combo1, Combo2, Combo3, Combo4, Combo5"
    // The range for a single combo is always of the form "Combo1" or "Combo2".
    // The range for multiple combos would be of the form "Combo1, Combo2".
    // This needs to taken into account when performing deletions:
    // To delete "Combo1", would delete "Combo1" plus the ", " separator.
    // To delete "Combo2", would following the same pattern.
    // To delete "Combo5", would delete the ", " separator plus "Combo5".

    NSRange returnRange = NSMakeRange(0, 0);
    NSString    *string     = [self string];

    // for some reason we are getting here with empty strings
    if (!string || [string isEqualToString:@""])
        return returnRange;

    // abort if supplied non-existent or zero-length range
    if ((selectedCombinations.location == NSNotFound) ||
        (selectedCombinations.length == 0))
        return returnRange;

    NSScanner   *scanner    = [NSScanner scannerWithString:string];
    unsigned i;

    // scan up to beginning of range
    for (i = 0; i < selectedCombinations.location; i++)
    {
        if ([scanner scanUpToString:@", " intoString:nil])
            [scanner scanString:@", " intoString:nil]; // skip separator
        else    // can only get here due to a programming error
            [NSException raise:NSInternalInconsistencyException
                        format:@"Internal inconsistency in -[%@ %@]",
                NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    }

    returnRange.location = [scanner scanLocation];

    // scan to end of range
    for (i = 0; i < selectedCombinations.length; i++)
    {
        // scan up to next separator or end of string, whichever comes first
        if ([scanner scanUpToString:@", " intoString:nil])
        {
            returnRange.length = [scanner scanLocation] - returnRange.location;

            // skip over separtor if it is present
            [scanner scanString:@", " intoString:nil];
        }
        // if last combo is only one letter long, so won't have scanned anything
        else if ([scanner scanLocation] + 1 == [string length])
            returnRange.length =
                [scanner scanLocation] - returnRange.location + 1;
        else // can only get here due to a programming error
            [NSException raise:NSInternalInconsistencyException
                        format:@"Internal inconsistency in -[%@ %@]",
                NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    }

    return returnRange;
}

// as per _textRangeForCombinations: but includes left and right-most separators
- (NSRange)_textRangeForCombinationsAndSeparators:(NSRange)selectedCombinations
{
    // This method can be used when performing deletions. For example.
    //      "Combo1, Combo2, Combo3, Combo4, Combo5"
    // Single combos:   "Combo1, " or "Combo2, " or ", Combo5"
    // Multiple combos: "Combo1, Combo2, "
    //                  "Combo3, Combo4, "
    //                  ", Combo4, Combo5"

    NSRange returnRange = [self _textRangeForCombinations:selectedCombinations];

    unsigned count = [hotKeys count];

    // if selection includes end item, no following (right-side) separator
    if ((selectedCombinations.location + selectedCombinations.length) == count)
    {
        if (selectedCombinations.location > 0) // preceding item exists
        {
            // strip preceding (left-side) separator
            returnRange.location    -= 2;
            returnRange.length      += 2;
        }
    }
    else // following items exist, strip following (right-side) sepator
    {
            returnRange.length      += 2;
    }
    return returnRange;
}

- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange
                              granularity:(NSSelectionGranularity)granularity
{
    // always select to a separator boundary (", ") or a start or end point
    NSRange selectedCombinations =
        [self _combinationsForTextRange:proposedSelRange];

    return [self _textRangeForCombinations:selectedCombinations];

    // disallow empty selection
}

// override super implementation: keyUp events ignored
- (void)keyUp:(NSEvent *)theEvent
{
    // super does not appear to do much, if anything, in this method anyway
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    // handle keyDown events, ignore keyUp events
    if ([theEvent type] == NSKeyDown) [self keyDown:theEvent];

    return YES; // events always "handled" even if only by discarding them
}

// this button is second from the right
- (NSRect)minusButtonRect
{
    NSRect bounds = [super bounds];
    return NSMakeRect(bounds.origin.x + bounds.size.width -
                      (WO_HOTKEY_BUTTON_SIZE + WO_HOTKEY_BUTTON_PAD) * 2,
                      bounds.origin.y + WO_HOTKEY_BUTTON_PAD,
                      WO_HOTKEY_BUTTON_SIZE,
                      WO_HOTKEY_BUTTON_SIZE);
}

// this button is third from the right
- (NSRect)plusButtonRect
{
    NSRect bounds = [super bounds];
    return NSMakeRect(bounds.origin.x + bounds.size.width -
                      (WO_HOTKEY_BUTTON_SIZE + WO_HOTKEY_BUTTON_PAD) * 3,
                      bounds.origin.y + WO_HOTKEY_BUTTON_PAD,
                      WO_HOTKEY_BUTTON_SIZE,
                      WO_HOTKEY_BUTTON_SIZE);
}

// this button is first from the right
- (NSRect)tickButtonRect
{
    NSRect bounds = [super bounds];
    return NSMakeRect(bounds.origin.x + bounds.size.width -
                      (WO_HOTKEY_BUTTON_SIZE + WO_HOTKEY_BUTTON_PAD),
                      bounds.origin.y + WO_HOTKEY_BUTTON_PAD,
                      WO_HOTKEY_BUTTON_SIZE,
                      WO_HOTKEY_BUTTON_SIZE);
}

// report bounds as undersized to prevent buttons from getting overdrawn
- (NSRect)bounds
{
    NSRect realBounds = [super bounds];

    realBounds.size.width -= (WO_HOTKEY_BUTTON_SIZE + WO_HOTKEY_BUTTON_PAD) * 3;

    return realBounds;
}

// allow text to scroll while keeping buttons visible
- (NSRect)adjustScroll:(NSRect)proposedVisibleRect
{
    NSRect proposedRect = [super adjustScroll:proposedVisibleRect];

    // note that sometimes Cocoa returns non-integer values for proposedRect
    NSRect plusFrame    = [self plusButtonRect];
    plusFrame.origin.x  += ceil(proposedRect.origin.x); // ceil necessary due
    plusFrame.origin.y  += ceil(proposedRect.origin.y); // to Cocoa weirdness
    [plusButton setFrame:plusFrame];

    NSRect minusFrame   = [self minusButtonRect];
    minusFrame.origin.x += ceil(proposedRect.origin.x); // ceil necessary due
    minusFrame.origin.y += ceil(proposedRect.origin.y); // to Cocoa weirdness
    [minusButton setFrame:minusFrame];

    NSRect tickFrame    = [self tickButtonRect];
    tickFrame.origin.x += ceil(proposedRect.origin.x);  // ceil necessary due
    tickFrame.origin.y += ceil(proposedRect.origin.y);  // to Cocoa weirdness
    [tickButton setFrame:tickFrame];

    return proposedRect;
}

// show I-Beam cusor for most of the view, but show pointer over buttons
- (void)resetCursorRects
{
    NSCursor *IBeamCursor = [NSCursor IBeamCursor];
    [self addCursorRect:[self bounds] cursor:IBeamCursor];
    [IBeamCursor setOnMouseEntered:YES];

    if (plusButton && minusButton)  // add the arrow cursor over the buttons
    {
        NSRect      buttonRect      = NSUnionRect([plusButton frame],
                                                  [minusButton frame]);
        NSRect      insetRect       = NSInsetRect(buttonRect,
                                                  WO_HOTKEY_BUTTON_PAD,
                                                  WO_HOTKEY_BUTTON_PAD);
        NSCursor    *arrowCursor    = [NSCursor arrowCursor];
        [self addCursorRect:insetRect cursor:arrowCursor];
        [arrowCursor setOnMouseEntered:YES];
    }
}

#pragma mark Accessors

- (NSMutableArray *)hotKeys
{
    // TODO: refactor this away: if the caller wants a copy then the caller should be the one making the copy
    return [hotKeys mutableCopy];
}

- (void)setHotKeys:(NSMutableArray *)anArray
{
    if (anArray != hotKeys)
    {
        if (anArray)
            [hotKeys setArray:anArray];
        else // passed nil
            [hotKeys removeAllObjects];

        // refresh button state (enabled/disabled etc)
        [self showButtons];
    }
}

@end