using afIoc
using gfx
using fwt

internal class UriWidget : Canvas, RefluxEvents {
	private const Insets textInsets := Insets(4, 4, 4, 22)

	@Inject
	private Reflux	reflux
	
	private Image?	icon
	private Text	text := Text() {
		it.border = false
		it.onAction.add { this->onAction(it) }
		it.onFocus.add  { 
			Desktop.callLater(50ms) |->| {
				this.text.selectAll	
			}
		}
	}

	new make(EventHub eventHub, |This|in) {
		in(this)
		add(text)
		eventHub.register(this)
	}
	
	Void onAction(Event event) {
		uri := (Uri?) null
		try {
			file := File.os(text.text).normalize
			if (file.exists)
				uri = file.uri
		} catch { }
		
		try {
			if (uri == null)
				uri = text.text.toUri
		} catch { }
		
		if (uri != null)
			reflux.load(uri)
		else
			Dialog.openWarn(window, "Not a valid file: ${text.text}")
	}

	override Size prefSize(Hints hints := Hints.defVal) {
		ph := text.prefSize.h.max(icon?.size?.h ?: 0) + textInsets.top + textInsets.bottom
		return Size(100, ph)
	}

	override Void onPaint(Graphics g) {
		g.brush = Desktop.sysListBg
		g.fillRect(0, 0, size.w, size.h)

		g.brush = Desktop.sysNormShadow
		g.drawRect(0, 0, size.w-1, size.h - 1)

		if (icon != null)
			g.drawImage(icon, 4, 4)

		tp := text.prefSize
		tx := textInsets.left
		ty := (size.h - text.prefSize.h) / 2
		tw := size.w - textInsets.left - textInsets.right
		th := size.h - textInsets.top - textInsets.bottom
		text.bounds = Rect(tx, ty, tw, th)
	}
	
	override Void onLoad(Resource resource, LoadCtx ctx) {
		update(resource)
	}
	
	override Void onViewActivated(View view) {
		update(view.resource)
	}
	
	override Void onViewModified(View view) {
		update(view.resource)
	}
	
	private Void update(Resource? resource) {
		if (resource == null) return
		text.text = resource.displayName
		icon = resource.icon
		
		// repaint the icon - text gets redrawn automatically
		super.repaint(Rect(4, 4, 16, 16))
	}
}