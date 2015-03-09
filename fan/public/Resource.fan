using afIoc
using gfx
using fwt

** Resources are navigatable objects that may be represented by an URI.
** For example, the Explorer application has a 'FileResource' and a 'HttpResource'.
mixin Resource {

	** The URI that equates to this resource.
	abstract Uri uri()

	** The full name of this resource.
	abstract Str name()

	** An (optional) icon that represents this resource.
	virtual Image? icon() { null }

	** A display name for the resource.
	** File resources may show their OS specific variant rather than Fantom's canonical URI form.
	**
	** The display name is displayed in the address bar.
	**
	** Defaults to 'uri.toStr'.
	virtual Str displayName() {
		Url(uri).minusFrag.toStr
	}

	** By populating an existing menu, it allows Panels to create the initial menu.
	virtual Menu populatePopup(Menu menu) { menu }

	** Return child resources. Used by 'ResourceTree'.
	** 
	** Defaults to empty list.
	virtual Resource[] children() { Resource#.emptyList }
	
	** Return the parent resource. Root resources should return 'null'. Used by 'ResourceTree'.
	** 
	** Defaults to 'null'.
	virtual Resource? parent() { null }
	
	** If generating child resources is in-efficient, override this method for optimisation.   
	** 
	** Defaults to 'children.size > 0'. 
	virtual Bool hasChildren() { children.size > 0 }
	
	** The Views that may display this resource.
	**
	** Defaults to empty list.
	virtual Type[] viewTypes() { Type#.emptyList }

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

