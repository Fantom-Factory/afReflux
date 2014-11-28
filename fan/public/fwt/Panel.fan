using afIoc
using gfx
using fwt

abstract class Panel {

	@Inject private Log				_log
	@Inject private Registry		_registry
	@Inject private Errors 			_errors
	@Inject private RefluxIcons		_icons
	@Inject private RefluxEvents	_events
			private RefluxCommand?	_showHideCommand
			internal CTab?			_tab

	Widget? content {
		set { _tab?.remove(&content); _tab?.add(it); &content = it }
	}
	
	** Return this sidebar's preferred alignment which is used to
	** determine its default position.  Valid values are:
	**   - Halign.left (default)
	**   - Halign.right
	**   - Valign.bottom
	Obj prefAlign := Halign.left

	Str name := "" {
		set { &name = it; if (_tab != null) _tab.text = it; showHideCommand.update }
	}

	Image? icon {
		set { &icon = it; if (_tab != null) _tab.image = it; showHideCommand.update }
	}
	
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
	
	** Callback when this panel is shown.
	virtual Void onShow() {}

	** Callback when this panel is hidden.
	virtual Void onHide() {}
	
	** Callback when this panel is selected as the active tab.
	virtual Void onActivate() {}

	** Callback when this panel is unselected as the active tab.
	virtual Void onDeactivate() {}
	
	override Obj? trap(Str name, Obj?[]? args := null) {
		if (this is View)
			switch (name) {
				case #onShow.name		: _events.onShowView(this)
				case #onHide.name		: _events.onHideView(this)
				case #onActivate.name	: _events.onActivateView(this)
				case #onDeactivate.name	: _events.onDeactivateView(this)
			}
		else
			switch (name) {
				case #onShow.name		: _events.onShowPanel(this)
				case #onHide.name		: _events.onHidePanel(this)
				case #onActivate.name	: _events.onActivatePanel(this)
				case #onDeactivate.name	: _events.onDeactivatePanel(this)
			}
		
		if (name.startsWith("on"))
			_log.debug("${name} - $this")

		try return super.trap(name, args)
		catch(Err err) {
			if (name.startsWith("on") && typeof.method(name, false)?.returns == Void#) {
				_errors.add(err)
				return null
			}
			else throw err
		}
	}

	internal ShowHidePanelCommand showHideCommand() {
		if (_showHideCommand != null)
			return _showHideCommand
		_showHideCommand = _registry.autobuild(ShowHidePanelCommand#, [this])
		return _showHideCommand
	}
}
