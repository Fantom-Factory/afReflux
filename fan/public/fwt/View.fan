using afIoc

abstract class View : Panel {
	
	@Inject private  Reflux		_reflux
			internal Resource?	_resource

	protected new make(|This| in) : super(in) { }

	final override Obj prefAlign() { -1 }
	
	override Void onActivate() {
		super.onActivate
		if (_resource != null)
			_reflux.loadResource(_resource)
	}

	virtual Void update(Resource resource) {
		super.icon = resource.icon
		super.name = resource.name
	}
}
