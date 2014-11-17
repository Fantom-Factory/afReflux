using gfx
using fwt

** ViewTab manages the history and state of a single view tab.
internal class ViewTab : EdgePane {
	
	internal const static Int historyLimit := 100

	internal Str text := "???"
	internal Image? image

	internal Frame frame
	internal View view := ErrView("Booting...")


	new make(Frame frame) {
		this.frame = frame
		this.view = ErrView("init")	// dummy startup view
		this.view.tab = this
	}

//	Void load(Uri uri, LoadMode mode) {
//		try {
//			r := loadResource(uri)
//			v := loadView(r)
//			doOnLoad(v, r)
//			doLoad(r, v, mode)
//		}
//		catch (ViewLoadErr err)
//			loadErr(ErrResource(uri), err.msg, mode, err.cause)
//		catch (Err err)
//			loadErr(ErrResource(uri), "Cannot load view", mode, err)
//	}

	private Void doLoad(View newView, LoadMode mode) {
		oldView := this.view

		// unload old view
		deactivate
		try { oldView.onUnload	} catch (Err e) { e.trace }
		oldView.tab = null
		oldView.frame = null

		// update my state
//		this.text	= r.name
//		this.image	= r.icon
		this.view	= newView
		this.top	= doBuildToolBar(newView)
		this.center	= newView
		this.bottom	= doBuildStatusBar(newView)
		parent?.relayout

		activate
	}

	Widget? doBuildToolBar(View v) {
		try return v.buildToolBar
		catch (Err e) {
			e.trace
			return null
		}
	}

	Widget? doBuildStatusBar(View v) {
		try return v.buildStatusBar
		catch (Err e) {
			e.trace
			return null
		}
	}

	Void activate()	{
		frame.title = "Flux - $text"
		try { view.onActive } catch (Err e) { e.trace }
		if (view isnot ErrView) frame.sideBarPane.onActive(view)
	}

	Void deactivate() {
		try { view.onInactive } catch (Err e) { e.trace }
		if (view isnot ErrView) frame.sideBarPane.onInactive(view)
	}
}
