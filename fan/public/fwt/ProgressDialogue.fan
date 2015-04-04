using gfx
using fwt
using concurrent
using afConcurrent
using afIoc

** (Widget) - 
** A dialogue window that displays an updatable progress bar.
** 
** ![Progress Dialogue]`http://static.alienfactory.co.uk/fantom-docs/afReflux.progressDialogue.png`
**
** Sample usage:
** pre>
** dialogue := ProgressDialogue()
** 
** dialogue.with {
**     it.title = "Look at me!"
**     it.image = Image(`fan://icons/x48/flux.png`)
**     it.closeWhenFinished = false
** }
** 
** dialogue.open(reflux.window) |ProgressWorker worker| {
**     worker.update(1, 4, "Processing...")
**     Actor.sleep(2sec)
** 
**     worker.update(2, 4, "A Very Long...")
**     Actor.sleep(2sec)
** 
**     worker.update(3, 4, "Process...")
**     Actor.sleep(2sec)
** 
**     worker.update(4, 4, "Done.")
** }
** <pre
** 
** 
** 
** Processing
** ==========
** As seen in the example, the work should be performed in the callback func passed to 'open()'. 
** The work func should then make repeated calls to 'ProgressWorker.update()' to update the dialogue and progress bar.
**  
** The callback func is processed in its own thread. This keeps the UI thread free to update the progress dialogue as needed.
** To update other UI components from within the callback func, use 'Desktop':
** 
**   registry := this.registry
**   Desktop.callAsync |->| {
**       reflux := (Reflux) registry.serviceById(Reflux#.qname)
**       reflux.refresh
**       ...
**   }  
** 
** 
** 
** Cancelling
** ==========
** A user may cancel any progress dialogue at any time. 
** Callback funcs should check the status of the 'ProgressWorker.cancelled' flag and return early if set.
** An alternative is to call 'ProgressWorker.update()' often, which throws a 'sys::CancelledErr' if the 'cancelled' flag has been set.
** 
** Should a progress dialogue be cancelled, 'ProgressDialogue.onCancel()' is called. 
** This hook may be overridden to perform custom cancel handling.
** By default the dialogue shows a 'Cancelled by User' message. 
** 
** To mimic a user pressing 'Cancel' the callback func may simply throw a 'sys::CancelledErr'. 
** 
** 
** 
** Error Handling
** ==============
** Should an error occur, 'ProgressDialogue.onError(Err)' is called.
** This hook may be overridden to perform custom cancel handling.
** By default the dialogue shows an error message and displays the stack trace in the details panel. 
** 
** If the 'ProgressDialogue' is autobuilt then the error is added to the 'Errors' service.
** 
**   dialogue := (ProgressDialogue) registry.autobuild(ProgressDialogue#)
** 
** or the dialogue may be set as an IoC field:
** 
**   @Autobuild ProgressDialogue dialogue
** 
class ProgressDialogue {

	** Title string.
	Str title := "Progress Dialogue"

	** The image displayed to the left of the message.
	Image? image {
		set {
			v := &image = it
			if (_imageWidget != null) {
				safeWidget := Unsafe(_imageWidget)
				Desktop.callAsync |->| { safeWidget.val->image = v }
			}
		}
	}

	** The message text to display. 
	Str text := "" {
		set {
			v := &text = it
			if (_textWidget != null) {
				safeWidget := Unsafe(_textWidget)
				Desktop.callAsync |->| {
					safeWidget.val->text = _padToFiveLines(v)
					if (v.splitLines.size > 5)
						safeWidget.val->pack
				}
			}
		}
	}
	
	** The text displayed in the details panel. 
	Str detailText := "" {
		set {
			v := &detailText = it
			if (_detailsWidget != null) {
				safeWidget := Unsafe(_detailsWidget)
				Desktop.callAsync |->| { safeWidget.val->text = v }
			}
		}
	}
	
	// todo: Delay showing the ProgressDialogue - impossible! 
	// Whatever you do ends up blocking the UI thread... :( 
//	** The amount of time to elapse before the dialogue is displayed.
//	** This prevents short lived operations from flashing dialogues to the user.
//	** 
//	** Set to 'null' to display the dialogue immediately.
//	** 
//	** Defaults to '500ms'.
//	Duration? displayAfterDuration := 500ms {
//		set {
//			if (it != null && it < 0ms)
//				throw ArgErr("Duration must be > 0")
//			&displayAfterDuration = (0ms == it) ? null : it
//		}
//	}
	
	** If 'true' then the dialogue automatically closes when the work is done.
	** Set to 'false' to keep the dialogue open and have the user manually close it.
	** Handy to show a final status and / or let the user inspect the details.
	** 
	** Defaults to 'true'.
	Bool closeWhenFinished	:= true

	@Inject
	private Errors?			_errors
	private Bool			_inProgress
	private Label?			_textWidget
	private Label?			_imageWidget
	private Text?			_detailsWidget
	private Command?		_okCmd
	private Command?		_cancelCmd
	private ProgressBar?	_progressWidget

	@NoDoc	// Boring!
	new make(|This|? f := null) {
		f?.call(this)
	}
	
	** Creates and displays a progress dialogue. 
	** All work is done inside the given callback in a separate thread.
	Void open(Window parent, |ProgressWorker| callback) {
		if (_inProgress || _textWidget != null)
			throw Err("ProcessDialogue is already open")

		diag := _createDialogue(parent)
		diag.onOpen.add |Event e| {
			_doWork(ActorPool(), diag, callback)
		}
		diag.open
	}

	** Hook for handling cancelled events from the user.
	** 
	** By default this sets the dialogue text to 'Cancelled by User'.
	virtual Void onCancel() {
		text = "Cancelled by User"
		detailText += "\n\n----\nCancelled by User"
	}

	** Hook for handling errors from the 'ProgressWorker' callback function.
	** 
	** By default this adds a stack trace to the details panel and sets the text to the error msg. 
	** 'closeWhenFinished' is also set to 'false'.
	**  
	** If this progress dialogue was autobuilt by IoC then the 'Err' is also added to the 'Errors' service.
	virtual Void onError(Err err) {
		text  = "ERROR: ${err.typeof.qname} - ${err.msg}"
		image = Image(`fan://icons/x32/err.png`)
		detailText += "\n\n----\nERROR: ${err.traceToStr}"
		closeWhenFinished = false
		
		errorsRef := Unsafe(_errors)
		Desktop.callAsync |->| {
			((Errors) errorsRef.val).add(err, true)
		}
	}

	private Void _doWork(ActorPool actorPool, Window window, |ProgressWorker| callback) {
		winRef  := Unsafe(window)
		diagRef := Unsafe(this)
		// do the work in a separate thread so the UI thread is free to update the dialogue
		Synchronized(actorPool).async |->| {
			diag 	:= (ProgressDialogue) diagRef.val
			worker	:= ProgressWorker(diag, diag._progressWidget)
			((ProgressDialogueCancelCommand) diag._cancelCmd).worker = worker

			cwfBackup := diag.closeWhenFinished
			diag._inProgress = true
			try {
				callback(worker)
				
				// the callback func may check the cancelled flag and return nicely = no CancelledErr!
				if (worker.cancelled) {
					_disableCancelButton(diagRef)
					diag.onCancel()
				}

			} catch (CancelledErr err) {
				_disableCancelButton(diagRef)
				diag.onCancel()

			} catch (Err err) {
				_disableCancelButton(diagRef)
				diag.onError(err)
			}
			
			diag._inProgress = false

			if (diag.closeWhenFinished)
				Desktop.callAsync |->| {
					win := (Window) winRef.val
					win.close
				}
			else
				_disableCancelButton(diagRef)
				_enableOkayButton(diagRef)
			
			// clean up
			diag.closeWhenFinished	= cwfBackup
		}		
	}
	
	private static Void _disableCancelButton(Unsafe diagRef) {
		Desktop.callAsync |->| {
			diag2 := (ProgressDialogue) diagRef.val
			if (diag2._cancelCmd != null)
				diag2._cancelCmd.enabled = false
		}		
	}

	private static Void _enableOkayButton(Unsafe diagRef) {
		Desktop.callAsync |->| {
			diag2 := (ProgressDialogue) diagRef.val
			if (diag2._okCmd != null)
				diag2._okCmd.enabled = true
		}		
	}
	
	private Window _createDialogue(Window window) {
		t := this.text
		_textWidget = Label { it.text = _padToFiveLines(t) }

		bodyAndImage := (Widget) _textWidget
		
		if (image != null) {
			_imageWidget = Label { it.image = this.&image }
			bodyAndImage = GridPane {
				numCols		= 2
				expandCol	= 1
				halignCells	= Halign.fill
				_imageWidget,
				_textWidget,
			}
		}

		_detailsWidget = Text {
			it.multiLine= true
			it.editable	= false
			it.prefRows	= 10
			it.font		= Desktop.sysFontMonospace
			it.text		= this.&detailText
			it.visible	= false
		}

		_cancelCmd = ProgressDialogueCancelCommand()
		commands := [_cancelCmd, ProgressDialogueDetailsCommand(_detailsWidget)]
		if (!closeWhenFinished) {
			_okCmd = Dialog.ok { it.enabled = false }
			commands.insert(0, _okCmd)
		}

		buttons := GridPane {
			numCols		= commands.size
			halignCells	= Halign.fill
			halignPane	= Halign.right
			uniformRows	= true
			uniformCols	= true
			hgap		= 4
		}
		commands.each |Command c| {
			buttons.add(ConstraintPane {
				minw = 70
				b := Button.makeCommand(c) { insets = Insets(0, 10, 0, 10) }
				it.add(b)
			})
		}

		_progressWidget = ProgressBar()

		content := GridPane {
			expandCol = 0
			expandRow = 0
			valignCells = Valign.fill
			halignCells = Halign.fill
			InsetPane(16) {
				ConstraintPane {
					minw = 350
					bodyAndImage,
				},
			},
			InsetPane() {
				insets = Insets(0, 16, 16, 16)
				_progressWidget,
			},
			InsetPane {
				insets = Insets(0, 16, 16, 16)
				buttons,
			},
			_detailsWidget,
		}

		return Window(window) {
			it.title	= this.title
			it.content	= content
			it.mode		= WindowMode.appModal
			it.onClose.add |Event e| {
				// don't let users manually close the progress dialogue while it's executing
				if (_inProgress) {
					e.consume
					return
				}
	
				// clean up
				_textWidget			= null
				_imageWidget		= null
				_detailsWidget		= null
				_progressWidget		= null
				_okCmd				= null
				_cancelCmd			= null
			}
		}
	}
	
	static Str _padToFiveLines(Str text) {
		noOfLines := text.splitLines.size
		return (noOfLines < 5) ? text + "".padl(5 - noOfLines, '\n') : text
	}
}


** Used by [ProgressDialogues]`ProgressDialogue` to update the progress bar.
** 
** Example:
** pre>
** dialogue.open(window) |ProgressWorker worker| {
**     worker.update(1, 4, "Processing...")
**     Actor.sleep(2sec)
** 
**     worker.update(2, 4, "A Very Long...")
**     Actor.sleep(2sec)
** 
**     worker.update(3, 4, "Process...")
**     Actor.sleep(2sec)
** 
**     worker.update(4, 4, "Done.")
** }
** <pre 
class ProgressWorker {
	private ProgressDialogue	dialogue
	private ProgressBar			progressWidget
	
	** The image displayed in the progress dialogue.
	Image? image {
		get { dialogue.image }
		set { dialogue.image = it }
	}

	** The message displayed in the progress dialogue. 
	Str text {
		get { dialogue.text }
		set { dialogue.text = it } 
	}

	** The text displayed in the details panel. 
	Str detailText {
		get { dialogue.detailText }
		set { dialogue.detailText = it }
	}

	** Returns 'true' if the user clicked the Cancel button.
	Bool cancelled {
		internal set
	}

	internal new make(ProgressDialogue dialogue, ProgressBar progressWidget) {
		this.dialogue		= dialogue
		this.progressWidget	= progressWidget
	}
	
	** Updates the progress bar to show work done.
	** 'msg' is optional and sets the dialogue text and is appended to the detail text.
	** 
	** If the dialogue has been cancelled then this throws a 'CancelledErr'. 
	Void update(Int workDone, Int workTotal, Str? msg := null) {
		if (cancelled) throw CancelledErr("Progress dialogue cancelled.")

		// set text first so it may be overwritten should an Err occur later
		if (msg != null) {
			this.text = msg
			this.detailText += detailText.isEmpty ? msg : "\n" + msg
		}

		safeProgress := Unsafe(progressWidget)
		Desktop.callAsync |->| {
			progressBar := (ProgressBar) safeProgress.val
			progressBar.with {
				it.val = workDone
				it.max = workTotal
			}
		}
	}
	
	internal Void cancel() {
		this.cancelled = true
	}
}

internal class ProgressDialogueDetailsCommand : Command {
	Widget details

	new make(Widget details) : super.makeLocale(Dialog#.pod, "details") {
		this.details = details
		this.mode 	 = CommandMode.toggle
	}

	override Void invoked(Event? e)	{
		details.visible = selected
		window.pack
	}
}

internal class ProgressDialogueCancelCommand : Command {
	ProgressWorker? worker

	new make() : super.makeLocale(Dialog#.pod, "cancel") { }

	override Void invoked(Event? e)	{
		worker.cancel
	}
}
