using afIoc
using afBeanUtils
using gfx
using fwt

internal class ViewTabPane : PanelTabPane, RefluxEvents {
	@Inject	Registry	registry
	@Inject	Reflux		reflux
	
	new make(Reflux reflux, |This|in) : super(false, false, in) {
		this.tabPane.tabsValign = reflux.preferences.viewTabsOnTop ? Valign.top : Valign.bottom
	}

	@PostInjection
	private Void setup(EventHub eventHub) {
		eventHub.register(this)
	}

	Void replaceView(View view, Type viewType) {
		tuple := panelTabs.find { it.panel === view }
		if (tuple == null)
			throw ArgNotFoundErr("View '${view} not found", panelTabs.map { it.panel })

		activate(null)	// deactivate it if its showing
		tuple.panel.isShowing = false
		tuple.panel->onHide
		tuple.panel->onModify

		newView := (View) registry.autobuild(viewType) 
		newView._parentFunc = |->Widget| { tuple.tab ?: this }
		tuple.swapPanel(newView)
		if (panelTabs.size == 1) {
			this.content = newView.content
		}
		
		tuple.panel.isShowing = true
		tuple.panel->onShow
		tuple.panel->onModify

		super.parent.relayout
		super.relayout

		super.activate(tuple.panel)
	}
	
	override Void onLoad(Resource resource, LoadCtx ctx) {
		viewType := ctx.viewType ?: resource.viewTypes.first
		
		if (viewType == null) {
			this.typeof.pod.log.warn("Resource `${resource.uri}` has no default view")
			return
		}

		// if the resource is already loaded in the correct viewtype, just activate it 
		pots := panelTabs.findAll { it.panel.typeof.fits(viewType) }
		view := (View?) pots.find { ((View) it.panel).resource == resource }?.panel
		
		// find any view of the correct type and check for re-use
		if (view == null && !pots.isEmpty) {
			
			if (pots.any { it.panel == reflux.activeView } && reflux.activeView.reuseView)
				view = reflux.activeView
			else
				if (((View) pots.first.panel).reuseView)
					view = pots.first.panel
		}
		
		// create a new View
		if (view == null || ctx.newTab) {
			view = registry.autobuild(viewType)			
			super.addTab(view)
		}
		
		super.activate(view)
		view.load(resource)		
	}
}