using afIoc
using gfx
using fwt

abstract class Resource {

	@Inject private const Registry				_registry
	@Inject private const DefaultResourceViews	_defaultViews
	@Inject private Reflux						_reflux
	
	new make(|This|in) { in(this) }
	
	abstract Uri uri()

	abstract Str name()

	virtual Image? icon() { return null }

	virtual Str displayName() { uri.toStr }

	** By populating an existing menu, it allows Panels to create the initial menu. 
	virtual Menu populatePopup(Menu menu) {
		// FIXME:
//		serviceId := this.typeof.qname.replace("::", ".") + ".popupMenu"
//		menuItems := (MenuItem[]?) _registry.buildService(serviceId, false)
//		if (menuItems != null)
//			menu.addAll(menuItems)
		return menu 
	}

//	virtual ToolBar populateToolBar(ToolBar toolBar) { toolBar }
//
	virtual Void doAction() {
		_reflux.load(uri)
	} 
	
	virtual Type? defaultView() {
		_defaultViews[this.typeof]
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

