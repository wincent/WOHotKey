// WOHotKeyRef.m
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
#import "WOHotKeyRef.h"

// system headers
#import <libkern/OSAtomic.h>        /* OSAtomicIncrement32Barrier() */

@interface WOHotKeyRef ()

+ (int32_t)nextID;
+ (OSType)signature;

@end

@implementation WOHotKeyRef

// returns a unique, incrementing ID number on each invocation
+ (int32_t)nextID
{
    static int32_t counter = 0;
    return OSAtomicIncrement32Barrier(&counter);
}

+ (EventHotKeyID)nextEventHotKeyID
{
    EventHotKeyID returnID;
    returnID.signature  = [self signature];
    returnID.id         = (UInt32)[self nextID];    // cast from signed to unsigned is safe; all we care about is uniqueness
    return returnID;
}

// return an application-specific signature (for hotKeyID)
+ (OSType)signature
{
    static OSType signature = 0;

    // first time here, initialize application signature
    if (signature == 0)
    {
        // try to get CFBundleSignature from Info.plist
        NSBundle *bundle            = [NSBundle mainBundle];
        NSString *bundleSignature   = [bundle objectForInfoDictionaryKey:@"CFBundleSignature"];

        if (bundleSignature &&
            [bundleSignature isKindOfClass:[NSString class]] &&
            [bundleSignature length] == 4)
        {
            NSData* data = [bundleSignature dataUsingEncoding:NSMacOSRomanStringEncoding];
            if (data)
                [data getBytes:&signature length:sizeof(signature)];
            else
                signature = '???\?';    // use default '????'
        }
        else
            signature = '???\?';        // escape prevents GCC trigraph warning
    }

    return signature;
}

+ (id)ref
{
    WOHotKeyRef     *ref = [[self alloc] init];
    [ref setHotKeyID:[self nextEventHotKeyID]];
    return ref;
}

- (EventHotKeyID)hotKeyID
{
    return hotKeyID;
}

- (void)setHotKeyID:(EventHotKeyID)value
{
    hotKeyID = value;
}

- (EventHotKeyRef)hotKeyRef
{
    return hotKeyRef;
}

- (void)setHotKeyRef:(EventHotKeyRef)ref
{
    hotKeyRef = ref;
}

@end
