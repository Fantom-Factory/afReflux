using afIoc

** (Service) - 
class Errors {	
	@Inject private	RefluxEvents	refluxEvents
			internal Error[]		errors	:= Error[,]
			internal Int			nextId	:= 1	
	
	new make(|This|in) { in(this) }
	
	Void add(Err err) {
		error := errors.add(Error {
			it.id	= nextId++
			it.err	= err
			it.when	= DateTime.now
		}).last
		refluxEvents.onError(error)
	}
}

