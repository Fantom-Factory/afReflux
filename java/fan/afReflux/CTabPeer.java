package fan.afReflux;

import fan.fwt.*;

import org.eclipse.swt.*;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.custom.*;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.swt.widgets.Widget;

public class CTabPeer extends PanePeer {

	public static CTabPeer make(CTab self) throws Exception {
		CTabPeer peer = new CTabPeer();
		((fan.fwt.Widget) self).peer = peer;
		peer.self = self;
		return peer;
	}

	public Widget create(Widget parent) {
		return new CTabItem((CTabFolder) parent, SWT.NONE);
	}

	// Str text := ""
	public String text(CTab self) { return text.get(); }
	public void text(CTab self, String v) { text.set(v); }
	public final Prop.StrProp text = new Prop.StrProp(this, "") {
		public String get(Widget w) { return ((CTabItem) w).getText(); }
		public void set(Widget w, String v) { ((CTabItem) w).setText(v);  }
	};

	// Image image := null
	public fan.gfx.Image image(CTab self) { return image.get(); }
	public void image(CTab self, fan.gfx.Image v) { image.set(v); }
	public final Prop.ImageProp image = new Prop.ImageProp(this) {
		public void set(Widget w, Image v) { ((CTabItem) w).setImage(v); }
	};
}