using afIoc
using fwt

** (Service) - 
** An eventing strategy.
mixin EventHub {

	abstract Void register(Obj eventSink)

	abstract Void fireEvent(Method method, Obj?[]? args := null)
	
	abstract Void fireEventIn(Duration delay, Method method, Obj?[]? args := null)

}

internal class EventHubImpl : EventHub {
	@Inject private Errors	errors
			private Obj[]	eventSinks	:= [,]
	
	private new make(|This| in) {
		in(this)
	}

	// TODO: save into map of sinks, for optomidation
	override Void register(Obj eventSink) {
		// it's important that Reflux is notified first, so it can set the activeView
		if (eventSink is RefluxImpl)
			eventSinks.insert(0, eventSink)
		else
			eventSinks.add(eventSink)
	}

	override Void fireEvent(Method method, Obj?[]? args := null) {
		sinks := eventSinks.findAll { it.typeof.fits(method.parent) }
		
		sinks.each {
			try	method.callOn(it, args)
			catch (Err err)
				errors.add(err)
		}
	}
	
	override Void fireEventIn(Duration delay, Method method, Obj?[]? args := null) {
		Desktop.callLater(delay) |->| { fireEvent(method, args) }
	}
}
