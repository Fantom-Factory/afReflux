using gfx
using fwt

** Flux provides system level utilities for flux applications
class Flux {

	static const Log log := Flux#.pod.log
	
	internal static Image icon(Uri uri) {
		Image(("fan://icons"+uri).toUri)
	}
	
	internal static Type[] qnamesToTypes(Str[] qnames) {
		qnames.map |qn->Type| { Type.find(qn) }
	}
	
	** Given key like "flux.resource." find all indexed prop matches
	** for t, t.super, etc where the values are qualified type names
	internal static Type[] indexForInheritance(Str base, Type? t) {
		acc := Type[,]
		while (t != null) {
			acc.addAll(qnamesToTypes(Env.cur.index(base + t.qname)))
			t = t.base
		}
		return acc
	}
	
	** Read an session options file into memory.	An option file
	** is a serialized object stored at "etc/{pod}/{name}.fog".
	static Obj? loadOptions(Pod pod, Str name, Type? t)	{
		path := "etc/${pod.name}/${name}.fog"
		pathUri := path.toUri
		file := Env.cur.findFile(pathUri, false)
		if (file == null) file = Env.cur.workDir + pathUri
		Obj? value := null
		try {
			if (file.exists) {
				log.debug("Load options: $file")
				value = file.readObj
			}
		} catch (Err e) {
			log.err("Cannot load options: $file", e)
		}
		if (value == null) value = t?.make
		return value
	}

	** Save sessions options back to file. An option file is a
	** serialized object stored at "etc/{pod}/{name}.fog".
	** Return true on success, false on failure.
	static Bool saveOptions(Pod pod, Str name, Obj options)	{
		uri := `etc/${pod.name}/${name}.fog`
		file := Env.cur.workDir + uri
		try {
			log.debug("Save options: $file")
			file.writeObj(options, ["indent":2, "skipDefaults":true])
			return true
		} catch (Err e) {
			log.err("Cannot save options: $file", e)
			return false
		}
	}
}
