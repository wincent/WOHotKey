// WOHotKeyManager.m
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

// class header
#import "WOHotKeyManager.h"

// system headers
#import <ApplicationServices/ApplicationServices.h>

// project class headers
#import "WOHotKey.h"
#import "WOHotKeyHandler.h"
#import "WOHotKeyHandlerSet.h"
#import "WOHotKeyRef.h"

// embeds build number, version info, copyright info in bundle
#import "WOHotKey_Version.h"

// WOPublic macro headers
#import "WOPublic/WODebugMacros.h"
#import "WOPublic/WOEnumerate.h"

#pragma mark -
#pragma mark Notification posting macros

#define WO_POST_HOT_KEY_HANDLER_ADDED_NOTIFICATION(name, hotKeys, type)        \
[[NSNotificationCenter                                                         \
    defaultCenter] postNotificationName:WO_HOT_KEY_HANDLER_ADDED_NOTIFICATION  \
                                 object:self                                   \
                               userInfo:                                       \
    [NSDictionary dictionaryWithObjectsAndKeys:                                \
        name,       WO_HOT_KEY_NOTIFICATION_HANDLER_NAME,                      \
        hotKeys,    WO_HOT_KEY_NOTIFICATION_HOT_KEYS,                          \
        [NSNumber numberWithInt:type],                                         \
                    WO_HOT_KEY_NOTIFICATION_HANDLER_TYPE,                      \
        nil]]

#define WO_POST_HOT_KEY_HANDLER_REMOVED_NOTIFICATION(name, type)               \
[[NSNotificationCenter                                                         \
    defaultCenter] postNotificationName:@"WOHotKeyHandlerRemovedNotification"  \
                                 object:self                                   \
                               userInfo:                                       \
    [NSDictionary dictionaryWithObjectsAndKeys:                                \
        name,       WO_HOT_KEY_NOTIFICATION_HANDLER_NAME,                      \
        [NSNumber numberWithInt:type],                                         \
                    WO_HOT_KEY_NOTIFICATION_HANDLER_TYPE,                      \
        nil]]

#define WO_POST_HOT_KEY_HANDLER_CHANGED_NOTIFICATION(name, hotKeys, oldKeys, type) \
[[NSNotificationCenter                                                         \
    defaultCenter] postNotificationName:WO_HOT_KEY_HANDLER_CHANGED_NOTIFICATION \
                                 object:self                                   \
                               userInfo:                                       \
    [NSDictionary dictionaryWithObjectsAndKeys:                                \
        name,       WO_HOT_KEY_NOTIFICATION_HANDLER_NAME,                      \
        hotKeys,    WO_HOT_KEY_NOTIFICATION_HOT_KEYS,                          \
        oldKeys,    WO_HOT_KEY_NOTIFICATION_OLD_KEYS,                          \
        [NSNumber numberWithInt:type],                                         \
                    WO_HOT_KEY_NOTIFICATION_HANDLER_TYPE,                      \
        nil]]

#define WO_POST_HOT_KEY_DUPLICATE_HANDLER_REMOVED_NOTIFICATION(name, type)     \
[[NSNotificationCenter                                                         \
    defaultCenter] postNotificationName:                                       \
    @"WOHotKeyDuplicateHandlerRemovedNotification"                             \
                                 object:self                                   \
                               userInfo:                                       \
    [NSDictionary dictionaryWithObjectsAndKeys:                                \
        name,       WO_HOT_KEY_NOTIFICATION_HANDLER_NAME,                      \
        [NSNumber numberWithInt:type],                                         \
                    WO_HOT_KEY_NOTIFICATION_HANDLER_TYPE,                      \
        nil]]

#define WO_POST_HOT_KEY_DUPLICATE_HANDLER_CHANGED_NOTIFICATION(name, hotKeys,  \
                                                               type)           \
