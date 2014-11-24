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

	once EventListeners onClose() { EventListeners() }

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

//	** Only `Tab` children may be added.
//	@Operator override This add(Widget? kid) {
//		if (kid isnot CTab)
//			throw ArgErr("Child of TabPane must be CTab, not ${Type.of(kid)}")
//		child := (CTab?) kid
//		
//		// duplicate Widget.add() so we can call our own attach() method
//		if (child == null) return this
//		if (child.parent != null)
//			throw ArgErr("Child already parented: $child")
//		
////		child.parent = this	// stoopid private setter
//		Widget#.field("parent").set(this, this)
//		kids := (Widget[]) Widget#.field("kids").get(this)
//		kids.add(child)
//		try { child.attach2 } catch (Err e) { e.trace }
//		return this
//	}
	
	override Size prefSize(Hints hints := Hints.defVal) { Size(100,100) }

	override Void onLayout() {}
}