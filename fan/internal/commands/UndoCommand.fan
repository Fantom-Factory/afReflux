using afIoc
using fwt

internal class UndoCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdUndo", in) {
		eventHub.register(this)
		addEnabler("afReflux.cmdUndo", |->Bool| { !(reflux.activeView?._undoStack?.isEmpty ?: true) }, false )
	}
	
	override Void onInvoke(Event? event) {
		reflux.activeView?.undo
	}

	override Void onViewActivated	(View view) { update }
	override Void onViewDeactivated	(View view) { update } 
	override Void onViewModified	(View view)	{ update }
}