// WOHotKeyManager.h
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

#import <Carbon/Carbon.h>

@class WOHotKey, WOHotKeyHandler, WOHotKeyHandlerSet;

//! Singleton class for managing the registration of hot keys with the system and taking action when hot keys are pressed.
//!
//! WOHotKeyManager first tries to set up a Quartz event tap but will fall back and use a Carbon Event Handler if necessary. WOHotKeyManager prefers Quartz Event Services over a Carbon Event Handler because:
//!
//!     - Quartz Event Services work even if a full-screen game or other application has taken control of the display.
//!     - Quartz Event Services are more easily suspended (during editing) and can be suspended without side effects.
//!     - Carbon Event hot keys are not easily suspended (WOHotKeyManager ignores events during suspension but still ends up "eating" events so that other applications cannot see them); the only way to truly suspend Carbon Event hot keys is to fully unregister them.
//!
@interface WOHotKeyManager : NSObject {

    WOHotKeyHandlerSet  *handlers;
    WOHotKeyHandlerSet  *pressHandlers;
    WOHotKeyHandlerSet  *releaseHandlers;

    NSMutableDictionary *registeredHotKeys;

    BOOL                handlesHotKeyEvents;

    //! For Quartz Event Services. WOHotKeyManager prefers to check for hot key events using Quartz Event Services and tries to set up an event tap upon initialization, falling back to Carbon only if necessary.
    CFMachPortRef       eventTap;

    //! A Carbon Event Handler reference. WOHotKeyManager sets up the reference upon initialization if its initial attempt to set up a Quartz event tap fails.
    EventHandlerRef     handlerRef;

}

#pragma mark Singleton pattern enforcement methods
/*! @group Singleton pattern enforcement methods */

+ (WOHotKeyManager *)defaultManager;

#pragma mark Utility methods
/*! @group Utility methods */

- (NSArray *)hotKeyArrayForDictionaryRepresentationArray:(NSArray *)anArray;

- (NSArray *)dictionaryRepresentationArrayForHotKeyArray:(NSArray *)anArray;

- (NSString *)stringRepresentationForHotKeyArray:(NSArray *)anArray;

#pragma mark Setting and removing hot key handlers
/*! @group Setting and removing hot key handlers */

/*! Sets a new press/release handler with name, aTarget, aSelector and hotKeys. The target will be sent the action message on every press and on every release of any of the hot keys in the array. If a handler with name previously existed, replaces the older handler with the new one. name, aTarget and hotKeys are all retained. Trying to set a press/release handler when a press handler or release handler already exists with the same name raises an exception. A given hot key may not belong to multiple handlers. */
- (void)setHandler:(NSString *)name target:(id)aTarget action:(SEL)aSelector forHotKeys:(NSArray *)hotKeys;

/*! As per @link setPressHandler:target:action:forHotKeys: setPressHandler:target:action:forHotKeys: @/link, but the handler only sends messages on hot key press events. Trying to set a press handler when a press/release handler or release handler already exists with the same name raises an exception. */
- (void)setPressHandler:(NSString *)name target:(id)aTarget action:(SEL)aSelector forHotKeys:(NSArray *)hotKeys;

/*! As per @link setPressHandler:target:action:forHotKeys: setPressHandler:target:action:forHotKeys: @/link, but the handler only sends messages on hot key release events. Trying to set a release handler when a press/release handler or press handler already exists with the same name raises an exception. */
- (void)setReleaseHandler:(NSString *)name target:(id)aTarget action:(SEL)aSelector forHotKeys:(NSArray *)hotKeys;

- (void)removeHandler:(NSString *)name;

- (void)removePressHandler:(NSString *)name;

- (void)removeReleaseHandler:(NSString *)name;

- (void)removeAllHandlers;

- (void)removeAllPressHandlers;

- (void)removeAllReleaseHandlers;

/*! A given hot key combination may only be in use by a single handler at any time. This method searches through all handlers, press handlers and release handlers for clashes matching the hot keys in the supplied hotKeys array. When a clash is found, the duplicate is removed and a WOHotKeyHandlerChangedNotification is sent. The @link setHandler:target:action:forHotKeys: setHandler:target:action:forHotKeys: @/link, @link setPressHandler:target:action:forHotKeys: setPressHandler:target:action:forHotKeys: @/link and @link setReleaseHandler:target:action:forHotKeys: setReleaseHandler:target:action:forHotKeys: @/link methods all call this method prior to setting a new handler. */
- (void)removeDuplicateHotKeys:(NSArray *)hotKeys;

/*! As per @link removeDuplicateHotKeys: removeDuplicateHotKeys: @/link but confines the search for duplicates to a specified set. */
- (void)removeDuplicateHotKeys:(NSArray *)hotKeys set:(WOHotKeyHandlerSet *)set;

#pragma mark -
#pragma mark Finding hot keys

- (WOHotKey *)hotKeyForHotKeyID:(EventHotKeyID)hotKeyID;

