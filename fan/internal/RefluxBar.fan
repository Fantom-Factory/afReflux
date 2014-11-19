using afIoc
using gfx
using fwt

internal class RefluxBar : EdgePane {
	
	new make(Registry registry, |This|in) : super.make() {
		in(this)
	
		toolBar	:= (ToolBar?) registry.serviceById("afReflux.toolBar")
		content	:= (Widget?) null
		uriBar	:= toolBar.children.find { it.typeof == UriWidget# }

		if (uriBar == null) {
			content = toolBar
		} else {
			// ToolBars can only show Buttons, so split it up into L and R toolbars
			i := toolBar.children.indexSame(uriBar)
			content = EdgePane {
				l := ToolBar()
				toolBar.children[0..<i].each { toolBar.remove(it); l.add(it) }
				r := ToolBar()
				toolBar.children[i..-1].each { toolBar.remove(it); r.add(it) }
				toolBar.remove(uriBar)
				
				it.left	  = l
				it.center = uriBar
				it.right  = r				
			}
		}
		
		center = InsetPane(2, 2) { content, }
	}	
}
