using afIoc
using afIocConfig
using gfx
using fwt

@NoDoc
class RefluxModule {
	
	static Void defineServices(ServiceDefinitions defs) {
		defs.add(Reflux#).withProxy
		defs.add(Errors#).withProxy

		defs.add(Images#)
		defs.add(Preferences#)
		defs.add(EventHub#)
		defs.add(EventTypes#)
		defs.add(Panels#)
		defs.add(UriResolvers#)
		defs.add(LocaleFormat#)
		defs.add(RefluxIcons#)
		defs.add(GlobalCommands#)
	}
	
	@Contribute { serviceType=Panels# }
	static Void contributePanels(Configuration config) {
		config.add(config.autobuild(ErrorsPanel#))
	}

	@Contribute { serviceType=RefluxIcons# }
	static Void contributeRefluxIcons(Configuration config) {
		EclipseIcons.iconMap.each |uri, id| {
			config[id] = uri.isAbs || uri.toStr.isEmpty ? uri : `fan://afReflux/res/icons-eclipse/` + uri
		}
	}

	@Contribute { serviceType=EventTypes# }
	static Void contributeEventHub(Configuration config) {
		config["afReflux.reflux"] = RefluxEvents#
	}

	@Contribute { serviceType=DependencyProviders# }
	static Void contributeDependencyProviders(Configuration config) {
		eventProvider := config.autobuild(EventProvider#)
		config.set("afReflux.eventProvider", eventProvider).before("afIoc.serviceProvider")
	}

	@Contribute { serviceType=GlobalCommands# }
	static Void contributeGlobalCommands(Configuration config) {
		config["afReflux.cmdAbout"]			= config.autobuild(AboutCommand#)
		config["afReflux.cmdExit"]			= config.autobuild(ExitCommand#)
		config["afReflux.cmdParent"]		= config.autobuild(ParentCommand#)
		config["afReflux.cmdRefresh"]		= config.autobuild(RefreshCommand#)

		config["afReflux.cmdSave"]			= config.autobuild(SaveCommand#)
		config["afReflux.cmdToggleView"]	= config.autobuild(ToggleViewCommand#)
//		config["afReflux.cmdSaveAs"]	= config.autobuild(GlobalCommand#, ["afReflux.cmdSaveAs"])
//		config["afReflux.cmdSaveAll"]	= config.autobuild(GlobalCommand#, ["afReflux.cmdSaveAll"])
//		config["afReflux.cmdCut"]		= config.autobuild(GlobalCommand#, ["afReflux.cmdCut"])
//		config["afReflux.cmdCopy"]		= config.autobuild(GlobalCommand#, ["afReflux.cmdCopy"])
//		config["afReflux.cmdPaste"]		= config.autobuild(GlobalCommand#, ["afReflux.cmdPaste"])
//		config["afReflux.cmdUndo"]		= config.autobuild(GlobalCommand#, ["afReflux.cmdUndo"])
//		config["afReflux.cmdRedo"]		= config.autobuild(GlobalCommand#, ["afReflux.cmdRedo"])
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[RefluxConfigIds.appTitle]	= "Reflux"
		config[RefluxConfigIds.appIcon]		= `fan://icons/x32/flux.png`		
	}

	@Contribute { serviceType=RegistryShutdown# }
	internal static Void contributeRegistryShutdown(Configuration config, Registry registry) {
		config["afReflux.disposeOfImages"] = |->| {
			imgSrc := (Images) registry.dependencyByType(Images#)
			imgSrc.disposeOfImages
		}
	}
	
	
	
	// ---- Reflux Menu Bar -----------------------------------------------------------------------
	
	@Build { serviceId="afReflux.menuBar" }
	static Menu buildMenuBar(MenuItem[] menuItems) {
		Menu() { it.text="Menu" }.addAll(menuItems)
	}

	@Build { serviceId="afReflux.fileMenu" }
	static Menu buildFileMenu(MenuItem[] menuItems) {
		menu("afReflux.fileMenu").addAll(menuItems)
	}

	@Build { serviceId="afReflux.editMenu" }
	static Menu buildEditMenu(MenuItem[] menuItems) {
		menu("afReflux.editMenu").addAll(menuItems)
	}

	@Build { serviceId="afReflux.optionsMenu" }
	static Menu buildOptionsMenu(MenuItem[] menuItems) {
		menu("afReflux.optionsMenu").addAll(menuItems)
	}

	@Build { serviceId="afReflux.panelMenu" }
	static Menu buildPanelMenu(MenuItem[] menuItems, Registry reg, Panels panels, GlobalCommands globalCmds) {
		menu := menu("afReflux.panelMenu")
		
		panels.panels.each {
			cmd := reg.autobuild(ShowHidePanelCommand#, [it])
			menu.add(MenuItem.makeCommand(cmd))
		}
		
		if (!menuItems.isEmpty) {
			menu.addSep
			menu.addAll(menuItems)
		}
		return menu
	}

	@Build { serviceId="afReflux.helpMenu" }
	static Menu buildHelpMenu(MenuItem[] menuItems) {
		menu("afReflux.helpMenu").addAll(menuItems)
	}

	@Contribute { serviceId="afReflux.menuBar" }
	static Void contributeMenuBar(Configuration config) {
		addNonEmptyMenu(config, "afReflux.fileMenu")
		addNonEmptyMenu(config, "afReflux.editMenu")
		addNonEmptyMenu(config, "afReflux.optionsMenu")
		addNonEmptyMenu(config, "afReflux.panelMenu")
		addNonEmptyMenu(config, "afReflux.helpMenu")
	}
	
	static Void addNonEmptyMenu(Configuration config, Str menuId) {
		menu := (Menu) config.registry.serviceById(menuId)
		if (!menu.children.isEmpty)
			config[menuId] = menu
	}

	@Contribute { serviceId="afReflux.fileMenu" }
	static Void contributeFileMenu(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.save"]		= MenuItem.makeCommand(globalCmds["afReflux.cmdSave"].command)
		config["separator.01"]		= MenuItem { it.mode = MenuItemMode.sep }
		config["afReflux.exit"]		= MenuItem.makeCommand(globalCmds["afReflux.cmdExit"].command)	// separator
	}

	@Contribute { serviceId="afReflux.panelMenu" }
	static Void contributePanelMenu(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.toggleView"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdRefresh"].command)
		config["afReflux.refresh"]		= MenuItem.makeCommand(globalCmds["afReflux.cmdToggleView"].command)
	}

	@Contribute { serviceId="afReflux.helpMenu" }
	static Void contributeHelpMenu(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.about"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdAbout"].command)
	}
	
	
	// ---- Reflux Tool Bar -----------------------------------------------------------------------

	@Build { serviceId="afReflux.toolBar" }
	static ToolBar buildToolBar(Widget[] toolBarItems) {
		ToolBar().addAll(toolBarItems)
	}

	@Contribute { serviceId="afReflux.toolBar" }
	static Void contributeToolBar(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.save"]			= toolBarCommand(globalCmds["afReflux.cmdSave"].command)
		config["separator.01"]			= Button { mode = ButtonMode.sep }
		config["afReflux.refresh"]		= toolBarCommand(globalCmds["afReflux.cmdRefresh"].command)
		config["afReflux.uriWidget"]	= config.autobuild(UriWidget#)
		config["afReflux.parent"]		= toolBarCommand(globalCmds["afReflux.cmdParent"].command)
	}
	
	
	
	// ---- Private Methods -----------------------------------------------------------------------

	private static Menu menu(Str menuId) {
		Menu() {
			if (menuId.startsWith("afReflux."))
				menuId = menuId["afReflux.".size..-1]
			if (menuId.endsWith("Menu"))
				menuId = menuId[0..<-"Menu".size]
			it.text = menuId.toDisplayName
		}
	}

	@Deprecated
	private static MenuItem menuCommand(Configuration config, Type cmdType) {
		MenuItem.makeCommand(config.autobuild(cmdType))
	}

	private static Button toolBarCommand(Command command) {
	    button  := Button.makeCommand(command)
	    if (command.icon != null)
	    	button.text = ""
		return button
	}
}
