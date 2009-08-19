//
//  WOHotKeyInspector.m
//  WOHotKey
//
//  Created by Wincent Colaiuta on 22 April 2005.
//  Copyright 2005-2007 Wincent Colaiuta.
//

#import "WOHotKeyInspector.h"
#import "WOHotKey/WOHotKey.h"

@implementation WOHotKeyInspector

- (id)init
{
    if ((self = [super init]))
    {
        if (![NSBundle loadNibNamed:@"WOHotKeyInspector" owner:self])
            NSLog(@"WOHotKeyInspector error in init");
    }
    return self;
}

- (void)ok:(id)sender
{
    /* Your code Here */
    [super ok:sender];
}

- (void)revert:(id)sender
{
    /* Your code Here */
    [super revert:sender];
}

@end
