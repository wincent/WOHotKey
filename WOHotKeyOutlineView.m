// WOHotKeyOutlineView.m
// WOHotKey
//
// Copyright 2005-2009 Wincent Colaiuta. All rights reserved.
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

#import "WOHotKeyOutlineView.h"
#import "WOHotKeyNode.h"
#import "WOHotKeyManager.h"

@implementation WOHotKeyOutlineView

- (void)commonInit
{
    NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
    [c addObserver:self
          selector:@selector(handleNotification:)
              name:WO_HOT_KEY_DUPLICATE_HOT_KEYS_REMOVED_NOTIFICATION
            object:nil];
}

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
        [self commonInit];

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder]))
        [self commonInit];

    return self;
}

- (void)finalize
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super finalize];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSString    *name       = [aNotification name];
    id          userInfo    = [aNotification userInfo];
    if (name && [name isEqualToString:WO_HOT_KEY_DUPLICATE_HOT_KEYS_REMOVED_NOTIFICATION] && userInfo)
        [self reloadData];  // make sure changes are reflected in the UI
}

- (NSArray *)hotKeys
{
    NSArray *returnValue = nil;
    id delegate = [self delegate];
    if (delegate && [delegate respondsToSelector:@selector(editedNode)])
        returnValue = [[delegate performSelector:@selector(editedNode)] hotKeys];
    return returnValue;
}

#pragma mark -
#pragma mark NSText delegate methods

- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
    // handle WOHotKey array manually
    if ([aTextObject respondsToSelector:@selector(hotKeys)])
    {
        // unlike NSTextField subclass, we do not store a single hot keys array
        // instead, our nodes each have their own array...

        id delegate = [self delegate];
        WOHotKeyNode *node = nil;
        if (delegate && [delegate respondsToSelector:@selector(editedNode)])
            node = [delegate performSelector:@selector(editedNode)];

        if (node)
        {
            [node setHotKeys:[aTextObject performSelector:@selector(hotKeys)]];
            [delegate performSelector:@selector(setEditedNode:) withObject:nil];
        }
    }
    else // programmer error if the field editor is not WOHotKeyCaptureTextView
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected field editor class %@ returned to %@",
            NSStringFromClass([aTextObject class]), NSStringFromClass([self class])];

    // let Cocoa handle string representation
    (void)[super textShouldEndEditing:aTextObject];

    return YES;
}

@end
