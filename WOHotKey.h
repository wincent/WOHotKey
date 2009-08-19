// WOHotKey.h
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

//! \file WOHotKey.h
//!
//! The main classes in the framework are:
//!
//!   - WOHotKeyManager: responsible for registering hot keys and firing off
//!     actions in response to hot key events
//!   - WOHotKey: represents a hot key combination and provides methods for
//!     obtaining human-readable representations
//!   - WOHotKeyOutlineView: user interface class for displaying and
//!     customizing hot keys
//!
//! There are numerous other classes which support the operation of the
//! principal classes, including:
//!
//!   - WOHotKeyTableColumn: a table column class for use with
//!     WOHotKeyOutlineView
//!   - WOHotKeyCaptureTextField, WOHotKeyCaptureTextFieldCell and
//!     WOHotKeyCaptureTextView: classes for displaying hot keys in a
//!     WOHotKeyOutlineView and providing a field editor for customizing them
//!   - WOHotKeyState: a timer class which encapsulates state information of a
//!     pressed hot key; it is used to facilitate dual-purpose hot key
//!     combinations where a quick press-and-release should behave differently
//!     than a press-and-hold.
//!   - WOHotKeyHandler: encapsulates a "handler" (target and action) that
//!     should be fired in response to a hot key event
//!   - WOHotKeyNode: a node model class for use with WOHotKeyOutlineView
//!
//! WOHotKey is a Cocoa framework and so the user interface classes collect
//! Cocoa-centric information from the user (key codes and Cocoa modifiers).
//! WOHotKey objects store this information in a Cocoa-centric way internally
//! and on disk when hot key combinations are written out to the preferences.
//! Under the hood, however, WOHotKey must work with Quartz or Carbon because
//! Cocoa itself provides no hot key support. As such, the WOHotKey class has
//! methods for converting modifier flags between the three different systems
//! (Cocoa, Carbon and Quartz).
//!
//! If access for assistive devices is enabled in the Universal Access pane of
//! the System Preferences then WOHotKey will use Quartz Event Services. For
//! hot key events to be received the main run loop must be running. If
//! assistive device access is turned off then WOHotKey will fall back to using
//! a Carbon Event Handler. See the WOHotKeyManager documentation for more
//! information.

// "public" classes: intended for use when linking to the framework
#import "WOHotKeyCaptureTextField.h"
#import "WOHotKeyCaptureTextFieldCell.h"
#import "WOHotKeyCaptureTextView.h"
#import "WOHotKeyClass.h"
#import "WOHotKeyHandler.h"
#import "WOHotKeyManager.h"
#import "WOHotKeyNode.h"
#import "WOHotKeyOutlineView.h"
#import "WOHotKeyState.h"
#import "WOHotKeyTableColumn.h"
#import "WOHotKeyValueTransformer.h"

// "private" classes: intended for internal use within the framework
#import "WOHotKeyHandlerSet.h"
#import "WOHotKeyRef.h"
