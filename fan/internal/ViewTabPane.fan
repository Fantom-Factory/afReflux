using afIoc
using gfx
using fwt


internal class ViewTabPane : PanelTabPane, RefluxEvents {
	@Inject	Registry	registry
	
	new make(|This|in) : super(false, false, in) { }

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
		view._resource = resource
		view.update(resource)		
	}
}