[[NSNotificationCenter                                                         \
    defaultCenter] postNotificationName:                                       \
    @"WOHotKeyDuplicateHandlerChangesNotification"                             \
                                 object:self                                   \
                               userInfo:                                       \
    [NSDictionary dictionaryWithObjectsAndKeys:                                \
        name,       WO_HOT_KEY_NOTIFICATION_HANDLER_NAME,                      \
        hotKeys,    WO_HOT_KEY_NOTIFICATION_HOT_KEYS,                          \
        [NSNumber numberWithInt:type],                                         \
                    WO_HOT_KEY_NOTIFICATION_HANDLER_TYPE,                      \
        nil]]

@interface WOHotKeyManager ()

- (void)installQuartzEventHandler;
- (void)removeQuartzEventHandler;
- (CGEventRef)handleCGEvent:(CGEventRef)event type:(CGEventType)type userInfo:(void *)userInfo;

- (void)installCarbonEventHandler;
- (void)removeCarbonEventHandler;
- (void)registerHotKeys:(WOHotKeyHandler *)handler;
- (void)unregisterHotKeys:(WOHotKeyHandler *)handler;
- (void)unregisterHotKeysInArray:(NSArray *)hotKeys;
- (void)handleHotKeyEvent:(EventRef)theEvent userInfo:(void *)userInfo;
- (void)removeAllHandlersFromSet:(WOHotKeyHandlerSet *)set;

@end

#pragma mark -
#pragma mark C function prototypes

//! Preferred callback function (works even when a full-screen application is in front).
CGEventRef WOCGHotKeyEventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon);

//! Fallback function.
pascal OSStatus WOHandleHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

#pragma mark -
#pragma mark C functions

CGEventRef WOCGHotKeyEventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    return [[WOHotKeyManager defaultManager] handleCGEvent:event type:type userInfo:refcon];
}

pascal OSStatus WOHandleHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    [[WOHotKeyManager defaultManager] handleHotKeyEvent:theEvent userInfo:userData];

    // propagate the event to the next handler
    return CallNextEventHandler(nextHandler, theEvent);
}

@implementation WOHotKeyManager

#pragma mark -
#pragma mark Class variables

static WOHotKeyManager *_WOHotKeyDefaultManager = nil;

#pragma mark -
#pragma mark Singleton pattern enforcement methods

+ (WOHotKeyManager *)defaultManager
{
    // TODO: make this properly thread safe
    if (_WOHotKeyDefaultManager)
        return _WOHotKeyDefaultManager;
    else
        return [[self alloc] init];
}

- (id)init
{
    if (!_WOHotKeyDefaultManager)
    {
        if ((self = [super init]))
        {
            handlers                = [[WOHotKeyHandlerSet alloc] init];
            pressHandlers           = [[WOHotKeyHandlerSet alloc] init];
            releaseHandlers         = [[WOHotKeyHandlerSet alloc] init];
            registeredHotKeys       = [[NSMutableDictionary alloc] init];
            _WOHotKeyDefaultManager = self;

            [self installQuartzEventHandler];       // first, try with Quartz Event Services
            if (!eventTap)
                [self installCarbonEventHandler];   // fallback to Carbon Event Manager if necessary
        }
    }
    return _WOHotKeyDefaultManager;
}

- (void)finalize
{
    if (eventTap)
        [self removeQuartzEventHandler];
    else
        [self removeCarbonEventHandler];

    [super finalize];
}

#pragma mark -
#pragma mark Quartz wrappers

- (void)installQuartzEventHandler
{
    WOAssert(eventTap == NULL);
    CGEventMask mask = (CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp));
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0x00000000 /* kCGEventTapOptionDefault */,
                                mask, WOCGHotKeyEventTapCallback, NULL);
    if (eventTap == NULL)
    {
        NSLog(@"CGEventTapCreate() returned NULL; this is a harmless warning, but you can eliminate it by turning on access for "
              @"assistive devices in the Universal Access pane (Keyboard tab) of the System Preferences");
    }
    else
    {
        CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, (CFIndex)0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(eventTap, true);
    }
}

