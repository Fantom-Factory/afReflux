using afIoc
using gfx
using fwt

internal class DeleteFileCommand : RefluxCommand {
	@Inject	private Reflux	reflux
			private File	file

	new make(File file, |This|in) : super.make(in) {
		this.file = file
		this.name = "Delete"
	}

	override Void invoked(Event? event) {
		okay := Dialog.openQuestion(reflux.window, "Delete ${file.osPath}?", null, Dialog.yesNo)
		if (okay == Dialog.yes) {
			file.delete
			reflux.refresh
		}
	}
}
