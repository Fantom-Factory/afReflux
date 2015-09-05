using afIoc3
using gfx
using fwt

internal class NavHomeCommand : GlobalCommand {
	@Inject	private Reflux reflux
	
	new make(|This|in) : super.make("afReflux.cmdNavHome", in) {
		this.command.enabled = true
	}
	
	override Void doInvoke(Event? event) {
		reflux.load(reflux.preferences.homeUri.toStr)
	}
}
