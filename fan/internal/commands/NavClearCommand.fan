using afIoc3
using fwt

@Js
internal class NavClearCommand : GlobalCommand, RefluxEvents {
	@Inject	private History history
	
	new make(|This|in) : super.make("afReflux.cmdNavClear", in) {
		addEnabler("afReflux.cmdNavClear", |->Bool| { !history.history.isEmpty }, false )
	}
	
	override Void doInvoke(Event? event) {
		history.clear
		update
	}
	
	override Void onLoad(Resource resource) { update }
}
