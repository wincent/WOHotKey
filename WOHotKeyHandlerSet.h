// WOHotKeyHandlerSet.h
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

 @header        WOHotKeyHandlerSet
 @abstract      Manages a set of WOHotKeyHandler objects
 @discussion    WOHotKeyHandlerSet objects manage a set of unique WOHotKeyHandler objects. The objects are considered to be unique if they have a unique name, which means that if two WOHotKeyHandler objects which share the same name then only one may be in a given WOHotKeyHandlerSet.

*/

@class WOHotKeyHandler;

@interface WOHotKeyHandlerSet : NSObject {  // can no longer use WOObject (in WOCommon)

    NSMutableSet    *handlers;

}

- (WOHotKeyHandler *)handlerNamed:(NSString *)name;

- (NSEnumerator *)objectEnumerator;

/*! Adds a WOHotKeyHandler object to the receiver. If there is already an object in the receiver with the same name then no action is taken. */
- (void)addHandler:(WOHotKeyHandler *)aHandler;

- (void)removeHandler:(WOHotKeyHandler *)aHandler;

- (void)removeHandlerNamed:(NSString *)name;

- (void)removeAllHandlers;

#pragma mark -
#pragma mark NSFastEnumeration protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len;

@end
