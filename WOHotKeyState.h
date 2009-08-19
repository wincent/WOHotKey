// WOHotKeyState.h
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

#pragma mark -
#pragma mark Macros

/*! Default timer value for differentiating between a click and a "click-and-hold". */
#define WO_HOTKEY_STATE_DEFAULT_TIMER 0.30

@interface WOHotKeyState : NSObject {

    /*! Timer that starts running on button down. */
    NSTimer *timer;

}

//! \throws NSInternalInconsistencyException thrown if \p interval is less than or equal to zero, if \p aTarget is nil, or if \p aSelector is NULL.
+ (WOHotKeyState *)hotKeyStateWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                       repeats:(BOOL)flag;

/*! Identical to hotKeyStateWithTimeInterval:target:selector:repeats: but uses the default time interval. */
+ (WOHotKeyState *)hotKeyStateWithTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)flag;

/*! Stops the timer if it is running. */
- (void)cancelTimer;

- (BOOL)timerRunning;

#pragma mark -
#pragma mark Properties

@property(assign) NSTimer *timer;

@end
