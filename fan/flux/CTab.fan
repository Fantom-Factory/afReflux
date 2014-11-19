using gfx
using fwt

class CTab : Pane {
	** Text of the tab's label. Defaults to "".
	native Str text

	** Image to display on tab. Defaults to null.
	native Image? image

	new make() : super() { }
	
	override Size prefSize(Hints hints := Hints.defVal){ Size(100,100)}
	override Void onLayout() {}
	
//	native Void attach2()
}