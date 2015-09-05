using afIoc3
using fwt

** (Service) - 
** Maintains a history of View URIs.
mixin History {
	
	** Loads the previous history item.
	** Does nothing if there is no prev.
	abstract Void navBackward()
	
	** Loads the next history item. 
	** Does nothing if there is no next.
	abstract Void navForward()
	
	** Returns a unique list of URIs visited.
	abstract Resource[] history()

	** Clears the history.
	abstract Void clear()

	@NoDoc
	abstract Bool navBackwardEnabled()

	@NoDoc
	abstract Bool navForwardEnabled()
	
	@NoDoc
	abstract Void load(Resource resource, LoadCtx ctx)
}

internal class HistoryImpl : History, RefluxEvents {
			private	Resource[]	backStack		:= Resource[,]
			private	Resource[]	forwardStack	:= Resource[,]
			private Resource?	showing
			override Resource[] history			:= Resource[,]
	@Inject	private Registry	registry
//	@Inject	private UriResolvers
	@Inject	private Reflux		reflux

	new make(EventHub eventHub, |This|in) {
		in(this)
		eventHub.register(this)
	}
	
	override Void navBackward() {
		if (!navBackwardEnabled) return

		if (showing != null)
			forwardStack.push(showing)
		showing = backStack.pop
	
		reflux.loadResource(showing, LoadCtx { it.addToHistory = false })
	}
	
	override Void navForward() {
		if (!navForwardEnabled) return
		
		if (showing != null)
			backStack.push(showing)
		showing = forwardStack.pop
	
		reflux.loadResource(showing, LoadCtx { it.addToHistory = false })
	}
	
	override Bool navBackwardEnabled() {
		!backStack.isEmpty		
	}

	override Bool navForwardEnabled() {
		!forwardStack.isEmpty
	}

	override Void load(Resource resource, LoadCtx ctx) {		
		if (ctx.addToHistory && resource != showing) {
			if (showing != null)
				backStack.push(showing)
			showing = resource
			forwardStack.clear	// you can't return to the same future once you've changed the past!

			if (backStack.size > 50)
				backStack.size = 50	// keep 50 entries
		}

		history.insert(0, resource)
		history = history.unique
		if (history.size > 50) history.size = 50

		showHistoryMenu
	}
	
	override Void clear() {
		backStack.clear
		forwardStack.clear
		history.clear

		showHistoryMenu
	}
	
	private Void showHistoryMenu() {
		historyMenu := (Menu) registry.serviceById("afReflux.historyMenu")		
		((MenuItem[]) historyMenu.children).each { if (it.command is HistoryCommand) historyMenu.remove(it) }
		
		history := history.dup
		history.insert(0, showing)
		history = history.unique
		if (history.size > 13) history.size = 13	// TODO: move to prefs
		history.each { historyMenu.add(MenuItem.makeCommand(registry.autobuild(HistoryCommand#, [it]))) }		
	}
	
	override Void onViewActivated(View view) {
		// treat tabbing the same as loading, so we can nav back.
		if (view.resource != null)
			load(view.resource, LoadCtx())
	}
	
	override Void onLoadSession(Str:Obj? session) {
		history = Uri?[,].addAll(session["afReflux.history"] ?: Uri#.emptyList).map |uri->Resource?| {
			try 	return reflux.resolve(uri.toStr)
			catch	return null
		}.exclude { it == null }
	}

	override Void onSaveSession(Str:Obj? session) {
		session["afReflux.history"] = history.map { it.uri }
	}
}

internal class HistoryCommand : RefluxCommand {
	new make(Resource resource, Reflux reflux, |This|in) : super.make(in) {
		this.name = (resource.uri.toStr != resource.displayName) ? resource.displayName : Url(resource.uri).minusFrag.toStr
		this.icon = resource.icon
		this.onInvoke.add { reflux.loadResource(resource) }
	}
}