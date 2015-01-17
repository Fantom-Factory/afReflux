using afIoc
using gfx::Image

** (Service) - 
** Loads and maintains images, ensuring they get disposed on registry shutdown. 
mixin Images {
	
	abstract internal Void disposeOfImages()
	
	abstract Void stash(Image image)
	
	@Operator
	abstract Image? get(Uri? icoUri, Bool faded := false, Bool checked := true)
}

internal class ImagesImpl : Images {
	@Inject private Log			log
			private Uri:Image	images		:= Uri:Image[:]
			private Uri:Image	fadedImages	:= Uri:Image[:]
			private Image[]		extra		:= Image[,]

	new make(|This| in) { in(this) }

	override internal Void disposeOfImages() {
		images.vals.each { it.dispose }
		images.clear
		extra.each { it.dispose }
		extra.clear
	}

	override Void stash(Image image) {
		extra.add(image)
	}
	
	override Image? get(Uri? icoUri, Bool faded := false, Bool checked := true) {
		if (icoUri == null)
			return null

		try {
			image := images.getOrAdd(icoUri) { Image(icoUri) }

			return faded ? fadedImages.getOrAdd(icoUri) {
				Image.makePainted(image.size) |gfx| {
					gfx.alpha = 128
					gfx.antialias = false
					gfx.drawImage(image, 0, 0)
				}			
			} : image

		// any other err is potentially dangerous / or there's something wrong with the image
		} catch (UnresolvedErr err) {
			if (checked)
				log.warn("Could not load `${icoUri}`")
			return null
		}
	}
}
