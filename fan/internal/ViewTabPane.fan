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

	override Void onLoad(Resource resource) {
		viewType := resource.defaultView
		
		// TODO: what to do when no view?
		if (viewType == null)
			return

		view := (View?) panelTabs.find { it.panel.typeof.fits(viewType) }?.panel
		
		if (view == null) {
			view = registry.autobuild(viewType)			
			super.addTab(view)
		}
		
		super.activate(view)
		view.load(resource)		
	}
}