// WOHotKeyNode.m
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
#import "WOHotKeyNode.h"

// project class headers
#import "WOHotKey.h"
#import "WOHotKeyCaptureTextField.h"
#import "WOHotKeyManager.h"

// WOPublic macro headers
#import "WOPublic/WOConvenienceMacros.h"

@implementation WOHotKeyNode
WO_CLASS_EXPORT(WOHotKeyNode);

+ (void)initialize
{
    [self exposeBinding:WO_HOT_KEY_VALUE_BINDING];
}

+ (WOHotKeyNode *)categoryNodeWithParent:(WOHotKeyNode *)aNode actionString:(NSString *)description
{
    NSParameterAssert(description != nil); // but aNode can be nil

    // set up category node
    WOHotKeyNode *node = [[self alloc] init];
    [node setParent:aNode];
    [node setActionString:description];
    [node setStringRepresentation:@""];
    [node setIsLeafNode:NO];

    // add category node to parent
    if (aNode) [aNode addChild:node];
    return node;
}

+ (WOHotKeyNode *)leafNodeWithParent:(WOHotKeyNode *)aNode
                        actionString:(NSString *)description
                            plistKey:(NSString *)key
                              target:(id)aTarget
                              action:(SEL)anAction
{
    return [self leafNodeWithParent:aNode
                       actionString:description
                           plistKey:key
                             target:aTarget
                             action:anAction
                               type:WOHotKeyHandlerRespondsToPressEvents];
}

+ (WOHotKeyNode *)leafNodeWithParent:(WOHotKeyNode *)aNode
                        actionString:(NSString *)description
                            plistKey:(NSString *)key
                              target:(id)aTarget
                              action:(SEL)anAction
                                type:(WOHotKeyHandlerType)handlerType
{
    NSParameterAssert(aNode != nil);
    NSParameterAssert(description != nil);
    NSParameterAssert(key != nil);
    NSParameterAssert(aTarget != nil);
    NSParameterAssert(anAction != NULL);

    // set up leaf node
    WOHotKeyNode *node = [[self alloc] init];
    [node setParent:aNode];
    [node setActionString:description];
    [node setPlistKey:key];
    [node setIsLeafNode:YES];
    [node setType:handlerType];
    [node setTarget:aTarget];
    [node setAction:anAction];

    [aNode addChild:node];  // add leaf node to parent

    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

    // bind to user defaults controller
    NSString *keyPath = [NSString stringWithFormat:@"values.%@", key];
    [node bind:WO_HOT_KEY_VALUE_BINDING
      toObject:defaults
   withKeyPath:keyPath
       options:[NSDictionary dictionaryWithObject:@"WOHotKeyValueTransformer" forKey:@"NSValueTransformerName"]];

    // register hot key(s) if defined in user preferences
    WOHotKeyManager *manager = [WOHotKeyManager defaultManager];
    NSArray *a = (NSArray *)[[defaults values] valueForKey:key];
    if (!a || ![a isKindOfClass:[NSArray class]])
        a = nil;
    NSArray *hotKeys = [manager hotKeyArrayForDictionaryRepresentationArray:a];

    if (hotKeys)
    {
        if (handlerType == WOHotKeyHandlerRespondsToPressEvents)
            [manager setPressHandler:description target:aTarget action:anAction forHotKeys:hotKeys];
        else if (handlerType == WOHotKeyHandlerRespondsToPressReleaseEvents)
            [manager setHandler:description target:aTarget action:anAction forHotKeys:hotKeys];
        else if (handlerType == WOHotKeyHandlerRespondsToReleaseEvents)
            [manager setReleaseHandler:description target:aTarget action:anAction forHotKeys:hotKeys];
    }

    return node;
}

- (id)init
{
    if ((self = [super init]))
    {
        defaults = [NSUserDefaultsController sharedUserDefaultsController];
        NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
        [c addObserver:self
              selector:@selector(handleNotification:)
                  name:WO_HOT_KEY_DUPLICATE_HOT_KEYS_REMOVED_NOTIFICATION
                object:nil];
    }
    return self;
}

- (void)finalize
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSString *key = [self plistKey];
    if (key) [self unbind:WO_HOT_KEY_VALUE_BINDING];

    [super finalize];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSString    *name       = [aNotification name];
    id          userInfo    = [aNotification userInfo];

    if (name && [name isEqualToString:WO_HOT_KEY_DUPLICATE_HOT_KEYS_REMOVED_NOTIFICATION] && userInfo)
    {
        NSString *handlerName       = [userInfo objectForKey:WO_HOT_KEY_NOTIFICATION_HANDLER_NAME];
        NSArray *newHotKeysArray    = [userInfo objectForKey:WO_HOT_KEY_NOTIFICATION_HOT_KEYS];
        if (handlerName && [handlerName isEqualToString:[self actionString]] && newHotKeysArray)
            [self setHotKeys:newHotKeysArray];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %x ActionString=\"%@\" HotKey=%@ PlistKey=\"%@\" Parent=%x Children=%x",
        NSStringFromClass([self class]), self, [self actionString], [self hotKeys], [self plistKey], [self parent],
        [self children]];
}

- (WOHotKeyNode *)objectAtIndex:(unsigned)anIndex
{
    if ([self isLeafNode])
        return nil;

    NSArray *childrenArray = [self children];
    if (childrenArray && ([childrenArray count] > anIndex))
        return [childrenArray objectAtIndex:anIndex];
    else
        return nil;
}

- (unsigned)count
{
    if ([self isLeafNode])
        return 0;

    NSArray *childrenArray = [self children];
    if (childrenArray)
        return [childrenArray count];

    return 0;
}

- (BOOL)isRootLevelNode
{
    return ([self parent] ? NO : YES);
}

