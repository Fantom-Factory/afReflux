using afIoc3
using fwt

@Js
internal class ShowHidePanelCommand : RefluxCommand, RefluxEvents {
	@Inject private Registry	reg
	@Inject private Reflux		reflux
			private Panel 		panel

	new make(Panel panel, |This|in) : super.make(in) {
		this.panel = panel
		this.mode = CommandMode.toggle
		onPanelModified(panel)
	}

	override Void doInvoke(Event? event) {
		if (this.selected) reflux.showPanel(panel.typeof); else reflux.hidePanel(panel.typeof)
	}

	override Void onPanelModified(Panel panel) {
		if (this.panel == panel) {
			this.name 		= panel.name
			this.icon		= panel.icon
			this.selected	= panel.isShowing
		}
	}
	
	override Void onPanelShown	(Panel panel) { if (panel == this.panel) update }
	override Void onPanelHidden	(Panel panel) { if (panel == this.panel) update }

	private Void update() {
		this.selected = panel.isShowing
	}
}