using afIoc3
using gfx

@NoDoc	// Advanced use only!
class RefluxIcons {
	@Inject private const Log	log
	@Inject private Images		images
			private Str:Uri		iconMap
	
	new make(Str:Uri iconMap, |This| in) {
		in(this)
		this.iconMap = iconMap
	}
	
	@Operator
	virtual Image? get(Str name, Bool checked := true) {
		if (!iconMap.containsKey(name)) {
			if (checked)
				log.warn("No icon for : $name")
			return null
		}

		uri := iconMap[name]
		if (uri.toStr.isEmpty)
			return null

		return images.get(uri, checked)
	}

	virtual Image? getFaded(Str name, Bool checked := true) {
		if (!iconMap.containsKey(name)) {
			if (checked)
				log.warn("No icon for : $name")
			return null
		}

		uri := iconMap[name]
		if (uri.toStr.isEmpty)
			return null

		return images.getFaded(uri, checked)
	}
	
	Image? fromUri(Uri uri, Bool checked := true) {
		images.get(uri, checked)
	}
}

@NoDoc
internal class EclipseIcons {
	static const Str:Uri iconMap := [
		"cmdExit"				: ``,
		"cmdAbout"				: `fan://icons/x16/flux.png`,
		"cmdRefresh"			: `nav_refresh.gif`,

		"cmdNavUp"				: `up_nav.gif`,
		"cmdNavHome"			: `nav_home.gif`,
		"cmdNavBackward"		: `nav_backward.gif`,
		"cmdNavForward"			: `nav_forward.gif`,
		"cmdNavClear"			: `clear.gif`,

		"cmdSave"				: `save_edit.gif`,
		"cmdSaveAs"				: `saveas_edit.gif`,
		"cmdSaveAll"			: `saveall_edit.gif`,

		"cmdUndo"				: `undo_edit.gif`,
		"cmdRedo"				: `redo_edit.gif`,
		
		"cmdCut"				: `cut_edit.gif`,
		"cmdCopy"				: `copy_edit.gif`,
		"cmdPaste"				: `paste_edit.gif`,

		"cmdToggleView"			: ``,

		"icoErrorsPanel"		: `error_log.gif`
		
	]
}
