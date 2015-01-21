
** (Events) -
** Events raised by Reflux.
** 
** To handle these events, just implement this mixin and override the methods you want!
** You also need to registry yourself with the 'EventHub'. You can do this in the ctor:
** 
**   class MyService : RefluxEvents {
**       new make(EventHub eventHub) {
**           eventHub.register(this)
**       }
** 
**       override Void onLoad(Resource resource) { ... }
**   }
** 
** Note that instances of 'Panels', 'Views' and 'GlobalCommands' are automatically added 
** to 'EventHub' by default. 
mixin RefluxEvents {
	virtual Void onLoadSession(Str:Obj? session) { }
	virtual Void onSaveSession(Str:Obj? session) { }
	
	virtual Void onLoad(Resource resource)	{ }
	
	virtual Void onError(Error error)	{ }

	virtual Void onPanelShown		(Panel panel) { }
	virtual Void onPanelHidden		(Panel panel) { }
	virtual Void onPanelActivated	(Panel panel) { }
	virtual Void onPanelDeactivated	(Panel panel) { }
	virtual Void onPanelModified	(Panel panel) { }

	virtual Void onViewShown		(View view) { }
	virtual Void onViewHidden		(View view) { }
	virtual Void onViewActivated	(View view) { }
	virtual Void onViewDeactivated	(View view) { } 
	virtual Void onViewModified		(View view) { }	// usually when the name / icon / dirty has changed
}
