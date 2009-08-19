// WOHotKeyCaptureTextField.m
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

#import "WOHotKeyCaptureTextField.h"
#import "WOHotKeyCaptureTextFieldCell.h"
#import "WOHotKeyCaptureTextView.h"
#import "WOHotKeyClass.h"
#import "WOHotKeyManager.h"

// WOPublic macro headers
#import "WOPublic/WODebugMacros.h"

@interface WOHotKeyCaptureTextField ()

- (void)WOHotKeyCaptureTextField_commonInit;

@end

@implementation WOHotKeyCaptureTextField

+ (void)initialize
{
    [self exposeBinding:WO_HOT_KEY_VALUE_BINDING];
}

+ (Class)cellClass
{
    return [WOHotKeyCaptureTextFieldCell class];
}

// make a string representation of all the hot keys in an array
+ (NSString *)stringRepresentationFromHotKeyArray:(NSArray *)anArray
{
    if (!anArray) return nil;

    // extract string representations from array
    NSMutableArray *stringRepresentations = [NSMutableArray array];
    for (id object in anArray)
    {
        if ([object respondsToSelector:@selector(stringRepresentation)])
        {
            NSString *string = [object performSelector:@selector(stringRepresentation)];
            if (string) [stringRepresentations addObject:string];
        }
    }

    return [stringRepresentations componentsJoinedByString:@", "];
}

- (void)WOHotKeyCaptureTextField_commonInit
{
    [self setHotKeys:[NSMutableArray arrayWithCapacity:1]];

    if (![[self cell] isKindOfClass:[WOHotKeyCaptureTextFieldCell class]])
    {
        NSString *stringValue = [self stringValue];
        if (!stringValue) stringValue = @"";
        [self setCell:[[WOHotKeyCaptureTextFieldCell alloc] initTextCell:stringValue]];
    }
}

// the designated initializer for NSControl
- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
        [self WOHotKeyCaptureTextField_commonInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder]))
        [self WOHotKeyCaptureTextField_commonInit];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
}

- (void)setEnabled:(BOOL)flag
{
    // not sure why this is necessary, but must explicitly remove first responder status from custom field editor here
    NSResponder *firstResponder = [[self window] firstResponder];

    if ((flag == NO) && firstResponder && [firstResponder isKindOfClass:[WOHotKeyCaptureTextView class]])
        (void)[[self window] makeFirstResponder:nil];

    [super setEnabled:flag];
}

#pragma mark -
#pragma mark NSText delegate methods

- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
    // handle WOHotKey array manually
    WOAssert([aTextObject respondsToSelector:@selector(hotKeys)]);
    [self setHotKeys:[aTextObject performSelector:@selector(hotKeys)]];

    // let Cocoa handle string representation
    (void)[super textShouldEndEditing:aTextObject];

    return YES;
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
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:hotKeysTransformerName];
            initialValue = [transformer transformedValue:[hotKeysObserver valueForKeyPath:keyPath]];
        }
        else
            initialValue = [hotKeysObserver valueForKeyPath:keyPath];

        [self setHotKeys:initialValue];
    }
    else
        // TODO: find out if this may need to change
        // http://homepage.mac.com/mmalc/CocoaExamples/controllers.html#ibBindings
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
    if ([keyPath isEqualToString:hotKeysKeyPath])
    {
        NSArray *value = nil;
        if (hotKeysTransformerName)
        {
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:hotKeysTransformerName];
            value = [transformer transformedValue:[hotKeysObserver valueForKeyPath:keyPath]];
        }
        else
            value = [hotKeysObserver valueForKeyPath:keyPath];

        [self setHotKeys:value];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSArray *)hotKeys
{
    return hotKeys;
}

- (void)setHotKeys:(NSArray *)anArray
{
    if (anArray != hotKeys)
    {
        NSArray *transformedValue = nil;
        if (hotKeysTransformerName)
        {
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:hotKeysTransformerName];
            transformedValue = [transformer reverseTransformedValue:anArray];
        }
        else
            transformedValue = anArray;

        // notify controller as well, but only if necessary
        if (![[hotKeysObserver valueForKeyPath:hotKeysKeyPath] isEqualTo:transformedValue])
            [hotKeysObserver setValue:transformedValue forKeyPath:hotKeysKeyPath];

        hotKeys = [anArray copy];

        // update string value
        NSString *stringRepresentation = [[WOHotKeyManager defaultManager] stringRepresentationForHotKeyArray:hotKeys];
        [self setStringValue:stringRepresentation];
    }
}

@end
