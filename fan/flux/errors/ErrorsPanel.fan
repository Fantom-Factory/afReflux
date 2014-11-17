using afIoc
using gfx
using fwt

// TODO: have 'Show stack trace in Console' command
// TODO: have 'Clear' command
internal class ErrorsPanel : Panel, RefluxEvents {

	@Inject private Registry		registry
	@Inject private Reflux			reflux
	@Inject private RefluxIcons		icons
	@Inject private Log				log
			private Table			table

	@Autobuild private ErrorsPanelModel model
	
	override Obj	prefAlign	:= Valign.bottom	

	new make(|This| in) : super(in) {		
		content = table = Table {
			it.multi = true
			it.onAction.add |e| { this->onAction(e) }
//			it.onPopup.add	|e| { this.onPopup(e) }
			it.border = false
			it.model = this.model
		}
	}
	
	override Void onError(Error error) {
		log.err(error.err.msg, error.err)
		table.refreshAll
	    Dialog.openErr(content.window, error.err.toStr, error.err)
	}
	
	Void onAction(Event event) {
		if (event.index != null) {
			// can't be bothered with resources and views just now so
			// just display a dialogue
			error := model.errors.errors[event.index]
			Dialog.openErr(content.window, error.err.toStr, error.err)
		}
	}
}

internal class ErrorsPanelModel : TableModel {
	@Inject LocaleFormat	locale
	@Inject Errors			errors
	
	File[]? files
	Str[] headers := ["Type", "Msg", "When"]
	Int[] width	  := [95, 260, 105]

	new make(|This| in) { in(this) }
	
	override Int numCols() { 3 }
	override Int numRows() { errors.errors.size }
	override Str header(Int col) { headers[col] }
	override Halign halign(Int col) { Halign.left }
	override Int? prefWidth(Int col) { width[col] }

	override Str text(Int col, Int row) {
		error := errors.errors[row]
		switch (col) {
			case 0:	return error.err.typeof.qname
			case 1:	return error.err.msg
			case 2:	return locale.formatDateTime(error.when)
			default: return "???"
		}
	}

	override Int sortCompare(Int col, Int row1, Int row2) {
		a := errors.errors[row1]
		b := errors.errors[row2]
		switch (col) {
			case 1:	return a.typeof.name <=> b.typeof.name
			case 2:	return a.err.msg <=> b.err.msg
			default: return super.sortCompare(col, row1, row2)
		}
	}
}