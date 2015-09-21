using afIoc3
using gfx
using fwt

@Js
internal class RefluxBar : EdgePane {
	
	new make(Scope scope, |This|in) : super.make() {
		in(this)
	
		toolBar	:= (ToolBar?) scope.serviceById("afReflux.toolBar")
		content	:= (Widget?) null
		uriBar	:= toolBar.children.find { it.typeof == UriWidget# || it.typeof == UriWidgetJs# }

		if (uriBar == null) {
			content = toolBar
		} else {
			
//			if (Env.cur.runtime == "js") {
//				toolBar.remove(uriBar)
//				content = EdgePane {
//					it.top = uriBar
//					it.bottom = toolBar
//				}
//				
//			} else {
				// ToolBars can only show Buttons, so split it up into L and R toolbars
				i := toolBar.children.indexSame(uriBar)
				lKids := toolBar.children[0..<i]
				rKids := toolBar.children[i+1..-1]

				toolBar.children.each { toolBar.remove(it) }
				
				l := ToolBar().addAll(lKids)
				r := ToolBar().addAll(rKids)

				content = EdgePane {
					it.left	  = l
					it.center = uriBar
					it.right  = r				
				}				
//			}
		}
		
		center = Env.cur.runtime == "js" ? InsetPane(0, 0, 6, 0) { content, } : InsetPane(2, 2) { content, }
	}	
}
