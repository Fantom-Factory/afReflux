using fwt

internal class ShowHidePanelCommand : RefluxCommand {
	private Panel panel

	new make(Panel panel, |This|in) : super.make(in) {
		this.panel = panel
		this.mode = CommandMode.toggle
		update
	}

	override Void invoked(Event? event) {
		if (panel.isShowing) panel.hide; else panel.show
	}

	Void update() {
		this.name 		= panel.name
		this.icon		= panel.icon
		this.selected	= panel.isShowing
	}
}