using afIoc
using fwt

internal class NavBackwardCommand : GlobalCommand, RefluxEvents {
	@Inject	private History history
	
	new make(|This|in) : super.make("afReflux.cmdNavBackward", in) {
		addEnabler("afReflux.cmdNavBackward", |->Bool| { history.navBackwardEnabled }, false )
	}
	
	override Void doInvoke(Event? event) {
		history.navBackward
	}
	
	override Void onLoad(Resource resource) { update }
}
