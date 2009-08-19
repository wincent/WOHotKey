// WOHotKeyState.m
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
#import "WOHotKeyState.h"

// WOPublic macro headers
#import "WOPublic/WOConvenienceMacros.h"

@implementation WOHotKeyState
WO_CLASS_EXPORT(WOHotKeyState);

+ (WOHotKeyState *)hotKeyStateWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                       repeats:(BOOL)flag
{
    NSParameterAssert(interval > 0.0);
    NSParameterAssert(aTarget != nil);
    NSParameterAssert(aSelector != NULL);

    WOHotKeyState *object = [[self alloc] init];
    [object setTimer:[NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:aTarget
                                                    selector:aSelector
                                                    userInfo:self
                                                     repeats:flag]];
    return object;
}

+ (WOHotKeyState *)hotKeyStateWithTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)flag
{
    return [self hotKeyStateWithTimeInterval:WO_HOTKEY_STATE_DEFAULT_TIMER target:aTarget selector:aSelector repeats:flag];
}

- (void)finalize
{
    [self cancelTimer];
    [super finalize];
}

- (void)cancelTimer
{
    NSTimer *currentTimer = [self timer];
    if (currentTimer && [currentTimer isValid])
    {
        [currentTimer invalidate];
        [self setTimer:nil];
    }
}

- (BOOL)timerRunning
{
    NSTimer *currentTimer = [self timer];
    if (currentTimer && [currentTimer isValid])
        return YES;
    else
        return NO;
}

#pragma mark -
#pragma mark Properties

@synthesize timer;

@end
