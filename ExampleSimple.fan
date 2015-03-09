using afIoc
using afReflux
using fwt
using gfx

class Example {
    Void main() {
		RefluxBuilder(AppModule#).start |Reflux reflux, Window window| {
            reflux.showPanel(MyPanel#)
        }
    }
}

class AppModule {
    @Contribute { serviceType=Panels# }
    static Void contributePanels(Configuration config) {
    	myPanel := config.autobuild(MyPanel#)
        config.add(myPanel)
    }
}

class MyPanel : Panel {
    new make(|This| in) : super(in) { 
        content = Label() {
            it.text = "Hello Mum!"
            it.bg   = Color.yellow
        }
    }
}
