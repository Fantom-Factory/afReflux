using gfx
using fwt

class CTabPane : Pane {

	** Callback when the new tab is selected.
	**
	** Event id fired:
	**	 - `EventId.select`
	**
	** Event fields:
	**	 - `Event.index`: index of selected tab
	**	 - `Event.data`: new active Tab instance
	once EventListeners onSelect() { EventListeners() }

	** Get the list of installed tabs.	Tabs are added and
	** removed using normal `Widget.add` and `Widget.remove`.
	CTab[] tabs() { return CTab[,].addAll(children) }

	** The currently selected index of `tabs`.
	@Transient native Int? selectedIndex

	** The currently selected tab.
	@Transient CTab? selected {
		get { i := selectedIndex; return i == null ? null : tabs[i] }
		set { i := index(it); if (i != null) selectedIndex = i }
	}

	** Get the index of the specified tab.
	Int? index(CTab tab) { return tabs.index(tab) }

	** Only `Tab` children may be added.
	@Operator override This add(Widget? kid) {
		if (kid isnot CTab)
			throw ArgErr("Child of TabPane must be CTab, not ${Type.of(kid)}")
		super.add(kid)
		return this
	}
	
	override Size prefSize(Hints hints := Hints.defVal){ Size(100,100)}
	override Void onLayout() {}
}