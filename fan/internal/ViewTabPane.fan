using afIoc
using gfx
using fwt


internal class ViewTabPane : PanelTabPane, RefluxEvents {
	@Inject	Registry	registry
	
	new make(Reflux reflux, |This|in) : super(false, false, in) {
		this.tabPane.tabsValign = reflux.preferences.viewTabsOnTop ? Valign.top : Valign.bottom
	}

	@PostInjection
	private Void setup(EventHub eventHub) {
		eventHub.register(this)
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
		if (view == null && !pots.isEmpty && ((View) pots.first.panel).reuseView)
			view = pots.first.panel
		
		// create a new View
		if (view == null || ctx.newTab) {
			view = registry.autobuild(viewType)			
			super.addTab(view)
		}
		
		super.activate(view)
		view.load(resource)		
	}
}