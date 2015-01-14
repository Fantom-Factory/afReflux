using afIoc
using gfx
using fwt

** Provides an abstraction layer for reusable commands by de-coupling the creation and invocation.
class GlobalCommand {
	@Inject private RefluxIcons		_refluxIcons
	@Inject private Registry		_registry
	
			private Str:|Event?|	_invokers	:= Str:|Event?|[:]
			private Str:|->Bool|	_enablers	:= Str:|->Bool|[:]
			private Str				_baseName
	
	RefluxCommand	command

	new make(Str baseName, |This|in) {
		in(this)
		this._baseName = baseName

		podd := this.typeof.pod.name + "."
		base := baseName.startsWith(podd) ? baseName[podd.size..-1] : baseName
		name := (base.startsWith("cmd") ? base["cmd".size..-1] : base).toDisplayName
		icon := _refluxIcons[base]
		
		command = _registry.autobuild(RefluxCommand#, [name, icon, |Event? event| { onInvoke(event) } ])
		command.localise(this.typeof.pod, baseName)
		update
	}

	virtual Void onInvoke(Event? event) { }
	
	Void addInvoker(Str listenerId, |Event?| listener) {
		_invokers[listenerId] = listener
		command.onInvoke.add(listener)
	}

	Void removeInvoker(Str listenerId) {
		listener := _invokers.remove(listenerId)
		command.onInvoke.remove(listener)
	}

	Void addEnabler(Str listenerId, |->Bool| listener) {
		_enablers[listenerId] = listener
		update
	}

	Void removeEnabler(Str listenerId) {
		listener := _enablers.remove(listenerId)
		update
	}
	
	Bool enabled {
		get { _enablers.any { it.call() } }
		private set { }
	}
	
	Void update() {
		command.enabled = enabled
	}
}
