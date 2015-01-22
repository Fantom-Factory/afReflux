using afBeanUtils

@NoDoc
class Panels {
	Panel[] panels
	private Type:Panel panelMap
	
	// Panels need to be created at start so we know what icons and text to use in the Show/Hide commands
	private new make(Panel[] panels) {
		this.panels = panels
		this.panelMap = Type:Panel[:].setList(panels) { it.typeof }
	}
	
	@Operator
	Panel? get(Type panelType, Bool checked := true) {
		panelMap[panelType] ?: (checked ? throw ArgNotFoundErr("Could not find Panel: ${panelType.name}", panelMap.keys) : null)
	}
	
	Type[] panelTypes() {
		panelMap.keys
	}
}
