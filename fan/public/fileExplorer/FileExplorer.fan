using afIoc
using gfx
using fwt

mixin FileExplorer {
	abstract Void rename(File file)
	abstract Void delete(File file)
	abstract Void cut(File file)
	abstract Void copy(File file)
	abstract Void paste(File destDir)
	abstract Void newFile(File containingFolder)
	abstract Void newFolder(File containingFolder)
	abstract Void openFile(File file)
	abstract Image fileToIcon(File f)
	abstract FileExplorerPrefs preferences()

	static Void main() {
		Reflux.start([,]) |Reflux reflux| {
			reflux.showPanel(FoldersPanel#)
			reflux.load(File.osRoots.first.normalize.uri)
		}
	}
}
	
internal class FileExplorerImpl : FileExplorer {
	@Inject private Registry	registry
	@Inject private RefluxIcons	icons
	@Inject private ImageSource	imgSrc
	@Inject private PrefsCache	prefsCache
	@Inject private Reflux		reflux
					Uri			fileIconsRoot	:= `fan://afReflux/res/icons-file/`

	private File? copiedFile
	private File? cutFile

	new make(|This| in) { in(this) }

	override Void rename(File file) {
		newName := Dialog.openPromptStr(reflux.window, "Rename", file.name)
		if (newName != null) {
			file.rename(newName)
			reflux.refresh
		}
	}

	override Void delete(File file) {
		okay := Dialog.openQuestion(reflux.window, "Delete ${file.osPath}?", null, Dialog.yesNo)
		if (okay == Dialog.yes) {
			file.delete
			reflux.refresh
		}
	}

	override Void cut(File file) {
		cutFile		= file
		copiedFile	= null
	}
	
	override Void copy(File file) {
		cutFile		= null
		copiedFile	= file
	}

	override Void paste(File destDir) {
		// TODO: dialog for copy overwrite options
		if (cutFile != null) {
			cutFile.moveInto(destDir)
			cutFile = null
		}
		if (copiedFile != null) {
			copiedFile.copyInto(destDir)
			copiedFile = null
		}
		reflux := (Reflux) registry.serviceById(Reflux#.qname)
		reflux.refresh
	}
	
	override Void newFile(File containingFolder) {
		fileName := Dialog.openPromptStr(reflux.window, "New File", "NewFile.txt")
		if (fileName != null) {
			containingFolder.createFile(fileName)
			reflux.refresh
		}
	}

	override Void newFolder(File containingFolder) {
		dirName := Dialog.openPromptStr(reflux.window, "New Folder", "NewFolder")
		if (dirName != null) {
			containingFolder.createDir(dirName)
			reflux.refresh
		}
	}
	
	override Void openFile(File file) {
		Desktop.launchProgram(file.uri)
	}
	
	override Image fileToIcon(File f) {
		hidden := preferences.isHidden(f)

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

	override FileExplorerPrefs preferences() {
		prefsCache.loadPrefs(FileExplorerPrefs#)
	}

	private Image? fileIcon(Str fileName, Bool hidden) {
		imgSrc.get(fileIconsRoot.plusName(fileName), hidden, false)
	}
}
