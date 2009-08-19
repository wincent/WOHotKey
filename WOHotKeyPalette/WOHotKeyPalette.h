//
//  WOHotKeyPalette.h
//  WOHotKey
//
//  Created by Wincent Colaiuta on 22 April 2005.
//  Copyright 2005-2007 Wincent Colaiuta.
//

#import <InterfaceBuilder/InterfaceBuilder.h>
#import "WOHotKey/WOHotKey.h"

@interface WOHotKeyPalette : IBPalette {

}

@end

@interface WOHotKeyCaptureTextField (WOHotKeyPaletteInspector)

- (NSString *)inspectorClassName;

@end
