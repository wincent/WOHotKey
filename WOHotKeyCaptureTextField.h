// WOHotKeyCaptureTextField.h
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

#define WO_HOT_KEY_VALUE_BINDING    @"hotKeys"

/*!

@class      WOHotKeyCaptureTextField
@abstract   Simple subclass of NSTextField
@coclass    WOHotKeyCaptureTextFieldCell
@discussion Simple subclass of NSTextField that uses WOHotKeyCaptureTextFieldCell as its default cell class

*/
@interface WOHotKeyCaptureTextField : NSTextField <NSCoding> {

        /*! An array of hot key representations. These are actual WOHotKey objects. They are representations consisting of the key codes, modifiers. I should hook this up so that it uses (or can use) key-value observing/binding and I can update the preferences automatically with almost no glue code. */
    NSArray     *hotKeys;

    /*! For compatibility with Cocoa Bindings and NSUserDefaults, the hotKeys array is also replicated here, but instead of containing actual WOHotKey objects it contains NSDictionary representations of those objects, which means the array can be written out to plists and used by NSUserDefaults and Cocoa Bindings. */
    NSArray     *hotKeysDictionaryRep;

    /*! For Cocoa Bindings compliance. */
    id          hotKeysObserver;
    NSString    *hotKeysKeyPath;
    NSString    *hotKeysTransformerName;
}

// make a string representation of all the hot keys in an array
+ (NSString *)stringRepresentationFromHotKeyArray:(NSArray *)anArray;

/*! Always returns WOHotKeyCaptureTextFieldCell. The setCellClass: class method is a no-op. */
+ (Class)cellClass;

#pragma mark Accessors

- (NSArray *)hotKeys;
- (void)setHotKeys:(NSArray *)anArray;

@end
