//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//	 2 Sep 08	Brian Frank	Creation
//

using fwt
using syntax

**
** TextEditorSupport provides a bunch of convience methods
**
internal mixin TextEditorSupport {

	abstract TextEditorView editor()

//	Frame frame() { return editor.frame }

	TextEditorOptions options() { return editor.options }

	SyntaxRules rules() { return editor.rules }

	TextEditorController controller() { return editor.controller }

	RichText richText() { return editor.richText }

	TextDoc doc() { return editor.doc }

}