#pragma mark -
#pragma mark Finding hot key handlers
/*! @group Finding hot key handlers */

- (WOHotKeyHandler *)handlerForKeyCode:(CGKeyCode)keyCode modifiers:(CGEventFlags)modifiers;

/*! A low level routine that finds a handler given an EventHotKeyID (as returned by the Carbon hot key APIs). In general the caller need not worry about these IDs because they are encapsulated and managed by the classes in the WOHotKey framework. More likely to be of use are the @link handlerNamed: handlerNamed: @/link, @link pressHandlerNamed: pressHandlerNamed: @/link and @link releaseHandlerNamed: releaseHandlerNamed: @/link methods. */
- (WOHotKeyHandler *)handlerForHotKeyID:(EventHotKeyID)hotKeyID;

/*! Search for a WOHotKeyHandler that uses hotKey. */
- (WOHotKeyHandler *)handlerForHotKey:(WOHotKey *)hotKey;

/*! Search within a given WOHotKeyHandlerSet for a handler that uses hotKey. */
- (WOHotKeyHandler *)handlerForHotKey:(WOHotKey *)hotKey set:(WOHotKeyHandlerSet *)set;

- (WOHotKeyHandler *)handlerNamed:(NSString *)name;

- (WOHotKeyHandler *)pressHandlerNamed:(NSString *)name;

- (WOHotKeyHandler *)releaseHandlerNamed:(NSString *)name;

#pragma mark Activating and deactivating hot key handling
/*! @group Activating and deactivating hot key handling */

- (BOOL)handlesHotKeyEvents;

/*! Sets whether hot key events generated by the system will be handled by the receiver, or passed on to NSApplication. When flag is YES, any registered hot key combinations will cause hot key events to be sent to the receiver's hot key event handler, which will then process them. When the flag is NO, hot key events to the receiver's hot key event handler are not processed; instead, the handler attempts to generate an appropriate NSEvent and passes it to NSApplication. Note that in both cases, the system effectively "swallows" any registered hot key events and does not pass them to any other application. Even if flag is set to NO, registered hot key combinations will have no effect in other applications. If you wish to not only suspend hot key processing within the application using the WOHotKey framework, but also allow those hot keys to be used by other applications on the system, you must actually unregister the hot key combinations. */
- (void)setHandlesHotKeyEvents:(BOOL)flag;

@end

#pragma mark Hot Key notifications
/*! @group Hot Key notifications */

#define WO_HOT_KEY_HANDLER_ADDED_NOTIFICATION               @"WOHotKeyHandlerAddedNotification"

#define WO_HOT_KEY_HANDLER_REMOVED_NOTIFICATION             @"WOHotKeyHandlerRemovedNotification"

#define WO_HOT_KEY_HANDLER_CHANGED_NOTIFICATION             @"WOHotKeyHandlerChangedNotification"

#define WO_HOT_KEY_DUPLICATE_HOT_KEYS_REMOVED_NOTIFICATION  @"WOHotKeyDuplicateHotKeysRemovedNotification"

#define WO_HOT_KEY_DUPLICATE_HANDLER_REMOVED_NOTIFICATION   @"WOHotKeyDuplicateHandlerRemovedNotification"

#define WO_HOT_KEY_DUPLICATE_HANDLER_CHANGED_NOTIFICATION   @"WOHotKeyDuplicateHandlerChangedNotification"

#pragma mark Hot Key notification dictionary keys
/*! @group Hot Key notification dictionary keys */

/*! Dictionary key associated with an NSString object containing the name of a handler that was added, removed or changed. This key is always present in the notification's userInfo dictionary. */
#define WO_HOT_KEY_NOTIFICATION_HANDLER_NAME                @"WOHotKeyNotificationHandlerName"

/*! Dictionary key associated with an NSArray of WOHotKey objects. The array contains all of the hot keys in the handler. */
#define WO_HOT_KEY_NOTIFICATION_HOT_KEYS                    @"WOHotKeyNotificationHotKeys"

/*! Dictionary key associated with an NSArray of WOHotKey objects. This key is present in the userInfo dictionary of a WOHotKeyHandlerChangedNotification, and indicates which hot key combinations were removed from the handler as a result of the change. For example, if a user defines a new hot key combination which happens to clash with a hot key already defined in an existing handler, the old hot key is removed from that handler, the notification is posted, and the removed hot key is indicated in the userInfo dictionary. */
#define WO_HOT_KEY_NOTIFICATION_OLD_KEYS                    @"WOHotKeyNotificationOldHotKeys"

/*! Dictionary key associated with an NSNumber that encodes the handler type WOHotKeyHandlerRespondsToPressEvents, WOHotKeyHandlerRespondsToReleaseEvents or WOHotKeyHandlerRespondsToPressReleaseEvents. */
#define WO_HOT_KEY_NOTIFICATION_HANDLER_TYPE                @"WOHotKeyNotificationHandlerType"

