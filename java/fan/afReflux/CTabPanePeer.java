package fan.afReflux;

import java.util.Iterator;

import fan.sys.*;
import fan.fwt.*;
import fan.gfx.Valign;

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
		CTabPane self = (CTabPane) CTabPanePeer.this.self;
		int style = SWT.CLOSE | SWT.FLAT;
		if (self.tabsValign.equals(Valign.top))
			style |= SWT.TOP;
		if (self.tabsValign.equals(Valign.bottom))
			style |= SWT.BOTTOM;
		CTabFolder c = new CTabFolder((Composite) parent, style);
		c.setSimple(self.simpleTabs);
		c.setBorderVisible(true);	// the border is on the tab pane - makes them look more like tabs!
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
					fan.fwt.Event fe = event(EventId.close);
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
		
		fan.fwt.Event fe = event(EventId.select);
		fe.index = Long.valueOf(control.getSelectionIndex());
		fe.data  = self.tabs().get(fe.index);
		self.onSelect().fire(fe);
	}
}
