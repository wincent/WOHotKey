//
//  WOHotKeyPalette.m
//  WOHotKey
//
//  Created by Wincent Colaiuta on 22 April 2005.
//  Copyright 2005-2007 Wincent Colaiuta.
//

#import "WOHotKeyPalette.h"

@implementation WOHotKeyPalette

- (void)finishInstantiate
{
    /* `finishInstantiate' can be used to associate non-view objects with
     * a view in the palette's nib.  For example:
     *   [self associateObject:aNonUIObject ofType:IBObjectPboardType
     *                withView:aView];
     */
}

@end

@implementation WOHotKey (WOHotKeyPaletteInspector)

- (NSString *)inspectorClassName
{
    return @"WOHotKeyInspector";
}

@end
