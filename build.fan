using build
using fanr

class Build : BuildPod {

	new make() {
		podName = "afReflux"
		summary = "A framework for creating FWT desktop applications"
		version = Version("0.1.3")

		meta = [
			"proj.name"		: "Reflux",
			"afIoc.module"	: "afReflux::RefluxModule",
			"repo.tags"		: "system",
			"repo.public"	: "false"
		]

		depends = [	
			"sys          1.0.68 - 1.0", 
			"gfx          1.0.68 - 1.0",
			"fwt          1.0.68 - 1.0",			
			"concurrent   1.0.68 - 1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0", 
			"afConcurrent 1.0.12 - 1.0", 
			"afPlastic    1.1.0  - 1.1", 
			"afIoc        3.0.0  - 3.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/commands/`, `fan/public/`, `fan/public/advanced/`, `fan/public/errors/`, `fan/public/fwt/`, `fan/public/services/`]
		resDirs = [`doc/`, `locale/`, `res/icons-eclipse/`]
		
		javaDirs = [`java/`]
	}
}