// WOHotKeyTableColumn.m
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

// class header
#import "WOHotKeyTableColumn.h"

// project class headers
#import "WOHotKeyCaptureTextFieldCell.h"

#pragma mark -
#pragma mark Class variables

/*

 Unfortunately Cocoa obliges us to maintain this as a class variable (which effectively leaks because it is never deallocated). We cannot store this cell as an instance variable because Cocoa bindings causes the dataCell method to be called three times before initWithCode is ever called, therefore there is no time to do any setup beforehand. Neither can we create an autoreleased cell in the dataCell method because Cocoa does not retain cells obtained in that way and so the app will crash.

 */
WOHotKeyCaptureTextFieldCell *WOHotKeyTableColumnCaptureCell = nil;

@implementation WOHotKeyTableColumn

+ (void)initialize
{
    if (!WOHotKeyTableColumnCaptureCell)
    {
        WOHotKeyTableColumnCaptureCell = [[WOHotKeyCaptureTextFieldCell alloc] initTextCell:@""];
        [WOHotKeyTableColumnCaptureCell setEditable:YES];
        [WOHotKeyTableColumnCaptureCell setSelectable:YES];
    }
}

#pragma mark -
#pragma mark NSTableColumn overrides

// Apple quirk: this is getting called THREE times before we hit initWithCoder...
- (id)dataCell
{
    return [[self class] captureCell];
}

#pragma mark -
#pragma mark Class accessors

+ (WOHotKeyCaptureTextFieldCell *)captureCell
{
    return WOHotKeyTableColumnCaptureCell;
}

+ (void)setCaptureCell:(WOHotKeyCaptureTextFieldCell *)aCaptureCell
{
    if (WOHotKeyTableColumnCaptureCell != aCaptureCell)
        WOHotKeyTableColumnCaptureCell = aCaptureCell;
}

@end