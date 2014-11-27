using gfx
using fwt

@Serializable { collection = true }
class CTab : Pane {
	** Text of the tab's label. Defaults to "".
	native Str text

	** Image to display on tab. Defaults to null.
	native Image? image

	@NoDoc
	new make() : super() { }
	
	@NoDoc	// required by Pane
	override Size prefSize(Hints hints := Hints.defVal) { Size(100,100) }

	@NoDoc	// required by Pane
	override Void onLayout() {}
}