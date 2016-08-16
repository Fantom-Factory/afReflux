using afIoc

** (Service) - 
** Maintains a list of errors incurred by the application.
** Errors are displayed in the 'ErrorsPanel'.
** 
** Errors are *not* persisted and are only held in memory. 
@Js
mixin Errors {
	
	** The list of errors.
	abstract Error[] errors()
	
	** Adds the given 'Err' to the 'ErrorsPanel' and raises an 'onError' event from 'RefluxEvent'.
	** 
	** If 'skipEventRaising' is 'true' then the error is simply added to the list; 
	** a 'RefluxEvent.onError()' event is *not* raised. 
	abstract Void add(Err err, Bool skipEventRaising := false)
}

@Js
internal class ErrorsProxy : Errors {

	@Inject { type=ErrorsImpl# }
	private |->Errors| errorsFunc
	
	new make(|This|in) { in(this) }

	override Error[] errors()									{ errorsFunc().errors() }
	override Void add(Err err, Bool skipEventRaising := false)	{ errorsFunc().add(err, skipEventRaising) }
}

@Js
internal class ErrorsImpl : Errors {
	@Inject private	RefluxEvents	refluxEvents
			override Error[]		errors	:= Error[,]
			private Int				nextId	:= 1
			private	Bool			inErrorHandler
	
	new make(|This|in) { in(this) }
	
	override Void add(Err err, Bool skipEventRaising := false) {
		error := errors.add(Error {
			it.id	= nextId++
			it.err	= err
			it.when	= DateTime.now
		}).last
		
		if (!skipEventRaising && !inErrorHandler) {
			inErrorHandler = true
			try		refluxEvents.onError(error)
			finally	inErrorHandler = false
		}
	}
}
