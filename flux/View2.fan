using afIoc
using gfx
using fwt

class View2 {
	
	internal SideBarPane? sideBarPane

	@Inject private EventHub?	eventHub
	
	** Get this sidebar's preferred alignment which is used to
	** determine its default position.  Valid values are:
	**   - Halign.left (default)
	**   - Halign.right
	**   - Valign.bottom
	virtual Obj prefAlign() { return Halign.left }

	** Is the view currently showing?
	Bool isShowing := false { internal set }

	** Show this view in the frame.
	This show() {
		if (isShowing) return this
		isShowing = true
//		sideBarPane.show(this)
//		content?.relayout
		return this
	}

	** Hide this view in the frame.
	This hide() {
		if (!isShowing) return this
		isShowing = false
//		sideBarPane.hide(this)
		return this
	}
	
	Void fireEvent(Method event, Obj?[]? eventArgs) {
	}
	
	** Callback when sidebar is first loaded into memory.
	** This is the time to load persistent state.
	virtual Void onLoad() {}

	** Callback when sidebar is being unloaded from memory.
	** This is the time to save persistent state.
	** This is called no matter whether the sidebar is shown or hidden.
	virtual Void onUnload() {}

	** Callback when sidebar is shown in the frame.
	virtual Void onShow() {}

	** Callback when sidebar is hidden in the frame.
	virtual Void onHide() {}

}
