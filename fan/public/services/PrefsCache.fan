using afIoc
using afIocConfig

class PrefsCache {
			private static const Log 	log 	:= PrefsCache#.pod.log
			private Type:CachedPrefs	cache	:= Type:CachedPrefs[:]
	@Inject private Registry			registry
	@Inject @Config private Str			appTitle
	
	new make(|This| in) { in(this) }
		
	Obj loadPrefs(Type prefsType, Str name := "${prefsType.name}.fog") {
		cached	:= loadFromCache(prefsType)
		
		if (cached != null) {
			log.debug("Returning cached $prefsType.name $cached")
			return cached
		}

		file	:= toFile(prefsType, name)
		prefs 	:= loadFromFile(file)

		if (prefs == null) {
			log.debug("Making preferences: $prefsType.name")
			prefs = registry.autobuild(prefsType)
		}

		cache[prefsType] = CachedPrefs(file, prefs)
		
		return prefs
	}

	Void savePrefs(Obj prefs, Str name := "${prefs.typeof.name}.fog") {
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
	
	File? toFile(Type prefsType, Str name := "${prefsType.name}.fog") {
		pathUri := `etc/${appTitle}/${name}`
		if (runtimeIsJs) {
			log.info("File $pathUri does not exist in JS")
			return null
		}
		
		envFile := Env.cur.findFile(pathUri, false) ?: Env.cur.workDir + pathUri
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
				log.debug("Loading preferences: $file")
				value = file.readObj
				registry.injectIntoFields(value)
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
