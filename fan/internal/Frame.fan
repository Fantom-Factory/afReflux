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
	@Inject private RefluxEvents		refluxEvents
			private Reflux				reflux
			private Obj:PanelTabPane	panelTabs	:= [:]
			private ViewTabPane			viewTabs

	internal new make(Reflux reflux, |This|in) : super() {
		in(this)
		this.reflux = reflux	// need to pass this in, 'cos it's created in Reflux's ctor

		imageSource	:= (ImageSource) registry.serviceById(ImageSource#.qname)
		this.title	= appTitle
		this.icon	= imageSource.get(appIcon, false)
		this.size	= Size(640, 480)

		eventHub	:= (EventHub) registry.serviceById(EventHub#.qname)
		eventHub.register(this)
		
		panelTabs[Halign.left]	= registry.autobuild(PanelTabPane#, [false, false])
		panelTabs[Halign.right]	= registry.autobuild(PanelTabPane#, [false, false])
		panelTabs[Valign.bottom]= registry.autobuild(PanelTabPane#, [false, true])
		viewTabs				= registry.autobuild(ViewTabPane#, [reflux])
		
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
		panelTabs[prefAlign(panel)].addTab(panel).activate(panel)
		refluxEvents.onShowPanel(panel)
	}
	
	Void hidePanel(Panel panel) {
		panelTabs[prefAlign(panel)].activate(null).removeTab(panel)
		refluxEvents.onHidePanel(panel)
	}
	
	Void closeView(View view) {
		viewTabs.removeTab(view)
	}

	override Void onLoad(Resource resource) {
		this.title = "${appTitle} - ${resource.name}" 
	}
	
	Obj prefAlign(Panel panel) {
		reflux.preferences.panelPrefAligns[panel.typeof] ?: panel.prefAlign
	}
}
