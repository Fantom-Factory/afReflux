using afIoc
using gfx
using fwt

internal class ToggleViewCommand : GlobalCommand {
	@Inject	private Reflux	reflux

	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdToggleView", in) {
		addEnabler("afReflux.cmdSave", |->Bool| { true } )
	}
	
	override Void onInvoke(Event? event) {
		activeView	:= reflux.activeView
		viewTypes	:= activeView.resource.viewTypes

		i := viewTypes.index(reflux.activeView.typeof) ?: -1
		if (++i >= viewTypes.size) i = 0

		reflux.replaceView(reflux.activeView, viewTypes[i])
	}
}