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
		view := resource.defaultView
		
		// TODO: what to do when no view?
		if (view == null)
			return
		
		if (!panelTabs.any { it.panel === view }) {
			// FIXME: use frame.showPanel
			super.addTab(view)
		}			

		super.activate(view)
		view._resource = resource
		view.update(resource)		
	}
}
