using afIoc
using gfx

internal class FileResolver : UriResolver {
	
	@Inject private Registry		registry
	@Inject private RefluxIcons		icons
	@Inject private ImageSource		imgSrc
	@Inject private FileExplorer	fileExplorer
			private File[]			osRoots			:= File.osRoots.map { it.normalize }
					Uri				fileIconsRoot	:= `fan://afReflux/res/icons-file/`

	new make(|This|in) { in(this) }	
	
	override Resource? resolve(Uri uri) {
		file := uri.toFile.normalize
		if (!file.exists)
			return null
		return registry.autobuild(FileResource#, null, [
			FileResource#uri	: file.uri,
			FileResource#name	: file.uri.name,
			FileResource#file	: file,
			FileResource#icon	: fileToIcon(file)
		])
	}
	
	Image fileToIcon(File f) {
		hidden := fileExplorer.options.isHidden(f)
		
		// look for explicit match based off ext
		if (f.ext != null) {
			icon := fileIcon("file${f.ext.capitalize}.png", hidden)
			if (icon != null) return icon
		}
		
		mimeType := f.mimeType?.noParams
		if (mimeType != null) {
			if (f.isDir)
				return osRoots.contains(f) ? icons.icon("icoFolderRoot", hidden) : icons.icon("icoFolder", hidden)
			
			mime := mimeType.mediaType.fromDisplayName.capitalize + mimeType.subType.fromDisplayName.capitalize
			icon := fileIcon("file${mime}.png", hidden)
			if (icon != null) return icon

			mime = mimeType.mediaType.fromDisplayName.capitalize
			icon = fileIcon("file${mime}.png", hidden)
			if (icon != null) return icon
		}

		return fileIcon("file.png", hidden)
	}
	
	Image? fileIcon(Str fileName, Bool hidden) {
		imgSrc.get(fileIconsRoot.plusName(fileName), hidden, false)
	}
}
