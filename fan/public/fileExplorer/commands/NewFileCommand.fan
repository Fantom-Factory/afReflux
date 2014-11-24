using afIoc
using gfx
using fwt

internal class NewFileCommand : RefluxCommand {
	@Inject	private Reflux	reflux
	private File	containingFolder

	new make(File containingFolder, |This|in) : super.make(in) {
		this.containingFolder = containingFolder
	}

	override Void invoked(Event? event) {
		fileName := Dialog.openPromptStr(reflux.window, "New File", "NewFile.txt")
		if (fileName != null) {
			containingFolder.createFile(fileName)
			reflux.refresh
		}
	}
}
