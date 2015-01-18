
** (Events) -
** 
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
	virtual Void onViewDeactivated	(View view) { }	// when tab 
	virtual Void onViewModified		(View view) { }	// usually when the name / icon / dirty has changed
}
