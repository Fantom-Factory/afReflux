using afIoc

** Views are 'Panels' that are associated with an (editable) resource.
** Views are always displayed in the centre of the Window.
abstract class View : Panel {

	@Inject private	Reflux		_reflux
	
	** The resource associated with this view.
	** Set via 'load()'. 
					Resource?	resource

	** Subclasses should define the following ctor:
	**  
	**   new make(|This| in) : super(in) { ... }
	protected new make(|This| in) : super(in) { }

	** Returns 'true' if the resource has unsaved change. 
	** 'Views' are responsible for setting this themselves.
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

	** Called when the 'View' should load the given resource.
	**  
	** This implementation just sets the resource, name and icon.
	virtual Void load(Resource resource) {
		this.resource	= resource
		super.icon 		= resource.icon
		super.name 		= resource.name
	}

	** Called when the View should save its resource.
	**  
	** This implementation just clears the dirty flag.
	virtual Void save() {
		dirty = false
	}
}
