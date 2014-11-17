using afIoc
using gfx
using fwt

abstract class Panel {

	@Inject private Registry?		_registry
	@Inject private Frame? 			_frame
	@Inject private Errors? 		_errors
	@Inject private RefluxIcons?	_icons
			private RefluxCommand?	_showHideCommand
			internal Tab?			_tab

	Widget? content {
		set { _tab?.remove(&content); _tab?.add(it); &content = it }
	}
	
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
	private Void setup(EventHub eventHub) {
		eventHub.register(this)
	}
	
	** Return this sidebar's preferred alignment which is used to
	** determine its default position.  Valid values are:
	**   - Halign.left (default)
	**   - Halign.right
	**   - Valign.bottom
	**   - Valign.center
	virtual Obj prefAlign() { return Halign.left }
	
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
	
	This show() {
		_frame.showPanel(this)
	}
	
	This hide() {
		_frame.hidePanel(this)
	}
	
	override Obj? trap(Str name, Obj?[]? args := null) {
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
