using fwt

abstract class View : ContentPane {
	
	** Get the top level flux window.
	Frame? frame { internal set }
	
	internal ViewTab? tab
	
	** Build a view specific toolbar to merge into the frame.
	** This method is called after `onLoad`, but before mounting.
	** Return null for no toolbar.	See `flux::Frame.command` if you
	** wish to use predefined commands like cut/copy/paste.
	**
	virtual Widget? buildToolBar() { return null }

	** Build a view specific status bar to merge into the frame.
	** This method is called after `onLoad`, but before mounting.
	** Return null for no status bar.
	virtual Widget? buildStatusBar() { return null }
	
	** Callback to load the `resource`.	At this point the
	** view can access `frame`, but has not been mounted yet.
	abstract Void onLoad()

	** Callback when the view is being unloaded.
	virtual Void onUnload() {}

	** Callback when the view is selected as the current tab.
	** This method should be used to enable predefined commands
	** such as find or replace which the view will handle.
	virtual Void onActive() {}

	** Callback when the view is deactivated because the user
	** has selected another tab.
	virtual Void onInactive() {}

	** Callback when predefined view managed commands such as
	** find and replace are invoked. Before view managed commands
	** are routed to the view, they must be enabled in the onActive
	** callback.	A convenient technique is to route to handler
	** methods via trap:
	**
	**   trap("on${id.capitalize}", [event])
	**
	virtual Void onCommand(Str id, Event? event) {}
}
