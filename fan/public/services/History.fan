using afIoc

** (Service) - 
** Maintains a history of view URIs.
mixin History {
	
	** Loads the previous history item.
	** Does nothing if there is no prev.
	abstract Void navBackward()
	
	** Loads the next history item. 
	** Does nothing if there is no next.
	abstract Void navForward()
	
	@NoDoc
	abstract Bool navBackwardEnabled()

	@NoDoc
	abstract Bool navForwardEnabled()
	
	@NoDoc
	abstract Void load(Resource resource, LoadCtx ctx)
}

internal class HistoryImpl : History {
			// no point in making this public unless we also make the index public
			private Uri[]	history	:= [,]
			private Int?	showing
	@Inject	private Reflux	reflux

	new make(|This|in) { in(this) }
	
	override Void navBackward() {
		if (navBackwardEnabled) {
			showing++
			reflux.load(history[showing], LoadCtx { it.addToHistory = false })
		}
	}
	
	override Void navForward() {
		if (navForwardEnabled) {
			showing--
			reflux.load(history[showing], LoadCtx { it.addToHistory = false })			
		}
	}
	
	override Bool navBackwardEnabled() {
		showing != null && showing < (history.size-1)
	}

	override Bool navForwardEnabled() {
		showing != null && showing > 0
	}

	override Void load(Resource resource, LoadCtx ctx) {
		if (ctx.addToHistory) {
			if (history.size > 99)
				history.size = 99	// keep 100 entries

			if (history.first != resource.uri) {
				history.insert(0, resource.uri)
				showing = 0
			}
		}
	}
}
