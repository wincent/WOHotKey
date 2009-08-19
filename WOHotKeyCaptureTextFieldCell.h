// WOHotKeyCaptureTextFieldCell.h
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

/*!

@class      WOHotKeyCaptureTextFieldCell

@abstract   NSTextFieldCell subclass designed to provide "hot key capture" functionality like that found in Apple's Xcode IDE

@coclass    WOHotKey
@coclass    WOHotKeyCaptureTextField

@discussion The principle features are the ability to capture and record "hot keys" when first responder and editing. A "plus" button can be used to define multiple hot key combinations in a single cell. The "minus" button removes representations.

A number of enhancements appear in this class which correct shortcomings in the Xcode equivalent. For example, the cell automatically checks against the definition of duplicate elements (in Xcode it is possible to define the same combination over and over simply by pressing the "plus" button after defining). Also, it is possible to select multiple combinations (in Xcode it is only possible to select one combination at a time). Finally, placeholder text (a feature introduced in Mac OS X 10.3) is displayed when no combination is present.

Can be used in a normal NSTextField, or as a row in an NSTableView or NSOutlineView. Stops listening for new combinations when the cell ceases to edit.

Posts a notification? When editing ends? ie. need a way to inform the controller that the setting has changed
Any way to tie this in to Cocoa Bindings?

Desired behaviour (correcting a few problems with Apple's version):

- consider adding "undo" capability
- placeholder text when empty but first responder?
- to stop editing have to click outside of textfield (currently only stops IF the click results in the first responder being changed)

*/
@interface WOHotKeyCaptureTextFieldCell : NSTextFieldCell <NSCoding> {

}

@end