using afIoc
using gfx
using fwt

abstract class SideBar : ContentPane {
	
	internal SideBarPane? sideBarPane

	@Inject private EventHub?	eventHub
	
	** Get this sidebar's preferred alignment which is used to
	** determine its default position.  Valid values are:
	**   - Halign.left (default)
	**   - Halign.right
	**   - Valign.bottom
	virtual Obj prefAlign() { return Halign.left }

	** Is the sidebar currently shown in the frame?
	Bool showing := false { internal set }

	** Show this sidebar in the frame.
	This show() {
		if (showing) return this
		showing = true
		sideBarPane.show(this)
		content?.relayout
		return this
	}

	** Hide this sidebar in the frame.
	This hide() {
		if (!showing) return this
		showing = false
		sideBarPane.hide(this)
		return this
	}
	
	Obj[] fireEvent(Str event, 
		Obj? a := null, Obj? b := null, Obj? c := null, Obj? d := null,
		Obj? e := null, Obj? f := null, Obj? g := null, Obj? h := null) {
		eventHub.fireEvent(event, a, b, c, d, e, f, g, h)
	}
	
	** Callback when sidebar is first loaded into memory.
	** This is the time to load persistent state.
	virtual Void onLoad() {}

	** Callback when sidebar is being unloaded from memory.
	** This is the time to save persistent state.	This is
	** called no matter whether the sidebar is shown or hidden.
	virtual Void onUnload() {}

	** Callback when sidebar is shown in the frame.
	virtual Void onShow() {}

	** Callback when sidebar is hidden in the frame.
	virtual Void onHide() {}

	** Callback when specified view is selected as the
	** active tab.	This callback is invoked only if showing.
	virtual Void onActive(View view) {}

	** Callback when specified view is unselected as the
	** active tab.	This callback is invoked only if showing.
	virtual Void onInactive(View view) {}
}
