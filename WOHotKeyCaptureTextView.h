// WOHotKeyCaptureTextView.h
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

#define WO_HOTKEY_BUTTON_SIZE   ((float)13.0)
#define WO_HOTKEY_BUTTON_PAD    ((float)2.0)

/*!

@discussion Manages two levels of editing. The upper level, the one the user sees, consists of the string representations of the hot key combinations that the object manages. The lower level, hidden from the user but of much more interest to the programmer, is the array of WOHotKey objects managed by the object. The two levels have a one-for-one correspondence, in that each WOHotKey object corresponds exactly to a portion of the string representation.

*/
@interface WOHotKeyCaptureTextView : NSTextView {

    NSButton                *plusButton;
    NSImage                 *plusButtonImage;

    NSButton                *minusButton;
    NSImage                 *minusButtonImage;

    NSButton                *tickButton;
    NSImage                 *tickButtonImage;

    /*! A mutable array of WOHotKey objects currently represented by this field editor. */
    NSMutableArray          *hotKeys;

    BOOL                    handlesHotKeyEvents;

}

#pragma mark Accessors

/*! Returns an mutable copy of the receiver's hot key array. */
- (NSMutableArray *)hotKeys;

/*! Makes a mutable copy of the passed array. */
- (void)setHotKeys:(NSMutableArray *)anArray;

@end
