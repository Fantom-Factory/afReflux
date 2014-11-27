using afIoc

// TODO: save options as ext file?
@Serializable
class FileExplorerPrefs {

	@Inject @Transient 
	private FileExplorerEvents	events
	
	Str:Uri shortcuts := 
		Str:Uri[:] { it.ordered=true }
			.add("My Computer", `file:/C:/`) 
			.add("My Documents", `file:/C:/Users/${Env.cur.user}/Documents/`) 
			.add("My Downloads", `file:/C:/Users/${Env.cur.user}/Downloads/`) 
			.add("C:\\Apps\\fantom-1.0.66", `file:/C:/Apps/fantom-1.0.66/`) 
			.add("C:\\Projects", `file:/C:/Projects/`) 
			.add("C:\\Temp", `file:/C:/Temp/`) 

	Bool showHiddenFiles	:= false {
		set {
			&showHiddenFiles = it
			events.onShowHiddenFiles(it)
		}
	}
	
	Str[] hiddenNameFilters := [
		"^\\..*\$",
		"^\\\$.*\$",
		"^build\$",
	]

	Str[] hiddenPathFilters := [
		"^/C:/Boot/\$",
		"^/C:/Documents and Settings/\$",
		"^/C:/MSOCache/\$",
		"^/C:/Program Files/\$",
		"^/C:/Program Files \\(x86\\)/\$",
		"^/C:/ProgramData/\$",
		"^/C:/Recovery/\$",
		"^/C:/System Volume Information/\$",
		"^/C:/Users/\$",
		"^/C:/Windows/\$",
		"^/C:/bootmgr\$",
		"^/C:/BOOTSECT.BAK\$",
	]

	new make(|This|? f := null) { f?.call(this) }

	Bool isHidden(File file) {
		hiddenNameFilters.map { it.toRegex }.any |Regex rex -> Bool| { rex.matches(file.name) } ||
		hiddenPathFilters.map { it.toRegex }.any |Regex rex -> Bool| { rex.matches(file.uri.pathStr) }
	}

	Bool shouldHide(File file) {
		showHiddenFiles ? false : isHidden(file)
	}
}
