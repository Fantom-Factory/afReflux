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

//	public void attach2(CTab self) { attach2(self, null); }
//	public void attach2(CTab self, Widget parentControl) {
//
//		// short circuit if I'm already attached
//		if (control() != null) return;
//		
//		// if parent wasn't explictly specified use my fwt parent
//		fan.fwt.Widget parentWidget = null;
//		if (parentControl == null) {
//			// short circuit if my parent isn't attached
//			parentWidget = self.parent();
//			System.err.println("########## " + parentWidget);
//			if (parentWidget == null || parentWidget.peer.control() == null) return;
//			parentControl = parentWidget.peer.control();
//		}
//		
//		// create control and initialize
//		// TODO: need to rework this cluster f**k
//		if (parentControl instanceof CTabItem) {
//			CTabItem item = (CTabItem) parentControl;
//			attachTo2(create(item.getParent()));
//			item.setControl((Control) this.control());
//		} else if (parentControl instanceof TabItem) {
//			TabItem item = (TabItem) parentControl;
//			attachTo2(create(item.getParent()));
//			item.setControl((Control) this.control());
//		} else {
//			attachTo2(create(parentControl));
//			if (parentControl instanceof ScrolledComposite)
//				((ScrolledComposite) parentControl).setContent((Control) control());
//		}
//
//		System.err.println("########## " + parentWidget.peer);
//		// callback on parent
////		if (parentWidget != null) parentWidget.peer.childAdded(self);
//	}
//	
//	private void attachTo2(Widget control) {
//		try {
//			java.lang.reflect.Method method = WidgetPeer.class.getDeclaredMethod("attachTo", Widget.class);
//	        method.setAccessible(true); 
//	        method.invoke(this, control);
//		} catch (Exception err) {
//			err.printStackTrace();
//			throw new RuntimeException(err.getMessage(), err);
//		}		
//	}
}