using afIoc3
using fwt

@Js
internal class UndoCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(|This|in) : super.make("afReflux.cmdUndo", in) {
		addEnabler("afReflux.cmdUndo", |->Bool| { !(reflux.activeView?._undoStack?.isEmpty ?: true) }, false )
	}
	
	override Void doInvoke(Event? event) {
		reflux.activeView?.undo
	}

	override Void onViewActivated	(View view) { update }
	override Void onViewDeactivated	(View view) { update } 
	override Void onViewModified	(View view)	{ update }
}