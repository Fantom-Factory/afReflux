using build
using fanr

class Build : BuildPod {

	new make() {
//		podName = "afCmdr"
		podName = "afReflux"
		summary = "Flux::Reloaded"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Cmdr",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afcmdr",
			"repo.private"	: "true",

			"afIoc.module"	: "afReflux::RefluxModule"
		]

		depends = [	
			"sys 1.0", 
			"gfx 1.0",
			"fwt 1.0",
			"concurrent 1.0",
//			"flux 1.0",
			
			// ---- Core ------------------------
			"afBeanUtils  1.0", 
			"afConcurrent 1.0", 
			"afIoc        2.0.1+", 
			"afIocConfig  1.0",
			"afIocEnv     1.0",

			"web     1.0",
			"afBedSheet     1.4"

		]

		srcDirs = [`fan/`, `fan/flux/`, `fan/flux/public/`, `fan/flux/public/services/`, `fan/flux/public/fwt/`, `fan/flux/internal/`, `fan/flux/internal/commands/`, `fan/flux/folders/`, `fan/flux/folders/commands/`, `fan/flux/errors/`, `fan/flux/advanced/`]
		resDirs = [`res/icons-eclipse/`, `res/icons/` ,`res/icons-file/`]
		
//		javaDirs = [`java/`]
	}
}