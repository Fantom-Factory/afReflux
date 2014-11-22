using afIoc
using gfx
using fwt

class FolderResource : Resource {

	@Inject private const Registry	reg

	override Uri 	uri
	override Str 	name
	override Image?	icon
	override Str	displayName
			 File	file

	new make(|This|in) : super.make(in) { 
		displayName = file.osPath
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
	
	Void addCommand(Menu menu, Type commandType, Obj[]? context := null) {
		menu.add(MenuItem.makeCommand(reg.autobuild(commandType, context)))		
	}
}