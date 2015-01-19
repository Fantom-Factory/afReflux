using fwt
using gfx

** (Widget) - 
** 
** See [SWT Browser]`http://help.eclipse.org/indigo/topic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/browser/package-summary.html`
class Browser : Pane {

	private native	Widget?	browser
	private 		Label?	statusBar
	
	@NoDoc
	new make() : super() {
		statusBar = Label() { it.text="status"}
//		add(statusBar)
	}
	
	override Size prefSize(Hints hints := Hints.defVal) { Size(100, 100) }
//	override Void onLayout() { }

//	@NoDoc	// required by Pane
//	override Size prefSize(Hints hints := Hints.defVal) {
//		bottom := pref(this.statusBar)
//		center := pref(this.browser)
//
//		w := (center.w).max(bottom.w)
//		h := bottom.h + center.h
//		return Size(w, h)
//	}
//
//	private Size pref(Widget? w) {
//		return w == null || !w.visible ? Size.defVal : w.prefSize(Hints.defVal)
//	}
//
	@NoDoc	// required by Pane
	override Void onLayout() {
		x := 0; y := 0; w := size.w; h := size.h

		bottom := this.statusBar
		if (bottom != null) {
			prefh := bottom.prefSize(Hints(w, null)).h
			bottom.bounds = Rect(x, y+h-prefh, w, prefh)
			h -= prefh
		}

//		center := this.browser
//		if (center != null)
//			center.bounds = Rect(x, y, w, h)
		
		echo("onLayout")
	}
	
	
//	** Callback when the user clicks a hyperlink.
//	** The callback is invoked before the actual hyperlink.	
//	** The event handler can modify the 'data' field with a new Uri or set to null to cancel the hyperlink.
//	** This callback is *not* called if explicitly loaded via the `load` method.
//	**
//	** Event id fired:
//	**	 - `EventId.hyperlink`
//	**
//	** Event fields:
//	**	 - `Event.data`: the `sys::Uri` of the new page.
//	once EventListeners onHyperlink() { EventListeners() }
//
//	** Navigate to the specified URI.
//	native This load(Uri uri)
//
//	** Load the given HTML into the browser.
//	native This loadStr(Str html)
//
//	** Refresh the current page.
//	native This refresh()
//
//	** Stop any load activity.
//	native This stop()
//
//	** Navigate to the previous session history.
//	native This back()
//
//	** Navigate to the next session history.
//	native This forward()

}
