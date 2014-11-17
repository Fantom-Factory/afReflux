using afIoc
using gfx
using fwt

internal class CopyFileUriCommand : RefluxCommand {
	private File	file

	new make(File file, |This|in) : super.make(in) {
		this.file = file
	}

	override Void invoked(Event? event) {
		Desktop.clipboard.setText(file.uri.toStr)
	}
}
