
@NoDoc
mixin UriResolvers {
	abstract Resource resolve(Uri uri)
}


internal class UriResolversImpl : UriResolvers {
	private UriResolver[] resolvers
	
	new make(UriResolver[] resolvers) {
		this.resolvers = resolvers
	}
	
	override Resource resolve(Uri uri) {
		resolvers.eachWhile { it.resolve(uri) } ?: throw ArgErr("Could not resolve URI: ${uri}")
	}
}
