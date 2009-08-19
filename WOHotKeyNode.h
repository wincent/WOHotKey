// WOHotKeyNode.h
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

#import "WOHotKeyHandler.h"

@interface WOHotKeyNode : NSObject {

    /*! The hot key description that will appear in the lefthand column. */
    NSString        *actionString;

    /*! The hot key(s) represented as a string. nil on non-leaf nodes. So named so as to match the conventions used in NSTextField (and by inheritance WOHotKeyCaptureTextField). */
    NSString        *stringRepresentation;

    /*! An array of WOHotKey objects. Is nil on non-leaf nodes. */
    NSArray         *hotKeys;

    /*! Property list key that identifies this hot key combination in the user defaults. nil for non-leaf nodes. */
    NSString        *plistKey;

    /*! nil for nodes at the root level. */
    WOHotKeyNode    *parent;

    /*! nil for leaf nodes. */
    NSArray         *children;

    BOOL            isLeafNode;

    /*! undefined for non-leaf nodes. */
    WOHotKeyHandlerType type;

    /*!

     \name Cocoa Bindings support

     For Cocoa Bindings support.

    */
    //@{

    id          hotKeysObserver;

    NSString    *hotKeysKeyPath;

    NSString    *hotKeysTransformerName;

    //@}

    /*! The selector performed when the hot key is pressed. */
    SEL         action;

    /*! A non-retained reference to the target of the hot key. The reference is non-retained so as to avoid retain cycles. In most cases the target should be the main controller class for the application (usually the NSApplication delegate). */
    id          target;

    /*! Non-retained reference to the shared NSUserDefaultsController. */
    NSUserDefaultsController *defaults;
}

//! Convenience method that returns a new non-leaf node. The \p aNode parameter may be nil for category nodes in the top-level of the hierarchy.
//! \throws NSInternalInconsistencyException thrown if \description is nil.
+ (WOHotKeyNode *)categoryNodeWithParent:(WOHotKeyNode *)aNode actionString:(NSString *)description;

/*! Convenience method that returns a new leaf node. Use this method to define simple press-based hot keys. The value of the hot key node will be bound to the user defaults using the key. An exception is raised if any of the parameters is nil or NULL. */
+ (WOHotKeyNode *)leafNodeWithParent:(WOHotKeyNode *)aNode
                        actionString:(NSString *)description
                            plistKey:(NSString *)key
                              target:(id)aTarget
                              action:(SEL)anAction;

/*! Convenience method that returns a new leaf node. Use this method to define complex hot key keys that require separate press and release events (or only release events) to be triggered. In all other respects this method is like the leafNodeWithParent:actionString:plistKey:target:action: method. */
+ (WOHotKeyNode *)leafNodeWithParent:(WOHotKeyNode *)aNode
                        actionString:(NSString *)description
                            plistKey:(NSString *)key
                              target:(id)aTarget
                              action:(SEL)anAction
                                type:(WOHotKeyHandlerType)handlerType;

/*! Do not call on leaf nodes. */
- (WOHotKeyNode *)objectAtIndex:(unsigned)anIndex;

/*! Returns the count of the children of this node. Returns 0 for leaf nodes. */
- (unsigned)count;

/*! Returns YES if the node appears at the root level. The actual root node itself ("/") does not appear in the hierarchy. */
- (BOOL)isRootLevelNode;

/*! Do not call on leaf nodes. */
- (void)addChild:(WOHotKeyNode *)aNode;

#pragma mark -
#pragma mark Properties

@property(copy)     NSString            *actionString;
@property(copy)     NSString            *stringRepresentation;
@property(copy)     NSArray             *hotKeys;
@property(copy)     NSString            *plistKey;
@property(assign)   WOHotKeyNode        *parent;
@property(copy)     NSArray             *children;
@property           BOOL                isLeafNode;
@property           WOHotKeyHandlerType type;
@property           SEL                 action;
@property(assign)   id                  target;

@end
