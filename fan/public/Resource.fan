using afIoc
using gfx
using fwt

** Resources are navigatable objects that may be represented by an URI, such as files and URLs.
abstract class Resource {

	@Inject private Registry	_registry
	@Inject private Reflux		_reflux
	
	new make(|This|in) { in(this) }
	
	abstract Uri uri()

	abstract Str name()

	virtual Image? icon() { return null }

	virtual Str displayName() { uri.toStr }

	** By populating an existing menu, it allows Panels to create the initial menu. 
	virtual Menu populatePopup(Menu menu) {
		return menu 
	}

	virtual Void doAction() {
		_reflux.load(uri)
	} 
	
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

