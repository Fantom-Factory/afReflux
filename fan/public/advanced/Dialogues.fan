using afIoc
using fwt

** A wrapper around the FWT Dialog class that allows you to redefine the the commands.
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
	
	Obj? openErr(Str msg, Obj? details := null, Command[]? commands := null) {
		Dialog.openMsgBox(Dialog#.pod, "err", reflux.window, msg, details, commands ?: [ok])
	}
	
	Obj? openWarn(Str msg, Obj? details := null, Command[]? commands := null) {
		Dialog.openMsgBox(Dialog#.pod, "warn", reflux.window, msg, details, commands ?: [ok])
	}
}
