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

	** Set to 'true' if the View should re-used for multiple resources.
	Bool reuseView := false
	
	** Returns 'true' if the resource has unsaved change. 
	** 'Views' are responsible for setting this themselves.
	Bool isDirty {
		set {
			if (&isDirty == it) return
			&isDirty = it
			if (it) {
				name = "* ${name}"
			} else {
				if (name.startsWith("* "))
					name = name[2..-1]
			}
			// could call this->onModify() but setting 'name' already does that
		}
	}

	** Callback when the View should load the given resource.
	**  
	** By default this sets the resource, name and icon.
	virtual Void load(Resource resource) {
		this.resource	= resource
		super.icon 		= resource.icon
		super.name 		= resource.name
	}

	** Callback for when the panel should refresh it's contents. 
	** 
	** By default this calls 'load()'. 
	override Void refresh() {
		if (resource != null)
			load(resource)
	} 

	** Callback when the View should save its resource. Only called when 'isDirty' is 'true'.
	**  
	** By default this just clears the dirty flag.
	virtual Void save() {
		isDirty = false
	}
	
	** Callback when the view is being closed. 
	** Return 'false' if the view should be kept open.
	** 
	** By default this returns 'true'.  
	virtual Bool confirmClose() {
		true
	}
}
