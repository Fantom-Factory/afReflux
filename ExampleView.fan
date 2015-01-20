using afIoc
using afReflux
using fwt
using gfx

class Example {
    Void main() {
        Reflux.start("Example", [AppModule#])
    }
}

class AppModule {
    @Contribute { serviceType=UriResolvers# }
    static Void contributeUriResolvers(Configuration config) {
        config["myResolver"] = config.autobuild(MyResolver#)
    }
	
@Contribute { serviceId="afReflux.menuBar" }
static Void contributeMenuBar(Configuration config) {
    menu := Menu() { it.text = "Example"}
    config
        .set("example", menu)
        .after("afReflux.editMenu")
        .before("afReflux.viewMenu")

}

@Contribute { serviceId="afReflux.editMenu" }
static Void contributeEditMenu(Configuration config, GlobalCommands globalCmds) {
	command := Command("Hello Mum!", null) |Event event| { echo("Hello Mum!") }
	config.set("myCommand", MenuItem(command)).before("afReflux.cmdUndo")
}
}

class MyResolver : UriResolver {
    @Inject Registry registry
    
    new make(|This|in) { in(this) }
    
    override Resource? resolve(Str uri) {
        uri.toUri.scheme == "example"
            ? registry.autobuild(MyResource#, [uri.toUri])
            : null
    }
}

class MyResource : Resource {
    override Uri     uri
    override Str     name
    override Image?  icon

    new make(Uri uri, |This|in) : super.make(in) { 
        this.uri  = uri
        this.name = uri.name
        this.icon = Image("fan://icons/x16/database.png")
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
