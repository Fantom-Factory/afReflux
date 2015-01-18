using afIoc
using afReflux
using fwt
using gfx

class Example {
    Void main() {
        Reflux.start("Example", [AppModule#]) |Reflux reflux, Window window| {
            reflux.showPanel(MyPanel#)
        }
    }
}

class AppModule {
    @Contribute { serviceType=Panels# }
    static Void contributePanels(Configuration config) {
        config.add(config.autobuild(MyPanel#))
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
