using afIoc
using gfx
using fwt

// TODO: convert FileExplorer to a service mixin
internal class FileExplorer {
	
	@Inject private Registry	registry
	@Inject private Reflux		reflux
	@Inject	private Frame		frame

	FileExplorerOptions options	
	
	private File? copiedFile
	private File? cutFile

	new make(|This| in) {
		in(this)
		this.options = registry.autobuild(FileExplorerOptions#)
	}
	
	Void rename(File file) {
		newName := Dialog.openPromptStr(frame, "Rename", file.name)
		if (newName != null) {
			file.rename(newName)
			reflux.refresh
		}
	}
	
	Void cut(File file) {
		cutFile		= file
		copiedFile	= null
	}
	
	Void copy(File file) {
		cutFile		= null
		copiedFile	= file
	}

	Void paste(File destDir) {
		// TODO: dialog for copy overwrite options
		if (cutFile != null) {
			cutFile.moveInto(destDir)
			cutFile = null
		}
		if (copiedFile != null) {
			copiedFile.copyInto(destDir)
			copiedFile = null
		}
		reflux.refresh
	}
}

// TODO: save options as ext file - rename as Prefs?
internal class FileExplorerOptions {

	@Inject private FileExplorerEvents	events
	
	new make(|This| in) { in(this) }
	
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
		"^/C:/Program Files (x86)/\$",
		"^/C:/ProgramData/\$",
		"^/C:/Recovery/\$",
		"^/C:/System Volume Information/\$",
		"^/C:/Users/\$",
		"^/C:/bootmgr\$",
		"^/C:/BOOTSECT.BAK\$",
	]

	Bool isHidden(File file) {
		hiddenNameFilters.map { it.toRegex }.any |Regex rex -> Bool| { rex.matches(file.name) } ||
		hiddenPathFilters.map { it.toRegex }.any |Regex rex -> Bool| { rex.matches(file.uri.pathStr) }
	}

	Bool shouldHide(File file) {
		showHiddenFiles ? false : isHidden(file)
	}
}

mixin FileExplorerEvents {

	virtual Void onShowHiddenFiles(Bool show)	{ }

	// add cut, copy, paste here...maybe
	
}

//FIXME: make am injectale plastic version!
class FileExplorerEventsImpl : FileExplorerEvents {
	@Inject EventHub eventHub	
	new make(|This|in) { in(this) }
	
	override Void onShowHiddenFiles(Bool show)	{
		eventHub.fireEvent(FileExplorerEvents#onShowHiddenFiles, [show])
	}
}
