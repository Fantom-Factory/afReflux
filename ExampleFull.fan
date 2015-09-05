using afIoc3
using afReflux
using fwt
using gfx

class Example {
    Void main() {
        RefluxBuilder(AppModule#).start |Reflux reflux, Window window| {
            reflux.showPanel(EventsPanel#)
            reflux.showPanel(AlienAlertPanel#)
            reflux.load("example:Fantom")
        }
    }
}

class AppModule {
    @Contribute { serviceType=Panels# }
    static Void contributePanels(Configuration config) {
        config["events"]     = config.autobuild(EventsPanel#)
        config["alienAlert"] = config.autobuild(AlienAlertPanel#)
    }
    
    @Contribute { serviceType=UriResolvers# }
    static Void contributeUriResolvers(Configuration config) {
        config["myResolver"] = config.autobuild(MyResolver#)
    }
    
    @Contribute { serviceType=GlobalCommands# }
    static Void contributeGlobalCommands(Configuration config) {
        config["cmdLaunchNukes"] = config.autobuild(LaunchNukesCommand#)
    }

    @Contribute { serviceId="afReflux.menuBar" }
    static Void contributeMenuBar(Configuration config, Reflux reflux) {
        menu := Menu() { it.text = "Example"}
        config
            .set("example", menu)
            .after("afReflux.editMenu")
            .before("afReflux.viewMenu")
        menu.add(MenuItem(Command("Monica",  null) { reflux.load("example:Monica" ) } ))
        menu.add(MenuItem(Command("Erica",   null) { reflux.load("example:Erica"  ) } ))
        menu.add(MenuItem(Command("Rita",    null) { reflux.load("example:Rita"   ) } ))
        menu.add(MenuItem(Command("Tina",    null) { reflux.load("example:Tina"   ) } ))
        menu.add(MenuItem(Command("Sandra",  null) { reflux.load("example:Sandra" ) } ))
        menu.add(MenuItem(Command("Mary",    null) { reflux.load("example:Mary"   ) } ))
        menu.add(MenuItem(Command("Jessica", null) { reflux.load("example:Jessica") } ))
    }
    
    @Contribute { serviceId="afReflux.editMenu" }
    static Void contributeEditMenu(Configuration config, GlobalCommands globalCmds) {
        config["cmdLaunchNukes"] = MenuItem(globalCmds["cmdLaunchNukes"].command)
    }

    @Contribute { serviceId="afReflux.toolBar" }
    static Void contributeToolBar(Configuration config, GlobalCommands globalCmds) {
        button := Button(globalCmds["cmdLaunchNukes"].command) 
        button.text = ""
        config["cmdLaunchNukes"] = button 
    }
}

class LaunchNukesCommand : GlobalCommand {
    new make(|This|in) : super.make("cmdLaunchNukes", in) {
        command.icon = Image(`fan://icons/x16/sun.png`)
    }
    
    override Void doInvoke(Event? event) {
        Dialog.openWarn(command.window, "Launching Nukes!")
    }
}

** This panel lists all the events it receives
class EventsPanel : Panel, RefluxEvents {
    Table table
    EventsPanelModel model := EventsPanelModel()

    new make(|This| in) : super(in) { 
        icon = Image(`fan://icons/x16/history.png`)
        table = content = Table()
        table.model = model
    }
    
    override Void onLoadSession (Str:Obj? session) { update("onLoadSession"      ) }
    override Void onSaveSession (Str:Obj? session) { update("onSaveSession"      ) }
    override Void onLoad       (Resource resource) { update("onLoad"             ) }
    override Void onError            (Error error) { update("onError"            ) }
    override Void onPanelShown       (Panel panel) { update("onPanelShown"       , panel) }
    override Void onPanelHidden      (Panel panel) { update("onPanelHidden"      , panel) }
    override Void onPanelActivated   (Panel panel) { update("onPanelActivated"   , panel) }
    override Void onPanelDeactivated (Panel panel) { update("onPanelDeactivated" , panel) }
    override Void onPanelModified    (Panel panel) { update("onPanelModified"    , panel) }
    override Void onViewShown          (View view) { update("onViewShown"        , view) }
    override Void onViewHidden         (View view) { update("onViewHidden"       , view) }
    override Void onViewActivated      (View view) { update("onViewActivated"    , view) }
    override Void onViewDeactivated    (View view) { update("onViewDeactivated"  , view) } 
    override Void onViewModified       (View view) { update("onViewModified"     , view) }
    
    Void update(Str event, Obj? panel := null) {
        model.events.add([event, panel?.typeof?.name ?: ""])
        table.refreshAll
    }
}
class EventsPanelModel : TableModel {
    Str[][] events := Str[][,]
    override Int numCols() { 2 }
    override Int numRows() { events.size }
    override Str header(Int col) { col == 0 ? "Events" : "Panel" }
    override Str text(Int col, Int row) { events[row][col] }
}

** This panel, when active, enables the global cmdLaunchNukes command
class AlienAlertPanel : Panel {
    @Inject GlobalCommands globalCommands
    
    new make(|This| in) : super(in) { 
        icon = Image(`fan://icons/x16/warn.png`)
        name = "Alien Alert!"
        content = Text() {
            it.bg = Color.red
            it.multiLine = true
            it.text = "Alien Alert!\n
                       Aliens are attacking!\nLaunch the Nukes!\n
                       Tip: Select the other tab first."
        }
    }
    
    override Void onActivate() {
        globalCommands["cmdLaunchNukes"].removeEnabler("alienAlert")
    }
    
    override Void onDeactivate() {
        // only enable the nuke when we *aren't* active!
        globalCommands["cmdLaunchNukes"].addEnabler("alienAlert") |->Bool| { true }
    }
}

class MyResolver : UriResolver {
    @Inject Registry registry
    
    new make(|This|in) { in(this) }
    
    override Resource? resolve(Str uri) {
        uri.toUri.scheme == "example"
            ? MyResource(uri.toUri)
            : null
    }
}

class MyResource : Resource {
    override Uri     uri
    override Str     name
    override Image?  icon

    new make(Uri uri) { 
        this.uri  = uri
        this.name = uri.name
        this.icon = Image(`fan://icons/x16/database.png`)
    }

    override Type[] viewTypes() {
        [MyView#]
    }    
}

class MyView : View {
    Label label

    new make(|This| in) : super(in) { 
        content = label = Label() {
            it.bg   = Color.green
        }
    }
    
    override Void load(Resource resource) {
        super.load(resource)
        label.text = "Resource Name: ${resource.name}"
    }
}