using afIoc
using fwt
using afPlastic

@NoDoc	@Js	// Don't overwhelm the masses!
const class EventTypes {
	
	const Type[]	eventTypes 
	
	private new make(Type[] eventTypes) {
		this.eventTypes = eventTypes
	}

}
