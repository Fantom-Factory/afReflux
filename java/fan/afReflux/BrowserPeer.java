package fan.afReflux;

import fan.sys.*;
import fan.fwt.Label;
import fan.fwt.PanePeer;
import org.eclipse.swt.*;
import org.eclipse.swt.browser.*;
//import org.eclipse.swt.layout.*;
import org.eclipse.swt.widgets.*;

public class BrowserPeer extends PanePeer implements LocationListener {

	Uri loadUri;
	String loadStr;
	boolean explicitLoad;
	
	fan.fwt.Widget	fanBrowser;

	public static BrowserPeer make(fan.afReflux.Browser self) throws Exception {
		BrowserPeer peer = new BrowserPeer();
		((fan.fwt.Widget)self).peer = peer;
		peer.self = self;
		return peer;
	}

	public fan.fwt.Widget browser(fan.afReflux.Browser self) {
		return fanBrowser;
	}
	public void browser(fan.afReflux.Browser self, fan.fwt.Widget browser) {
		this.fanBrowser = browser;
	}
	
	public Widget create(Widget parent) {
		org.eclipse.swt.browser.Browser browser = new org.eclipse.swt.browser.Browser((Composite) parent, 0);
		
		browser.setText("Steve");
		
		Browser self = (Browser) this.self;

//		b.addLocationListener(this);
//		if (loadUri != null) load((Browser)self, loadUri);
//		else if (loadStr != null) loadStr((Browser)self, loadStr);
		return b;
	}

	// ---- Commands ------------------------------------------------------------------------------
	
//	public Browser load(Browser self, Uri uri) {
//		Browser b = (Browser) this.control;
//		if (b == null) { loadUri = uri; return self; }
//		explicitLoad = true;
//		
//		try {
//			b.setUrl(uri.toString());
//			return self;
//			
//		} finally {
//			explicitLoad = false;
//		}
//	}
//
//	public Browser loadStr(Browser self, String html) {
//		Browser b = (Browser) this.control;
//		if (b == null) { loadStr = html; return self; }
//		explicitLoad = true;
//		
//		try {
//			b.setText(html);
//			return self;
//			
//		} finally {
//			explicitLoad = false;
//		}
//	}
//
//	public Browser refresh(Browser self) {
//		Browser b = (Browser) this.control;
//		if (b != null) b.refresh();
//		return self;
//	}
//
//	public Browser stop(Browser self) {
//		Browser b = (Browser) this.control;
//		if (b != null) b.stop();
//		return self;
//	}
//
//	public Browser back(Browser self) {
//		Browser b = (Browser) this.control;
//		if (b != null) b.back();
//		return self;
//	}
//
//	public Browser forward(Browser self) {
//		Browser b = (Browser) this.control;
//		if (b != null) b.forward();
//		return self;
//	}

	// ---- Events --------------------------------------------------------------------------------

	public void changing(LocationEvent event) {
//		// don't handle event if load() called
//		if (explicitLoad) return;
//
//		// map to a Uri, this is a bit hacky, but it appears that links
//		// on local file system give us back an OS path instead of a URI;
//		// we need to handle the Windows case of "c:\..." since the drive
//		// will be interpretted as a scheme
//		String loc = event.location;
//		if (loc.startsWith("file:///")) loc = "file:/" + loc.substring(8);
//		if (loc.startsWith("file://"))	loc = "file:/" + loc.substring(7);
//		Uri uri = Uri.fromStr(loc);
//		if (uri.scheme() == null || uri.scheme().length() == 1)
//			uri = File.os(loc).normalize().uri();
//
//		fan.fwt.Browser self = (fan.fwt.Browser)this.self;
//		fan.fwt.Event fe = event(EventId.hyperlink, uri);
//		self.onHyperlink().fire(fe);
//		if (fe.data == null) {
//		
//			event.doit = false;
//		}
//		else {
//		
//			event.doit = true;
//			event.location = fe.data.toString();
//		}
	}

	public void changed(LocationEvent event) { }
}