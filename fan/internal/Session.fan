using afIoc

** (Service) - 
** A general dumping ground for data to be saved between applications.
class Session {
	@Inject private Preferences		preferences
	@Inject private RefluxEvents	events
	@Inject private Errors			errors
	
	** The session data.
					Str:Obj?		data		:= Str:Obj?[:]
	
	** The file name of the session data 
				const Str 			fileName	:= "sessionData.fog"
	
	private new make(|This|in) { in(this) }

	** Loads the session data and fires the 'onLoadSession()' event.
	Void load() {
		try {
			file := preferences.findFile("sessionData.fog")
			data = file.exists ? file.readObj : data
		} catch (Err err)
			errors.add(err)
		
		events.onLoadSession(data)
	}
	
	** Fires the 'onSaveSession()' event and saves the session data to file.
	Void save() {
		events.onSaveSession(data)

		try	preferences.findFile("sessionData.fog").writeObj(data, ["indent":2])
		catch (Err err)
			errors.add(err)
	}
}
