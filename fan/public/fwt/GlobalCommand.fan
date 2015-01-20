using afIoc
using gfx
using fwt

** Reusable commands that may be contextually enabled by Views and Panels.
** 
** 'GlobalCommands' must be *autobuilt* by IoC. 
** Contribute 'GlobalCommand' instances to the 'GlobalCommands' service in your 'AppModule':
** 
**   @Contribute { serviceType=GlobalCommands# }
**   static Void contributeGlobalCommands(Configuration config) {
**       config["myGlobCmd"] = config.autobuild(MyGlobalCommand#)
**   }
** 
** Use the contribution Id to access the command in the 'GlobalCommands' service:
** 
**   globalCommands.get("myGlobCmd")
** 
**   globalCommands["myGlobCmd"]
** 
** 'GlobalCommands' are disabled by default. To enable, add an enabler function or enable the fwt command directly. 
** 
** 'GlobalCommands' are automatically added to the 'EventHub', so to receive events they only need to implement the required event mixin.
class GlobalCommand {
	@Inject private RefluxIcons		_refluxIcons
	@Inject private Registry		_registry
	@Inject private EventHub		_eventHub
	
			private Str:|Event?|	_invokers	:= Str:|Event?|[:]
			private Str:|->Bool|	_enablers	:= Str:|->Bool|[:]
			private Str				_baseName
	
	** The wrapped command.
	RefluxCommand	command

	** Creates a global command. The base name is used as a localisation key.
	new make(Str baseName, |This|in) {
		in(this)
		_baseName = baseName
		_eventHub.register(this, false)

		podd := this.typeof.pod.name + "."
		base := baseName.startsWith(podd) ? baseName[podd.size..-1] : baseName
		name := (base.startsWith("cmd") ? base["cmd".size..-1] : base).toDisplayName
		icon := _refluxIcons.get(base, false)
		
		command = _registry.autobuild(RefluxCommand#, [name, icon, |Event? event| { doInvoke(event) } ])
		command.localise(this.typeof.pod, baseName)
		command.enabled = false	// use enablers to switch command on
	}

	** Callback for subclasses. 
	virtual Void doInvoke(Event? event) { }
	
	** Adds a function to be executed when the command is invoked.
	Void addInvoker(Str listenerId, |Event?| listener) {
		_invokers[listenerId] = listener
		command.onInvoke.add(listener)
	}

	** Removes the specified invoker function.
	Void removeInvoker(Str listenerId) {
		listener := _invokers.remove(listenerId)
		command.onInvoke.remove(listener)
	}

	** Adds a function that helps decide if the underlying command should be enabled or not.
	** 
	** If 'update' if 'true' then the underlying command is updated.
	** Defaults to 'true'.
	** 
	** Sometimes an enabler function gives undesirable results (such as IoC recursion errs) when added from a ctor. 
	** If this happens, try setting 'update' to false.  
	Void addEnabler(Str listenerId, |->Bool| listener, Bool update := true) {
		_enablers[listenerId] = listener
		if (update)
			this.update
	}

	** Removes the specified enabler function.
	Void removeEnabler(Str listenerId) {
		listener := _enablers.remove(listenerId)
		update
	}
	
	** Returns if this command is currently enabled or not. 
	** A 'GlobalCommand' is enabled if any enabler function returns true.
	Bool enabled {
		get { _enablers.any { it.call() } }
		private set { }
	}
	
	** Enables / disables the underlying fwt command based on the 'enabled' property.
	virtual Void update() {
		command.enabled = enabled
	}
}
