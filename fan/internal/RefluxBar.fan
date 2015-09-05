using afIoc3
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
				lKids := toolBar.children[0..<i]
				rKids := toolBar.children[i+1..-1]

				toolBar.children.each { toolBar.remove(it) }
				
				l := ToolBar().addAll(lKids)
				r := ToolBar().addAll(rKids)
				
				it.left	  = l
				it.center = uriBar
				it.right  = r				
			}
		}
		
		center = InsetPane(2, 2) { content, }
	}	
}
