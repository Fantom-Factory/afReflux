
** Implement to resolve URIs to a 'Resource'.
** 
** 'UriResolver' implementations should be contributed to the 'UriResolvers' service:
** 
**   @Contribute { serviceType=UriResolvers# }
** 	 internal static Void contributeUriResolvers(Configuration config) {
** 	     resolver := MyUriResolver()
** 	     config.add(resolver)
** 	 }
** 
** If your resolver requires dependencies to be injected then it should be *autobuilt*.
** It is also good practice to contribute the instance with an ID, so others may override it if they wish:
** 
**   @Contribute { serviceType=UriResolvers# }
** 	 internal static Void contributeUriResolvers(Configuration config) {
** 	     resolver := config.autobuild(MyUriResolver#)
** 	     config["myResolver"] = resolver
** 	 }
** 
mixin UriResolver {
	
	** Return 'null' if the URI is not applicable to this resolver.
	abstract Resource? resolve(Str uri)
}
