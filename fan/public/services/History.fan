
** (Service) -
** 
mixin History {
	
	abstract Void navBackward()
	
	abstract Void navForward()
	
	Bool canNavBackward() {
		false
	}

	Bool canNavForward() {
		false
	}
}

class HistoryImpl : History {
	
	override Void navBackward() {
		
	}
	
	override Void navForward() {
		
	}
}