- (void)removeQuartzEventHandler
{
    if (eventTap)
        CFRelease(eventTap);
}

- (CGEventRef)handleCGEvent:(CGEventRef)event type:(CGEventType)type userInfo:(void *)userInfo
{
    WOHotKeyHandler *handler = nil;
    if ((type == kCGEventKeyDown) && handlesHotKeyEvents)
    {
        handler = [self handlerForKeyCode:CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode)
                                modifiers:CGEventGetFlags(event)];
        if (CGEventGetIntegerValueField(event, kCGKeyboardEventAutorepeat) == 0)    // don't actually perform for repeat events
            [handler performPressedAction:[handler name]];
    }
    else if ((type == kCGEventKeyUp) && handlesHotKeyEvents)
    {
        handler = [self handlerForKeyCode:CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode)
                                modifiers:CGEventGetFlags(event)];
        if (CGEventGetIntegerValueField(event, kCGKeyboardEventAutorepeat) == 0)    // don't actually perform for repeat events
            [handler performReleasedAction:[handler name]];
    }
    return handler ? NULL : event;  // return NULL for handled events otherwise Cocoa will beep
}

#pragma mark -
#pragma mark Carbon wrappers

- (void)installCarbonEventHandler
{
    EventHandlerUPP HandlerUPP  = NewEventHandlerUPP(WOHandleHotKeyEvent);
    EventTypeSpec   EventTypes[2];
    EventTypes[0].eventClass    = kEventClassKeyboard;
    EventTypes[0].eventKind     = kEventHotKeyPressed;
    EventTypes[1].eventClass    = kEventClassKeyboard;
    EventTypes[1].eventKind     = kEventHotKeyReleased;

    OSStatus err = InstallEventHandler(GetApplicationEventTarget(), HandlerUPP, 2, EventTypes, NULL, &handlerRef);
    if (err != noErr)
        NSLog(@"InstallEventHandler reported an error (%d)", err);
}

- (void)removeCarbonEventHandler
{
    OSStatus err = RemoveEventHandler(handlerRef);
    if (err != noErr)
        NSLog(@"RemoveEventHandler reported an error (%d)", err);
}

- (void)registerHotKeys:(WOHotKeyHandler *)handler
{
    for (WOHotKey *hotKey in [handler hotKeys])
    {
        // try with Quartz Event Services first
        if (eventTap)
            [registeredHotKeys setObject:[NSNull null] forKey:hotKey];  // only the Carbon implementation depends on the object
        else    // fall back to Carbon
        {
            WOHotKeyRef *ref = [WOHotKeyRef ref];
            EventHotKeyRef hotKeyRef;
            OSStatus err = RegisterEventHotKey([hotKey hotKeyCode],
                                               [WOHotKey carbonModifiersFromCocoa:[hotKey hotKeyModifiers]],
                                               [ref hotKeyID],
                                               GetApplicationEventTarget(),
                                               0,
                                               &hotKeyRef);
            if (err != noErr)
                NSLog(@"RegisterEventHotKey reported an error (%d)", err);
            else
            {
                [ref setHotKeyRef:hotKeyRef];
                [registeredHotKeys setObject:ref forKey:hotKey];
            }
        }
    }
}

- (void)unregisterHotKeys:(WOHotKeyHandler *)handler
{
    [self unregisterHotKeysInArray:[handler hotKeys]];
}

- (void)unregisterHotKeysInArray:(NSArray *)hotKeys
{
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    for (WOHotKey *hotKey in hotKeys)
    {
        // special handling for Carbon (Quartz Event Services requires no special action)
        if (!eventTap)
        {
            WOHotKeyRef *ref = [registeredHotKeys objectForKey:hotKey];

            if (ref)
            {
                OSStatus err = UnregisterEventHotKey([ref hotKeyRef]);
                if (err != noErr)
                    NSLog(@"UnregisterEventHotKey reported an error (%d)", err);
            }
        }

        // will remove from registeredHotKeys
        [objectsToRemove addObject:hotKey];
    }

    for (WOHotKey *hotKey in objectsToRemove)
        [registeredHotKeys removeObjectForKey:hotKey];
}

