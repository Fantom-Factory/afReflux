using afIoc
using gfx
using fwt

abstract class GlobalCommand {
	@Inject private RefluxIcons	_refluxIcons
	@Inject private Registry	_registry
	
	RefluxCommand	command

	new make(Str baseName, |This|in) {
		in(this)

		base := baseName.startsWith("afReflux.") ? baseName["afReflux.".size..-1] : baseName
		name := (base.startsWith("cmd") ? base["cmd".size..-1] : base).toDisplayName
		icon := _refluxIcons[base]
		
		command = _registry.autobuild(RefluxCommand#, [name, icon, |Event? event| { onInvoke(event) } ])
		localise(this.typeof.pod, baseName)
	}
	
	abstract Void onInvoke(Event? event)
	
	Void localise(Pod pod, Str keyBase) {
		command.localise(pod, keyBase)
	}
}
