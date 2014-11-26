using afIoc
using afPlastic
using afConcurrent

const class EventProvider : DependencyProvider {

	@Inject private const Registry 			registry
	@Inject private const PlasticCompiler	compiler
	@Inject private const EventTypes		eventTypes
	@Inject { type=[Type:Obj]# }
			private const LocalMap			cache
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(InjectionCtx injectionCtx) {
		injectionCtx.fieldFacets.any { it.typeof == Inject# } && 
		injectionCtx.injectingIntoType.pod.name != "afIoc" && 
		injectionCtx.injectingIntoType != EventTypes# &&
		injectionCtx.dependencyType != EventTypes# &&
		eventTypes.eventTypes.contains(injectionCtx.dependencyType)
	}

	override Obj? provide(InjectionCtx injectionCtx) {
		eventType := injectionCtx.dependencyType
		
		return cache.getOrAdd(eventType) |->Obj| {
			echo("building $eventType")
			model	:= PlasticClassModel("${eventType.name}Impl", false).extend(eventType)
			methods	:= eventType.methods.exclude { it.parent == Obj# }.exclude { it.isPrivate }.exclude { it.isStatic }.findAll { it.isVirtual }
			methods.each |method| {
				methodCode	:= method.qname.replace(".", "#")
				params 		:= method.params.join(",") { it.name }
				model.overrideMethod(method, "echo(${methodCode.toCode});eventHub.fireEvent(${methodCode}, [${params}])")
			}
			model.addField(EventHub#, "eventHub").addFacet(Inject#)
			
			implType := compiler.compileModel(model)
			
			return registry.autobuild(implType)
		}
	}
}
