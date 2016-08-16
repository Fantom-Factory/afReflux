using afIoc
using fwt

@Js
internal class RedoCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(|This|in) : super.make("afReflux.cmdRedo", in) {
		addEnabler("afReflux.cmdRedo", |->Bool| { !(reflux.activeView?._redoStack?.isEmpty ?: true) }, false )
	}
	
	override Void doInvoke(Event? event) {
		reflux.activeView?.redo
	}

	override Void onViewActivated	(View view) { update }
	override Void onViewDeactivated	(View view) { update } 
	override Void onViewModified	(View view)	{ update }
}