- (void)addChild:(WOHotKeyNode *)aNode
{
    if (!aNode || [self isLeafNode])
        return;

    NSMutableArray *newChildren;
    NSArray *currentChildren = [self children];
    if (currentChildren)
        newChildren = [NSMutableArray arrayWithArray:currentChildren];
    else
        newChildren = [NSMutableArray array];
    [newChildren addObject:aNode];
    [self setChildren:[NSArray arrayWithArray:newChildren]];
}

#pragma mark -
#pragma mark Cocoa bindings compliance

- (Class)valueClassForBinding:(NSString *)binding
{
    if ([binding isEqualToString:WO_HOT_KEY_VALUE_BINDING])
        return [NSArray class];
    else
        return [super valueClassForBinding:binding];
}

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    if ([binding isEqualToString:WO_HOT_KEY_VALUE_BINDING])
    {
        hotKeysObserver         = observableController;
        hotKeysKeyPath          = [keyPath copy]; // balanced in -unbind:
        hotKeysTransformerName  = [[options objectForKey:@"NSValueTransformerName"] copy];

        [hotKeysObserver addObserver:self forKeyPath:keyPath options:0 context:NULL];

        // set up initial value
        NSArray *initialValue = nil;
        if (hotKeysTransformerName)
        {
            // get an NSArray of WOHotKey objects
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:hotKeysTransformerName];
            initialValue = [transformer transformedValue:[hotKeysObserver valueForKeyPath:keyPath]];
        }
        else
            initialValue = [hotKeysObserver valueForKeyPath:keyPath];

        [self setHotKeys:initialValue]; // store an NSArray of WOHotKey objects
    }
    else
        [super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)unbind:(NSString *)binding
{
    if ([binding isEqualToString:WO_HOT_KEY_VALUE_BINDING])
    {
        [hotKeysObserver removeObserver:self forKeyPath:hotKeysKeyPath];

        // balance copies in bind:toObject:withKeyPath:options:
        hotKeysKeyPath = nil;
        hotKeysTransformerName = nil;
    }
    else
        [super unbind:binding];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath && hotKeysKeyPath && [keyPath isEqualToString:hotKeysKeyPath])
    {
        NSArray *value = [hotKeysObserver valueForKeyPath:keyPath];
        NSValueTransformer *transformer = nil;
        if (hotKeysTransformerName)
            transformer = [NSValueTransformer valueTransformerForName:hotKeysTransformerName];

        if (value && ([value count] > 0))
        {
            if ([[value objectAtIndex:0] isKindOfClass:[WOHotKey class]])
            {
                if (transformer)
                    value = [transformer reverseTransformedValue:value];
            }
        }

        WOHotKeyManager *m              = [WOHotKeyManager defaultManager];
        NSArray         *hotKeysArray   = [m hotKeyArrayForDictionaryRepresentationArray:value];

        if (type == WOHotKeyHandlerRespondsToPressEvents)
            [m setPressHandler:[self actionString] target:[self target] action:[self action] forHotKeys:hotKeysArray];
        else if (type == WOHotKeyHandlerRespondsToPressReleaseEvents)
            [m setHandler:[self actionString] target:[self target] action:[self action] forHotKeys:hotKeysArray];
        else if (type == WOHotKeyHandlerRespondsToReleaseEvents)
            [m setReleaseHandler:[self actionString] target:[self target] action:[self action] forHotKeys:hotKeysArray];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark -
#pragma mark Psuedo (complex) accessors

- (NSArray *)hotKeys
{
    return hotKeys;
}

- (void)setHotKeys:(NSArray *)anArray
{
    NSArray *hotKeyArray        = anArray;
    NSArray *dictionaryArray    = anArray;

    NSValueTransformer *transformer = nil;
    if (hotKeysTransformerName)
        transformer = [NSValueTransformer valueTransformerForName:hotKeysTransformerName];

    if (anArray != hotKeys)
    {
        // Witness this horrible but effective kludge... Unfortunately this is
        // necessary because sometimes this method will be called by the
        // NSUserDefaultsController which will pass an array of dictionaries
        // and sometimes it will be called by the view which will pass an array
        // of hot key objects. It is impossible to know in advance which one
        // will apply.
        //
        // It seems that the correct way to handle this would be to use an
        // NSValueTransformer, but this class shouldn't have to "know" whether
        // it should be calling reverseTransformedValue or transformedValue.
        if (anArray && ([anArray count] > 0))
        {
            if ([[anArray objectAtIndex:0] isKindOfClass:[WOHotKey class]])
            {
                // passed an array of WOHotKey objects
                if (transformer)
                    dictionaryArray = [transformer reverseTransformedValue:hotKeyArray];
            }
            else // passed an array of dictionaries
            {
                if (transformer)
                    hotKeyArray = [transformer transformedValue:dictionaryArray];
            }
        }

        // notify controller as well, but only if necessary
        if (![[hotKeysObserver valueForKeyPath:hotKeysKeyPath] isEqual:dictionaryArray])
        {
            [hotKeysObserver setValue:dictionaryArray forKeyPath:hotKeysKeyPath];
        }

        hotKeys = hotKeyArray;

        // update string value
        NSString *stringRep = [[WOHotKeyManager defaultManager] stringRepresentationForHotKeyArray:hotKeyArray];
        [self setStringRepresentation:stringRep];
    }
}

#pragma mark -
#pragma mark Properties

@synthesize actionString;
@synthesize stringRepresentation;
@synthesize hotKeys;
@synthesize plistKey;
@synthesize parent;
@synthesize children;
@synthesize isLeafNode;
@synthesize type;
@synthesize action;
@synthesize target;

@end
