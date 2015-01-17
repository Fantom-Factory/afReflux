using afBeanUtils

@NoDoc	// Don't overwhelm the masses!
mixin GlobalCommands {
	
	@Operator
	abstract GlobalCommand get(Str cmdId)
}

internal class GlobalCommandsImpl : GlobalCommands {
	
	Str:GlobalCommand cmds
	
	new make(Str:GlobalCommand cmds) {
		this.cmds = cmds
	}
	
	override GlobalCommand get(Str cmdId) {
		cmds[cmdId] ?: throw ArgNotFoundErr("Could not find a GlobalCommand with Id '${cmdId}'", cmds.keys)
	}
}
