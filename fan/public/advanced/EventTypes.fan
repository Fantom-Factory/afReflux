using afIoc3
using fwt
using afPlastic

@NoDoc	// Don't overwhelm the masses!
const class EventTypes {
	
	const Type[]	eventTypes 
	
	private new make(Type[] eventTypes) {
		this.eventTypes = eventTypes
	}

}
