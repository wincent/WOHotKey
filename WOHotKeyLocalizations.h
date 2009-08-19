// WOHotKeyLocalizations.h
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

// was in WOCommon
#define _WO_SELF    [NSBundle bundleForClass:[self class]]

#pragma mark -
#pragma mark User interface strings

#define _WO_FIELD_EDITOR_TOOL_TIP NSLocalizedStringFromTableInBundle(@"Currently defined Hot Key combinations", nil, _WO_SELF, @"Currently defined Hot Key combinations")

#define _WO_PLUS_BUTTON_TOOL_TIP NSLocalizedStringFromTableInBundle(@"Add another Hot Key combination", nil, _WO_SELF, @"Add another Hot Key combination")

#define _WO_MINUS_BUTTON_TOOL_TIP NSLocalizedStringFromTableInBundle(@"Remove the selected Hot Key combination(s)", nil, _WO_SELF, @"Remove the selected Hot Key combination(s)")

#define _WO_TICK_BUTTON_TOOL_TIP NSLocalizedStringFromTableInBundle(@"Finish editing", nil, _WO_SELF, @"Finish editing")

#define _WO_GHOSTED_PLUS_BUTTON_TOOL_TIP NSLocalizedStringFromTableInBundle(@"Add another Hot Key combination (disabled because there are no combinations defined yet)", nil, _WO_SELF, @"Add another Hot Key combination (disabled because there are no combinations defined yet)")

#define _WO_GHOSTED_MINUS_BUTTON_TOOL_TIP NSLocalizedStringFromTableInBundle(@"Remove the selected Hot Key combinations (disabled because there are no combinations selected)", nil, _WO_SELF, @"Remove the selected Hot Key combinations (disabled because there are no combinations selected)")

#pragma mark -
#pragma mark Key names for display in the user interface

#define _WO_UNKNOWN NSLocalizedStringFromTableInBundle (@"Unknown", @"Keys", _WO_SELF, @"Unknown key.")

#define _WO_FN_KEY_WITH_HYPHEN NSLocalizedStringFromTableInBundle (@"fn-", @"Keys", _WO_SELF, @"'fn' key, with hyphen. Common on laptops.")

#define _WO_FN_KEY NSLocalizedStringFromTableInBundle (@"fn", @"Keys", _WO_SELF, @"'fn' key, no hyphen. Common on laptops.")

#define _WO_PAD NSLocalizedStringFromTableInBundle (@"Pad-", @"Keys", _WO_SELF, @"Modifier for numeric keypad, with hyphen.")

#define _WO_INSERT NSLocalizedStringFromTableInBundle (@"Insert", @"Keys", _WO_SELF, @"'Insert' key. Not on most Macintosh keyboards.")

#define _WO_BEGIN NSLocalizedStringFromTableInBundle (@"Begin", @"Keys", _WO_SELF, @"'Begin' key. Not on most Macintosh keyboards.")

#define _WO_PRINT_SCREEN NSLocalizedStringFromTableInBundle (@"Print Screen", @"Keys", _WO_SELF, @"'Print Screen' key. Not on most Macintosh keyboards.")

#define _WO_SCROLL_LOCK NSLocalizedStringFromTableInBundle (@"Scroll Lock", @"Keys", _WO_SELF, @"'Scroll lock' key. Not on most Macintosh keyboards.")

#define _WO_PAUSE NSLocalizedStringFromTableInBundle (@"Pause", @"Keys", _WO_SELF, @"'Pause' key. Not on most Macintosh keyboards.")

#define _WO_SYSTEM_REQUEST NSLocalizedStringFromTableInBundle (@"System Request", @"Keys", _WO_SELF, @"'System Request' key. Not on most Macintosh keyboards.")

#define _WO_BREAK NSLocalizedStringFromTableInBundle (@"Break", @"Keys", _WO_SELF, @"'Break' key. Not on most Macintosh keyboards.")

#define _WO_RESET NSLocalizedStringFromTableInBundle (@"Reset", @"Keys", _WO_SELF, @"'Reset' key. Not on most Macintosh keyboards.")

#define _WO_STOP NSLocalizedStringFromTableInBundle (@"Stop", @"Keys", _WO_SELF, @"'Stop' key. Not on most Macintosh keyboards.")

#define _WO_MENU NSLocalizedStringFromTableInBundle (@"Menu", @"Keys", _WO_SELF, @"'Menu' key. Not on most Macintosh keyboards.")

#define _WO_USER NSLocalizedStringFromTableInBundle (@"User", @"Keys", _WO_SELF, @"'User' key. Not on most Macintosh keyboards.")

#define _WO_SYSTEM NSLocalizedStringFromTableInBundle (@"System", @"Keys", _WO_SELF, @"'System' key. Not on most Macintosh keyboards.")

#define _WO_PRINT NSLocalizedStringFromTableInBundle (@"Print", @"Keys", _WO_SELF, @"'Print' key. Not on most Macintosh keyboards.")

#define _WO_CLEAR NSLocalizedStringFromTableInBundle (@"Clear", @"Keys", _WO_SELF, @"'Clear' key. Not on most Macintosh keyboards.")

#define _WO_INSERT_LINE NSLocalizedStringFromTableInBundle (@"Insert Line", @"Keys", _WO_SELF, @"'Insert Line' key. Not on most Macintosh keyboards.")

#define _WO_DELETE_LINE NSLocalizedStringFromTableInBundle (@"Delete Line", @"Keys", _WO_SELF, @"'Delete Line' key. Not on most Macintosh keyboards.")

#define _WO_INSERT_CHAR NSLocalizedStringFromTableInBundle (@"Insert Char", @"Keys", _WO_SELF, @"'Insert Char' key. Not on most Macintosh keyboards.")

#define _WO_DELETE_CHAR NSLocalizedStringFromTableInBundle (@"Delete Char", @"Keys", _WO_SELF, @"'Delete Char' key. Not on most Macintosh keyboards.")

#define _WO_PREVIOUS NSLocalizedStringFromTableInBundle (@"Previous", @"Keys", _WO_SELF, @"'Previous' key. Not on most Macintosh keyboards.")

#define _WO_NEXT NSLocalizedStringFromTableInBundle (@"Next", @"Keys", _WO_SELF, @"'Next' key. Not on most Macintosh keyboards.")

#define _WO_SELECT NSLocalizedStringFromTableInBundle (@"Select", @"Keys", _WO_SELF, @"'Select' key. Not on most Macintosh keyboards.")

#define _WO_EXECUTE NSLocalizedStringFromTableInBundle (@"Execute", @"Keys", _WO_SELF, @"'Execute' key. Not on most Macintosh keyboards.")

#define _WO_UNDO NSLocalizedStringFromTableInBundle (@"Undo", @"Keys", _WO_SELF, @"'Undo' key. Not on most Macintosh keyboards.")

#define _WO_REDO NSLocalizedStringFromTableInBundle (@"Redo", @"Keys", _WO_SELF, @"'Redo' key. Not on most Macintosh keyboards.")

#define _WO_FIND NSLocalizedStringFromTableInBundle (@"Find", @"Keys", _WO_SELF, @"'Find' key. Not on most Macintosh keyboards.")

#define _WO_MODE_SWITCH NSLocalizedStringFromTableInBundle (@"Mode Switch", @"Keys", _WO_SELF, @"'Mode Switch' key. Not on most Macintosh keyboards.")

#define _WO_SPACE NSLocalizedStringFromTableInBundle (@"Space", @"Keys", _WO_SELF, @"'Space' key.")


