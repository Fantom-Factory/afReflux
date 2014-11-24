using afIoc
using gfx
using fwt

class FileResource : Resource {

	@Inject protected const Registry			registry
	@Inject protected const DefaultFileViews	defaultViews
	@Inject protected 		FileExplorerCmds	fileCmds

	override Uri 	uri
	override Str 	name
	override Image?	icon
	override Str	displayName
			 File	file

	new make(|This|in) : super.make(in) { 
		displayName = file.osPath
	}

	override Type? defaultView() {
		defaultViews[file.ext]
	}
	
	override Menu populatePopup(Menu m) {
		menu := super.populatePopup(m)
		
		if (!file.isDir) {
			addCmd(menu, fileCmds.openFileCmd(file))		
			menu.addSep
		}

		// TODO: F2 accel
		addCmd(menu, fileCmds.renameFileCmd(file))
		addCmd(menu, fileCmds.deleteFileCmd(file))

		menu.addSep
		addCmd(menu, fileCmds.cutFileCmd(file))
		addCmd(menu, fileCmds.copyFileCmd(file))
		addCmd(menu, fileCmds.pasteFileCmd(file))

		menu.addSep
		addCmd(menu, fileCmds.copyFileNameCmd(file))
		addCmd(menu, fileCmds.copyFilePathCmd(file))
		addCmd(menu, fileCmds.copyFileUriCmd(file))

		if (file.isDir) {
			menu.addSep
			addCmd(menu, fileCmds.newFileCmd(file))
			addCmd(menu, fileCmds.newFolderCmd(file))
		}
		
		// open
		// open in new tab
		// edit
		// find in files
		// delete
		// rename
		// new - file / folder
		// cmd prompt
		// add to zip
		// properties
		
		return menu 
	}
	
	override Void doAction() {
		// FIXME: specify def action for mimetype / ext
		if (uri.isDir) {
			super.doAction
			return
		}
		
		if (uri.mimeType?.mediaType == "image") {
			super.doAction
			return
		}

		if (uri.mimeType?.noParams == MimeType("text/html")) {
			super.doAction
			return
		}
		
		Desktop.launchProgram(uri)
	}
	
	Void addCommand(Menu menu, Type commandType, Obj[]? context := null) {
		menu.add(MenuItem.makeCommand(registry.autobuild(commandType, context)))
	}

	Void addCmd(Menu menu, Command cmd) {
		menu.add(MenuItem.makeCommand(cmd))
	}
}



class FolderResource : FileResource {
	new make(|This|in) : super.make(in) { }
	override Type? defaultView() {
		FolderView#
	}
}
