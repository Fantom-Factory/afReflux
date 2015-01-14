using afIoc
using gfx
using fwt

** Extends the standard 'fwt Command' to ensure errors incurred when invoked are added to the 'ErrorsView'.  
class RefluxCommand : Command {
	@Inject private Errors	_errors
	@Inject private Images	_images
	
	
	** For subclasses
	protected new make(|This|in, Str? name := null, Image? icon := null, |Event event|? onInvoke := null) : super.make(name ?: "", icon, onInvoke) {
		in(this)
	}

	** Create an 'RefluxCommand'. Should be done via IoC:
	** 
	**   registry.autobuild(MyCommand#, ["Command Name", cmdImage])
	@Inject
	new makeViaIoc(Str? name, Image? icon, |Event event|? onInvoke, |This|in) : super.make(name ?: "", icon, onInvoke) {
		in(this)
	}
	
	** Logs the err with the 'Errors' service. 
	override Void onInvokeErr(Event? event, Err err) {
		_errors.add(err)
	}

	@NoDoc	// patching an FWT bug - Errs are swallowed in Event.fire() 
	override Void invoked(Event? event) {
		if (onInvoke.isEmpty) throw UnsupportedErr("Must set onInvoke or override invoke: $name")
		try {
			listeners := (|Event|[]) Slot.findField("fwt::EventListeners.listeners").get(onInvoke)
			listeners.each |cb| {
				if (event?.consumed == true) return
				cb(event)
			}
		} catch (Err err)
			onInvokeErr(event, err)			
	}
	
	** Sets the 'name', 'icon' and 'accelerator' via values in 'en.props'.
	protected Void localise(Pod pod, Str keyBase) {
		plat := Desktop.platform

		// name
		locName := pod.locale("${keyBase}.name.${plat}", null)
		if (locName == null)
			locName = pod.locale("${keyBase}.name", null)
		if (locName != null)
			this.name = locName

		// icon
		locIcon := pod.locale("${keyBase}.icon.${plat}", null)
		if (locIcon == null)
			locIcon = pod.locale("${keyBase}.icon", null)
		if (locIcon != null)
			try {
				this.icon = (locIcon.trimToNull == null) ? null : _images.get(locIcon.toUri, false)
			} catch (Err err)
				_errors.add(Err("Command: cannot load '${keyBase}.icon' => $locIcon", err))
		
		// accelerator
		locAcc := pod.locale("${keyBase}.accelerator.${plat}", null)
		locAccPlat := locAcc != null
		if (locAcc == null)
			locAcc = pod.locale("${keyBase}.accelerator", null)
		if (locAcc != null)
			try {
				this.accelerator = (locAcc.trimToNull == null) ? null : Key.fromStr(locAcc)
			
				// if on a Mac and an explicit .mac prop was not defined,
				// then automatically swizzle Ctrl to Command
				if (!locAccPlat && Desktop.isMac)
					this.accelerator = this.accelerator?.replace(Key.ctrl, Key.command)
			} catch (Err err)
				_errors.add(Err("Command: cannot load '${keyBase}.accelerator ' => $locAcc", err))		
	}
}
