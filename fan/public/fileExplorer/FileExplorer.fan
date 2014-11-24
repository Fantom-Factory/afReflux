using afIoc
using gfx
using fwt

// TODO: convert FileExplorer to a service mixin
// TODO: move all command actions in here - make a generic command
class FileExplorer {
	
	@Inject private Registry	registry
	@Inject private RefluxIcons	icons
	@Inject private ImageSource	imgSrc
	@Inject private Reflux		reflux
	@Inject	private Frame		frame
					Uri			fileIconsRoot	:= `fan://afReflux/res/icons-file/`

	internal FileExplorerOptions options	

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
	
	Image fileToIcon(File f) {
		hidden := options.isHidden(f)

		if (f.isDir) {
			// can't cache osRoots 'cos it changes with flash drives et al
			osRoots	:= File.osRoots.map { it.normalize }		
			return osRoots.contains(f) ? icons.icon("icoFolderRoot", hidden) : icons.icon("icoFolder", hidden)
		}
		
		// look for explicit match based off ext
		if (f.ext != null) {
			icon := fileIcon("file${f.ext.capitalize}.png", hidden)
			if (icon != null) return icon
		}
		
		mimeType := f.mimeType?.noParams
		if (mimeType != null) {
			mime := mimeType.mediaType.fromDisplayName.capitalize + mimeType.subType.fromDisplayName.capitalize
			icon := fileIcon("file${mime}.png", hidden)
			if (icon != null) return icon

			mime = mimeType.mediaType.fromDisplayName.capitalize
			icon = fileIcon("file${mime}.png", hidden)
			if (icon != null) return icon
		}

		return fileIcon("file.png", hidden)
	}
	
	private Image? fileIcon(Str fileName, Bool hidden) {
		imgSrc.get(fileIconsRoot.plusName(fileName), hidden, false)
	}

	
	static Void main() {
		Reflux.start([,]) |Registry registry| {
			// maybe move to an event?
			panels := (Panels) registry.dependencyByType(Panels#)
			panels[FoldersPanel#].show	
			
			// maybe move this into FoldersPanel, a fav or def folder
			reflux := (Reflux) registry.dependencyByType(Reflux#)
			reflux.load(File.osRoots.first.normalize.uri)
		}
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
		"^/C:/Program Files \\(x86\\)/\$",
		"^/C:/ProgramData/\$",
		"^/C:/Recovery/\$",
		"^/C:/System Volume Information/\$",
		"^/C:/Users/\$",
		"^/C:/Windows/\$",
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

