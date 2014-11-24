using afIoc
using gfx

internal class FileResolver : UriResolver {
	
	@Inject private Registry		registry
	@Inject private FileExplorer	fileExplorer

	new make(|This|in) { in(this) }	
	
	override Resource? resolve(Uri uri) {
		file := uri.toFile.normalize
		if (!file.exists)
			return null
		return registry.autobuild(file.isDir ? FolderResource# : FileResource#, null, [
			FileResource#uri	: file.uri,
			FileResource#name	: file.uri.name,
			FileResource#file	: file,
			FileResource#icon	: fileExplorer.fileToIcon(file)
		])
	}	
}
