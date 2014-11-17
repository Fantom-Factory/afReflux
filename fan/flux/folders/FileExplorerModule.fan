using afIoc
using gfx
using fwt

class FileExplorerModule {

	static Void defineServices(ServiceDefinitions defs) {		
		defs.add(FileExplorer#)
		defs.add(FileExplorerEvents#)
		defs.add(FileResolver#)
		defs.add(FileViews#)
	}

	@Contribute { serviceType=UriResolvers# }
//	internal static Void contributeUriResolvers(Configuration config, FileResolver fileResolver) {
	internal static Void contributeUriResolvers(Configuration config, Registry reg) {
		// FIXME: Why can't I just inject FileResolver?
		config["file"] = reg.dependencyByType(FileResolver#)
	}

	@Contribute { serviceType=Panels# }
	static Void contributePanels(Configuration config) {
		config.add(config.autobuild(FoldersPanel#))
	}

	@Contribute { serviceType=FileViews# }
	static Void contributeFileViews(Configuration config) {
		config["x-directory/*"]	= config.autobuild(FolderView#)
		config["image/*"]		= config.autobuild(ImageView#)
		config["text/html"]		= config.autobuild(HtmlView#)
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
