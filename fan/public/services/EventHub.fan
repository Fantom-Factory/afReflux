using afBeanUtils
using afIoc
using fwt

** (Service) - 
** An eventing strategy.
** 
** Eventing is *opt-in*.
** 
** panels, views, glob cmds are auto added, everythign else is opt in
mixin EventHub {

	** Registers an object to receive events. 
	abstract Void register(Obj eventSink, Bool checked := true)

	abstract Void fireEvent(Method method, Obj?[]? args := null)
	
	abstract Void fireEventIn(Duration delay, Method method, Obj?[]? args := null)

}

internal class EventHubImpl : EventHub {
	@Inject private EventTypes	eventTypes
	@Inject private Errors		errors
			private Obj[]		eventSinks	:= [,]
	
	private new make(|This| in) {
		in(this)
	}

	// TODO: save into map of sinks, for optomidation
	override Void register(Obj eventSink, Bool checked := true) {
		if (!eventTypes.eventTypes.any { eventSink.typeof.fits(it) })
			if (checked) throw ArgNotFoundErr("EventSink ${eventSink.typeof} does not implement a contributed EventType", eventTypes.eventTypes); else return

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
