using afIoc3
using fwt

internal class NavForwardCommand : GlobalCommand, RefluxEvents {
	@Inject	private History history
	
	new make(|This|in) : super.make("afReflux.cmdNavForward", in) {
		addEnabler("afReflux.cmdNavForward", |->Bool| { history.navForwardEnabled }, false )
	}
	
	override Void doInvoke(Event? event) {
		history.navForward
	}
	
	override Void onLoad(Resource resource) { update }
}
