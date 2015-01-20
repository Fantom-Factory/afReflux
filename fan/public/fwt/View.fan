using afIoc

** Views are 'Panels' that are associated with an (editable) resource.
** 
** For a 'View' to be displayed, a 'Resource' must list it as one of its 'viewTypes()'.
abstract class View : Panel {
	@Inject private		Reflux			_reflux
	@Inject private		Errors			_errors
	@Inject private 	RefluxEvents	_events
			internal	UndoRedo[]		_undoStack	:= UndoRedo[,]
			internal	UndoRedo[]		_redoStack	:= UndoRedo[,]
	
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
		if (isDirty)
			confirmClose(true)
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
	** Note: If 'force' is 'true' then the view **will** close regardless of the return value.
	** 
	** By default this returns 'true'.  
	virtual Bool confirmClose(Bool force) {
		true
	}
	
	** Add a pair of Undo / Redo commands.
	Void addUndoRedo(|->| undo, |->| redo) {
		// cap the history at something large but reasonable
		if (_undoStack.size > 999)
			_undoStack.size = 999

		_undoStack.add(UndoRedo { 
			it.undo = undo
			it.redo = redo
		})
		
		// you can't return to the same future once you've changed the past!
		_redoStack.clear
		_events.onViewModified(this)
	}
	
	** Undoes the last command.
	Void undo() {
		undoRedo := _undoStack.pop
		if (undoRedo == null) return
		
		try	undoRedo.undo.call()
		catch (Err err)
			_errors.add(err)
		
		_redoStack.push(undoRedo)
		_events.onViewModified(this)
	}
	
	** Redoes the last command.
	Void redo() {
		undoRedo := _redoStack.pop
		if (undoRedo == null) return
		
		try	undoRedo.redo.call()
		catch (Err err)
			_errors.add(err)
		
		_undoStack.push(undoRedo)		
		_events.onViewModified(this)
	}
}

internal class UndoRedo {
	|->| undo
	|->| redo
	new make(|This|f) { f(this) }
}