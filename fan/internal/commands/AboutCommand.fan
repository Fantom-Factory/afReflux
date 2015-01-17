using afIoc
using gfx
using fwt

internal class AboutCommand : GlobalCommand {
	
	new make(|This|in) : super.make("afReflux.cmdAbout", in) {
		addEnabler("adReflux.cmdAbout", |->Bool| { true } )
	}
	
	override Void doInvoke(Event? event) {
		icon	:= Pod.find("icons").file(`/x48/flux.png`)
		big		:= Font { it.name=Desktop.sysFont.name; it.size=Desktop.sysFont.size+(Desktop.isMac ? 2 : 3); it.bold=true }
		small	:= Font { it.name=Desktop.sysFont.name; it.size=Desktop.sysFont.size-(Desktop.isMac ? 3 : 1) }

		versionInfo := GridPane {
			halignCells = Halign.center
			vgap = 0
			Label {
				text = "Version:  ${this.typeof.pod.version}
				        Home Dir: ${Env.cur.homeDir}
				        Work Dir: ${Env.cur.workDir}
				        Env:      ${Env.cur}"
				font = small
			},
		}
		content := GridPane	{
			halignCells = Halign.center
			Label { image = Image.makeFile(icon) },
			Label { text = "Reflux"; font = big },
			versionInfo,
			Label { font = small; text =
				"Copyright (c) 2015, Steve Eynon
				 Licensed under the MIT Licence"
			},
		}
		d := Dialog(command.window) { title="About Flux"; body=content; commands=[Dialog.ok] }
		d.open
	}
}