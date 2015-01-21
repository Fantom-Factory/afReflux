using afIoc
using gfx
using fwt

** Resources are navigatable objects that may be represented by an URI. 
** For example, the Explorer application has a 'FileResource' and a 'HttpResource'.
abstract class Resource {

	** The URI that equates to this resource.
	abstract Uri uri()

	** The full name of this resource.
	abstract Str name()

	** An (optional) icon that represents this resource. 
	virtual Image? icon() { return null }

	** A display name for the resource. 
	** File resources may show their OS specific variant rather than Fantom's canonical URI form. 
	** 
	** Defaults to 'uri.toStr'.
	virtual Str displayName() { Url(uri).minusFrag.toStr }

	** By populating an existing menu, it allows Panels to create the initial menu. 
	virtual Menu populatePopup(Menu menu) {
		return menu 
	}

	** The Views that may display this resource.
	** 
	** Defaults to empty list.
	virtual Type[] viewTypes() {
		[,]
	}
	
	@NoDoc
	override Bool equals(Obj? that) {
		Url(uri).minusFrag == Url((that as Resource)?.uri).minusFrag
	}
	
	@NoDoc
	override Int hash() {
		Url(uri).minusFrag.hash
	}

	@NoDoc
	override Int compare(Obj that) {
		uri <=> (that as Resource)?.uri
	}
	
	@NoDoc
	override Str toStr() { uri.toStr }
}

