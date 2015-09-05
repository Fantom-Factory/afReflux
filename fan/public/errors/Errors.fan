using afIoc3

** (Service) - 
** Maintains a list of errors incurred by the application.
** Errors are displayed in the 'ErrorsPanel'.
** 
** Errors are *not* persisted and are only held in memory. 
mixin Errors {
	
	** The list of errors.
	abstract Error[] errors()
	
	** Adds the given 'Err' to the 'ErrorsPanel' and raises an 'onError' event from 'RefluxEvent'.
	** 
	** If 'skipEventRaising' is 'true' then the error is simply added to the list; 
	** a 'RefluxEvent.onError()' event is *not* raised. 
	abstract Void add(Err err, Bool skipEventRaising := false)
}

internal class ErrorsImpl : Errors {
	@Inject private	RefluxEvents	refluxEvents
			override Error[]		errors	:= Error[,]
			internal Int			nextId	:= 1	
	
	new make(|This|in) { in(this) }
	
	override Void add(Err err, Bool skipEventRaising := false) {
		error := errors.add(Error {
			it.id	= nextId++
			it.err	= err
			it.when	= DateTime.now
		}).last
		
		if (!skipEventRaising)
			refluxEvents.onError(error)
	}
}

