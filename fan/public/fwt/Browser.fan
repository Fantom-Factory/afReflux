using fwt
using gfx

** (Widget) - 
** A HTML and web browser widget. 
** 'Browser' is a drop in replacement for the standard FWT [WebBrowser]`fwt::WebBrowser` with the following enhancements:
** 
**  - Javascript support
**  - Title and status text support
**  - 'WebBrowser' bug fixes - see [Topic #2069]`http://fantom.org/forum/topic/2069`
** 
** Use the 'html' and 'url' fields to load content into the browser:
** 
**   browser.html = "<html><body>Fantom-Factory<body></html>"
** 
**   browser.url = `http://www.fantomfactory.org/`
** 
** See [SWT Browser]`http://help.eclipse.org/indigo/topic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/browser/package-summary.html`
class Browser : Pane {

	** Gets / sets the HTML in the current page.
	**  
	**   browser.html = "<html><body>Fantom-Factory<body></html>"
	native	Str?	html

	** Gets / sets the URL loaded in the browser.
	**  
	**   browser.url = `http://www.fantomfactory.org/`
	native	Uri?	url
	
	** Whether javascript is enabled in the browser. 
	** Note this only affects pages loaded *after* the value is set. 
	native	Bool	javascriptEnabled
	
	@NoDoc
	new make() : super() { }
	
	@NoDoc	// required by Pane
	override Size prefSize(Hints hints := Hints.defVal) { Size(100, 100) }

	@NoDoc	// required by Pane
	override Void onLayout() { }

	** Callback when the user clicks a hyperlink.
	** The callback is invoked before the actual hyperlink.	
	** The event handler can modify the 'data' field with a new URI or set to 'null' to cancel the hyperlink.
	**
	** Event id fired:
	**	 - 'EventId.hyperlink'
	**
	** Event fields:
	**	 - 'Event.data': the `sys::Uri` of the new page.
	once EventListeners onHyperlink() { EventListeners() }

	** Callback when the page loading is complete. 
	** DOM elements should be available for Javascript interaction at this time.
	**
	** Event id fired:
	**	 - 'EventId.unknown'
	once EventListeners onLoad() { EventListeners() }

	** Callback when the title text is available or is modified.
	**
	** Event id fired:
	**	 - 'EventId.unknown'
	**
	** Event fields:
	**	 - 'Event.data': the title text.
	once EventListeners onTitleText() { EventListeners() }

	** Callback when the status bar text changes.
	**
	** Event id fired:
	**	 - 'EventId.unknown'
	**
	** Event fields:
	**	 - 'Event.data': the status bar text.
	once EventListeners onStatusText() { EventListeners() }

	** Refresh the current page.
	native This refresh()

	** Stop any load activity.
	native This stop()

	** Navigate to the previous session history.
	native This back()

	** Navigate to the next session history.
	native This forward()

	** Returns the result, if any, of executing the specified script.
	** 
	** The the last Javascript statement should be a 'return' statement:
	** 
	**   browser.evaluate("alert('Hello Mum!'); return document.title;")
	native Obj? evaluate(Str script)

	** Executes the specified script. 
	** If document-defined functions or properties are accessed by the script then this method 
	** should not be invoked until the document has finished loading.
	** 
	**   browser.execute("alert('Hello Mum!');")
	** 
	** Throws 'Err' if the script did not complete successfully.
	native Void execute(Str script)

}
