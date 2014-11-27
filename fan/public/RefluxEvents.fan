
mixin RefluxEvents {

	virtual Void onLoad(Resource resource)	{ }

	virtual Void onRefresh(Resource resource) {
		onLoad(resource)
	}
	
	virtual Void onError(Error error)	{ }

	virtual Void onShowPanel(Panel panel) { }
	virtual Void onHidePanel(Panel panel) { }
	virtual Void onActivatePanel(Panel panel) { }
	virtual Void onDeactivatePanel(Panel panel) { }

	virtual Void onShowView(View view) { }
	virtual Void onHideView(View view) { }
	virtual Void onActivateView(View view) { }
	virtual Void onDeactivateView(View view) { }
}
