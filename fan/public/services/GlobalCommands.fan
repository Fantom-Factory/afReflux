using afBeanUtils

** (Service) -
** Maintains and provides access to 'GlobalCommand' instances.
@Js
mixin GlobalCommands {
	
	** Returns the command that was contributed with the given id.
	** 
	**   syntax: fantom
	**   myCmd := globalCommands.get("myCmd")
	** 
	**   myCmd := globalCommands["myCmd"]
	@Operator
	abstract GlobalCommand get(Str id)
}

@Js
internal class GlobalCommandsImpl : GlobalCommands {
	
	Str:GlobalCommand cmds
	
	new make(Str:GlobalCommand cmds) {
		this.cmds = cmds
	}
	
	override GlobalCommand get(Str cmdId) {
		cmds[cmdId] ?: throw ArgNotFoundErr("Could not find a GlobalCommand with Id '${cmdId}'", cmds.keys)
	}
}
