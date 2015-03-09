
internal class LogMsgs {
	
	// ---- RefluxBuilder -------------------------------------------------------------------------

	static Str refluxBuilder_foundPod(Pod pod) {
		"Found pod '$pod.name'"
	}

	static Str refluxBuilder_foundType(Type type) {
		"Found mod '$type.qname' "
	}

	static Str refluxBuilder_noModuleFound() {
		"Could not find any AppModules!"
	}

	static Str refluxBuilder_addModuleToPodMeta(Pod pod, Type mod) {
		"Pod '${pod.name}' should define the following meta - \"afIoc.module\" : \"${mod.qname}\""
	}
}
