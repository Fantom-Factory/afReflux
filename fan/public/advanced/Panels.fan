
@NoDoc
class Panels {
	Panel[] panels
	Type:Panel panelMap
	
	new make(Panel[] panels) {
		this.panels = panels
		// FIXME! cannot add multiple panels of same type
		this.panelMap = Type:Panel[:].setList(panels) { it.typeof }
	}
	
	@Operator
	Panel? get(Type panelType) {
		panelMap[panelType]
	}
}
