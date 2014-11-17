using afIoc
using gfx
using fwt

** Frame is the main top level window in flux applications.
class Frame : Window {

	internal LocatorBar		locator		:= LocatorBar(this)
	internal ViewTabPane	tabPane		:= ViewTabPane(this)
	internal SideBarPane	sideBarPane
	
	internal Registry		registry
	
	** Get the id of this frame within the VM.  The id may be used
	** as an immutable pointer to the frame to pass between threads.
	** See `findById` to resolve a frame by id.  The id is an opaque
	** string, no attempt should be made to interpret the format.
	const Str id

	internal new make(Registry registry) : super() {
		this.registry	= registry
		this.id			= initId
		this.title		= "Flux"
		this.icon		= Flux.icon(Desktop.isMac ? `/x256/flux.png` : `/x16/flux.png`)
		
		FluxModule.frameRef.val = this

		sideBarPane	= registry.autobuild(SideBarPane#, [tabPane])
		
//		menuBar	= commands.buildMenuBar
//		onClose.add |Event e| { e.consume; commands.exit.invoke(e) }
		onClose.add |Event e| { e.consume; saveState; registry.shutdown; Env.cur.exit(0) }
		this->onDrop 	= |data| { handleDrop(data) }	// use back-door hook for file drop
		this.content 	= EdgePane {
			top = EdgePane {
//				left = InsetPane(4,2) { commands.buildToolBar, }
				center = InsetPane(4,2) { locator, }
				bottom = Desktop.isMac ? null : ToolBarBorder()
			}
			center = sideBarPane
		}
	}

	// point?
//	** Get the sidebars which are currently created for this frame.
//	** This list includes both showing and hidden sidebars.
//	SideBar[] sideBars() {
//		return sideBarPane.sideBars.ro
//	}

	** Get the sidebar for the specified SideBar type.	
	** If the sidebar has already been created for this frame then return that instance.	
	** Otherwise if make is true, then create a new sidebar for this frame.	
	** If make is false return null.
	SideBar? sideBar(Type t, Bool make := true) {
		sideBarPane.sideBar(t, make)
	}

	internal Void handleDrop(Obj data) {
		files := data as File[]
		if (files == null || files.isEmpty) return
		files.each |File f, Int i| {
			// FIXME: file drop
//			load(f.normalize.uri, LoadMode { newTab = i > 0 })
		}
	}
	
	internal Str initId() {
		// FIXME: unique ID
		// allocate next id and register as thread local
//		Int idInt := Actor.locals.get("flux.nextFrameId", 0)
//		Actor.locals.set("flux.nextFrameId", idInt+1)
		idInt := 0
		id := "Frame-$idInt"
//		Actor.locals["flux.$id"] = this
		return id
	}

	internal Void loadState() {
		state := (FrameState) Flux.loadOptions(Flux#.pod, "session/frame", FrameState#)
		if (state.pos != null)	this.pos = state.pos
		if (state.size != null) this.size = state.size
	}

	internal Void saveState() {
		state := FrameState()
		state.pos = this.pos
		state.size = this.size
		Flux.saveOptions(Flux#.pod, "session/frame", state)
		sideBarPane.onUnload
	}
}

@Serializable
internal class FrameState {
	Point? pos := null
	Size? size := Size(800, 600)
}

internal class ToolBarBorder : Canvas {
	override Size prefSize(Hints hints := Hints.defVal) { return Size(100,2) }
	override Void onPaint(Graphics g) {
		g.brush = Desktop.sysNormShadow
		g.drawLine(0, 0, size.w, 0)
		g.brush = Desktop.sysHighlightShadow
		g.drawLine(0, 1, size.w, 1)
	}
}

internal class StatusBarBorder : Canvas {
	const Gradient gradient := Gradient("0% 0%, 0% 100%, $Desktop.sysNormShadow, $Desktop.sysBg")
	override Size prefSize(Hints hints := Hints.defVal) { return Size(100,4) }
	override Void onPaint(Graphics g) {
		g.brush = gradient
		g.fillRect(0, 0, size.w, size.h)
	}
}