using afIoc
using gfx
using fwt

internal class PasteFileCommand : RefluxCommand {
	@Inject	private FileExplorer	fileExplorer
			private File			file

	new make(File file, |This|in) : super.make(in) {
		this.file = file
		this.enabled = file.isDir
		this.name = "Paste"
	}

	override Void invoked(Event? event) {
		fileExplorer.paste(file)
	}
}
