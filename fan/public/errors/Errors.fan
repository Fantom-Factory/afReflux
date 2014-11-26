using afIoc

** (Service) - 
mixin Errors {
	abstract Error[]	errors()
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

