using afIoc
using gfx
using fwt

internal class NavUpCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux reflux
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdNavUp", in) {
		eventHub.register(this)
		addEnabler("afReflux.cmdNavUp", |->Bool| {
			parent := reflux.activeView?.resource?.uri?.parent
			return parent != null && parent.pathOnly != `/`
		}, false)
	}
	
	override Void doInvoke(Event? event) {
		parent := reflux.activeView?.resource?.uri?.parent
		if (parent != null && parent.pathOnly != `/`)
			reflux.load(parent)
	}
	
	override Void onLoad(Resource resource) { update }
	override Void onViewModified(View view) { update }
}
