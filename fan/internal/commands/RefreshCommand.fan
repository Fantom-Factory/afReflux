using afIoc
using gfx
using fwt

internal class RefreshCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(|This|in) : super.make("afReflux.cmdRefresh", in) {
		addEnabler("adReflux.cmdRefresh", |->Bool| { true } )
	}
	
	override Void doInvoke(Event? event) {
		reflux.refresh
	}
}