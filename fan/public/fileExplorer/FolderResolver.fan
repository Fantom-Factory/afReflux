using afIoc
using gfx

internal class FolderResolver : UriResolver {
	
	@Inject private Registry		registry
	@Inject private RefluxIcons		icons
	@Inject private ImageSource		imgSrc
	@Inject private FileExplorer	fileExplorer
					Uri				fileIconsRoot	:= `fan://afReflux/res/icons-file/`

	new make(|This|in) { in(this) }	
	
	override Resource? resolve(Uri uri) {
		file := uri.toFile.normalize
		if (!file.exists  || !file.isDir)
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
		// can't cache osRoots 'cos it changes with flash drives et al
		osRoots	:= File.osRoots.map { it.normalize }		
		return osRoots.contains(f) ? icons.icon("icoFolderRoot", hidden) : icons.icon("icoFolder", hidden)
	}
}
