using afIoc
using gfx
using fwt

internal class PanelTabPane : ContentPane {
	CTabPane		tabPane		:= CTabPane() { it.onSelect.add |e| { this->onSelect(e) }; it.onClose.add |e| { this->onClose(e) } }
	PanelTabTuple[]	panelTabs	:= PanelTabTuple[,]	// 'cos I can't use non-const Panel as a key
	Bool			alwaysShowTabs	// TODO: implement alwaysShowTabs
	
	new make(Bool visible, Bool alwaysShowTabs, |This|in) {
		in(this)
		this.visible = visible
		this.alwaysShowTabs = alwaysShowTabs
	}

	This addTab(Panel panel) {
		if (panelTabs.find { it.panel === panel } != null)
			return this	// already added

		content := panel.content

		if (panelTabs.isEmpty) {
			super.content = content

			panelTabs.add(PanelTabTuple() {
				it.panel	= panel
			})
			
			this.visible = true
		} else {

			if (panelTabs.size == 1) {
				super.content = tabPane
				panelTabs.first.addTab(tabPane)
			}

			panelTabs.add(PanelTabTuple() {
				it.panel	= panel
			}).last.addTab(tabPane)
		}

		this.parent.relayout
		this.relayout

		panel.isShowing = true
		panel->onShow
		panel->onModify

		return this
	}

	This removeTab(Panel panel) {
		tuple := panelTabs.find { it.panel === panel } 
		if (tuple == null)
			return this

		activate(null)	// deactivate it if its showing
		panel.isShowing = false
		panel->onHide
		panel->onModify

		panelTabs.removeSame(tuple)

		if (panelTabs.isEmpty) {
			super.content = null
			this.visible = false
			this.parent.relayout
			return this
		}

		tuple.removeTab(tabPane)

		if (panelTabs.size == 1) {
			this.content = panelTabs.first.removeTab(tabPane).panel.content
			relayout
		}

		this.parent.relayout
		return this
	}
	
	** Pass null to just deactivate
	This activate(Panel? panel) {
		tuple := panelTabs.find { it.panel === panel }
		
		panelTabs.each {
			if (it !== tuple && it.panel.isActive) {
				it.panel.isActive = false
				it.panel->onDeactivate
			}
		}

		if (tuple != null) {
			if (tuple.tab != null)
				tabPane.selected = tuple.tab
			if (tuple.panel.isActive == false) {
				tuple.panel.isActive = true
				tuple.panel->onActivate
			}
		}
		
		return this
	}

	Void onSelect(Event? event)	{
		selected := tabPane.selected

		if (selected != null) {
			tuple := panelTabs.find { it.tab === selected } 
			if (tuple == null) return
			activate(tuple.panel)			
		}
	}

	Void onClose(Event? event)	{
		tuple := panelTabs.find { it.tab === event.data }
		if (tuple?.panel != null) {
//			activate(null)
			removeTab(tuple.panel)
			
			// we've just removed the tab, so SWT doesn't need to
			event.consume
		}
	}
}

internal class PanelTabTuple {
	CTab?	tab
	Panel?	panel
	
	This addTab(CTabPane tabPane) {
		tab	= CTab()
		tab.add(panel.content)
		tab.text  = panel.name
		tab.image = panel.icon
		tabPane.add(tab)
		panel._tab = tab
		return this
	}

	This removeTab(CTabPane tabPane) {
		tab.remove(panel.content)
		tabPane.remove(tab)
		tab = null
		panel._tab = null
		return this
	}
}
