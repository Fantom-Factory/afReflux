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
	** The returned strings should be resolvable by 'Reflux'.  
	** 
	** Defaults to empty list.
	virtual Str[] children() { Str#.emptyList }

	** Override to manually resolve children. If 'null' is returned, the child is resolved through Reflux.
	** Overriding this method is an optional optimisation hook.
	virtual Resource? resolveChild(Str childUri) { null }
	
	** Return the parent resource. Root resources should return 'null'. 
	** The returned string should be resolvable by 'Reflux'.  
	** 
	** Used by 'ResourceTree'.
	** 
	** Defaults to 'null'.
	virtual Str? parent() { null }
	
	** If generating child resources is in-efficient, override this method for optimisation.   
	** 
	** Defaults to 'children.size > 0'. 
	virtual Bool hasChildren() { children.size > 0 }
	
	** The Views that may display this resource.
	**
	** Defaults to empty list.
	virtual Type[] viewTypes() { Type#.emptyList }

	** Compares the resource URIs (minus any frags).
	override Bool equals(Obj? that) {
		Url(uri).minusFrag == Url((that as Resource)?.uri).minusFrag
	}

	** Returns a hash of the resource URI (minus any frag).
	override Int hash() {
		Url(uri).minusFrag.hash
	}

	** Returns a comparison of the resource URIs (minus any frags).
	override Int compare(Obj that) {
		uri <=> (that as Resource)?.uri
	}

	@NoDoc
	override Str toStr() { uri.toStr }
}

