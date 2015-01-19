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
	Browser b
    new make(|This| in) : super(in) { 
        b = content = Browser()
    }
	
	override Void onShow() {
//		b.execute("alert('dude!');")
		b.html = "Wow!"
		
		b.html = null
		
	}
}