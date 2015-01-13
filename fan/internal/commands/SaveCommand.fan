using afIoc
using gfx
using fwt

internal class SaveCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
			private View?	view
	
	new make(EventHub eventHub, |This|in) : super.make("afReflux.cmdSave", in) {
		eventHub.register(this)
	}
	
	override Void onInvoke(Event? event) {
		view.save
	}
	
	override Void onViewActivated(View view) {
		this.view = view
		addEnabler("afReflux.cmdSave", |->Bool| { view.dirty } )
	}

	override Void onViewDeactivated(View view) {
		if (this.view == view) {
			this.view = null
			removeEnabler("afReflux.cmdSave")
		}
	}
	
	override Void onViewModified(View view) {
		update
	}
}