- (void)handleHotKeyEvent:(EventRef)theEvent userInfo:(void *)userInfo
{
    if (GetEventClass(theEvent) == kEventClassKeyboard)
    {
        UInt32          kind = GetEventKind(theEvent);
        EventHotKeyID   hotKeyID;
        if (kind == kEventHotKeyPressed)
        {
            if (GetEventParameter
                (theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(EventHotKeyID), NULL, &hotKeyID) == noErr)
            {
                if (handlesHotKeyEvents)
                {
                    WOHotKeyHandler *h = [self handlerForHotKeyID:hotKeyID];
                    [h performPressedAction:[h name]];
                }
                else
                {
#ifndef WO_SYSTEM_DOES_NOT_SWALLOW_HOT_KEY_EVENTS
                    // unfortunately, the system *does* swallow hot key events
                    NSEvent *event = [[self hotKeyForHotKeyID:hotKeyID] pressEvent];
                    if (event)
                        [[NSApplication sharedApplication] postEvent:event atStart:YES];
#endif /* WO_SYSTEM_DOES_NOT_SWALLOW_HOT_KEY_EVENTS */
                }
            }
        }
        else if (kind == kEventHotKeyReleased)
        {
            if (GetEventParameter
                (theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(EventHotKeyID), NULL, &hotKeyID) == noErr)
            {
                if (handlesHotKeyEvents)
                {
                    WOHotKeyHandler *h = [self handlerForHotKeyID:hotKeyID];
                    [h performReleasedAction:[h name]];
                }
                else
                {
#ifndef WO_SYSTEM_DOES_NOT_SWALLOW_HOT_KEY_EVENTS
                    // unfortunately, the system *does* swallow hot key events
                    NSEvent *event = [[self hotKeyForHotKeyID:hotKeyID] releaseEvent];
                    if (event)
                        [[NSApplication sharedApplication] postEvent:event atStart:YES];
#endif /* WO_SYSTEM_DOES_NOT_SWALLOW_HOT_KEY_EVENTS */
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Utility methods

- (NSArray *)hotKeyArrayForDictionaryRepresentationArray:(NSArray *)anArray
{
    NSMutableArray *workingArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *hotKeyDictionary in anArray)
        [workingArray addObject:[WOHotKey hotKeyWithDictionary:hotKeyDictionary]];
    return [workingArray copy]; // return immutable
}

- (NSArray *)dictionaryRepresentationArrayForHotKeyArray:(NSArray *)anArray
{
    NSMutableArray *workingArray = [NSMutableArray arrayWithCapacity:1];
    for (WOHotKey *hotKey in anArray)
        [workingArray addObject:[hotKey dictionaryRepresentation]];
    return [workingArray copy]; // return immutable
}

- (NSString *)stringRepresentationForHotKeyArray:(NSArray *)anArray
{
    NSMutableString *workingString = [NSMutableString string];
    for (unsigned i = 0, count = [anArray count]; i < count; i++)
    {
        WOHotKey *hotKey = [anArray objectAtIndex:i];
        NSString *stringRepresentation = nil, *separator = nil;

        if ([hotKey isEqual:[NSNull null]]) // "NO-BREAK SPACE"
            stringRepresentation = [NSString stringWithFormat:@"%C", 0x00a0];
        else
            stringRepresentation = [hotKey stringRepresentation];

        if (i == (count - 1))
            separator = @"";                // last hot key, no trailing separator
        else
            separator = @", ";              // more hot keys follow, append separator

        [workingString appendFormat:@"%@%@", stringRepresentation, separator];
    }
    return [NSString stringWithString:workingString];
}

#pragma mark -
#pragma mark Setting and removing hot key handlers

- (void)setHandler:(NSString *)name target:(id)aTarget action:(SEL)aSelector forHotKeys:(NSArray *)hotKeys
{
    NSParameterAssert(name != nil);
    NSParameterAssert(aTarget != nil);
    NSParameterAssert(aSelector != NULL);
    NSParameterAssert(hotKeys != nil);
    NSParameterAssert(![pressHandlers handlerNamed:name]);
    NSParameterAssert(![releaseHandlers handlerNamed:name]);

    WOHotKeyHandler *oldHandler = [handlers handlerNamed:name];
    WOHotKeyHandler *newHandler = [WOHotKeyHandler handlerWithName:name
                                                            target:aTarget
                                                            action:aSelector
                                                           hotKeys:hotKeys
                                                              type:WOHotKeyHandlerRespondsToPressReleaseEvents];

    if (oldHandler)
    {
        [self unregisterHotKeys:oldHandler];
        [handlers removeHandler:oldHandler];
        WO_POST_HOT_KEY_HANDLER_CHANGED_NOTIFICATION(name, hotKeys, [NSNull null], WOHotKeyHandlerRespondsToPressReleaseEvents);
    }
    else
        WO_POST_HOT_KEY_HANDLER_ADDED_NOTIFICATION(name, hotKeys, WOHotKeyHandlerRespondsToPressReleaseEvents);

    [self removeDuplicateHotKeys:hotKeys];
    [handlers addHandler:newHandler];
    [self registerHotKeys:newHandler];
}

- (void)setPressHandler:(NSString *)name target:(id)aTarget action:(SEL)aSelector forHotKeys:(NSArray *)hotKeys
{
    NSParameterAssert(name != nil);
    NSParameterAssert(aTarget != nil);
    NSParameterAssert(aSelector != NULL);
    NSParameterAssert(hotKeys != nil);
    NSParameterAssert(![handlers handlerNamed:name]);
    NSParameterAssert(![releaseHandlers handlerNamed:name]);

    WOHotKeyHandler *oldHandler = [pressHandlers handlerNamed:name];
    WOHotKeyHandler *newHandler = [WOHotKeyHandler handlerWithName:name
                                                            target:aTarget
                                                            action:aSelector
                                                           hotKeys:hotKeys
                                                              type:WOHotKeyHandlerRespondsToPressEvents];

    if (oldHandler)
    {
        [self unregisterHotKeys:oldHandler];
        [pressHandlers removeHandler:oldHandler];
        WO_POST_HOT_KEY_HANDLER_CHANGED_NOTIFICATION(name, hotKeys, [NSNull null], WOHotKeyHandlerRespondsToPressEvents);
    }
    else
        WO_POST_HOT_KEY_HANDLER_ADDED_NOTIFICATION(name, hotKeys, WOHotKeyHandlerRespondsToPressEvents);

    [self removeDuplicateHotKeys:hotKeys];
    [pressHandlers addHandler:newHandler];
    [self registerHotKeys:newHandler];
}

- (void)setReleaseHandler:(NSString *)name target:(id)aTarget action:(SEL)aSelector forHotKeys:(NSArray *)hotKeys
{
    NSParameterAssert(name != nil);
    NSParameterAssert(aTarget != nil);
    NSParameterAssert(aSelector != NULL);
    NSParameterAssert(hotKeys != nil);
    NSParameterAssert(![handlers handlerNamed:name]);
    NSParameterAssert(![pressHandlers handlerNamed:name]);

    WOHotKeyHandler *oldHandler = [releaseHandlers handlerNamed:name];
    WOHotKeyHandler *newHandler = [WOHotKeyHandler handlerWithName:name
                                                            target:aTarget
                                                            action:aSelector
                                                           hotKeys:hotKeys
                                                              type:WOHotKeyHandlerRespondsToReleaseEvents];
    if (oldHandler)
    {
        [self unregisterHotKeys:oldHandler];
        [releaseHandlers removeHandler:oldHandler];
        WO_POST_HOT_KEY_HANDLER_CHANGED_NOTIFICATION(name, hotKeys, [NSNull null], WOHotKeyHandlerRespondsToReleaseEvents);
    }
    else
        WO_POST_HOT_KEY_HANDLER_ADDED_NOTIFICATION(name, hotKeys, WOHotKeyHandlerRespondsToReleaseEvents);

    [self removeDuplicateHotKeys:hotKeys];
    [releaseHandlers addHandler:newHandler];
    [self registerHotKeys:newHandler];
}

- (void)removeHandler:(NSString *)name
{
    WOHotKeyHandler *handler = [handlers handlerNamed:name];

    if (handler)
    {
        [handlers removeHandler:handler];
        WO_POST_HOT_KEY_HANDLER_REMOVED_NOTIFICATION(name, WOHotKeyHandlerRespondsToPressReleaseEvents);
    }
}

- (void)removePressHandler:(NSString *)name
{
    WOHotKeyHandler *handler = [pressHandlers handlerNamed:name];

    if (handler)
    {
        [pressHandlers removeHandler:handler];
        WO_POST_HOT_KEY_HANDLER_REMOVED_NOTIFICATION(name, WOHotKeyHandlerRespondsToPressEvents);
    }
}

- (void)removeReleaseHandler:(NSString *)name
{
    WOHotKeyHandler *handler = [releaseHandlers handlerNamed:name];

    if (handler)
    {
        [releaseHandlers removeHandler:handler];
        WO_POST_HOT_KEY_HANDLER_REMOVED_NOTIFICATION(name, WOHotKeyHandlerRespondsToReleaseEvents);
    }
}

- (void)removeAllHandlersFromSet:(WOHotKeyHandlerSet *)set
{
    for (WOHotKeyHandler *handler in set)
        WO_POST_HOT_KEY_HANDLER_REMOVED_NOTIFICATION([handler name], WOHotKeyHandlerRespondsToPressReleaseEvents);
    [set removeAllHandlers];
}

- (void)removeAllHandlers
{
    [self removeAllHandlersFromSet:handlers];
}

- (void)removeAllPressHandlers
{
    [self removeAllHandlersFromSet:pressHandlers];
}

- (void)removeAllReleaseHandlers
{
    [self removeAllHandlersFromSet:releaseHandlers];
}

- (void)removeDuplicateHotKeys:(NSArray *)hotKeys
{
    [self removeDuplicateHotKeys:hotKeys set:handlers];
    [self removeDuplicateHotKeys:hotKeys set:pressHandlers];
    [self removeDuplicateHotKeys:hotKeys set:releaseHandlers];
}

- (void)removeDuplicateHotKeys:(NSArray *)hotKeys set:(WOHotKeyHandlerSet *)set
{
    for (WOHotKeyHandler *handler in set)
    {
        NSMutableArray *duplicates = [NSMutableArray array];
        for (WOHotKey *hotKey in [handler hotKeys])
        {
            for (WOHotKey *innerHotKey in hotKeys)
            {
                if ([hotKey isEqual:innerHotKey])   // duplicate found!
                    [duplicates addObject:hotKey];
            }
        }

        // batch all duplicates for a given handler into one notification
        if ([duplicates count] > 0)
        {
            // unregister duplicates
            [self unregisterHotKeysInArray:duplicates];

            // remove duplicates
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:[handler hotKeys]];
            [newArray removeObjectsInArray:duplicates];
            [handler setHotKeys:[NSArray arrayWithArray:newArray]];

            // post notification
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                [handler name],                                             WO_HOT_KEY_NOTIFICATION_HANDLER_NAME,
                [handler hotKeys],                                          WO_HOT_KEY_NOTIFICATION_HOT_KEYS,
                duplicates,                                                 WO_HOT_KEY_NOTIFICATION_OLD_KEYS,
                [NSNumber numberWithInt:[(WOHotKeyHandler *)handler type]], WO_HOT_KEY_NOTIFICATION_HANDLER_TYPE,
                nil];

            [[NSNotificationCenter defaultCenter] postNotificationName:WO_HOT_KEY_DUPLICATE_HOT_KEYS_REMOVED_NOTIFICATION
                                                                object:self
                                                              userInfo:userInfo];
        }
    }
}

#pragma mark -
#pragma mark Finding hot keys

- (WOHotKey *)hotKeyForHotKeyID:(EventHotKeyID)hotKeyID
{
    // key enumeration: cannot use Objective-C 2.0 fast enumeration
    WO_KEY_ENUMERATE(registeredHotKeys, key)
    {
        WOHotKeyRef *ref = [registeredHotKeys objectForKey:key];
        if (([ref hotKeyID].signature == hotKeyID.signature) && ([ref hotKeyID].id == hotKeyID.id))
            return key; // match found
    }
    return nil;
}

#pragma mark -
#pragma mark Finding hot key handlers

- (WOHotKeyHandler *)handlerForKeyCode:(CGKeyCode)keyCode modifiers:(CGEventFlags)modifiers
{
    // TODO: write unit tests to confirm that Quartz and Carbon key codes are the same
    return [self handlerForHotKey:[WOHotKey hotKeyWithKeyCode:keyCode modifiers:[WOHotKey cocoaModifiersFromQuartz:modifiers]]];
}

- (WOHotKeyHandler *)handlerForHotKeyID:(EventHotKeyID)hotKeyID
{
    WOHotKeyHandler *handler = nil;

    // key enumeration: cannot use Objective-C 2.0 fast enumeration
    WO_KEY_ENUMERATE(registeredHotKeys, key)
    {
        WOHotKeyRef *ref = [registeredHotKeys objectForKey:key];
        if (([ref hotKeyID].signature == hotKeyID.signature) && ([ref hotKeyID].id == hotKeyID.id))
        {
            handler = [self handlerForHotKey:key];  // match found
            break;
        }
    }
    return handler;
}

- (WOHotKeyHandler *)handlerForHotKey:(WOHotKey *)hotKey
{
    WOHotKeyHandler *handler = nil;

    // search in handlers, pressHandlers and releaseHandlers
    handler = [self handlerForHotKey:hotKey set:handlers];
    if (handler) return handler;

    handler = [self handlerForHotKey:hotKey set:pressHandlers];
    if (handler) return handler;

    handler = [self handlerForHotKey:hotKey set:releaseHandlers];
    return handler;
}

- (WOHotKeyHandler *)handlerForHotKey:(WOHotKey *)hotKey set:(WOHotKeyHandlerSet *)set
{
    for (WOHotKeyHandler *handler in set)
    {
        for (WOHotKey *aHotKey in [handler hotKeys])
        {
            if ([aHotKey isEqual:hotKey]) return handler;   // match found
        }
    }
    return nil;
}

- (WOHotKeyHandler *)handlerNamed:(NSString *)name
{
    return [handlers handlerNamed:name];
}

- (WOHotKeyHandler *)pressHandlerNamed:(NSString *)name
{
    return [pressHandlers handlerNamed:name];
}

- (WOHotKeyHandler *)releaseHandlerNamed:(NSString *)name
{
    return [releaseHandlers handlerNamed:name];
}

#pragma mark -
#pragma mark Activating and deactivating hot key handling

- (BOOL)handlesHotKeyEvents
{
    return handlesHotKeyEvents;
}

- (void)setHandlesHotKeyEvents:(BOOL)flag
{
    if (flag != handlesHotKeyEvents)
    {
        handlesHotKeyEvents = flag;

        if (eventTap)
            CGEventTapEnable(eventTap, handlesHotKeyEvents ? true : false);
    }
}

@end
