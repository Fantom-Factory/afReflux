using afIoc
using gfx
using fwt

@Js
internal class NavUpCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux reflux
	
	new make(|This|in) : super.make("afReflux.cmdNavUp", in) {
		addEnabler("afReflux.cmdNavUp", |->Bool| {
			parent := reflux.activeView?.resource?.uri?.parent
			return parent != null && parent.pathOnly != `/`
		}, false)
	}
	
	override Void doInvoke(Event? event) {
		parent := reflux.activeView?.resource?.uri?.parent
		if (parent != null && parent.pathOnly != `/`)
			reflux.load(parent.toStr)
	}
	
	override Void onLoad(Resource resource) { update }
	override Void onViewModified(View view) { update }
}
