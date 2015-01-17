using afIoc
using afIocConfig
using gfx
using fwt

** (Service) - The main API for managing a Reflux application.
mixin Reflux {
	
	abstract Registry registry()
	abstract Void callLater(Duration delay, |->| f)

	abstract RefluxPrefs preferences()
	
	abstract Void refresh()
	abstract Window window()
	abstract Void exit()
	
	abstract Void load(Uri uri, LoadCtx? ctx := null)
	abstract Void loadResource(Resource resource, LoadCtx? ctx := null)
	abstract View? activeView()
	abstract Bool closeView(View view)		// currently, only activeView is available, need views()
	abstract Void replaceView(View view, Type viewType)	// currently, only activeView is available, need views()
	
	abstract Panel showPanel(Type panelType)
	abstract Panel hidePanel(Type panelType)
	abstract Panel getPanel(Type panelType)
	
	abstract Void copyToClipboard(Str text)



	static Void start(Type[] modules, |Reflux| onOpen) {
		registry := RegistryBuilder().addModules([RefluxModule#, ConfigModule#]).addModules(modules).build.startup
		reflux	 := (Reflux) registry.serviceById(Reflux#.qname)
		frame	 := (Frame)  reflux.window
		
		// onActive -> onFocus -> onOpen
		frame.onOpen.add {
			// Give the widgets a chance to display themselves and set defaults
			Desktop.callLater(50ms) |->| {
				onOpen.call(reflux)
			}
		}

		frame.open
		registry.shutdown
	}
}

internal class RefluxImpl : Reflux, RefluxEvents {
	@Inject private UriResolvers	uriResolvers
	@Inject private RefluxEvents	refluxEvents
	@Inject private Preferences		prefsCache
	@Inject private Errors			errors
	@Inject private Panels			panels
	@Inject private History			history
	@Inject override Registry		registry
			override View?			activeView
//	@Autobuild { implType=Frame# }
			override Window			window

	new make(EventHub eventHub, |This| in) { in(this)
		eventHub.register(this)
		// FIXME: IoC Err - autobuild builds twice
		window = registry.autobuild(Frame#, [this])
	}

	override RefluxPrefs preferences() {
		prefsCache.loadPrefs(RefluxPrefs#)
	}

	override Void callLater(Duration delay, |->| f) {
		Desktop.callLater(delay) |->| {
			try f()
			catch (Err err) {
				errors.add(err)
			}
		}
	}

	override Void load(Uri uri, LoadCtx? ctx := null) {
		ctx = ctx ?: LoadCtx()

		if (uri.query.containsKey("view")) {
			ctx.viewType = Type.find(uri.query["view"])
			uri = removeQuery(uri, "view", uri.query["view"])
		}

		if (uri.query.containsKey("newTab")) {
			ctx.newTab = uri.query["newTab"].toBool(false) ?: false
			uri = removeQuery(uri, "newTab", uri.query["newTab"])
		}

		resource := uriResolvers.resolve(uri)
		
		loadResource(resource, ctx)
	}

	override Void loadResource(Resource resource, LoadCtx? ctx := null) {
		history.load(resource, ctx ?: LoadCtx())
		view := frame.load(resource, ctx ?: LoadCtx())
		loadIntoView(view, resource)
	}

	override Void refresh() {
		activeView.refresh

		panels.panels.each {
			if (it.isActive)
				it.refresh
		}
	}

	override Void replaceView(View view, Type viewType) {
		resource := view.resource

		if (view.isDirty)
			view.save
		
		newView := frame.replaceView(view, viewType)
		loadIntoView(newView, resource)
	}
	
	override Bool closeView(View view) {
		frame.closeView(view)
	}

	override Panel getPanel(Type panelType) {
		panels.panelMap[panelType]
	}
	
	override Panel showPanel(Type panelType) {
		panel := getPanel(panelType)
		
		if (panel.isShowing)
			return panel
		
		frame.showPanel(panel)

		// initialise panel with data
		if (panel is RefluxEvents && activeView?.resource != null)
			Desktop.callLater(50ms) |->| {
				((RefluxEvents) panel)->onLoad(activeView.resource, LoadCtx())
			}

		return panel
	}

	override Panel hidePanel(Type panelType) {
		panel := getPanel(panelType)
		
		if (!panel.isShowing)
			return panel

		frame.hidePanel(panel)		

		return panel
	}
	
	override Void exit() {
		while (activeView != null && closeView(activeView)) { }
		if    (activeView != null) return
		
		panels.panels.each { hidePanel(it.typeof) }
		frame.close
	}
	
	override Void copyToClipboard(Str text) {
		Desktop.clipboard.setText(text)
	}
	
	override Void onViewActivated(View view) {
		activeView = view
	}

	override Void onViewDeactivated(View view) {
		activeView = null
	}

	private Void loadIntoView(View? view, Resource resource) {
		try	view?.load(resource)
		catch (Err err)
			errors.add(err)
		refluxEvents.onLoad(resource)		
	}

	private Frame frame() {
		window
	}
	
	private static Uri removeQuery(Uri uri, Str key, Str val) {
		str := uri.toStr.replace("${key}=${val}", "")
		if (str.endsWith("?"))
			str = str[0..-2]
		return str.toUri
	}
}

** Contextual data for loading 'Resources'. 
class LoadCtx {
	** If 'true' then the resource is opened in a new View tab.
	Bool	newTab
	
	** The 'View' the resource should be opened in. 
	Type?	viewType

	@NoDoc
	Bool	addToHistory	:= true
}
