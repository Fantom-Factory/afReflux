using afIoc
using gfx
using fwt

internal class CopyFileCommand : RefluxCommand {
	@Inject	private FileExplorer	fileExplorer
			private File			file

	new make(File file, |This|in) : super.make(in) {
		this.file = file
		this.name = "Copy"
	}

	override Void invoked(Event? event) {
		fileExplorer.copy(file)
	}
}
