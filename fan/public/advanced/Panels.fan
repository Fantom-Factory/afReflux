
@NoDoc
class Panels {
	Panel[] panels
	Type:Panel panelMap
	
	// Panels need to be created at start so we know what icons and text to use in the Show/Hide commands
	new make(Panel[] panels) {
		this.panels = panels
		this.panelMap = Type:Panel[:].setList(panels) { it.typeof }
	}	
}
