using afIoc
using afBeanUtils
using gfx
using fwt

@Js
internal class ViewTabPane : PanelTabPane, RefluxEvents {
	@Inject	private Scope	scope
	@Inject	private Reflux	reflux

	new make(Reflux reflux, |This|in) : super(false, false, in) {
		if (Env.cur.runtime != "js")
			// tabsValign only available in CTabPane
			this.tabPane->tabsValign = reflux.preferences.viewTabsOnTop ? Valign.top : Valign.bottom
	}

	@PostInjection
	private Void setup(EventHub eventHub) {
		eventHub.register(this)
	}

	View[] dirtyViews() {
		panelTabs.findAll { ((View) it.panel).isDirty }.map { it.panel }
	}

	View replaceView(View view, Type viewType) {
		tuple := panelTabs.find { it.panel === view }
		if (tuple == null)
			throw Env.cur.runtime == "js" ? ArgErr("View '${view} not found") : ArgNotFoundErr("View '${view} not found", panelTabs.map { it.panel })

		activate(null)	// deactivate it if its showing
		tuple.panel.isShowing = false
		tuple.panel->onHide

		newView := (View) scope.build(viewType)
		newView._parentFunc = |->Widget| { tuple.tab ?: this }
		tuple.swapPanel(newView)
		if (panelTabs.size == 1) {
			this.content = newView.content
		}

		tuple.panel.isShowing = true
		tuple.panel->onShow

		super.parent.relayout
		super.relayout

		super.activate(tuple.panel)

		return tuple.panel
	}

	Bool closeView(View view, Bool force) {
		// give the view a chance to stay alive - it may have unsaved changes.
		confirmClose := view.confirmClose(force)
		if (confirmClose)
			removeTab(view)
		return confirmClose
	}

	View? load(Resource resource, LoadCtx ctx) {

		// if the resource is already loaded in a view, just activate it
		view := (View?) panelTabs.find { ((View) it.panel).resource == resource }?.panel
		if (view != null && !ctx.newTab) {
			super.activate(view)
			// returning the view would re-load the resource - we just want to switch tabs
			return null
		}

		viewType := ctx.viewType ?: resource.viewTypes.first
		if (viewType == null) {
			this.typeof.pod.log.warn("Resource `${resource.uri}` has no default view")
			return null
		}

		// find any view of the correct type and check for re-use
		// BugFix: Don't use fits() 'cos FandocViewer can't display http resources and tries to convert ALL file resources
		pots := panelTabs.findAll { it.panel.typeof == viewType }
		if (!pots.isEmpty && !ctx.newTab) {
			if (pots.any { it.panel == reflux.activeView } && reflux.activeView.reuseView(resource))
				view = reflux.activeView
			else
				if (((View) pots.first.panel).reuseView(resource))
					view = pots.first.panel
		}

		// create a new View
		if (view == null || ctx.newTab) {
			view = scope.build(viewType)
			super.addTab(view)
		}

		super.activate(view)
		return view
	}
}