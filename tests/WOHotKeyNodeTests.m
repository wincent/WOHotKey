// WOHotKeyNodeTests.m
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
#import "WOHotKeyNodeTests.h"

// tested class header
#import "WOHotKeyNode.h"

@implementation WOHotKeyNodeTests

- (void)testExposedBindings
{
    NSArray *exposedBindings = [[WOHotKeyNode categoryNodeWithParent:nil actionString:@"foo"] exposedBindings];
    WO_TEST([exposedBindings containsObject:@"hotKeys"]);
}

- (void)testCategoryNodeWithParentActionString
{
    // description must not be nil
    WO_TEST_THROWS([WOHotKeyNode categoryNodeWithParent:nil actionString:nil]);

    // but node can be
    WO_TEST_DOES_NOT_THROW([WOHotKeyNode categoryNodeWithParent:nil actionString:@"foobar"]);
}

// TODO: write a lot more tests

@end
