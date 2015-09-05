using afIoc3
using fwt

** Use to build and launch a Reflux application. Example:
**
**   syntax: fantom
** 
**   RefluxBuilder(AppModule#).start() |Reflux reflux, Window window| {
**	   reflux.showPanel(MyPanel#)
**	   ...
**   }
class RefluxBuilder {
	private const static Log log := RefluxBuilder#.pod.log

	** The underlying IoC 'RegistryBuilder'. 
	RegistryBuilder registryBuilder := RegistryBuilder() { private set }
	
	** The application name. Taken from the app pod's 'proj.name' meta, or the pod name if the meta doesn't exist.
	** Read only.
	Str appName {
		get { options[RefluxConstants.meta_appName] }
		private set { throw Err("Read only") }
	}

	** Returns options from the IoC 'RegistryBuilder'.
	Str:Obj? options {
		get { registryBuilder.options }
		private set { throw Err("Read only") }
	}
	
	** Creates a 'BedSheetBuilder'. 
	** 'modOrPodName' may be a pod name or a qualified 'AppModule' type name. 
	** 'addPodDependencies' is only used if a pod name is passed in.
	new makeFromName(Str modOrPodName, Bool addPodDependencies := true) {
		initModules(registryBuilder, modOrPodName, addPodDependencies)
		initBanner()
	}
	
	** Creates a 'BedSheetBuilder' from the given 'AppModule'.
	new makeFromAppModule(Type appModule) {
		initModules(registryBuilder, appModule.qname, true)
		initBanner()
	}

	** Creates a 'BedSheetBuilder' with the given 'AppModules'.
	new makeFromAppModules(Type[] appModules) {
		if (appModules.isEmpty)
			throw ArgErr("appModules must not be empty")
		initModules(registryBuilder, appModules.first.qname, true)
		initBanner()
		registryBuilder.addModules(appModules)
	}
	
	** Adds a module to the registry. 
	** Any modules defined with the '@SubModule' facet are also added.
	** 
	** Convenience for 'registryBuilder.addModule()'
	This addModule(Type moduleType) {
		registryBuilder.addModule(moduleType)
		return this
	}
	
	** Adds many modules to the registry.
	** 
	** Convenience for 'registryBuilder.addModules()'
	This addModules(Type[] moduleTypes) {
		registryBuilder.addModules(moduleTypes)
		return this
	}
	
	** Inspects the [pod's meta-data]`docLang::Pods#meta` for the key 'afIoc.module'. This is then 
	** treated as a CSV list of (qualified) module type names to load.
	** 
	** If 'addDependencies' is 'true' then the pod's dependencies are also inspected for IoC 
	** modules.
	**  
	** Convenience for 'registryBuilder.addModulesFromPod()'
	This addModulesFromPod(Str podName, Bool addDependencies := true) {
		registryBuilder.addModulesFromPod(podName, addDependencies)
		return this		
	}
	
	Void start(|Reflux, Window|? onOpen := null) {
		registry := registryBuilder.build.startup
		reflux	 := (Reflux) registry.serviceById(Reflux#.qname)
		frame	 := (Frame)  reflux.window

		// onActive -> onFocus -> onOpen
		frame.onOpen.add {
			// Give the widgets a chance to display themselves and set defaults
			Desktop.callLater(50ms) |->| {
				// load the session before we start loading URIs and opening tabs
				session := (Session) registry.serviceById(Session#.qname)
				session.load

				// once we've all started up and settled down, load URIs from the command line
				onOpen?.call(reflux, frame)
			}
		}

		frame.open
		registry.shutdown
	}
	
	private Void initBanner() {
		pod := (Pod?) registryBuilder[RefluxConstants.meta_appPod]
		ver  := pod?.version ?: "???"
		registryBuilder["afIoc.bannerText"] = "$appName v$ver"
	}

	private static Void initModules(RegistryBuilder bob, Str moduleName, Bool transDeps) {
		Pod?  pod
		Type? mod
		Type[] mods := Type#.emptyList
		
		// Pod name given...
		// lots of start up checks looking for pods and modules... 
		// see https://bitbucket.org/SlimerDude/afbedsheet/issue/1/add-a-warning-when-no-appmodule-is-passed
		if (!moduleName.contains("::")) {
			pod = Pod.find(moduleName, true)
			log.info(LogMsgs.refluxBuilder_foundPod(pod))
			mods = findModFromPod(pod)
			mod = mods.first
		}

		// AppModule name given...
		if (moduleName.contains("::")) {
			mod = Type.find(moduleName, true)
			log.info(LogMsgs.refluxBuilder_foundType(mod))
			pod = mod.pod
		}

		// we're screwed! No module = no web app!
		if (mod == null)
			log.warn(LogMsgs.refluxBuilder_noModuleFound)
		
		if (pod != null) {
			if (!transDeps)
				log.info("Suppressing transitive dependencies...")
			bob.addModulesFromPod(pod.name, transDeps)
		}
		if (mod != null) {
			if (!bob.moduleTypes.contains(mod))
				bob.addModule(mod)
		}
		bob.addModules(mods)
		
		// A simple thing - ensure the Reflux module is added! 
		// (transitive dependencies are added explicitly via @SubModule)
		if (!bob.moduleTypes.contains(RefluxModule#))
			 bob.addModule(RefluxModule#)

		regOpts := bob.options
		regOpts[RefluxConstants.meta_appName]	= (pod?.meta?.get("proj.name") ?: pod?.name) ?: "Unknown"
		regOpts[RefluxConstants.meta_appPod]	= pod
		regOpts[RefluxConstants.meta_appModule]	= mod
	}

	** Looks for an 'AppModule' in the given pod. 
	private static Type[] findModFromPod(Pod pod) {
		mods := Type#.emptyList
		modNames := pod.meta["afIoc.module"]
		if (modNames != null) {
			mods = modNames.split.map { Type.find(it, true) }
			log.info(LogMsgs.refluxBuilder_foundType(mods.first))
		} else {
			// we have a pod with no module meta... so lets guess the name 'AppModule'
			mod := pod.type("AppModule", false)
			if (mod != null) {
				mods = [mod]
				log.info(LogMsgs.refluxBuilder_foundType(mod))
				log.warn(LogMsgs.refluxBuilder_addModuleToPodMeta(pod, mod))
			}
		}
		return mods
	}
}
