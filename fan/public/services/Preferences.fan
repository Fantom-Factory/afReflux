using afIoc

** (Service) - 
** Loads / saves and maintains a cache of preference objects. 
** Instances are cached until the backing file is updated / modified.  
** 
** Because Reflux is application centric, preference files are not associated 
** with pods, but with the application name supplied at startup:
** 
**   %FAN_HOME%/etc/<app-name>/xxx.fog
** 
** Preference instances must be serializable. 
class Preferences {
			private static const Log 	log 	:= Preferences#.pod.log
			private Type:CachedPrefs	cache	:= Type:CachedPrefs[:]
			private Str					appName
	@Inject private Registry			registry
	
	private new make(RegistryMeta regMeta, |This| in) {
		in(this)
		this.appName = regMeta["afReflux.appName"].toStr.fromDisplayName
	}
	
	** Returns an instance of the given preferences object.
	** 
	**   preferences.loadPrefs(MyPrefs#, "myPrefs.fog")
	Obj loadPrefs(Type prefsType, Str? name := null) {
		name = name ?: "${prefsType.name}.fog"
		cached	:= loadFromCache(prefsType)

		if (cached != null) {
			log.debug("Returning cached $prefsType.name $cached")
			return cached
		}

		file	:= findFile(name)
		prefs 	:= loadFromFile(file)

		if (prefs == null) {
			log.debug("Making preferences: $prefsType.name")
			prefs = registry.autobuild(prefsType)
		}

		cache[prefsType] = CachedPrefs(file, prefs)
		
		return prefs
	}

	** Saves the given preference instance.
	** 
	**   preferences.savePrefs(myPrefs, "myPrefs.fog")
	Void savePrefs(Obj prefs, Str? name := null) {
		name = name ?: "${prefs.typeof.name}.fog"
		if (runtimeIsJs) {
			log.info("Cannot save $name in JS")
			return 
		}
		file := findFile(name)
		file.writeObj(prefs, ["indent":2])
	}
	
	** Returns 'true' if the preferences file has been updated since it was last read.
	Bool updated(Type prefsType) {
		((CachedPrefs?) cache[prefsType])?.modified ?: true
	}
	
	** Finds the named file in the applications 'etc' dir. 
	** If such a file does not exist, a file in the 'workDir' is returned.  
	File? findFile(Str name) {
		pathUri := `etc/${appName}/${name}`
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
