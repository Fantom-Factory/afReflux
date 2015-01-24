using afIoc
using gfx
using fwt

** (Service) - The main API for managing a Reflux application.
mixin Reflux {

    // TODO: Fandoc this class
    abstract Registry registry()
    abstract Void callLater(Duration delay, |->| f)

    abstract RefluxPrefs preferences()

    abstract Void refresh(Resource? resource := null)
    abstract Window window()
    abstract Void exit()

    ** Resolves the given URI into a 'Resource'.
    abstract Resource resolve(Str uri)

    abstract Void load(Str uri, LoadCtx? ctx := null)
    abstract Void loadResource(Resource resource, LoadCtx? ctx := null)
    abstract View? activeView()
    abstract Bool closeView(View view, Bool force)      // currently, only activeView is available, need views()
    abstract Void replaceView(View view, Type viewType) // currently, only activeView is available, need views()

    abstract Panel? getPanel(Type panelType, Bool checked := true)
    abstract Panel showPanel(Type panelType)
    abstract Panel hidePanel(Type panelType)

    abstract Void copyToClipboard(Str text)


    ** Use to launch a Reflux application. Example:
    **
    **   Reflux.start("Example App", [AppModule#]) |Reflux reflux, Window window| {
    **       reflux.showPanel(MyPanel#)
    **       ...
    **   }
    static Void start(Str appName, Type[] modules, |Reflux, Window|? onOpen := null) {
        bob := RegistryBuilder()

        // try to dig out the project name
        projName := modules.first?.pod?.meta?.get("proj.name")
        version  := modules.first?.pod?.version
        if (projName != null && version != null)
            bob["afIoc.bannerText"] = "$projName v$version"

        registry := bob
            .addModule(RefluxModule#)
            .addModules(modules)
            .set("afReflux.appName", appName)
            .build.startup
        reflux   := (Reflux) registry.serviceById(Reflux#.qname)
        frame    := (Frame)  reflux.window

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
}

internal class RefluxImpl : Reflux, RefluxEvents {
    @Inject private UriResolvers    uriResolvers
    @Inject private RefluxEvents    refluxEvents
    @Inject private Preferences     prefsCache
    @Inject private Errors          errors
    @Inject private Panels          panels
    @Inject private History         history
    @Inject private Session         session
    @Inject override Registry       registry
            override View?          activeView
//  @Autobuild { implType=Frame# }
            override Window         window

    new make(EventHub eventHub, |This| in) { in(this)
        eventHub.register(this)
        // FIXME: IoC Err - autobuild builds twice
        window = registry.autobuild(Frame#, [this])
    }

    override RefluxPrefs preferences() {
        prefsCache.loadPrefs(RefluxPrefs#, "afReflux.fog")
    }

    override Void callLater(Duration delay, |->| f) {
        Desktop.callLater(delay) |->| {
            try f()
            catch (Err err) {
                errors.add(err)
            }
        }
    }

    override Resource resolve(Str uri) {
        uriResolvers.resolve(uri)
    }

    override Void load(Str uri, LoadCtx? ctx := null) {
        ctx = ctx ?: LoadCtx()

        try {
            u := uri.toUri
            if (u.query.containsKey("view")) {
                ctx.viewType = Type.find(u.query["view"])
                uri = removeQuery(uri, "view", u.query["view"])
            }

            u = uri.toUri
            if (u.query.containsKey("newTab")) {
                ctx.newTab = u.query["newTab"].toBool(false) ?: false
                uri = removeQuery(uri, "newTab", u.query["newTab"])
            }

        } catch { /* meh */ }

        try {
            resource := uriResolvers.resolve(uri)
            loadResource(resource, ctx)
        } catch (Err err) {
            errors.add(err)
        }
    }

    override Void loadResource(Resource resource, LoadCtx? ctx := null) {
        history.load(resource, ctx ?: LoadCtx())
        view := frame.load(resource, ctx ?: LoadCtx())
        loadIntoView(view, resource)
    }

    override Void refresh(Resource? resource := null) {
        activeView?.refresh(resource)

        panels.panels.each {
            if (it.isShowing)
                it.refresh(resource)
        }
    }

    override Void replaceView(View view, Type viewType) {
        resource := view.resource

        if (view.isDirty)
            view.save

        newView := frame.replaceView(view, viewType)
        loadIntoView(newView, resource)
    }

    override Bool closeView(View view, Bool force) {
        frame.closeView(view, true)
    }

    override Panel? getPanel(Type panelType, Bool checked := true) {
        panels.get(panelType, checked)
    }

    override Panel showPanel(Type panelType) {
        panel := getPanel(panelType)

        if (panel.isShowing)
            return panel

        frame.showPanel(panel, prefAlign(panel))

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

        frame.hidePanel(panel, prefAlign(panel))

        return panel
    }

    override Void exit() {
		// only active and close what we have to - we don't want refresh flashes causing an epi-fit!
		frame.dirtyViews.each |view| {
			frame.activateView(view)
			closeView(view, true)
		}

        session.save
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

    override Void onLoadSession(Str:Obj? session) {
        frame.size = session["afReflux.frameSize"] ?: frame.size

        // a tiny fudge to show the Folder Panel by defauly
        panels := (Str[]) session.get("afReflux.openPanels", ["afExplorer::FoldersPanel"])
        panels.each {
            panelType := Type.find(it, false)
            if (panelType != null && getPanel(panelType, false) != null)
                showPanel(panelType)
        }
    }

    override Void onSaveSession(Str:Obj? session) {
        session["afReflux.frameSize" ] = frame.size
        session["afReflux.openPanels"] = panels.panels.findAll { it.isShowing }.map { it.typeof.qname }
    }

    private Void loadIntoView(View? view, Resource resource) {
        try view?.load(resource)
        catch (Err err)
            errors.add(err)
        refluxEvents.onLoad(resource)
    }

    private Obj prefAlign(Panel panel) {
        preferences.panelPrefAligns[panel.typeof] ?: panel.prefAlign
    }

    private Frame frame() {
        window
    }

    private static Str removeQuery(Str str, Str key, Str val) {
        str = str.replace("${key}=${val}", "")
        if (str.endsWith("?"))
            str = str[0..-2]
        return str
    }
}

** Contextual data for loading 'Resources'.
class LoadCtx {
    ** If 'true' then the resource is opened in a new View tab.
    Bool    newTab

    ** The 'View' the resource should be opened in.
    Type?   viewType

    @NoDoc
    Bool    addToHistory    := true

    override Str toStr() {
        str := "LoadCtx { "
        str += "newTab=${newTab} "
        if (viewType != null)
            str += "viewType=${viewType.qname} "
        str += "}"
        return str
    }
}