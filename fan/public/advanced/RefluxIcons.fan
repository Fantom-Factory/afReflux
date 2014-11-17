using afIoc
using gfx

@NoDoc	// Advanced use only!
abstract class RefluxIcons {
	@Inject private Log			log
	@Inject private ImageSource imgSrc
	
	new make(|This| in) { in(this) }
	
	@Operator
	virtual Image? get(Str name) {
		icon(name, false)
	}
	
	Image? icon(Str name, Bool faded) {
		uri := iconUri(name)
		if (uri == null) {
			log.warn("No icon for : $name")
			return null
		}
		if (uri.toStr.isEmpty)
			return null
		return imgSrc.get(uri, faded)
	}
	
	abstract Uri? iconUri(Str name)
}

@NoDoc
class EclipseIcons : RefluxIcons {
	const Str:Uri iconMap := [
		"cmdExit"				: ``,
		"cmdAbout"				: `fan://icons/x16/flux.png`,
		"cmdRefresh"			: `nav_refresh.gif`,
		"cmdParent"				: `up_nav.gif`,
		"cmdShowHidePanel"		: ``,
		
		"icoErrorsPanel"		: `error_log.gif`,
		
		
		// ---- File Explorer -------------------
		"icoFoldersPanel"		: `filenav_nav.gif`,
		"icoFolderView"			: `fldr_obj.gif`,
		"icoImageView"			: `image_obj.gif`,
		
		"cmdShowHiddenFiles"	: ``,

		"cmdOpenFile"			: ``,
		"cmdRenameFile"			: ``,
		"cmdDeleteFile"			: `delete_obj.gif`,
		"cmdCutFile"			: `cut_edit.gif`,
		"cmdCopyFile"			: `copy_edit.gif`,
		"cmdPasteFile"			: `paste_edit.gif`,
		"cmdNewFile"			: `new_untitled_text_file.gif`,
		"cmdNewFolder"			: `newfolder_wiz.gif`,
		"cmdCopyFileName"		: ``,
		"cmdCopyFilePath"		: ``,
		"cmdCopyFileUri"		: ``,

		"icoFile"				: `file_obj.gif`,
		"icoFileImage"			: `image_obj.gif`,
		"icoFolder"				: `fldr_obj.gif`,
		"icoFolderRoot"			: `prj_obj.gif`,
		
		// ---- Image View ----------------------
		"icoImageNotFound"		: `delete_obj.gif`,
		"cmdImageFitToWindow"	: `collapseall.gif`,
		"cmdImageFullSize"		: `image_obj.gif`,

		
		// ---- Html View -----------------------
		"icoHtmlView"			: `fan://afReflux/res/icons-file/fileTextHtml.png`,

		
		// ignore
		"cmdExPanel"			: ``,
		"cmdErr"				: ``,
		"":``
	]

	new make(|This| in) : super(in) { }
	
	override Uri? iconUri(Str name) {
		if (!iconMap.containsKey(name))
			return null
		
		uri := iconMap[name]
		if (uri.toStr.isEmpty)
			return uri
		return uri.isAbs ? uri : `fan://afReflux/res/icons-eclipse/` + uri
	}
}
