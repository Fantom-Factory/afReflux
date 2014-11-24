using afIoc
using afIocConfig
using afConcurrent
using gfx
using fwt

internal class Frame : Window, RefluxEvents {
	@Config
	@Inject private Str					appTitle

	@Config
	@Inject private Uri					appIcon

	@Inject private Registry?			registry
			private Obj:PanelTabPane	panelTabs	:= [:]
			private ViewTabPane			viewTabs

	internal new make(|This|in) : super() {
		in(this)

		imageSource	:= (ImageSource) registry.dependencyByType(ImageSource#)
		this.title	= appTitle
		this.icon	= imageSource.get(appIcon, false)
		this.size	= Size(640, 480)

		eventHub	:= (EventHub) registry.dependencyByType(EventHub#)
		eventHub.register(this)
		
		panelTabs[Halign.left]	= registry.autobuild(PanelTabPane#, [false, false])
		panelTabs[Halign.right]	= registry.autobuild(PanelTabPane#, [false, false])
		panelTabs[Valign.bottom]= registry.autobuild(PanelTabPane#, [false, true])
		viewTabs				= registry.autobuild(ViewTabPane#)
		
		navBar := (RefluxBar) registry.autobuild(RefluxBar#)
		
		this.menuBar	= registry.serviceById("afReflux.menuBar")
		
		this.content 	= EdgePane {
			top = navBar
			center = SashPane {
				it.orientation = Orientation.horizontal
				it.weights = [200, 600, 200]
				panelTabs[Halign.left],
				SashPane {
					it.orientation = Orientation.vertical
					it.weights = [600, 200]
					viewTabs,
					panelTabs[Valign.bottom],
				},
				panelTabs[Halign.right],
			}
		}
	}
	
	Void showPanel(Panel panel) {
		panelTabs[panel.prefAlign].addTab(panel).activate(panel)
	}
	
	Void hidePanel(Panel panel) {
		panelTabs[panel.prefAlign].activate(null).removeTab(panel)
	}
	
	override Void onLoad(Resource resource) {
		this.title = "${appTitle} - ${resource.name}" 
	}	
}
