using afIoc

class PrefsCache {
	private static const Log 	log 	:= PrefsCache#.pod.log
	private Type:CachedPrefs	cache	:= Type:CachedPrefs[:]
	@Inject private Registry	registry
	
	new make(|This| in) { in(this) }
		
	Obj loadPrefs(Type prefsType, Str name := prefsType.name) {
		cached	:= loadFromCache(prefsType)
		
		if (cached != null) {
			log.debug("Returning cached $prefsType.name $cached")
			return cached
		}

		file	:= toFile(prefsType, name)
		prefs 	:= loadFromFile(file)

		if (prefs == null) {
			log.info("Making preferences: $prefsType.name")
			prefs = registry.autobuild(prefsType)
		}

		cache[prefsType] = CachedPrefs(file, prefs)
		
		return prefs
	}

	Void savePrefs(Obj prefs, Str name := prefs.typeof.name) {
		if (runtimeIsJs) {
			log.info("Cannot save $name in JS")
			return 
		}
		file := toFile(prefs.typeof, name)
		file.writeObj(prefs, ["indent":2])
	}
	
	Bool updated(Type prefsType) {
		((CachedPrefs?) cache[prefsType])?.modified ?: true
	}
	
	static File? toFile(Type prefsType, Str name := prefsType.name) {
		pathUri := `etc/${prefsType.pod.name}/${name}`
		if (runtimeIsJs) {
			log.info("File $pathUri does not exist in JS")
			return null
		}
		
		envFile := Env.cur.findFile(pathUri, false) ?: File(pathUri)
		return envFile.normalize	// normalize gives the full absolute path
	}
	
	// ---- Private -------------------------------------------------------------------------------

	private Obj? loadFromCache(Type prefsType) {
		cached 		:= (CachedPrefs?) cache[prefsType]
		modified 	:= cached?.modified ?: true
		return modified ? null : cached.prefs
	}
	
	private Obj? loadFromFile(File? file) {
		Obj? value := null
		try {
			if (file != null && file.exists) {
				log.info("Loading preferences: $file")
				value = file.readObj
			}
		} catch (Err e) {
			log.err("Cannot load options: $file", e)
		}
		return value
	}
	
	private static Bool runtimeIsJs() {
		Env.cur.runtime == "js"
	}
}

internal class CachedPrefs {
  	private File? 		file
  	private DateTime? 	modied
  			Obj 		prefs

	new make(File? f, Obj prefs) {
		this.file 	= f
		this.modied	= f?.modified
		this.prefs 	= prefs
  	}
	
	Bool modified() {
		if (file == null)
			return false
		return file.modified != modied
	}
}
