using afIoc
using gfx
using fwt

internal class Frame : Window, RefluxEvents {

	private Obj:PanelTabPane	panelTabs	:= [:]
	private ViewTabPane			viewTabs
	private Bool				closing
	private Str					appName

	internal new make(Reflux reflux, Registry registry, RegistryMeta regMeta) : super() {
		this.appName= regMeta["afReflux.appName"]
		this.title	= regMeta["afReflux.appName"]
		this.icon	= Image(`fan://icons/x32/flux.png`)
		this.size	= Size(640, 480)

		eventHub	:= (EventHub) registry.serviceById(EventHub#.qname)
		eventHub.register(this)
		
		panelTabs[Halign.left]	= registry.autobuild(PanelTabPane#, [false, false])
		panelTabs[Halign.right]	= registry.autobuild(PanelTabPane#, [false, false])
		panelTabs[Valign.bottom]= registry.autobuild(PanelTabPane#, [false, true])
		viewTabs				= registry.autobuild(ViewTabPane#,  [reflux])
		
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
		
		this.onClose.add |Event e| { if (!closing) reflux.exit }
	}
	
	Void showPanel(Panel panel, Obj prefAlign) {
		panelTabs[prefAlign].addTab(panel).activate(panel)
	}
	
	Void hidePanel(Panel panel, Obj prefAlign) {
		panelTabs[prefAlign].activate(null).removeTab(panel)
	}
	
	View? replaceView(View view, Type viewType) {
		viewTabs.replaceView(view, viewType)
	}
	
	Bool closeView(View view, Bool force) {
		viewTabs.closeView(view, force)
	}

	View? load(Resource resource, LoadCtx ctx) {
		view := viewTabs.load(resource, ctx)
		update(resource, false)
		return view
	}
	
	override Void onViewActivated(View view) {
		update(view.resource, view.isDirty)
	}
	
	override Void onViewModified(View view) {
		update(view.resource, view.isDirty)
	}
	
	override Void close(Obj? result := null) {
		this.closing = true
		super.close(result)
	}
	
	private Void update(Resource? resource, Bool isDirty) {
		if (resource == null) return
		this.title = "${appName} - ${resource.name}"
		if (isDirty)
			title += " *"
	}	
}
