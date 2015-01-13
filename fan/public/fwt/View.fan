using afIoc

abstract class View : Panel {
	
	@Inject private	Reflux		_reflux
	
	** The resource associated with this view.
	** Set via 'load()'. 
					Resource?	resource

	protected new make(|This| in) : super(in) { }

	Bool dirty {
		set {
			if (&dirty == it) return
			&dirty = it
			if (it) {
				name = "* ${name}"
			} else {
				if (name.startsWith("* "))
					name = name[2..-1]
			}
			// could call this->onModify() but setting 'name' already does that
		}
	}

	** Called to instruct the View to load the given resource.
	**  
	** By default this sets the name and icon of the tab to that of the resource.
	virtual Void load(Resource resource) {
		this.resource	= resource
		super.icon 		= resource.icon
		super.name 		= resource.name
	}

	** Called to instruct the View to save it's resource
	**  
	** By default this clears the dirty flag
	virtual Void save() {
		dirty = false
	}
}
