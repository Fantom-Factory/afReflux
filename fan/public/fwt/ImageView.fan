using afIoc
using gfx
using fwt
using concurrent

class ImageView : View {

	@Inject private RefluxIcons 	icons
	@Inject private Registry		registry

	protected new make(|This| in) : super(in) { }
	
	override Void update(Resource resource) {
		super.update(resource)
		fileResource := (FileResource) resource
		image := loadImage(fileResource.file) 

		imageWidget := ImageViewWidget(image ?: icons["icoImageNotFound"])
		toolBar := ToolBar {
			it.addCommand(registry.autobuild(ImageFullSizeCommand#, [imageWidget]))
			it.addCommand(registry.autobuild(ImageFitToWindowCommand#, [imageWidget]))
		}

	    content = EdgePane {
	    	top = EdgePane {
				it.top = InsetPane(2) {
					EdgePane {
						if (image != null) {
							left = GridPane {
								numCols = 2
								Label { text="Size"; font=Desktop.sysFont.toBold },
								Label { text="${image.size.w}px x ${image.size.h}px"},
							}
						} else
							left = Label { text="Image not found: ${fileResource.file.osPath}"}
						right =  toolBar
					},
				}
				it.bottom = BorderPane {
					it.border = Border("1, 0, 1, 0 $Desktop.sysNormShadow, #000, $Desktop.sysHighlightShadow")
				}
			}
			center = ScrollPane { it.content = imageWidget; it.border = false }
	    }
	}
	
	Image? loadImage(File file) {
		image := (Image?) (file.exists ? Image.makeFile(file) : null)
		
		if (image != null) {
			napTime := 0sec
			while (napTime < 200ms && (image.size.w == 0 || image.size.h == 0)) {
				napTime += 20ms
				Actor.sleep(20ms)
			}
			if (image.size.w == 0 || image.size.h == 0)
				image = null
		}
		
		return image
	}
	
	private Button toolBarCommand(Type cmdType, Obj[] args) {
		command	:= (Command) registry.autobuild(cmdType, args)
	    button  := Button.makeCommand(command)
	    if (command.icon != null)
	    	button.text = ""
		return button
	}

}

internal class ImageViewWidget : Canvas {
	Image 	image
	Float	zoom	:= 1f
	Int		border	:= 8
	Size	iSize
	
	new make(Image image) {
		this.image = image
		this.iSize = image.size
	}

	override Void onPaint(Graphics g) {
		g.brush = Color.white
		g.fillRect(0, 0, size.w, size.h)
		g.copyImage(image, Rect(0, 0, image.size.w, image.size.h), Rect(border, border, (zoom * image.size.w.toFloat).toInt, (zoom * image.size.h.toFloat).toInt))
	}

	override Size prefSize(Hints hints := Hints.defVal) { iSize }

	Void doFitToWindow() {
		w := (parent.size.w - (border*2)).toFloat / image.size.w.toFloat
		h := (parent.size.h - (border*2)).toFloat / image.size.h.toFloat
		zoom = w.min(h)
		iSize = parent.size
		parent->onLayout
		repaint
	}

	Void doFullSize() {
		zoom = 1f
		iSize = image.size
		parent->onLayout
		repaint
	}
}

internal class ImageFitToWindowCommand : RefluxCommand {
	private ImageViewWidget	imageWidget

	new make(ImageViewWidget imageWidget, |This|in) : super.make(in) {
		this.imageWidget = imageWidget
		this.name = "Fit to Window"
	}

	override Void invoked(Event? event) {
		imageWidget.doFitToWindow
	}
}

internal class ImageFullSizeCommand : RefluxCommand {
	private ImageViewWidget	imageWidget

	new make(ImageViewWidget imageWidget, |This|in) : super.make(in) {
		this.imageWidget = imageWidget
		this.name = "Zoom to 100%"
	}

	override Void invoked(Event? event) {
		imageWidget.doFullSize
	}
}
