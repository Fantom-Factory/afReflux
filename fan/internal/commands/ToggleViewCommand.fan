using afIoc
using gfx
using fwt

@Js
internal class ToggleViewCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux

	new make(|This|in) : super.make("afReflux.cmdToggleView", in) {
		addEnabler("afReflux.cmdToggleView", |->Bool| { (reflux.activeView?.resource?.viewTypes?.size ?: 0) > 1 }, false )
	}
	
	override Void doInvoke(Event? event) {
		activeView	:= reflux.activeView
		viewTypes	:= activeView.resource.viewTypes

		i := viewTypes.index(reflux.activeView.typeof) ?: -1
		if (++i >= viewTypes.size) i = 0

		reflux.replaceView(reflux.activeView, viewTypes[i])
	}
	
	override Void onViewActivated	(View view) { update }
	override Void onViewDeactivated	(View view) { update } 
	override Void onLoad(Resource resource)		{ update }
}