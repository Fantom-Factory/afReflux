using afIoc
using gfx
using fwt

class PathSideBar : SideBar {

	Image? icon
	Text path := Text() // { onAction.add { goDefaultView(it) }; border = false }

	new make(|This| in) {
		in(this)
		content = path
		
		path.text = "Wotcha"
	}
	
	override Obj prefAlign() { return Valign.bottom }
	
	override Size prefSize(Hints hints := Hints.defVal) {
		ph := path.prefSize.h.max(icon?.size?.h ?: 0)
		return Size(100, ph)
	}

	Void onDirOpened(Uri url) {
		path.text = url.toStr
	}
	
//	override Void onPaint(Graphics g) {
//		vw := Desktop.sysFont.width(view) + viewInsets.left + viewInsets.right
//		vx := size.w - vw
//		vy := (size.h - Desktop.sysFont.height) / 2
//
//		g.brush = Desktop.sysListBg
//		g.fillRect(0, 0, size.w, size.h)
//
//		g.brush = Desktop.sysNormShadow
//		g.drawRect(0, 0, size.w-1, size.h-1)
//
//		if (icon != null)
//			g.drawImage(icon, 4, 4)
//
//		g.brush = Desktop.sysFg
//		g.drawText(view, vx+viewInsets.left, vy)
//
//		ax := size.w - viewInsets.right + 3
//		ay := (size.h - 3) / 2
//		g.drawLine(ax	, ay,	 ax+4, ay)
//		g.drawLine(ax+1, ay+1, ax+3, ay+1)
//		g.drawLine(ax+2, ay+2, ax+2, ay+2)
//
//		tp := uriText.prefSize
//		tx := textInsets.left
//		ty := (size.h - uriText.prefSize.h) / 2
//		tw := size.w - vw - textInsets.left - textInsets.right
//		th := size.h - textInsets.top - textInsets.bottom
//		uriText.bounds = Rect(tx, ty, tw, th)
//	}
}
