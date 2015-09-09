using afIoc3

** (Events) -
** Events raised by Reflux.
** 
** To handle these events, just implement this mixin and override the methods you want!
** You also need to registry yourself with the 'EventHub'. You can do this in the ctor:
** 
**   syntax: fantom
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
@Js
mixin RefluxEvents {
	virtual Void onLoadSession(Str:Obj? session) { }
	virtual Void onSaveSession(Str:Obj? session) { }
	
	virtual Void onLoad(Resource resource)		 { }

	virtual Void onRefresh(Resource? resource)	 { }
	
	virtual Void onError(Error error)			 { }

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

@Js
internal class RefluxEventsImpl : RefluxEvents {

//	@Inject private |->EventHub| eventHub
	@Inject private Scope scope
	
	new make(|This|in) { in(this) }
	
	override Void onLoadSession(Str:Obj? session)	{ eventHub().fireEvent(RefluxEvents#onLoadSession, 		[session]) }
	override Void onSaveSession(Str:Obj? session)	{ eventHub().fireEvent(RefluxEvents#onSaveSession, 		[session]) }
	
	override Void onLoad(Resource resource)			{ eventHub().fireEvent(RefluxEvents#onLoad,				[resource]) }

	override Void onRefresh(Resource? resource)		{ eventHub().fireEvent(RefluxEvents#onRefresh,			[resource]) }
	
	override Void onError(Error error)				{ eventHub().fireEvent(RefluxEvents#onError,			[error]) }

	override Void onPanelShown		(Panel panel)	{ eventHub().fireEvent(RefluxEvents#onPanelShown,		[panel]) }
	override Void onPanelHidden		(Panel panel)	{ eventHub().fireEvent(RefluxEvents#onPanelHidden,		[panel]) }
	override Void onPanelActivated	(Panel panel)	{ eventHub().fireEvent(RefluxEvents#onPanelActivated,	[panel]) }
	override Void onPanelDeactivated(Panel panel)	{ eventHub().fireEvent(RefluxEvents#onPanelDeactivated,	[panel]) }
	override Void onPanelModified	(Panel panel)	{ eventHub().fireEvent(RefluxEvents#onPanelModified,	[panel]) }

	override Void onViewShown		(View view)		{ eventHub().fireEvent(RefluxEvents#onViewShown,		[view]) }
	override Void onViewHidden		(View view)		{ eventHub().fireEvent(RefluxEvents#onViewHidden,		[view]) }
	override Void onViewActivated	(View view)		{ eventHub().fireEvent(RefluxEvents#onViewActivated,	[view]) }
	override Void onViewDeactivated	(View view)		{ eventHub().fireEvent(RefluxEvents#onViewDeactivated,	[view]) } 
	override Void onViewModified	(View view)		{ eventHub().fireEvent(RefluxEvents#onViewModified,		[view]) }

	private EventHub eventHub() {
		scope.resolveByType(EventHub#)
	}
}
