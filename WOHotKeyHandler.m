// WOHotKeyHandler.m
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
#import "WOHotKeyHandler.h"

@implementation WOHotKeyHandler

#pragma mark Creating WOHotKeyHandler objects

+ (id)handlerWithName:(NSString *)aName
               target:(id)aTarget
               action:(SEL)aSelector
              hotKeys:(NSArray *)anArray
                 type:(WOHotKeyHandlerType)aType
{
    return [[self alloc] initWithName:aName
                               target:aTarget
                               action:aSelector
                              hotKeys:anArray
                                 type:aType];
}

- (id)initWithName:(NSString *)aName
            target:(id)aTarget
            action:(SEL)aSelector
           hotKeys:(NSArray *)anArray
              type:(WOHotKeyHandlerType)aType
{
    self = [super init];
    [self setName:aName];
    [self setTarget:aTarget];
    [self setAction:aSelector];
    [self setHotKeys:anArray];
    [self setType:aType];
    return self;
}

#pragma mark -

#pragma mark Performing actions

- (void)performPressedAction:(NSString *)handlerName
{
    if ((type == WOHotKeyHandlerRespondsToPressEvents) || (type == WOHotKeyHandlerRespondsToPressReleaseEvents))
        [target performSelector:action
                     withObject:[NSNotification notificationWithName:WO_HOT_KEY_PRESS_NOTIFICATION object:handlerName]];
}

- (void)performReleasedAction:(NSString *)handlerName
{
    if ((type == WOHotKeyHandlerRespondsToReleaseEvents) || (type == WOHotKeyHandlerRespondsToPressReleaseEvents))
        [target performSelector:action
                     withObject:[NSNotification notificationWithName:WO_HOT_KEY_RELEASE_NOTIFICATION object:handlerName]];
}

#pragma mark Convenience methods

- (NSEnumerator *)hotKeyEnumerator
{
    return [hotKeys objectEnumerator];
}

#pragma mark Accessors

- (NSString *)name
{
    return name;
}

- (void)setName:(NSString *)aName
{
    name = aName;
}

- (id)target
{
    return target;
}

- (void)setTarget:(id)aTarget
{
    target = aTarget;
}

- (SEL)action
{
    return action;
}

- (void)setAction:(SEL)aSelector
{
    action = aSelector;
}

- (NSArray *)hotKeys
{
    return hotKeys;
}

- (void)setHotKeys:(NSArray *)anArray
{
    hotKeys = anArray;
}

- (WOHotKeyHandlerType)type
{
    return type;
}

- (void)setType:(WOHotKeyHandlerType)aType
{
    type = aType;
}

@end