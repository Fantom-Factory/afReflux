using afIoc
using fwt

internal class NavBackwardCommand : GlobalCommand, RefluxEvents {
	@Inject	private History history
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdNavBackward", in) {
		eventHub.register(this)
		addEnabler("afReflux.cmdNavBackward", |->Bool| { history.navBackwardEnabled }, false )
	}
	
	override Void doInvoke(Event? event) {
		history.navBackward
	}
	
	override Void onViewActivated	(View view) { update }
	override Void onViewDeactivated	(View view) { update } 
}
