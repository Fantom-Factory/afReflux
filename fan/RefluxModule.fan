using afIoc
using gfx
using fwt

** The IoC Module definition for Reflux.
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
		defs.add(History#)
		defs.add(Session#).withCtorArgs(["sessionData.fog"])
		defs.add(Dialogues#)
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
		config["afReflux.cmdSave"]			= config.autobuild(SaveCommand#)
		config["afReflux.cmdSaveAs"]		= config.autobuild(GlobalCommand#, ["afReflux.cmdSaveAs"])
		config["afReflux.cmdSaveAll"]		= config.autobuild(GlobalCommand#, ["afReflux.cmdSaveAll"])
		config["afReflux.cmdExit"]			= config.autobuild(ExitCommand#)
		config["afReflux.cmdAbout"]			= config.autobuild(AboutCommand#)
		config["afReflux.cmdRefresh"]		= config.autobuild(RefreshCommand#)
		
		config["afReflux.cmdCut"]			= config.autobuild(GlobalCommand#, ["afReflux.cmdCut"])
		config["afReflux.cmdCopy"]			= config.autobuild(GlobalCommand#, ["afReflux.cmdCopy"])
		config["afReflux.cmdPaste"]			= config.autobuild(GlobalCommand#, ["afReflux.cmdPaste"])

		config["afReflux.cmdNavUp"]			= config.autobuild(NavUpCommand#)
		config["afReflux.cmdNavHome"]		= config.autobuild(NavHomeCommand#)
		config["afReflux.cmdNavBackward"]	= config.autobuild(NavBackwardCommand#)
		config["afReflux.cmdNavForward"]	= config.autobuild(NavForwardCommand#)
		config["afReflux.cmdNavClear"]		= config.autobuild(NavClearCommand#)

		config["afReflux.cmdToggleView"]	= config.autobuild(ToggleViewCommand#)

		config["afReflux.cmdUndo"]			= config.autobuild(UndoCommand#)
		config["afReflux.cmdRedo"]			= config.autobuild(RedoCommand#)
	}
	
	@Contribute { serviceType=RegistryShutdown# }
	internal static Void contributeRegistryShutdown(Configuration config, Registry registry) {
		config["afReflux.disposeOfImages"] = |->| {
			imgSrc := (Images) registry.dependencyByType(Images#)
			imgSrc.disposeAll
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

	@Build { serviceId="afReflux.viewMenu" }
	static Menu buildViewMenu(MenuItem[] menuItems) {
		menu("afReflux.viewMenu").addAll(menuItems)	 
	}

	@Build { serviceId="afReflux.historyMenu" }
	static Menu buildHistoryMenu(MenuItem[] menuItems) {
		menu("afReflux.historyMenu").addAll(menuItems)
	}

	@Build { serviceId="afReflux.prefsMenu" }
	static Menu buildPrefsMenu(MenuItem[] menuItems) {
		menu("afReflux.preferencesMenu").addAll(menuItems)
	}

	@Build { serviceId="afReflux.helpMenu" }
	static Menu buildHelpMenu(MenuItem[] menuItems) {
		menu("afReflux.helpMenu").addAll(menuItems)
	}

	@Contribute { serviceId="afReflux.menuBar" }
	static Void contributeMenuBar(Configuration config) {
		addNonEmptyMenu(config, "afReflux.fileMenu")
		addNonEmptyMenu(config, "afReflux.editMenu")
		addNonEmptyMenu(config, "afReflux.viewMenu")
		addNonEmptyMenu(config, "afReflux.historyMenu")
		addNonEmptyMenu(config, "afReflux.prefsMenu")
		addNonEmptyMenu(config, "afReflux.helpMenu")
	}
	
	private static Void addNonEmptyMenu(Configuration config, Str menuId) {
		menu := (Menu) config.registry.serviceById(menuId)
		if (!menu.children.isEmpty)
			config[menuId] = menu
	}

	@Contribute { serviceId="afReflux.fileMenu" }
	static Void contributeFileMenu(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.cmdSave"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdSave"].command)
		config["separator.01"]		= MenuItem { it.mode = MenuItemMode.sep }
		config["afReflux.cmdExit"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdExit"].command)
	}

	@Contribute { serviceId="afReflux.editMenu" }
	static Void contributeEditMenu(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.cmdUndo"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdUndo"].command)
		config["afReflux.cmdRedo"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdRedo"].command)
		config["separator.01"]		= MenuItem { it.mode = MenuItemMode.sep }
		config["afReflux.cmdCut"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdCut"].command)
		config["afReflux.cmdCopy"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdCopy"].command)
		config["afReflux.cmdPaste"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdPaste"].command)
		config["separator.02"]		= MenuItem { it.mode = MenuItemMode.sep }
	}

	@Contribute { serviceId="afReflux.viewMenu" }
	static Void contributeViewMenu(Configuration config, Panels panels, Registry reg, GlobalCommands globalCmds) {
		
		// only stick panels in a sub-menu should there be a few of them
		if (panels.panels.size > 5) {   
			panelsMenu := menu("afReflux.showPanelMenu")
			panels.panels.each {
				cmd := reg.autobuild(ShowHidePanelCommand#, [it])
				panelsMenu.add(MenuItem.makeCommand(cmd))
			}
			config["afReflux.panelMenu"] = panelsMenu

		} else {
			panels.panels.each {
				cmd := reg.autobuild(ShowHidePanelCommand#, [it])
				config.add(MenuItem.makeCommand(cmd))
			}	
		}

		config["separator.01"]				= MenuItem { it.mode = MenuItemMode.sep }
		config["afReflux.cmdRefresh"]		= MenuItem.makeCommand(globalCmds["afReflux.cmdRefresh"].command)
		config["afReflux.cmdToggleView"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdToggleView"].command)
	}

	@Contribute { serviceId="afReflux.historyMenu" }
	static Void contributeHistoryMenu(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.cmdNavBackward"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdNavBackward"].command)
		config["afReflux.cmdNavForward"]	= MenuItem.makeCommand(globalCmds["afReflux.cmdNavForward"].command)
		config["afReflux.cmdNavUp"]			= MenuItem.makeCommand(globalCmds["afReflux.cmdNavUp"].command)
		config["afReflux.cmdNavHome"]		= MenuItem.makeCommand(globalCmds["afReflux.cmdNavHome"].command)
		config["separator.01"]				= MenuItem { it.mode = MenuItemMode.sep }
		config["afReflux.cmdNavClear"]		= MenuItem.makeCommand(globalCmds["afReflux.cmdNavClear"].command)
		config["separator.02"]				= MenuItem { it.mode = MenuItemMode.sep }
	}

	@Contribute { serviceId="afReflux.helpMenu" }
	static Void contributeHelpMenu(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.cmdAbout"]		 = MenuItem.makeCommand(globalCmds["afReflux.cmdAbout"].command)
	}
	


	// ---- Reflux Tool Bar -----------------------------------------------------------------------

	@Build { serviceId="afReflux.toolBar" }
	static ToolBar buildToolBar(Widget[] toolBarItems) {
		ToolBar().addAll(toolBarItems)
	}

	@Contribute { serviceId="afReflux.toolBar" }
	static Void contributeToolBar(Configuration config, GlobalCommands globalCmds) {
		config["afReflux.cmdSave"]			= toolBarCommand(globalCmds["afReflux.cmdSave"].command)
		config["separator.01"]				= Button { mode = ButtonMode.sep }
		config["afReflux.cmdNavBackward"]	= toolBarCommand(globalCmds["afReflux.cmdNavBackward"].command)
		config["afReflux.cmdNavForward"]	= toolBarCommand(globalCmds["afReflux.cmdNavForward"].command)
		config["afReflux.cmdNavUp"]			= toolBarCommand(globalCmds["afReflux.cmdNavUp"].command)
		config["afReflux.cmdRefresh"]		= toolBarCommand(globalCmds["afReflux.cmdRefresh"].command)
		config["afReflux.uriWidget"]		= config.autobuild(UriWidget#)
		config["afReflux.cmdNavHome"]		= toolBarCommand(globalCmds["afReflux.cmdNavHome"].command)
	}



	// ---- Private Methods -----------------------------------------------------------------------

	private static Menu menu(Str menuId) {
		Menu() {
			// TODO: localise using id
			if (menuId.startsWith("afReflux."))
				menuId = menuId["afReflux.".size..-1]
			if (menuId.endsWith("Menu"))
				menuId = menuId[0..<-"Menu".size]
			it.text = menuId.toDisplayName
		}
	}

	private static Button toolBarCommand(Command command) {
		button  := Button.makeCommand(command)
		if (command.icon != null)
			button.text = ""
		return button
	}
}