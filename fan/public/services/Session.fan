using afIoc

** (Service) - 
** A general dumping ground for data to be saved between applications.
@Js
mixin Session {
	** The session data.
	abstract Str:Obj? data
	
	** The file name of the session data.
	** Defaults to 'sessionData.fog'. 
	abstract Str fileName()
	
	** Loads the session data and fires the 'onLoadSession()' event.
	abstract Void load()
	
	** Fires the 'onSaveSession()' event and saves the session data to file.
	abstract Void save()

}

@NoDoc	@Js	// so others can change the ctor argument
class SessionImpl : Session {
	@Inject private Preferences		preferences
	@Inject private RefluxEvents	events
	@Inject private Errors			errors
	
			override Str:Obj?		data		:= Str:Obj?[:]
	
		override const Str 			fileName
	
	private new make(Str fileName, |This|in) {
		in(this)
		this.fileName = fileName
	}

	override Void load() {
		try {
			file := preferences.findFile("sessionData.fog")
			data = file != null && file.exists ? file.readObj : data
		} catch (Err err)
			errors.add(err)
		
		events.onLoadSession(data)
	}
	
	override Void save() {
		events.onSaveSession(data)

		try	preferences.findFile("sessionData.fog")?.writeObj(data, ["indent":2])
		catch (Err err)
			errors.add(err)
	}
}
