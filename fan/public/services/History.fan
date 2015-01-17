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
	abstract Bool canNavBackward()

	@NoDoc
	abstract Bool canNavForward()
	
	@NoDoc
	abstract Void load(Resource resource, LoadCtx ctx)
}

class HistoryImpl : History {
			private Uri[]	history	:= [,]
			private Int?	showing
	@Inject	private Reflux	reflux

	new make(|This|in) { in(this) }
	
	override Void navBackward() {
		if (canNavBackward) {
			showing++
			reflux.load(history[showing], LoadCtx { it.addToHistory = false })
		}
	}
	
	override Void navForward() {
		if (canNavForward) {
			showing--
			reflux.load(history[showing], LoadCtx { it.addToHistory = false })			
		}
	}
	
	override Bool canNavBackward() {
		showing != null && showing < (history.size-1)
	}

	override Bool canNavForward() {
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
