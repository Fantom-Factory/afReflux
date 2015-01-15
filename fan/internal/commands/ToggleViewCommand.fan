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
		resource	:= activeView.resource
		viewTypes	:= resource.viewTypes

		i := viewTypes.index(reflux.activeView.typeof) ?: -1
		echo(viewTypes)
		echo("i=$i")
		if (++i >= viewTypes.size) i = 0
		echo("i=$i")

		if (activeView.isDirty)
			activeView.save
		
		reflux.replaceView(reflux.activeView, viewTypes[i])
		reflux.activeView.load(resource)
	}
}