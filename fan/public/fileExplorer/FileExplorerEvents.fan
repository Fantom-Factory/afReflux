using afIoc

@NoDoc
mixin FileExplorerEvents {

	virtual Void onShowHiddenFiles(Bool show)	{ }

	// add cut, copy, paste here...maybe
	
}

//FIXME: make am injectale plastic version!
@NoDoc
class FileExplorerEventsImpl : FileExplorerEvents {
	@Inject EventHub eventHub	
	new make(|This|in) { in(this) }
	
	override Void onShowHiddenFiles(Bool show)	{
		eventHub.fireEvent(FileExplorerEvents#onShowHiddenFiles, [show])
	}
}
