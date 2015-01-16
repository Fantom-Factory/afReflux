using afIoc
using gfx
using fwt

internal class NavHomeCommand : GlobalCommand {
	@Inject	private Reflux reflux
	
	new make(|This|in) : super.make("afReflux.cmdNavHome", in) {
		addEnabler("afReflux.cmdNavHome") |->Bool| { true }
	}
	
	override Void onInvoke(Event? event) {
		// FIXME: set home in prefs
		reflux.load(`file:/C:/Projects/`)
	}
}
