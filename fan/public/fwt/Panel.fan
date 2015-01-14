using afIoc
using gfx
using fwt

// maybe created at application startup. Instances are cached / reused.
** Panels are displayed in the main Window. 
abstract class Panel {

	@Inject private Log				_log
	@Inject private Registry		_registry
	@Inject private Errors 			_errors
	@Inject private RefluxIcons		_icons
	@Inject private RefluxEvents	_events
			internal CTab?			_tab

	** The content displayed in the panel. May be set / re-set at any time.
	Widget? content {
		set { _tab?.remove(&content); _tab?.add(it); &content = it }
	}
	
	** Return this sidebar's preferred alignment which is used to
	** determine its default position.  Valid values are:
	**   - 'Halign.left' (default)
	**   - 'Halign.right'
	**   - 'Valign.bottom'
	Obj prefAlign := Halign.left

	** As displayed in the panel's tab.
	Str name := "" {
		set { &name = it; if (_tab != null) _tab.text = it; this->onModify }
	}

	** As displayed in the panel's tab.
	Image? icon {
		set { &icon = it; if (_tab != null) _tab.image = it; this->onModify }
	}
	
	** Subclasses should define the following ctor:
	**  
	**   new make(|This| in) : super(in) { ... }
	new make(|This| in) {
		in(this)
		
		baseName := typeof.name
		if (baseName.endsWith("Panel"))
			baseName = baseName[0..<-"Panel".size]
		if (baseName.endsWith("View"))
			baseName = baseName[0..<-"View".size]

		this.name = baseName.toDisplayName
		this.icon = _icons["ico${typeof.name}"]
	}

	@PostInjection
	private Void _setup(EventHub eventHub) {
		eventHub.register(this)
	}
	
	** Is the panel currently the active tab?
	Bool isActive := false { internal set }

	** Is the panel currently showing in the frame?
	Bool isShowing := false { internal set }

	** Callback when this panel is created.
	virtual Void onShow() {}

	** Callback when this panel is closed.
	virtual Void onHide() {}
	
	** Callback when this panel is selected as the active tab.
	virtual Void onActivate() {}

	** Callback when this panel is unselected as the active tab.
	virtual Void onDeactivate() {}

	** Callback when panel details are modified, such as the name or icon. 
	virtual Void onModify() {}
	
	// TODO: explain how to use!
	override Obj? trap(Str name, Obj?[]? args := null) {
		if (name.startsWith("on"))
			_log.debug("${name} - $this")

		retVal := null
		try retVal = super.trap(name, args)
		catch(Err err) {
			if (name.startsWith("on") && typeof.method(name, false)?.returns == Void#) {
				_errors.add(err)
				return null
			}
			else throw err
		}

		if (this is View)
			switch (name) {
				case #onShow.name		: _events.onViewShown(this)
				case #onHide.name		: _events.onViewHidden(this)
				case #onActivate.name	: _events.onViewActivated(this)
				case #onDeactivate.name	: _events.onViewDeactivated(this)
				case #onModify.name		: _events.onViewModified(this)
			}
		else
			switch (name) {
				case #onShow.name		: _events.onPanelShown(this)
				case #onHide.name		: _events.onPanelHidden(this)
				case #onActivate.name	: _events.onPanelActivated(this)
				case #onModify.name		: _events.onPanelModified(this)
			}
		
		return retVal
	}

}
