using afIoc
using gfx
using fwt

abstract class Resource {

	@Inject private const Registry				registry
	@Inject private const DefaultResourceViews	defaultViews
	@Inject private Reflux						reflux
	
	new make(|This|in) { in(this) }
	
	abstract Uri uri()

	abstract Str name()

	virtual Image? icon() { return null }

	virtual Str displayName() { uri.toStr }

	** By populating an existing menu, it allows Panels to create the initial menu. 
	virtual Menu populatePopup(Menu menu) {
		serviceId := this.typeof.qname.replace("::", ".") + ".popupMenu"
		menuItems := (MenuItem[]?) registry.buildService(serviceId, false)
		if (menuItems != null)
			menu.addAll(menuItems)
		return menu 
	}

//	virtual ToolBar populateToolBar(ToolBar toolBar) { toolBar }
//
	virtual Void doAction() {
		reflux.load(uri)
	} 
	
	virtual View? defaultView() {
		viewType := defaultViews[this.typeof]
		
		// FIXME: need Views service / holder
		return registry.autobuild(viewType)
	}
	
	@NoDoc
	override Bool equals(Obj? that) {
		uri == (that as Resource)?.uri
	}
	
	@NoDoc
	override Int hash() {
		uri.hash
	}

	@NoDoc
	override Int compare(Obj that) {
		uri <=> (that as Resource)?.uri
	}
	
	@NoDoc
	override Str toStr() { uri.toStr }
}

