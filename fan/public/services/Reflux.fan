using afIoc
using afIocConfig
using afConcurrent
using gfx
using fwt

** (Service) - 
mixin Reflux {
	
	abstract Registry registry()
	
	abstract Resource? resource()
	abstract Void load(Uri uri)
	abstract Void loadResource(Resource resource)
	abstract Void refresh()
	abstract Bool loadParent()
	
	abstract Window window()
	abstract Panel showPanel(Type panelType)
	abstract Panel hidePanel(Type panelType)
	abstract Void exit()
	
	abstract Void copyToClipboard(Str text)
	
	static Void start(Type[] modules, |Reflux| onOpen) {
		registry := RegistryBuilder().addModules([RefluxModule#, ConfigModule#]).addModules(modules).build.startup
		reflux	 := (Reflux) registry.serviceById(Reflux#.qname)
		frame	 := (Frame)  reflux.window
		
		// onActive -> onFocus -> onOpen
		frame.onOpen.add {
			// Give the widgets a chance to display themselves and set defaults
			Desktop.callLater(50ms) |->| {
				onOpen.call(reflux)
			}
		}

		frame.open
		registry.shutdown
	}
}

internal class RefluxImpl : Reflux {
	@Inject private UriResolvers	uriResolvers
	@Inject private RefluxEvents	refluxEvents
	@Inject override Registry		registry
			override Resource?		resource
//	@Autobuild { implType=Frame# }
			override Window			window

	new make(|This| in) { in(this)
		// FIXME: IoC Err - autobuild builds twice
		window = registry.autobuild(Frame#)
	}

	override Void load(Uri uri) {
		resource = uriResolvers.resolve(uri)
		refluxEvents.onLoad(resource)
	}

	override Void loadResource(Resource resource) {
		refluxEvents.onLoad(resource)
	}

	override Void refresh() {
		if (resource != null)
			refluxEvents.onRefresh(resource)
	}
	
	override Bool loadParent() {
		parent := resource?.uri?.parent
		if (parent != null && parent.pathOnly != `/`) {
			load(parent)
			return true
		}
		return false
	}
	
	@Inject private Panels		panels

	override Panel showPanel(Type panelType) {
		panel := panels.panelMap[panelType]
		
		if (panel.isShowing)
			return panel
		
		frame.showPanel(panel)

		// initialise panel with data
		if (panel is RefluxEvents && resource != null)
			Desktop.callLater(50ms) |->| {
				((RefluxEvents) panel).onLoad(resource)
			}

		return panel
	}

	override Panel hidePanel(Type panelType) {
		panel := panels.panelMap[panelType]
		
		if (!panel.isShowing)
			return panel

		frame.hidePanel(panel)		

		return panel
	}
	
	override Void exit() {
		// TODO: deactivate and hide all panels...? 
		frame.close
	}
	
	override Void copyToClipboard(Str text) {
		Desktop.clipboard.setText(text)
	}

	private Frame frame() {
		window
	}
}
