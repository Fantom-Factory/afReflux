using afIoc3
using afPlastic
using afConcurrent

internal const class EventProvider : DependencyProvider {

	@Inject private const Registry 			registry
	@Inject private const PlasticCompiler	compiler
	@Inject private const EventTypes		eventTypes
	@Inject { type=[Type:Obj]# }
			private const LocalMap			cache
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(Scope currentScope, InjectionCtx ctx) {
		if (ctx.isFieldInjection && !ctx.field.hasFacet(Inject#))
			return false

		if (ctx.isFuncInjection && ctx.isFuncArgReserved)
			return false

		dependencyType := (ctx.field?.type ?: ctx.funcParam?.type).toNonNullable
		return dependencyType != EventTypes# && eventTypes.eventTypes.contains(dependencyType)
	}

	override Obj? provide(Scope currentScope, InjectionCtx ctx) {
		eventType := (ctx.field?.type ?: ctx.funcParam?.type).toNonNullable
		
		return cache.getOrAdd(eventType) |->Obj| {
			model	:= PlasticClassModel("${eventType.name}Impl", false).extend(eventType)
			methods	:= eventType.methods.exclude { it.parent == Obj# }.exclude { it.isPrivate }.exclude { it.isStatic }.findAll { it.isVirtual }
			methods.each |method| {
				methodCode	:= method.qname.replace(".", "#")
				params 		:= method.params.join(",") { it.name }
				if (params.isEmpty) params = ","
				model.overrideMethod(method, "eventHub.fireEvent(${methodCode}, [${params}])")
			}
			model.addField(EventHub#, "eventHub").addFacet(Inject#)
			
			implType := compiler.compileModel(model)
			
			return currentScope.build(implType)
		}
	}
}
