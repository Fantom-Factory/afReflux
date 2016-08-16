using afIoc
using gfx
using fwt

** Panels are widget panes that decorate the edges of the main window.
** Only one instance of each panel type may exist.
** They are (typically) created at application startup and live until the application shuts down.
**
** 'Panel' implementations should be *autobuilt* and contributed to the 'Panels' service:
**
**   syntax: fantom
** 
**   @Contribute { serviceType=Panels# }
**   static Void contributePanels(Configuration config) {
**       config["myPanel"] = config.autobuild(MyPanel#)
**   }
**
** 'Panels' are automatically added to the 'EventHub', so to receive events they only need to implement the required event mixin.
@Js
abstract class Panel {

	@Inject private Log				_log
	@Inject private Registry		_registry
	@Inject private Errors 			_errors
	@Inject private RefluxIcons		_icons
	@Inject private RefluxEvents	_events
	 		internal |->Widget|?	_parentFunc

	** The content displayed in the panel. May be set / re-set at any time.
	Widget? content {
		set {
			_parent := (Widget?) _parentFunc?.call()	// nullable, as content may be set in the ctor
			if (_parent is ContentPane) {
				((ContentPane) _parent).content = it
			} else {
				_parent?.remove(&content)
				_parent?.add(it)
			}
			&content = it
			_parent?.relayout
		}
	}

	** Return this panel's preferred alignment which is used to
	** determine its default position.  Valid values are:
	**   - 'Halign.left' (default)
	**   - 'Halign.right'
	**   - 'Valign.bottom'
	Obj prefAlign := Halign.left

	** As displayed in the panel's tab.
	** If no name is given, it defaults the the Panel's type, minus any 'Panel' suffix.
	Str name := "" {
		set { &name = it; if (content?.parent?.typeof?.qname == "fwt::Tab" || content?.parent?.typeof?.qname == "afReflux::CTab") content.parent->text = it; if (isShowing) this->onModify }
	}

	** As displayed in the panel's tab.
	Image? icon {
		set { &icon = it; if (content?.parent?.typeof?.qname == "fwt::Tab" || content?.parent?.typeof?.qname == "afReflux::CTab") content.parent->image = it; if (isShowing) this->onModify }
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
		this.icon = _icons.get("ico${typeof.name}", false)
	}

	@PostInjection
	private Void _setup(EventHub eventHub) {
		// also see RefluxCommand
		eventHub.register(this, false)
	}

	** Is the panel currently the active tab in the tab pane?
	Bool isActive := false { internal set }

	** Is the panel currently showing in the tab pane?
	Bool isShowing := false { internal set }

	** Callback when this panel is shown in the tab pane.
	virtual Void onShow() {}

	** Callback when this panel is removed from the tab pane.
	virtual Void onHide() {}

	** Callback when this panel is selected as the active tab.
	virtual Void onActivate() {}

	** Callback when this panel is unselected as the active tab.
	virtual Void onDeactivate() {}

	** Callback when panel details are modified, such as the name or icon.
	virtual Void onModify() {}

	** Callback for when the panel should refresh it's contents.
	** Typically, active panels are asked to refresh when the 'refresh' button is clicked.
	**
	** The given resource is a hint as to what's been updated.
	** If 'null' then all content should be refreshed
	virtual Void refresh(Resource? resource := null) {}

	** It is common to handle events from FWT widgets, such as 'onSelect()', but should these throw
	** an Err they are usually just swallowed (or at best traced to std err). To work around it,
	** follow this pattern:
	**
	** pre>
	** class MyPanel : Panel {
	**     new make(|This| in) : super(in) {
	**         content = Tree() { it.onSelect.add |e| { this->onSelect(e) } }
	**     }
	**
	**     private Void onSelect(Event e) {
	**         ...
	**     }
	** }
	** <pre
	**
	** Routing the event to a handler method via '->' calls this 'trap()' method. Should that
	** method return 'Void' and be prefixed with 'onXXX' then any Err thrown is logged with the
	** Errors service.
	**
	** Simple Err handling without fuss!
	override Obj? trap(Str name, Obj?[]? args := null) {
		retVal := null

		// FIXME: see super.trap() in Javascript - http://fantom.org/forum/topic/2457
//		try retVal = super.trap(name, args)
		try retVal = this.typeof.method(name).callOn(this, args)
		catch (Err err) {
			// because we handle the err and return null, we want to make sure we only do it for fwt events
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
				case #onDeactivate.name	: _events.onPanelDeactivated(this)
				case #onModify.name		: _events.onPanelModified(this)
			}

		return retVal
	}
}

