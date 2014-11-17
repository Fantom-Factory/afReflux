using afIoc
using afConcurrent

class FluxModule {
	static const LocalRef frameRef := LocalRef("frame")
	
	static Void defineServices(ServiceDefinitions defs) {
		defs.add(EventHub#)
	}
	
	
	@Build
	static Frame buildFrame() {
		frameRef.val
	}
}
