// WOHotKeyCaptureTextFieldCell.m
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

#import "WOHotKeyCaptureTextFieldCell.h"
#import "WOHotKeyCaptureTextView.h"
#import "WOHotKeyManager.h"

@interface WOHotKeyCaptureTextFieldCell ()

- (void)WOHotKeyCaptureTextFieldCell_commonInit;

@end

@implementation WOHotKeyCaptureTextFieldCell

#pragma mark Class variables

static WOHotKeyCaptureTextView *customFieldEditor = nil;

#pragma mark Instance method overrides

// TODO: thread safety
- (void)WOHotKeyCaptureTextFieldCell_commonInit
{
    // create custom shared field editor if necessary; it is effectively a singleton that persists for the lifetime of the program
    if (!customFieldEditor)
    {
        customFieldEditor = [[WOHotKeyCaptureTextView alloc] initWithFrame:NSZeroRect];

        [customFieldEditor setFieldEditor:YES];
        [customFieldEditor setAllowsUndo:NO];
        [customFieldEditor setAcceptsGlyphInfo:NO];
        [customFieldEditor setAllowsDocumentBackgroundColorChange:NO];
        [customFieldEditor setContinuousSpellCheckingEnabled:NO];
        [customFieldEditor setRulerVisible:NO];
        [customFieldEditor setUsesFindPanel:NO];
        [customFieldEditor setUsesFontPanel:NO];
        [customFieldEditor setUsesRuler:NO];
    }
    else
        [customFieldEditor retain];
}

- (id)initTextCell:(NSString *)aString
{
    // Cocoa creates a shared field editor here, if none exists
    if ((self = [super initTextCell:aString]))
        [self WOHotKeyCaptureTextFieldCell_commonInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder]))
        [self WOHotKeyCaptureTextFieldCell_commonInit];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [super copyWithZone:zone];
    [copy WOHotKeyCaptureTextFieldCell_commonInit];
    return copy;
}

// override from NSTextFieldCell
- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj
{
    NSText* defaultEditor = [super setUpFieldEditorAttributes:textObj];

    // super insets the text view frame to make room for the focus ring
    [customFieldEditor setFrame:[defaultEditor frame]];

    // must force these to match NSTextView object returned by super
    [customFieldEditor setString:[defaultEditor string]];
    [customFieldEditor setMaxSize:[defaultEditor maxSize]];
    [customFieldEditor setHorizontallyResizable:[defaultEditor isHorizontallyResizable]];
    [customFieldEditor setBackgroundColor:[defaultEditor backgroundColor]];

    NSFont *font = [defaultEditor font];
    if (font) [customFieldEditor setFont:font]; // nil font causes an exception

    [customFieldEditor setRichText:[defaultEditor isRichText]];
    [customFieldEditor setTextColor:[defaultEditor textColor]];

    // no need to force these, but do so anyway to ensure future compatibility
    [customFieldEditor setMinSize:[defaultEditor minSize]];
    [customFieldEditor setVerticallyResizable:[defaultEditor isVerticallyResizable]];
    [customFieldEditor setAlignment:[defaultEditor alignment]];
    [customFieldEditor setDelegate:[defaultEditor delegate]]; // always nil
    [customFieldEditor setDrawsBackground:[defaultEditor drawsBackground]];
    [customFieldEditor setEditable:[defaultEditor isEditable]];
    [customFieldEditor setImportsGraphics:[defaultEditor importsGraphics]];
    [customFieldEditor setSelectedRange:[defaultEditor selectedRange]]; // 0, 0

    if ([defaultEditor isKindOfClass:[NSTextView class]])   // and it always is
    {
        // no need to force these, but do so to ensure future compatibility
        [customFieldEditor setDefaultParagraphStyle:[(NSTextView *)defaultEditor defaultParagraphStyle]];
        [customFieldEditor setInsertionPointColor:[(NSTextView *)defaultEditor insertionPointColor]];
        [customFieldEditor setMarkedTextAttributes:[(NSTextView *)defaultEditor markedTextAttributes]];
        [customFieldEditor setSelectedTextAttributes:[(NSTextView *)defaultEditor selectedTextAttributes]];
        [customFieldEditor setSelectionGranularity:[(NSTextView *)defaultEditor selectionGranularity]];
        [customFieldEditor setSmartInsertDeleteEnabled:[(NSTextView *)defaultEditor smartInsertDeleteEnabled]];
        [customFieldEditor setTextContainerInset:[(NSTextView *)defaultEditor textContainerInset]];

        // these ones different
        [customFieldEditor setLinkTextAttributes:[(NSTextView *)defaultEditor linkTextAttributes]];
        [customFieldEditor setTypingAttributes:[(NSTextView *)defaultEditor typingAttributes]];
    }

    return customFieldEditor;
}

