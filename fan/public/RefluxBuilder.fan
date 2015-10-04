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
@Js
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
	
	** Creates a 'RefluxBuilder'. 
	** 'modOrPodName' may be a pod name or a qualified 'AppModule' type name. 
	** 'addPodDependencies' is only used if a pod name is passed in.
	new makeFromName(Str modOrPodName, Bool addPodDependencies := true) {
		initModules(registryBuilder, modOrPodName, addPodDependencies)
		initBanner()
	}
	
	** Creates a 'RefluxBuilder' from the given 'AppModule'.
	new makeFromAppModule(Type appModule) {
		initModules(registryBuilder, appModule.qname, true)
		initBanner()
	}
	
	** Adds an IoC module to the registry. 
	This addModule(Obj module) {
		registryBuilder.addModule(module)
		return this
	}
	
	** Adds many IoC modules to the registry. 
	This addModules(Obj[] modules) {
		registryBuilder.addModules(modules)
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
		
		registryBuilder.addScope("uiThread", true)
		
		registry := registryBuilder.build
		
		uiScope	:= (Scope?) null
		registry.rootScope.createChildScope("uiThread") {
			uiScope = it.jailBreak
		}
		
		reflux	 := (Reflux) uiScope.serviceById(Reflux#.qname)
		frame	 := (Frame)  reflux.window

		// onActive -> onFocus -> onOpen
		frame.onOpen.add {
			// Give the widgets a chance to display themselves and set defaults
			Desktop.callLater(50ms) |->| {
				// load the session before we start loading URIs and opening tabs
				session := (Session) uiScope.serviceById(Session#.qname)
				session.load

				// once we've all started up and settled down, load URIs from the command line
				onOpen?.call(reflux, frame)
			}
		}
		frame.open
		
		// see JS Window Events - http://fantom.org/forum/topic/1981
//		if (Env.cur.runtime == "js")
//			frame.onOpen.fire(Event() { it.id = EventId.open; it.widget = frame } )
		
		// JS is non-blocking - so don't shutdown the registry!
		if (Env.cur.runtime != "js")
			registry.shutdown
	}
	
	private Void initBanner() {
		pod := (Pod?) registryBuilder.options[RefluxConstants.meta_appPod]
		ver  := pod?.version ?: "???"
		registryBuilder.options["afIoc.bannerText"] = "$appName v$ver"
	}

	private static Void initModules(RegistryBuilder bob, Str moduleName, Bool transDeps) {
		Pod?  pod
		Type? mod
		
		// Pod name given...
		// lots of start up checks looking for pods and modules... 
		// see https://bitbucket.org/SlimerDude/afbedsheet/issue/1/add-a-warning-when-no-appmodule-is-passed
		if (!moduleName.contains("::")) {
			pod = Pod.find(moduleName, true)
			log.info(LogMsgs.refluxBuilder_foundPod(pod))
			mods := findModFromPod(pod)
			mod = mods.first
			
			if (!transDeps)
				log.info("Suppressing transitive dependencies...")
			bob.addModulesFromPod(pod.name, transDeps)
			mods.each { bob.addModule(it) }
		}

		// AppModule name given...
		if (moduleName.contains("::")) {
			mod = Type.find(moduleName, true)
			log.info(LogMsgs.refluxBuilder_foundType(mod))
			pod = mod.pod
			
			bob.addModule(mod)
		}

		// we're screwed! No module = no web app!
		if (mod == null)
			log.warn(LogMsgs.refluxBuilder_noModuleFound)
		
		// A simple thing - ensure the Reflux module is added! 
		// (transitive dependencies are added explicitly via @SubModule)
		 bob.addModule(RefluxModule#)

		projName := (Str?) null
		try pod?.meta?.get("proj.name")
		catch { /* JS F4 Errs */ }

		regOpts	 := bob.options
		regOpts[RefluxConstants.meta_appName]	= (projName ?: pod?.name) ?: "Unknown"
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
