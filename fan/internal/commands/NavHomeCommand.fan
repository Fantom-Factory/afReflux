using afIoc
using gfx
using fwt

internal class NavHomeCommand : GlobalCommand {
	@Inject	private Reflux reflux
	
	new make(|This|in) : super.make("afReflux.cmdNavHome", in) {
		addEnabler("afReflux.cmdNavHome") |->Bool| { true }
	}
	
	override Void doInvoke(Event? event) {
		reflux.load(reflux.preferences.homeUri)
	}
}
