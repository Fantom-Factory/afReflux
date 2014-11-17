using afIoc
using gfx
using fwt

internal class RenameFileCommand : RefluxCommand {
	@Inject	private FileExplorer	fileExplorer
			private File			file

	new make(File file, |This|in) : super.make(in) {
		this.file = file
		this.name = "Rename"
	}

	override Void invoked(Event? event) {
		fileExplorer.rename(file)
	}
}
