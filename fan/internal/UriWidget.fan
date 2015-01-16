using afIoc
using gfx
using fwt

internal class UriWidget : Canvas, RefluxEvents {
	private const Insets textInsets := Insets(4,  4, 4, 22)
	private const Insets viewInsets := Insets(4, 13, 4,  4)

	@Inject	private Reflux	reflux
	
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
		onMouseUp.add { this->onViewPopup(it) }
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

	Void onViewPopup(Event event) {
		if ((reflux.activeView?.resource?.viewTypes?.size ?: 0) <= 1)
			return

		vt := reflux.activeView?.typeof?.name?.toDisplayName ?: "Views"
		vw := Desktop.sysFont.width(vt) + viewInsets.left + viewInsets.right
		vx := size.w - vw
		if (event.pos.x > vx && event.pos.x < vx+vw) {
			views := reflux.activeView?.resource?.viewTypes ?: Type#.emptyList
			if (views == null || views.isEmpty) return
			menu := Menu {}
			views.each |Type t| {
				menu.add(MenuItem {
					it.text = t.name.toDisplayName
					it.mode	= MenuItemMode.check
					it.selected = (t == reflux.activeView.typeof)
					it.onAction.add { reflux.replaceView(reflux.activeView, t) }
				})
			}
			menu.open(this, Point(vx, size.h-1))
		}
	}
	
	override Void onPaint(Graphics g) {
		g.brush = Desktop.sysListBg
		g.fillRect(0, 0, size.w, size.h)
		g.brush = Desktop.sysNormShadow
		g.drawRect(0, 0, size.w - 1, size.h - 1)

		if (icon != null)
			g.drawImage(icon, 4, 3)

		vw := 0
		if ((reflux.activeView?.resource?.viewTypes?.size ?: 0) > 1) {
			vt := reflux.activeView.typeof.name.toDisplayName
			vw  = Desktop.sysFont.width(vt) + viewInsets.left + viewInsets.right
			vx := size.w - vw
			vy := (size.h - Desktop.sysFont.height) / 2
		    g.brush = Desktop.sysFg
		    g.drawText(vt, vx + viewInsets.left, vy)
		}

	    ax := size.w - viewInsets.right + 3
	    ay := (size.h - 3) / 2
	    g.drawLine(ax  , ay,   ax+4, ay)
	    g.drawLine(ax+1, ay+1, ax+3, ay+1)
	    g.drawLine(ax+2, ay+2, ax+2, ay+2)

		tp := text.prefSize
		tx := textInsets.left
		ty := (size.h - text.prefSize.h) / 2
		tw := size.w - textInsets.left - textInsets.right - vw
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
		repaint
	}
}