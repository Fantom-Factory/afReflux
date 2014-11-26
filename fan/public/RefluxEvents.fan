
mixin RefluxEvents {

	// TODO: virtual Void onAppStartup() 	{ }
	// TODO: virtual Void onAppShutdown() 	{ }
	virtual Void onLoad(Resource resource)	{ }

	virtual Void onRefresh(Resource resource) {
		onLoad(resource)
	}
	
	virtual Void onError(Error error)	{ }

}
