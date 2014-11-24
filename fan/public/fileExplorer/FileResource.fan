using afIoc
using gfx
using fwt

class FileResource : Resource {

	@Inject protected const Registry			registry
	@Inject protected const DefaultFileViews	defaultViews

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
		
		// TODO: how to contribute and add the file

		if (!file.isDir) {
			addCommand(menu, OpenFileCommand#, [file])		
			menu.addSep
		}

		addCommand(menu, RenameFileCommand#, [file])	// TODO: F2 accel
		addCommand(menu, DeleteFileCommand#, [file])

		menu.addSep
		addCommand(menu, CutFileCommand#, [file])
		addCommand(menu, CopyFileCommand#, [file])
		addCommand(menu, PasteFileCommand#, [file])
		
		menu.addSep
		addCommand(menu, CopyFileNameCommand#, [file])
		addCommand(menu, CopyFilePathCommand#, [file])
		addCommand(menu, CopyFileUriCommand#, [file])

		if (file.isDir) {
			menu.addSep
			addCommand(menu, NewFileCommand#, [file])
			addCommand(menu, NewFolderCommand#, [file])
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
}



class FolderResource : FileResource {

	new make(|This|in) : super.make(in) { }

	override Type? defaultView() {
		FolderView#
	}
	
	override Menu populatePopup(Menu m) {
		menu := super.populatePopup(m)
		
		addCommand(menu, OpenFileCommand#,		[file])		
		menu.addSep

		addCommand(menu, RenameFileCommand#,	[file])	// TODO: F2 accel
		addCommand(menu, DeleteFileCommand#,	[file])

		menu.addSep
		addCommand(menu, CutFileCommand#,		[file])
		addCommand(menu, CopyFileCommand#,		[file])
		addCommand(menu, PasteFileCommand#,		[file])
		
		menu.addSep
		addCommand(menu, CopyFileNameCommand#,	[file])
		addCommand(menu, CopyFilePathCommand#,	[file])
		addCommand(menu, CopyFileUriCommand#,	[file])

		menu.addSep
		addCommand(menu, NewFileCommand#,		[file])
		addCommand(menu, NewFolderCommand#,		[file])
		
		return menu 
	}	
}
