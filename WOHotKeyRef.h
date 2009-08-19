// WOHotKeyRef.h
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

// system headers
#import <Carbon/Carbon.h>

/*!

@header     WOHotKeyRef
@abstract   A simple wrapper class that can store a Carbon EventHotKeyID and EventHotKeyRef

*/

@interface WOHotKeyRef : NSObject { // can no longer use WOObject (in WOCommon)

    /*! Should be a unique ID number for the current Hot Key. WOHotKeyRef objects created using the ref class method have automatically generated unique ID numbers. You can also obtain a unique ID by calling the nextEventHotKeyID method. */
    EventHotKeyID   hotKeyID;

    /*! EventHotKeyRef is returned by Carbon when the hot key is registered. */
    EventHotKeyRef  hotKeyRef;

}

/*! Returns a unique hotKeyID */
+ (EventHotKeyID)nextEventHotKeyID;

+ (id)ref;

- (EventHotKeyID)hotKeyID;

- (void)setHotKeyID:(EventHotKeyID)value;

- (EventHotKeyRef)hotKeyRef;

- (void)setHotKeyRef:(EventHotKeyRef)ref;

@end
