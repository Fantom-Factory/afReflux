using afIoc

@NoDoc
class FileViews {
	private MimeType:View views
	
	new make(MimeType:View views) {
		this.views = views
	}
	
	@Operator
	View? get(Resource resource) {
		resMimeType := resource.uri.mimeType?.noParams
		if (resMimeType == null)
			return null
		return views[resMimeType] ?: views.find |view, mt| { mt.subType == "*"  && mt.mediaType == resMimeType.mediaType }
	}

	
	static Void main() {
		// TODO: Fantom forum - have a MimeType.fits()
		a:=MimeType.fromStr("image/*")
		echo(a)
	}
}
