
** (Service) - 
** Resolves URIs to 'Resources'. 
mixin UriResolver {
	
	** Return 'null' if the URI is not resolvable.
	abstract Resource? resolve(Uri uri)
}
