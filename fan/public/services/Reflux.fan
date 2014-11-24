using afIoc
using afIocConfig
using afConcurrent
using gfx
using fwt
using concurrent

** (Service) - 
class Reflux {		
	@Inject private UriResolvers	uriResolvers
	@Inject private RefluxEvents	refluxEvents

			private Resource?		resource  
	
	// add event sink?
	
	new make(|This| in) { in(this) }

	Void load(Uri uri) {
		resource = uriResolvers.resolve(uri)
		refluxEvents.onLoad(resource)
	}

	Void loadResource(Resource resource) {
		refluxEvents.onLoad(resource)
	}

	Void refresh() {
		if (resource != null)
			refluxEvents.onRefresh(resource)
	}
	
	Resource? showing() {
		resource
	}
	

	@Inject private Registry	registry
	@Inject private Panels		panels

	Void showPanel(Type panelType) {
		panel := panels.panelMap[panelType]
		frame := (Frame) registry.serviceById(Frame#.qname)
		frame.showPanel(panel)
	}

	Void hidePanel(Type panelType) {
		panel := panels.panelMap[panelType]
		frame := (Frame) registry.serviceById(Frame#.qname)
		frame.hidePanel(panel)		
	}
	
	static Void start(Type[] modules, |Reflux| onOpen) {
		registry	:= RegistryBuilder().addModules([RefluxModule#, ConfigModule#]).addModules(modules).set("frameRef", LocalRef("frame")).build.startup
		
		// TODO: move to build meth
		frame 		:= (Frame) registry.autobuild(Frame#)
		
		// onActive -> onFocus -> onOpen
		frame.onOpen.add {
			// Give the widgets a chance to display themselves and set defaults
			Desktop.callLater(50ms) |->| {
				reflux := (Reflux) registry.dependencyByType(Reflux#)
				onOpen.call(reflux)
			}
		}

		frame.open
		registry.shutdown
	}
}
