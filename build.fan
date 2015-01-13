using build
using fanr

class Build : BuildPod {

	new make() {
		podName = "afReflux"
		summary = "Flux::Reloaded"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Cmdr",
			"repo.private"	: "true",

			"afIoc.module"	: "afReflux::RefluxModule"
		]

		depends = [	
			"sys        1.0", 
			"gfx        1.0",
			"fwt        1.0",
			"syntax     1.0",
//			"flux       1.0",
//			"fluxText   1.0",
			"concurrent 1.0",	// for Actor.sleep when loading images
			
			// ---- Core ------------------------
			"afBeanUtils  1.0", 
			"afConcurrent 1.0", 
			"afPlastic    1.0", 
			"afIoc        2.0.1+", 
			"afIocConfig  1.0"
		]

		srcDirs = [`fan/`, `fan/public/`, `fan/public/services/`, `fan/public/fwt/`, `fan/public/errors/`, `fan/public/advanced/`, `fan/internal/`, `fan/internal/commands/`, `fan/explorer/`, `fan/explorer/textEditor/`, `fan/explorer/other/`]
		resDirs = [`locale/`, `res/icons-eclipse/`, `res/icons-file/`]
		
		javaDirs = [`java/`]
	}
}