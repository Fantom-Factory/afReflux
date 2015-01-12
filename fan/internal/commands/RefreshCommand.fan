using afIoc
using gfx
using fwt

internal class RefreshCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux reflux
	
	new make(|This|in) : super.make("afReflux.cmdRefresh", in) {
	}
	
	override Void onInvoke(Event? event) {
		reflux.refresh
	}
}