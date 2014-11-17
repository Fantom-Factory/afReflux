using afIoc
using gfx
using fwt

internal class OpenFileCommand : RefluxCommand {
	private File	file

	new make(File file, |This|in) : super.make(in) {
		this.file = file
	}

	override Void invoked(Event? event) {
		Desktop.launchProgram(file.uri)
	}
}
