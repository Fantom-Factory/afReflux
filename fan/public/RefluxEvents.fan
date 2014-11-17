
mixin RefluxEvents {

	// TODO: virtual Void onAppStartup() 	{ }
	// TODO: virtual Void onAppShutdown() 	{ }
	virtual Void onLoad(Resource resource)	{ }

	virtual Void onRefresh(Resource resource) {
		onLoad(resource)
	}
	
	virtual Void onError(Error error)	{ }

}

//FIXME: make am injectale plastic version!
// private RefluxEvents fireRefluxEvent
//
//   fireRefluxEvent.onLoad(file)
class RefluxEventsImpl : RefluxEvents {

	EventHub eventHub
	
	new make(EventHub eventHub) {
		this.eventHub = eventHub
	}
	
	override Void onLoad(Resource resource)	{
		eventHub.fireEvent(RefluxEvents#onLoad, [resource])
	}
	
	override Void onRefresh(Resource resource)	{
		eventHub.fireEvent(RefluxEvents#onRefresh, [resource])
	}
	
	override Void onError(Error error)	{
		eventHub.fireEvent(RefluxEvents#onError, [error])
	}
	
}