using afIoc
using fwt

internal class ShowHidePanelCommand : RefluxCommand {
	@Inject private Registry	reg
	@Inject private Reflux		reflux
			private Panel 		panel

	new make(Panel panel, |This|in) : super.make(in) {
		this.panel = panel
		this.mode = CommandMode.toggle
		update
	}

	override Void invoked(Event? event) {
		if (panel.isShowing) reflux.hidePanel(panel.typeof); else reflux.showPanel(panel.typeof)
	}

	Void update() {
		this.name 		= panel.name
		this.icon		= panel.icon
		this.selected	= panel.isShowing
	}
}