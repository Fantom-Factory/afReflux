using afIoc
using gfx
using fwt

internal class ParentCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux reflux
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdParent", in) {
		eventHub.register(this)
		ignore := true	// recursion err when we use the reflux service 
		addEnabler("adReflux.cmdParent", |->Bool| {
			if (ignore) return false
			parent := reflux.activeView?.resource?.uri?.parent
			return parent != null && parent.pathOnly != `/`
		} )
		ignore = false
	}
	
	override Void onInvoke(Event? event) {
		parent := reflux.activeView?.resource?.uri?.parent
		if (parent != null && parent.pathOnly != `/`)
			reflux.load(parent)
	}
	
	override Void onLoad(Resource resource, LoadCtx ctx) { update }
	override Void onViewModified(View view) { update }
}