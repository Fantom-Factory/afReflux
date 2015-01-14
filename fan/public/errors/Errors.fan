using afIoc

** (Service) - 
** Holds a list of errors incurred by the application.
** These are *not* persisted and are only held in memory. 
mixin Errors {
	abstract Error[]	errors()
	
	** Adds the given 'Err' to the 'ErrorsPanel'.
	abstract Void 		add(Err err)
}

internal class ErrorsImpl : Errors {
	@Inject private	RefluxEvents	refluxEvents
			override Error[]		errors	:= Error[,]
			internal Int			nextId	:= 1	
	
	new make(|This|in) { in(this) }
	
	override Void add(Err err) {
		error := errors.add(Error {
			it.id	= nextId++
			it.err	= err
			it.when	= DateTime.now
		}).last
		refluxEvents.onError(error)
	}
}

