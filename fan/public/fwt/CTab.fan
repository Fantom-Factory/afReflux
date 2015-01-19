using gfx
using fwt

** (Widget) - 
** The child widget for 'CTabPane' and a replacement for FWT [Tab]`fwt::Tab`.
** 
** See the [Fancy SWT Tabs]`http://www.javalobby.org/java/forums/t16488.html` article for details.
** 
** See [CTabItem]`http://help.eclipse.org/indigo/topic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/custom/CTabItem.html` SWT Widget.
@Serializable { collection = true }
class CTab : Pane {
	** Text of the tab's label. Defaults to "".
	native Str text

	** Image to display on tab. Defaults to null.
	native Image? image

	@NoDoc
	new make() : super() { }
	
	@NoDoc	// required by Pane
	override Size prefSize(Hints hints := Hints.defVal) { Size(100, 100) }

	@NoDoc	// required by Pane
	override Void onLayout() {}
}