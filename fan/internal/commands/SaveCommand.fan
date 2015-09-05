using afIoc3
using fwt

internal class SaveCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(|This|in) : super.make("afReflux.cmdSave", in) {
		addEnabler("afReflux.cmdSave", |->Bool| { reflux.activeView?.isDirty ?: false }, false )
	}
	
	override Void doInvoke(Event? event) {
		// cmd should only be enabled if dirty
		reflux.activeView?.save
	}

	override Void onViewActivated	(View view) { update }
	override Void onViewDeactivated	(View view) { update } 
	override Void onViewModified	(View view)	{ update }
}