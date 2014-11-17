using afIoc
using gfx
using fwt

internal class CutFileCommand : RefluxCommand {
	@Inject	private FileExplorer	fileExplorer
			private File			file

	new make(File file, |This|in) : super.make(in) {
		this.file = file
		this.name = "Cut"
	}

	override Void invoked(Event? event) {
		fileExplorer.cut(file)
	}
}
