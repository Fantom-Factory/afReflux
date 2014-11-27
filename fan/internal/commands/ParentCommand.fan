using afIoc
using gfx
using fwt

internal class ParentCommand : RefluxCommand, RefluxEvents {
	@Inject	private Reflux reflux
	
	new make(EventHub eventHub, |This|in) : super.make(in) {
		eventHub.register(this)
		this.name = "Up Folder"
	}
	
	override Void invoked(Event? event) {
		reflux.loadParent
	}
	
	override Void onLoad(Resource resource)	{
		parent := resource.uri.parent
		enabled = parent != null && parent.pathOnly != `/`
	}
}