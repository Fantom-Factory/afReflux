package fan.afReflux;

import java.util.Iterator;

import fan.sys.*;
import fan.fwt.*;
import org.eclipse.swt.*;
import org.eclipse.swt.events.*;
import org.eclipse.swt.custom.*;
import org.eclipse.swt.widgets.*;
import org.eclipse.swt.widgets.Widget;

public class CTabPanePeer extends WidgetPeer implements SelectionListener {

	public static CTabPanePeer make(CTabPane self) throws Exception {
		CTabPanePeer peer = new CTabPanePeer();
		((fan.fwt.Widget) self).peer = peer;
		peer.self = self;
		return peer;
	}

	public Widget create(Widget parent) {
		CTabFolder c = new CTabFolder((Composite) parent, SWT.CLOSE);
		c.setSimple(false);
		c.setBorderVisible(false);
		// control is package protected - D'Oh! Use reflection...
//		this.control = c;
		try {
			java.lang.reflect.Field controlField = WidgetPeer.class.getDeclaredField("control");
			controlField.setAccessible(true);
			controlField.set(this, c);
		} catch (Exception err) {
			err.printStackTrace();
			throw new RuntimeException(err.getClass() + " - " + err.getMessage(), err);
		}
		c.addSelectionListener(this);
		c.addCTabFolder2Listener(new CTabFolder2Adapter() {
			public void close(CTabFolderEvent event) {
				CTabPane self = (CTabPane) CTabPanePeer.this.self;
				CTab found = null;
				int i = 0;
				for (; i < self.tabs().size(); i++) {
					CTab tab = (CTab) self.tabs().get(i);
					if (((CTabPeer) tab.peer).control().equals(event.item))
						found = tab;
				}

				if (found != null) {
					// event() is packge protected - D'Oh! Use reflection...
//					fan.fwt.Event fe = event(EventId.close);
					fan.fwt.Event fe = makeEvent(EventId.close);

					fe.data  = found;
					fe.index = Long.valueOf(i);
					self.onClose().fire(fe);
					
					if (fe.consumed()) {
						event.doit = false;						
					}
				}
			}
		});
		return c;
	}

	// Int selectedIndex := 0
	public Long selectedIndex(CTabPane self) { return selectedIndex.get(); }
	public void selectedIndex(CTabPane self, Long v) { selectedIndex.set(v); }
	public final Prop.IntProp selectedIndex = new Prop.IntProp(this, 0, true) {
		public int get(Widget w) { return ((CTabFolder) w).getSelectionIndex(); }
		public void set(Widget w, int v) { ((CTabFolder) w).setSelection(v); }
	};

	public void widgetDefaultSelected(SelectionEvent e) {} // unused

	public void widgetSelected(SelectionEvent e) {
		CTabFolder control = (CTabFolder) this.control();
		CTabPane self = (CTabPane) this.self;
		
		// event() is packge protected - D'Oh! Use reflection...
//		fan.fwt.Event fe = event(EventId.select);
		fan.fwt.Event fe = makeEvent(EventId.select);

		fe.index = Long.valueOf(control.getSelectionIndex());
		fe.data  = self.tabs().get(fe.index);
		self.onSelect().fire(fe);
	}

	fan.fwt.Event makeEvent(EventId eventId) {
		try {
			java.lang.reflect.Method method = WidgetPeer.class.getDeclaredMethod("event", EventId.class);
	        method.setAccessible(true); 
	        return (fan.fwt.Event) method.invoke(this, eventId);
		} catch (Exception err) {
			throw new RuntimeException(err.getClass() + " - " + err.getMessage(), err);
		}		
	}
	
//	private void childAdded2(fan.fwt.Widget self) {
//		try {
//			java.lang.reflect.Method method = WidgetPeer.class.getDeclaredMethod("attachTo", Widget.class);
//			method.setAccessible(true); 
//			method.invoke(this, control);
//		} catch (Exception err) {
//			err.printStackTrace();
//			throw new RuntimeException(err.getMessage(), err);
//		}		
//	}
}
