using afIoc
using gfx
using fwt

internal class RefreshCommand : RefluxCommand, RefluxEvents {
	@Inject	private Reflux reflux
	
	new make(EventHub eventHub, |This|in) : super.make(in) {
		eventHub.register(this)
		enabled = false
	}
	
	override Void invoked(Event? event) {
		reflux.refresh
	}
	
	override Void onLoad(Resource resource)	{
		enabled = true
	}
}