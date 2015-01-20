using afIoc
using gfx
using fwt

** Resources are navigatable objects that may be represented by an URI. 
** For example, the Explorer application has a 'FileResource' and a 'HttpResource'.
abstract class Resource {

	@Inject private Registry	_registry
	@Inject private Reflux		_reflux
	
	** Resources should be built by IoC:
	** 
	**   registry.autobuild(MyResource#)
	new make(|This|in) { in(this) }
	
	** The URI that equates to this resource.
	abstract Uri uri()

	** The full name of this resource.
	abstract Str name()

	** An (optional) icon that represents this resource. 
	virtual Image? icon() { return null }

	** A display name for the resource. 
	** 
	** Defaults to 'uri.toStr'.
	virtual Str displayName() { uri.toStr }

	** By populating an existing menu, it allows Panels to create the initial menu. 
	virtual Menu populatePopup(Menu menu) {
		return menu 
	}

	** The default action this resource should perform if selected. 
	** By default it loads itself.
	virtual Void doAction() {
		_reflux.loadResource(this)
	} 
	
	** The Views that may display this resource.
	** 
	** Defaults to empty list.
	virtual Type[] viewTypes() {
		[,]
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