// override NSCell method to suppress contextual menu
- (NSMenu *)menuForEvent:(NSEvent *)anEvent inRect:(NSRect)cellFrame ofView:(NSView *)aView
{
    // super returns nil anyway, but just to be sure for future OS versions
    return nil;
}

#pragma mark -
#pragma mark NSCell drawing methods

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];

    // it appears that super checks to be sure that the shared default field
    // editor is first responder, thus not drawing a focus ring when we use our
    // custom field editor
    NSWindow    *window     = [controlView window];
    NSResponder *responder  = [window firstResponder];

    if ([window isKeyWindow] && [responder isKindOfClass:[NSView class]] && [(NSView *)responder isDescendantOf:controlView])
    {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        NSRectFill([controlView bounds]);
        [NSGraphicsContext restoreGraphicsState];
    }
}

#pragma mark -
#pragma mark NSCell editing and selecting methods

- (void)editWithFrame:(NSRect)aRect
               inView:(NSView *)controlView
               editor:(NSText *)textObj
             delegate:(id)anObject
                event:(NSEvent *)theEvent
{
    // update hotkeys array
    if ([controlView respondsToSelector:@selector(hotKeys)] && [customFieldEditor respondsToSelector:@selector(setHotKeys:)])
    {
        NSMutableArray *hotKeys = [controlView performSelector:@selector(hotKeys)];
        [customFieldEditor performSelector:@selector(setHotKeys:) withObject:hotKeys];
    }
    else
        [NSException raise:NSInternalInconsistencyException format:@"Internal inconsistency in -[%@ %@]",
            NSStringFromClass([self class]), NSStringFromSelector(_cmd)];

    [super editWithFrame:aRect
                  inView:controlView
                  editor:customFieldEditor      // the override
                delegate:anObject               // the text field
                   event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect
                 inView:(NSView *)controlView
                 editor:(NSText *)textObj
               delegate:(id)anObject
                  start:(int)selStart
                 length:(int)selLength
{
    // special case for NSTableView and subclasses (such as WOHotKeyOutlineView)
    if (controlView && [controlView isKindOfClass:[NSTableView class]])
    {
        // these don't get sent the editWithFrame:inView:editor:delegate:event:
        // message until the user starts typing which is too late for set-up
        if ([controlView respondsToSelector:@selector(hotKeys)] && [customFieldEditor respondsToSelector:@selector(setHotKeys:)])
        {
            NSMutableArray *hotKeys = [controlView performSelector:@selector(hotKeys)];
            [customFieldEditor performSelector:@selector(setHotKeys:) withObject:hotKeys];
        }
        else
            [NSException raise:NSInternalInconsistencyException format:@"Internal inconsistency in -[%@ %@]",
                NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    }

    [super selectWithFrame:aRect
                    inView:controlView
                    editor:customFieldEditor    // the override
                  delegate:anObject             // the text field
                     start:selStart
                    length:selLength];
}

- (void)endEditing:(NSText *)textObj
{
    [super endEditing:customFieldEditor];       // override
}

@end