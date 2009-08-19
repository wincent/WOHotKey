// WOHotKeyHandlerSet.m
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
#import "WOHotKeyHandlerSet.h"

// framework headers
#import "WOHotKeyHandler.h"

@implementation WOHotKeyHandlerSet

- (id)init
{
    if ((self = [super init]))
        self->handlers = [NSMutableSet set];
    return self;
}

- (NSEnumerator *)objectEnumerator
{
    return [handlers objectEnumerator];
}

- (WOHotKeyHandler *)handlerNamed:(NSString *)name
{
    for (WOHotKeyHandler *handler in handlers)
        if ([name isEqualToString:[handler name]]) return handler;
    return nil;
}

- (void)addHandler:(WOHotKeyHandler *)aHandler
{
    if (aHandler)
    {
        if (![self handlerNamed:[aHandler name]])
            [handlers addObject:aHandler];
    }
}

- (void)removeHandler:(WOHotKeyHandler *)aHandler
{
    if (aHandler)
        [handlers removeObject:aHandler];
}

- (void)removeHandlerNamed:(NSString *)name
{
    if (name)
    {
        WOHotKeyHandler *handler = [self handlerNamed:name];
        if (handler) [handlers removeObject:handler];
    }
}

- (void)removeAllHandlers
{
    [handlers removeAllObjects];
}

#pragma mark -
#pragma mark NSFastEnumeration protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
{
    return [handlers countByEnumeratingWithState:state
                                         objects:stackbuf
                                           count:len];
}

@end
