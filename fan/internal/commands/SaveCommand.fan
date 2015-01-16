using afIoc
using gfx
using fwt

internal class SaveCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdSave", in) {
		eventHub.register(this)
	}
	
	override Void onInvoke(Event? event) {
		// should actually on be enabled if dirty, but better safe than sorry
		if (reflux.activeView.isDirty)
			reflux.activeView.save
	}
	
	override Void onViewActivated(View view) {
		addEnabler("afReflux.cmdSave", |->Bool| { reflux.activeView?.isDirty ?: false} )
	}

	override Void onViewDeactivated(View view) {
		removeEnabler("afReflux.cmdSave")
	}
	
	override Void onViewModified(View view) {
		update
	}
}