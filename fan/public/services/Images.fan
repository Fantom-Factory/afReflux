using afIoc3
using gfx::Image
using concurrent::Actor

** (Service) -
** Maintains a cache of Images, ensuring they are disposed of properly.
** 
** A common usage is to create an 'Icons' class in your project that keeps tabs on the file mappings:
** 
** pre>
** syntax: fantom
** 
** using afIoc3::Inject
** using afReflux::Images
** using gfx::Image
** 
** class Icons {
**     @Inject private Images images
**     
**     private new make(|This| in) { in(this) }
**     
**     Image icoImage1() { get("image1.png") }
**     Image icoImage2() { get("image2.png") }
**     Image icoImage3() { get("image3.png") }
** 
**     Image get(Str name) {
**         images[`fan://${typeof.pod.name}/res/icons/${name}`]
**     }
** }
** <pre
** 
** Then the icons may be referenced with:
** 
**   syntax: fantom
** 
**   icon := icons.icoImage1
** 
** Don't forget to add the image directory to 'resDirs' in the 'build.fan':
** 
**   syntax: fantom
** 
**   resDirs = [`res/icons/`]
** 
@Js
mixin Images {

	** Returns (and caches) the image at the given URI.
	@Operator
	abstract Image? get(Uri uri, Bool checked := true)

	** Stashes the image under the given URI.
	** If another image existed under the same URI, it is disposed of.
	@Operator
	abstract Void set(Uri uri, Image image)

	** Returns true if an image is mapped to the given URI.
	abstract Bool contains(Uri uri)

	** Returns (and caches) a faded version of the image at the given URI.
	** Useful for generating *disabled* icons.
	abstract Image? getFaded(Uri uri, Bool checked := true)

	** Returns (and does not cache) the image at the given URI ensuring that it is fully loaded and that
	** its 'size()' is available.
	abstract Image? load(Uri uri, Bool checked := true)

	** Disposes of all the images. This is called on registry shutdown.
	** The 'AppModule' config key is 'afReflux.disposeOfImages'.
	abstract Void disposeAll()
}

@NoDoc	@Js // so maxLoadTime may be overridden
class ImagesImpl : Images {
	private Uri:Image		images		:= Uri:Image[:]
	private Uri:Image		fadedImages	:= Uri:Image[:]
	private Image[]			extra		:= Image[,]
	private Uri:DateTime	fileCache	:= Uri:DateTime[:]

			Duration maxLoadTime	:= 200ms

	new make(|This| in) { in(this) }

	override Image? get(Uri uri, Bool checked := true) {
		if (images.containsKey(uri))
			return images[uri]

		image := makeImage(uri, checked)

		if (image != null)
			images[uri] = image

		return image
	}

	override Void set(Uri uri, Image image) {
		if (image == images[uri])
			return
		if (images.containsKey(uri))
			images[uri].dispose
		images[uri] = image
	}

	override Bool contains(Uri uri) {
		images.containsKey(uri)
	}

	override Image? getFaded(Uri uri, Bool checked := true) {
		if (fadedImages.containsKey(uri))
			return fadedImages[uri]

		image := load(uri, checked)
		if (image == null)
			return null

		faded := Image.makePainted(image.size) |gfx| {
			gfx.alpha = 128
			gfx.antialias = false
			gfx.drawImage(image, 0, 0)
		}

		fadedImages[uri] = faded
		return faded
	}

	override Image? load(Uri uri, Bool checked := true) {
		// we may cache an image produced from load, but don't bother caching it itself
		image := makeImage(uri, checked)

		if (image == null)
			return null

		try {
			napTime := 0sec
			while (napTime < maxLoadTime && (image.size.w == 0 || image.size.h == 0)) {
				napTime += 20ms
				Actor.sleep(20ms)
			}
			if (image.size.w == 0 || image.size.h == 0)
				throw Err("Loading image `${uri}` took too long... (>${maxLoadTime.toLocale}) - w=${image.size.w} h=${image.size.h}")

		} catch (Err err) {
			// beware: org.eclipse.swt.SWTException: Unsupported or unrecognized format
			if (!checked)
				return null
			throw err
		}

		return image
	}
	
	** Fantom has some sort of internal Image caching going on - so we cache bust the URI if needed
	private Image? makeImage(Uri uri, Bool checked := true) {
		if (Env.cur.runtime == "js")
			return Image(uri, checked)

		try {
			f := (File?) uri.get
			if (f == null || !f.exists) throw UnresolvedErr("file does not exist: ${f?.normalize ?: uri}")
			
			lastUpdated := fileCache.getOrAdd(uri) { f.modified }
			if (f.modified > lastUpdated) {
				fileCache[uri] = f.modified
				uri = uri.plusQuery(["bustCache":Int.random(0..9999).toStr])
			}
			
			return Image(uri, checked)

		} catch (Err e) {
			if (checked) throw e
			return null
		}		
	}

	override Void disposeAll() {
		images.vals.each { it.dispose }
		images.clear
		extra.each { it.dispose }
		extra.clear
	}
}