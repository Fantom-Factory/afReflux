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

	@Inject private Registry			registry
	@Inject private Reflux				reflux
			private Obj:PanelTabPane	panelTabs	:= [:]
			private ViewTabPane			viewTabs

	internal new make(Registry registry, RegistryMeta regMeta) : super() {
		((LocalRef) regMeta["frameRef"]).val = this
		this.registry	= registry
		this.reflux		= registry.dependencyByType(Reflux#)
		// TODO: IoC 2.0.2
//		this.appTitle	= registry.dependencyByField(#appTitle)
//		this.appIcon	= registry.dependencyByField(#appIcon)
		configSource	:= (ConfigSource) registry.dependencyByType(ConfigSource#)
		this.appTitle	= configSource.get("afReflux.appTitle", Str#)
		this.appIcon	= configSource.get("afReflux.appIcon", Uri#)
		
		imageSource		:= (ImageSource) registry.dependencyByType(ImageSource#)
		this.title		= appTitle
		this.icon		= imageSource.get(appIcon, false)
		this.size		= Size(640, 480)

		eventHub		:= (EventHub) registry.dependencyByType(EventHub#)
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
	
	Panel showPanel(Panel panel) {
		if (panel.isShowing)
			return panel
		
		panelTabs[panel.prefAlign].addTab(panel).activate(panel)

		// initialise panel with data
		if (panel is RefluxEvents && reflux.showing != null)
			Desktop.callLater(50ms) |->| {
				((RefluxEvents) panel).onLoad(reflux.showing)
			}

		return panel
	}
	
	Panel hidePanel(Panel panel) {
		if (!panel.isShowing)
			return panel

		panelTabs[panel.prefAlign].activate(null).removeTab(panel)

		return panel
	}
	
	override Void onLoad(Resource resource) {
		this.title = "${appTitle} - ${resource.name}" 
	}
	
	Void exit() {
		// TODO: deactivate and hide all panels...? 
		this.close
	}
}
