using afIoc
using fwt
using gfx

class Main {
    Void main() {
        Reflux.start("Example", [AppModule#]) |Reflux reflux, Window window| {
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
        content = Browser()
    }
}