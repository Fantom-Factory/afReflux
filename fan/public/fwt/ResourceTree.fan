using gfx
using fwt

** (Widget) - A tree widget that displays 'Resource' hierarchies. 'ResourceTree' is a wrapper around the FWT 
** [Tree]`fwt::Tree` widget with the following enhancements:
** 
**  - A 'Resource' specific tree model. 
**  - Hassle free 'refreshNode()' and 'showNode()' methods that just work.
**  - Event data return the 'Resource' that's been actioned.
**  
** Because 'ResourceTree' does not extend 'fwt:Widget' it can not be added directly. 
** Instead, add the 'tree' field which returns the wrapped FWT Tree instance.
** 
**   tree := ResourceTree()
**   ContentPane() {
**       it.content = tree.tree
**   }
class ResourceTree {
	
	** The underlying FWT Tree widget.
	Tree tree

	** The model that customises the look of the tree. Leave as is for default behaviour.
	ResourceTreeModel model := ResourceTreeModel() {
		set {
			tree.model = TreeModelAdapter(roots, it)
			&model = it			
		}
	}
	
	** The root resources of the tree.
	Resource[] roots := Resource#.emptyList {
		set {
			tree.model = TreeModelAdapter(it, model)
			&roots = it
		}
	}

	** Creates a 'ResourceTree'.
	new make(|This|? in := null) {
		tree = Tree()
		in(this)
		tree.onAction.add |Event e| {
			node := (TreeNode?) e.data
			e.data = node?.resource
			onAction.fire(e)
			e.data = node
		}

		tree.onSelect.add |Event e| {
			node := (TreeNode?) e.data
			e.data = node?.resource
			onSelect.fire(e)
			e.data = node
		}

		tree.onPopup.add |Event e| {
			node := (TreeNode?) e.data
			e.data = node?.resource
			onPopup.fire(e)
			e.data = node
		}
	}

	** Callback when node is double clicked or Return/Enter key is pressed.
	**
	** Event id fired:
	**	 - 'EventId.modified'
	**
	** Event fields:
	**	 - 'Event.data': the 'Resource' actioned
	once EventListeners onAction() { EventListeners() }

	** Callback when selected nodes change.
	**
	** Event id fired:
	**	 - 'EventId.select'
	**
	** Event fields:
	**	 - 'Event.data': the 'Resource' selected
	once EventListeners onSelect() { EventListeners() }

	** Callback when user invokes a right click popup action. 
	** If the callback wishes to display a popup, then set the 'Event.popup' field with menu to open.
	** If multiple callbacks are installed, the first one to return a nonnull popup consumes the event.
	**
	** Event id fired:
	**	 - 'EventId.popup'
	**
	** Event fields:
	**	 - 'Event.data': the 'Resource' selected, or 'null' if this is a background popup.
	**	 - 'Event.pos': the mouse position of the popup.
	once EventListeners onPopup() { EventListeners() }

	** Update the entire tree's contents from the model.
	Void refreshAll() {
		tree.refreshAll		
	}
	
	** Updates the specified resource from the model before showing it.
	Void refreshNode(Resource resource) {
		node := findNodePath(resource)

		if (node.getSafe(-2) != null) {	// null for root nodes
			node.getSafe(-2).refresh
			tree.refreshNode(node.getSafe(-2))
		} else {
			tree.model = TreeModelAdapter(roots, model)
			tree.refreshAll					
		}
		
		Desktop.callLater(50ms) |->| {
			showNode(resource)
		}
	}
	
	** Scrolls and expands the tree until the 'Resource' is visible.
	** This also selects the resource in the tree.
	Void showNode(Resource resource) {
		path := findNodePath(resource)
		path.eachRange(0..-2) { tree.setExpanded(it, true) }
		tree.show(path.last)
		tree.select(path.last)
	}

	private TreeNode[] findNodePath(Resource resource) {
		resPath		:= path(resource)
		nodePath	:= TreeNode[,]
		nodes		:= treeModel.roots
		resPath.each |Resource s, i| {
			node := nodes.find { it.resource == resPath[i] }
			nodePath.add(node)
			nodes = node.children
		}
		return nodePath
	}

	private Resource[] path(Resource? r) {
		path	:= Resource[,]
		while (r != null) {
			path.add(r)
			r = r.parent
		}
		return path.reverse
	}
	
	private TreeModelAdapter treeModel() {
		tree.model
	}
}

** A model to customise the look of a 'ResourceTree'.
class ResourceTreeModel {

	** Get the text to display.
	** Defaults to 'resource.name'.
	virtual Str text(Resource resource) { resource.name }

	** Get the image to display.
	** Defaults to 'resource.icon'.
	virtual Image? image(Resource resource) { resource.icon }

	** Get the font for specified resource or 'null' for default.
	virtual Font? font(Resource resource) { null }

	** Get the foreground color for specified node or 'null' for default.
	virtual Color? fg(Resource resource) { null }

	** Get the background color for specified node or 'null' for default.
	virtual Color? bg(Resource resource) { null }

	** Return if this has or might have children.	This
	** is an optimisation to display an expansion control
	** without actually loading all the children.
	** 
	** Defaults to 'resource.hasChildren'.
	virtual Bool hasChildren(Resource resource) { resource.hasChildren }

	** Get the children of the specified node.
	** If no children return an empty list.
	** 
	** Defaults to 'resource.children'.
	virtual Resource[] children(Resource resource) { resource.children }

}

internal class TreeModelAdapter : TreeModel {
	override TreeNode[] roots
	ResourceTreeModel model
	
	new make(Resource[] roots, ResourceTreeModel model) {
		this.roots = TreeNode.map(null, roots)
		this.model = model
	}

	override Str	text		(Obj n) { model.text(res(n)) }
	override Image?	image		(Obj n) { model.image(res(n)) }
	override Font?	font		(Obj n) { model.font(res(n)) }
	override Color?	fg			(Obj n) { model.fg(res(n)) }
	override Color?	bg			(Obj n) { model.bg(res(n)) }
	override Bool	hasChildren	(Obj n) { node(n).hasChildren }
	override Obj[]	children	(Obj n) { node(n).children }
	
	Resource res(TreeNode n) { n.resource }
	TreeNode node(TreeNode n) { n }
}

internal class TreeNode {
	TreeNode? parent
	Resource resource
	
	new make(TreeNode? parent, Resource resource) {
		this.parent = parent
		this.resource = resource
	}
	
	Bool hasChildren() { !children.isEmpty }

	TreeNode[]? children {
		get {
			if (&children == null)
				&children = map(this, resource.children)
			return &children
		}
	}

	Void refresh() {
		children = null
	}

//	override Str toStr() { return resource.toStr }

	static TreeNode[] map(TreeNode? parent, Resource[] resources) {
		resources.map { TreeNode(parent, it) }
	}
}
