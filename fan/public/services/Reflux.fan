using afIoc
using afIocConfig
using afConcurrent
using gfx
using fwt

** (Service) - 
class Reflux {
	
	@Inject private UriResolvers	uriResolvers
	@Inject private RefluxEvents	refluxEvents

			private Resource?		resource  
	
	// add event sink?
	
	new make(|This| in) { in(this) }

	Void load(Uri uri) {
		echo("loading $uri")
		resource = uriResolvers.resolve(uri)
		echo("resource $resource.typeof $resource ")
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
	
	static Void start(Type[] modules, |Registry| onOpen) {
		registry	:= RegistryBuilder().addModules([RefluxModule#, ConfigModule#]).addModules(modules).set("frameRef", LocalRef("frame")).build.startup
		frame 		:= (Frame) registry.autobuild(Frame#)
		// onActive -> onFocus -> onOpen
		frame.onOpen.add {
			// maybe move to an event?
			panels := (Panels) registry.dependencyByType(Panels#)
			panels[FoldersPanel#].show	
//			panels[ErrorsPanel#].show

			// Give the widgets a chance to display themselves and set defaults
			Desktop.callLater(50ms) |->| {
				// maybe move this into FoldersPanel, a fav or def folder
				reflux := (Reflux) registry.dependencyByType(Reflux#)
				reflux.load(`file:/C:/Projects/`)
			}
		}

		frame.open
		registry.shutdown
	}
}
