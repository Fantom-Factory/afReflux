
@NoDoc
mixin UriResolvers {
	abstract Resource resolve(Str uri)
}


internal class UriResolversImpl : UriResolvers {
	private UriResolver[] resolvers
	
	new make(UriResolver[] resolvers) {
		this.resolvers = resolvers
	}
	
	override Resource resolve(Str uri) {
		resolvers.eachWhile { it.resolve(uri) } ?: throw UnresolvedErr("Could not resolve URI: ${uri}")
	}
}
