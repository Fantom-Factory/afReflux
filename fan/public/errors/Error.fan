
** Represents an 'Err' displayed in the 'ErrorsPanel'. 
class Error {
	@NoDoc // not used yet
	const Int		id
	
	** The 'Err' throw.
	const Err		err
	
	** When the 'Err' was thrown.
	const DateTime	when
	
	@NoDoc // boring!
	new make(|This|in) { in(this) }
}

