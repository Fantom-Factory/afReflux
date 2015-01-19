package fan.afReflux;

import fan.sys.*;
import fan.fwt.Label;
import fan.fwt.PanePeer;
import fan.fwt.Prop;

import org.eclipse.swt.*;
import org.eclipse.swt.browser.*;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.widgets.*;

public class BrowserPeer extends PanePeer implements LocationListener, TitleListener, StatusTextListener, ProgressListener, OpenWindowListener {

	String	statusText;
	Uri		nextUrl;
	
	public static BrowserPeer make(fan.afReflux.Browser self) throws Exception {
		BrowserPeer peer = new BrowserPeer();
		((fan.fwt.Widget)self).peer = peer;
		peer.self = self;
		return peer;
	}
	
	public Widget create(Widget parent) {
		org.eclipse.swt.browser.Browser browser = new org.eclipse.swt.browser.Browser((Composite) parent, 0);
		
		browser.addLocationListener(this);
		browser.addTitleListener(this);
		browser.addStatusTextListener(this);
		browser.addProgressListener(this);
		browser.addOpenWindowListener(this);

		return browser;
	}

	
	public Uri url(Browser self) { String u = url.get(); return "".equals(u) ? null : Uri.fromStr(u); }
	public void url(Browser self, Uri v) { url.set(v == null ? "" : v.toStr()); }
	public final Prop.StrProp url = new Prop.StrProp(this, "") {
		public String get(Widget w) { return ((org.eclipse.swt.browser.Browser) w).getUrl(); }
		public void set(Widget w, String v) { nextUrl = Uri.fromStr(v); ((org.eclipse.swt.browser.Browser) w).setUrl(v); }
	};

	public String html(Browser self) { String t = html.get(); return "".equals(t) ? null : t; }
	public void html(Browser self, String v) { html.set(v == null ? "" : v); }
	public final Prop.StrProp html = new Prop.StrProp(this, "") {
		public String get(Widget w) { return ((org.eclipse.swt.browser.Browser) w).getText(); }
		public void set(Widget w, String v) { nextUrl = Uri.fromStr("about:blank"); ((org.eclipse.swt.browser.Browser) w).setText(v, true); }	// trusted text
	};
	
	public boolean javascriptEnabled(Browser self) { return javascriptEnabled.get(); }
	public void javascriptEnabled(Browser self, boolean v) { javascriptEnabled.set(v); }
	public final Prop.BoolProp javascriptEnabled = new Prop.BoolProp(this, true) {
		public boolean get(Widget w) { return ((org.eclipse.swt.browser.Browser) w).getJavascriptEnabled(); }
		public void set(Widget w, boolean v) { ((org.eclipse.swt.browser.Browser) w).setJavascriptEnabled(v); }
	};

	// ---- Events --------------------------------------------------------------------------------

	public void changed (LocationEvent event) { }
	public void changing(LocationEvent event) {
		// map to a Uri, this is a bit hacky, but it appears that links
		// on local file system give us back an OS path instead of a URI;
		// we need to handle the Windows case of "c:\..." since the drive
		// will be interpretted as a scheme
		String loc = event.location;
		if (loc.startsWith("file:///")) loc = "file:/" + loc.substring(8);
		if (loc.startsWith("file://"))	loc = "file:/" + loc.substring(7);
		Uri uri = Uri.fromStr(loc);
		if (uri.scheme() == null || uri.scheme().length() == 1)
			uri = File.os(loc).normalize().uri();

		// don't handle ourselves!
		if (uri.equals(nextUrl)) {
			return;
		}		

		Browser self = (Browser) this.self;
		fan.fwt.Event fe = event(fan.fwt.EventId.hyperlink, uri);
		self.onHyperlink().fire(fe);
		
		if (fe.data == null) {
			event.doit = false;
		} else {
			event.doit = true;
			// meh, event.location is input only, we can't change it
			event.location = fe.data.toString();
		}
	}
	
	public void changed  (ProgressEvent event) { }
	public void completed(ProgressEvent event) {
		fan.fwt.Event fe = event(fan.fwt.EventId.unknown, null);
		((Browser) this.self).onLoad().fire(fe);
	}

	public void changed(StatusTextEvent event) {
		// we get a shed load of repeat events - so lets filter them out
		if (!event.text.equals(statusText)) {
			statusText = event.text; 
			fan.fwt.Event fe = event(fan.fwt.EventId.unknown, event.text);
			((Browser) this.self).onStatusText().fire(fe);
		}
	}
	
	public void changed(TitleEvent event) {
		fan.fwt.Event fe = event(fan.fwt.EventId.unknown, event.title);
		((Browser) this.self).onTitleText().fire(fe);
	}

	public void open(WindowEvent event) {
		// called when user selects 'open in new window'
//		event.required = false;	// true to launch in IE, false to ignore
//		event.browser = null;
	}	

	// ---- Commands ------------------------------------------------------------------------------

	public Browser refresh(Browser self) {
		if (browser() != null) browser().refresh();
		return self;
	}

	public Browser stop(Browser self) {
		if (browser() != null) browser().stop();
		return self;
	}

	public Browser back(Browser self) {
		if (browser() != null) browser().back();
		return self;
	}

	public Browser forward(Browser self) {
		if (browser() != null) browser().forward();
		return self;
	}

	public Object evaluate(Browser self, String script) {
		return browser() != null ? browser().evaluate(script) : null;
	}

	public void execute(Browser self, String script) {
		if (browser() != null) {
			boolean res = browser().execute(script);
			if (!res)
				throw new RuntimeException("Script was not successful:\n\n" + script);
		}
	}
	
	private org.eclipse.swt.browser.Browser browser() {
		return (org.eclipse.swt.browser.Browser) this.control();
	}
}
