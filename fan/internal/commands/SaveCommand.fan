using afIoc
using gfx
using fwt

internal class SaveCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdSave", in) {
		eventHub.register(this)
		addEnabler("afReflux.cmdSave", |->Bool| { reflux.activeView?.isDirty ?: false }, false )
	}
	
	override Void onInvoke(Event? event) {
		// cmd should only be enabled if dirty
		reflux.activeView?.save
	}

	override Void onViewActivated	(View view) { update }
	override Void onViewDeactivated	(View view) { update } 
	override Void onViewModified	(View view)	{ update }
}