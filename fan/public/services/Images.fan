using afIoc
using gfx::Image
using concurrent::Actor

** (Service) - 
** Maintains a cache of Images, ensuring they get disposed of properly. 
mixin Images {
	
	** Returns the image at the given URI, storing it in the cache. 
	@Operator
	abstract Image? get(Uri uri, Bool checked := true)

	** Returns (and caches) a faded version of the image at the given URI.
	** Useful for generating *disabled* icons. 
	abstract Image? getFaded(Uri uri, Bool checked := true)

	** Returns (and caches) the image at the given URI ensuring that it is fully loaded and that 
	** its 'size()' is available.
	abstract Image? load(Uri uri, Bool checked := true)

	** Disposes of all the images. This is called on registry shutdown. 
	** The 'AppModule' config key is 'afReflux.disposeOfImages'.
	abstract Void disposeAll()
}

@NoDoc	// so maxLoadTime may be overridden
class ImagesImpl : Images {
	private Uri:Image	images		:= Uri:Image[:]
	private Uri:Image	fadedImages	:= Uri:Image[:]
	private Image[]		extra		:= Image[,]

			Duration maxLoadTime	:= 200ms
	
	new make(|This| in) { in(this) }

	override Image? get(Uri uri, Bool checked := true) {
		if (images.containsKey(uri))
			return images[uri]
		
		image := Image.make(uri, checked)
		
		if (image != null)
			images[uri] = image

		return image
	}
	
	override Image? getFaded(Uri uri, Bool checked := true) {
		fadedImages.getOrAdd(uri) |->Image| {
			image := load(uri, checked)
			return Image.makePainted(image.size) |gfx| {
				gfx.alpha = 128
				gfx.antialias = false
				gfx.drawImage(image, 0, 0)
			}			
		}
	}
	
	override Image? load(Uri uri, Bool checked := true) {
		image := get(uri, checked)

		napTime := 0sec
		while (napTime < maxLoadTime && (image.size.w == 0 || image.size.h == 0)) {
			napTime += 20ms
			Actor.sleep(20ms)
		}
		if (image.size.w == 0 || image.size.h == 0)
			throw Err("Loading image `${uri}` took too long... (>${maxLoadTime.toLocale})")
		
		return image
	}

	override Void disposeAll() {
		images.vals.each { it.dispose }
		images.clear
		extra.each { it.dispose }
		extra.clear
	}
}
