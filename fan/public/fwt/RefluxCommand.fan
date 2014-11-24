using afIoc
using gfx
using fwt

class RefluxCommand : Command {
	@Inject private Errors? 	_errors
	@Inject private RefluxIcons	_refluxIcons
	@Inject private ImageSource	_imgSrc
	
	new make(|This|in) : super.make("reflux", null) {
		in(this)

		baseName := typeof.name.endsWith("Command") ? typeof.name[0..<-"Command".size] : typeof.name
		this.name = baseName.toDisplayName
		this.icon = _refluxIcons["cmd${baseName}"]
	}
	
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
	
	protected Void localise(Pod pod, Str keyBase) {
		plat := Desktop.platform

		// name
		name := pod.locale("${keyBase}.name.${plat}", null)
		if (name == null)
			name = pod.locale("${keyBase}.name")
		this.name = name

		// icon
		locIcon := pod.locale("${keyBase}.icon.${plat}", null)
		if (locIcon == null)
			locIcon = pod.locale("${keyBase}.icon", null)
		try {
			if (locIcon != null)
				this.icon = _imgSrc.get(locIcon.toUri, false)
		} catch
			_errors.add(Err("Command: cannot load '${keyBase}.icon' => $locIcon"))
		
		// accelerator
		locAcc := pod.locale("${keyBase}.accelerator.${plat}", null)
		locAccPlat := locAcc != null
		if (locAcc == null)
			locAcc = pod.locale("${keyBase}.accelerator", null)
		try {
			if (locAcc != null) {
			this.accelerator = Key.fromStr(locAcc)
		
			// if on a Mac and an explicit .mac prop was not defined,
			// then automatically swizzle Ctrl to Command
			if (!locAccPlat && Desktop.isMac)
				this.accelerator = this.accelerator.replace(Key.ctrl, Key.command)
			}
		} catch
			_errors.add(Err("Command: cannot load '${keyBase}.accelerator ' => $locAcc"))		
	}
}
