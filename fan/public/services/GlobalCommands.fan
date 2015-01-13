using afBeanUtils

class GlobalCommands {
	
	Str:GlobalCommand cmds
	
	new make(Str:GlobalCommand cmds) {
		this.cmds = cmds
	}
	
	@Operator
	GlobalCommand get(Str cmdId) {
		cmds[cmdId] ?: throw ArgNotFoundErr("Could not find a GlobalCommand with Id '${cmdId}'", cmds.keys)
	}
}
