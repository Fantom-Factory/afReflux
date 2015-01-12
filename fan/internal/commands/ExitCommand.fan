using afIoc
using gfx
using fwt

internal class ExitCommand : GlobalCommand {
	@Inject	private Reflux reflux
	
	new make(|This|in) : super.make("afReflux.cmdExit", in) { }

	override Void onInvoke(Event? event) {
//		dirty := frame.views.findAll |View v->Bool| { return v.dirty }
//		if (dirty.size > 0) {
//			grid := GridPane { Label { text=Flux.locale("saveChanges"); font=Desktop.sysFont.toBold },}
//			dirty.each |View v|	{
//				grid.add(InsetPane(0,0,0,8) {
//				 Button { it.mode=ButtonMode.check; it.text=v.resource.uri.toStr; it.selected=true },
//				})
//			}
//			saveSel	:= ExitSaveCommand(Pod.of(this), "saveSelected")
//			saveNone := ExitSaveCommand(Pod.of(this), "saveNone")
//			cancel	 := ExitSaveCommand(Command#.pod, "cancel")
//			pane := ConstraintPane {
//				minw = 400
//				add(InsetPane(0,0,12,0).add(grid))
//			}
//			d := Dialog(frame) { title="Save"; body=pane; commands=[saveSel,saveNone,cancel] }
//			r := d.open
//			if (r == cancel) return
//			if (r == saveSel) {
//				grid.children.each |Widget w, Int i| {
//					if (w isnot InsetPane) return
//					c := w.children.first as Button
//					v := dirty[i-1]
//					if (c.selected) v.tab.save
//				}
//			}
//		}
		
		reflux.exit
	}
}
