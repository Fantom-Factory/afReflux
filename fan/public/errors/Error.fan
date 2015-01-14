
** Represents an 'Err' displayed in the 'ErrorsPanel'. 
class Error {
	@NoDoc // not used yet
	const Int		id
	const Err		err
	const DateTime	when
	
	@NoDoc // boring!
	new make(|This|in) { in(this) }
}

