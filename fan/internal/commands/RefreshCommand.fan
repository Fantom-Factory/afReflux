using afIoc
using gfx
using fwt

@Js
internal class RefreshCommand : GlobalCommand, RefluxEvents {
	@Inject	private Reflux	reflux
	
	new make(|This|in) : super.make("afReflux.cmdRefresh", in) {
		this.command.enabled = true
	}
	
	override Void doInvoke(Event? event) {
		reflux.refresh
	}
}