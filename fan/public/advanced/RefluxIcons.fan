using afIoc
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
	virtual Image? get(Str name) {
		icon(name, false)
	}
	
	Image? icon(Str name, Bool faded, Bool checked := true) {
		if (!iconMap.containsKey(name)) {
			if (checked)
				log.warn("No icon for : $name")
			return null
		}

		uri := iconMap[name]
		if (uri.toStr.isEmpty)
			return null

		return images.get(uri, faded)
	}
	
	Image? fromUri(Uri? icoUri, Bool faded := false, Bool checked := true) {
		images.get(icoUri, faded, checked)
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
		
		"cmdToggleView"			: ``,

		"icoErrorsPanel"		: `error_log.gif`
	]
}
