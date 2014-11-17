using afIoc

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
	
}
