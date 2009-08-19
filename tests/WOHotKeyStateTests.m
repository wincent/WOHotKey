// WOHotKeyStateTests.m
// WOHotKey
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.
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
#import "WOHotKeyStateTests.h"

// tested class header
#import "WOHotKeyState.h"

@implementation WOHotKeyStateTests

- (void)testHotKeyStateWithTimeIntervalTargetSelectorRepeats
{
    // target must not be nil
    WO_TEST_THROWS([WOHotKeyState hotKeyStateWithTimeInterval:10 target:nil selector:@selector(description) repeats:YES]);

    // selector must not be NULL
    WO_TEST_THROWS([WOHotKeyState hotKeyStateWithTimeInterval:10 target:self selector:NULL repeats:YES]);

    // interval must be greater than 0
    WO_TEST_THROWS([WOHotKeyState hotKeyStateWithTimeInterval:-10 target:self selector:@selector(description) repeats:YES]);
    WO_TEST_THROWS([WOHotKeyState hotKeyStateWithTimeInterval:0 target:self selector:@selector(description) repeats:YES]);

    // but other combos should work
    WO_TEST_DOES_NOT_THROW([WOHotKeyState hotKeyStateWithTimeInterval:10 target:self selector:@selector(description) repeats:YES]);
}

@end
