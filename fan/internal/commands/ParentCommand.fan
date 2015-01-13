using afIoc
using gfx
using fwt

internal class ParentCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux reflux
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdParent", in) {
		eventHub.register(this)
		addEnabler("adReflux.cmdParent", |->Bool| { true } )
	}
	
	override Void onInvoke(Event? event) {
		reflux.loadParent
	}
	
	override Void onLoad(Resource resource)	{
		parent := resource.uri.parent
		command.enabled = parent != null && parent.pathOnly != `/`
	}
}