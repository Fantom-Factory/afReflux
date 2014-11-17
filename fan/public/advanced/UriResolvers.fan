using afBeanUtils

@NoDoc
mixin UriResolvers {
	abstract Resource resolve(Uri uri)
}


internal class UriResolversImpl : UriResolvers {
	private Str:UriResolver resolvers
	
	new make(Str:UriResolver resolvers) {
		this.resolvers = resolvers
	}
	
	override Resource resolve(Uri uri) {
		resolver := resolvers[uri.scheme] ?: throw ArgNotFoundErr("Scheme not found: ${uri.scheme}", resolvers.keys)
		resource := resolver.resolve(uri) ?: throw ArgErr("Could not resolve URI: ${uri}")
		return resource
	}
}
