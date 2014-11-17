using afIoc
using afBeanUtils

class EventHub {
	@Inject private Errors	errors
			private Obj[]	eventSinks	:= [,]
	
	new make(|This| in) { in(this) }

	// TODO: save into map of sinks, for optomidation
	Void register(Obj eventSink) {
		eventSinks.add(eventSink)
	}

	Void fireEvent(Method method, Obj?[] args) {
		sinks := eventSinks.findAll { it.typeof.fits(method.parent) }
		
		sinks.each {
			try	method.callOn(it, args)
			catch (Err err)
				errors.add(err)
		}
	}
}
