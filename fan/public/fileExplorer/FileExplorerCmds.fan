using afIoc
using gfx
using fwt

class FileExplorerCmds {
	@Inject private Registry		registry
	@Inject private Reflux			reflux
	@Inject private RefluxIcons		refluxIcons
	@Inject	private FileExplorer	fileExplorer

	new make(|This|in) { in(this) }

	Command cutFileCmd(File file) {
		command("CutFile") {
			it.name = "Cut"
			it.onInvoke.add {
				fileExplorer.cut(file)
			}
		}
	}
	
	Command copyFileCmd(File file) {
		command("CopyFile") {
			it.name = "Copy"
			it.onInvoke.add {
				fileExplorer.copy(file)
			}
		}
	}
	
	Command pasteFileCmd(File file) {
		command("PasteFile") {
			it.name = "Paste"
			it.enabled = file.isDir
			it.onInvoke.add {
				fileExplorer.paste(file)
			}
		}
	}
	
	private RefluxCommand command(Str baseName) {
		((RefluxCommand) registry.autobuild(RefluxCommand#)) {
			it.name = baseName.toDisplayName
			it.icon = refluxIcons["cmd${baseName}"]
		}
	}
}
