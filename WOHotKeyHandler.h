// WOHotKeyHandler.h
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

typedef enum WOHotKeyHandlerType {

    WOHotKeyHandlerRespondsToPressEvents        = 0,
    WOHotKeyHandlerRespondsToReleaseEvents      = 1,
    WOHotKeyHandlerRespondsToPressReleaseEvents = 2

} WOHotKeyHandlerType;

@interface WOHotKeyHandler : NSObject {

    NSString            *name;
    id                  target;
    SEL                 action;
    NSArray             *hotKeys;
    WOHotKeyHandlerType type;

}

#pragma mark Creating WOHotKeyHandler objects
/*! @group Creating WOHotKeyHandler objects */

/*! The handler selector should take exactly one parameter, an NSNotification object that is used to send information about the hot key event responsible for triggering the action to the target. */
+ (id)handlerWithName:(NSString *)aName
               target:(id)aTarget
               action:(SEL)aSelector
              hotKeys:(NSArray *)anArray
                 type:(WOHotKeyHandlerType)aType;

/*! The designated initializer. The handler selector should take exactly one parameter, an NSNotification object that is used to send information about the hot key event responsible for triggering the action to the target. */
- (id)initWithName:(NSString *)aName
            target:(id)aTarget
            action:(SEL)aSelector
           hotKeys:(NSArray *)anArray
              type:(WOHotKeyHandlerType)aType;

#pragma mark Performing actions
/*! @group Performing actions */

/*! Perform the action associated with the receiver, sending the action selector to the target, and passing supplementary information in an WOHotKeyPressNotification object. The name of the handler handling the action is passed as the object of the notification. */
- (void)performPressedAction:(NSString *)handlerName;

/*! As per @link performPressedAction: performPressedAction: @/link, but passes a WOHotKeyReleasedNotification. */
- (void)performReleasedAction:(NSString *)handlerName;

#pragma mark Convenience methods
/*! @group Convenience methods */

- (NSEnumerator *)hotKeyEnumerator;

#pragma mark Accessors
/*! @group Accessors */

- (NSString *)name;
- (void)setName:(NSString *)aName;
- (id)target;
- (void)setTarget:(id)aTarget;
- (SEL)action;
- (void)setAction:(SEL)aSelector;
- (NSArray *)hotKeys;
- (void)setHotKeys:(NSArray *)anArray;
- (WOHotKeyHandlerType)type;
- (void)setType:(WOHotKeyHandlerType)aType;

@end

#pragma mark Hot key handler notifications
/*! @group Hot key handler notifications */

#define WO_HOT_KEY_PRESS_NOTIFICATION       @"WOHotKeyPressNotification"

#define WO_HOT_KEY_RELEASE_NOTIFICATION     @"WOHotKeyReleaseNotification"
