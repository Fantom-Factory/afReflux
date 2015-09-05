using afIoc3
using fwt
using gfx

** (Service) - 
** A wrapper around the FWT Dialog class that allows you to redefine / intercept the commands by 
** overriding the service.
@NoDoc
class Dialogues {
	@Inject private Reflux reflux

	** Predefined dialog command for OK.
	Command	ok			:= Dialog.ok

	** Predefined dialog command for Cancel.
	Command	cancel		:= Dialog.cancel

	** Predefined dialog command for Yes.
	Command	yes			:= Dialog.yes

	** Predefined dialog command for No.
	Command	no			:= Dialog.no

	** Convenience for '[ok, cancel]'.
	Command[] okCancel	:= [ok, cancel]

	** Convenience for '[yes, no]'.
	Command[] yesNo		:= [yes, no]
	
	private new make(|This|in) { in(this) }
	
	** Open an error message box.
	virtual Obj? openErr(Str msg, Obj? details := null, Command[]? commands := null) {
		openMsgBox(Dialogues#.pod, "err", msg, details, commands ?: [ok])
	}
	
	** Open a warning message box.
	virtual Obj? openWarn(Str msg, Obj? details := null, Command[]? commands := null) {
		openMsgBox(Dialogues#.pod, "warn", msg, details, commands ?: [ok])
	}
	
	** Open a question message box.
	virtual Obj? openQuestion(Str msg, Obj? details := null, Command[]? commands := null) {
		openMsgBox(Dialogues#.pod, "question", msg, details, commands ?: [ok])
	}
		
	virtual Str? openPromptStr(Str msg, Str def := "", Int prefCols := 20) {
		field := Text { it.text = def; it.prefCols = prefCols }
		pane  := GridPane {
			numCols = 2
			expandCol = 1
			halignCells=Halign.fill
			Label { text=msg },
			field,
		}
		field.onAction.add |Event e| { e.widget.window.close(ok) }
		r := openMsgBox(Dialog#.pod, "question", pane, [ok, cancel])
		if (r != ok) return null
		return field.text
	}

	virtual Obj? openMsgBox(Pod pod, Str keyBase, Obj body, Obj? details := null, Command[]? commands := null) {
		Dialog.openMsgBox(pod, keyBase, reflux.window, body, details, commands ?: [ok])
	}
}
