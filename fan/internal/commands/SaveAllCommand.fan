using afIoc3
using fwt

internal class SaveAllCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
			private Bool	doingIt
	
	new make(|This|in) : super.make("afReflux.cmdSaveAll", in) {
		addEnabler("afReflux.cmdSaveAll", |->Bool| {
			((Frame) reflux.window).dirtyViews.size > 0 
		}, false )
	}
	
	override Void doInvoke(Event? event) {
		if (doingIt) return
		doingIt = true
		try 	reflux.saveAll
		finally doingIt = false
	}

	override Void onViewModified	(View view)	{ update }
}