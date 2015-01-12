using afIoc
using gfx
using fwt

// FIXME: Move to a RefluxExplorer pod
@NoDoc
class FileExplorerModule {

	static Void defineServices(ServiceDefinitions defs) {		
		defs.add(FileExplorer#)
		defs.add(FileExplorerCmds#)
		defs.add(DefaultResourceViews#)
		defs.add(DefaultFileViews#)
	}

	@Contribute { serviceType=UriResolvers# }
	internal static Void contributeUriResolvers(Configuration config) {
		config["file"] = config.autobuild(FileResolver#)
	}

	@Contribute { serviceType=Panels# }
	static Void contributePanels(Configuration config) {
		config.add(config.autobuild(FoldersPanel#))
	}
	
	@Contribute { serviceType=EventTypes# }
	static Void contributeEventHub(Configuration config) {
		config["afReflux.fileExplorer"] = FileExplorerEvents#
	}

	@Contribute { serviceType=DefaultResourceViews# }
	static Void contributeDefaultResourceViews(Configuration config) {
		config[FolderResource#]	= FolderView#

		config[FileResource#]	= TextEditorView#
	}

	@Contribute { serviceType=DefaultFileViews# }
	static Void contributeDefaultFileViews(Configuration config) {
		config["bmp"]	= ImageView#
		config["gif"]	= ImageView#
		config["jpg"]	= ImageView#
		config["png"]	= ImageView#

		config["htm"]	= HtmlView#
		config["html"]	= HtmlView#

		// TODO: Have file actions and DEFAULT file actions
		config["txt"]	= TextEditorView#
		config["xml"]	= TextEditorView#
	}

	// ---- Reflux Tool Bar -----------------------------------------------------------------------

	@Contribute { serviceId="afReflux.optionsMenu" }
	static Void contributeHelpMenu(Configuration config) {
		config["afReflux.showHiddenFiles"]	= menuCommand(config, ShowHiddenFilesCommand#)
	}



	// ---- File Resource Popup Menu --------------------------------------------------------------
	
	@Build { serviceId="afReflux.fileResource.popupMenu" }
	static MenuItem[] buildFileResourcePopupMenu(MenuItem[] menuItems) { menuItems }

	@Contribute { serviceId="afReflux.fileResource.popupMenu"; optional=true }
	static Void contributeFileResourcePopupMenu(Configuration config) {
//		menu.addCommand(reg.autobuild(DeleteFileCommand#, [file]))

//		config["afReflux.rename"]	= menuCommand(config, AboutCommand#)
	}



	// ---- Private Methods -----------------------------------------------------------------------

	private static MenuItem menuCommand(Configuration config, Type cmdType) {
		MenuItem.makeCommand(config.autobuild(cmdType))
	}
}
