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
**   syntax: fantom
** 
**   tree := ResourceTree(reflux)
**   ContentPane() {
**       it.content = tree.tree
**   }
class ResourceTree {
	private Reflux reflux
	
	** The underlying FWT Tree widget.
	Tree tree

	** The model that customises the look of the tree. Leave as is for default behaviour.
	ResourceTreeModel model := ResourceTreeModelImpl() {
		set {
			tree.model = TreeModelAdapter(reflux, roots, it)
			&model = it			
		}
	}
	
	** The root resources of the tree.
	Resource[] roots := Resource#.emptyList {
		set {
			tree.model = TreeModelAdapter(reflux, it, model)
			&roots = it
		}
	}

	** Creates a 'ResourceTree'. Use the ctor to pass in a tree:
	**   syntax: fantom
	**   ResourceTree(reflux) {
	**       it.tree = Tree {
	**           it.border = false
	**       }
	**   }
	new make(Reflux reflux, |This|? in := null) {
		this.reflux = reflux
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
	Void refreshNode(Str resourceUri) {
		node := findNodePath(resourceUri)

		if (node.getSafe(-2) != null) {	// null for root nodes
			node.getSafe(-2).refresh
			tree.refreshNode(node.getSafe(-2))
		} else {
			tree.model = TreeModelAdapter(reflux, roots, model)
			tree.refreshAll					
		}
		
		Desktop.callLater(50ms) |->| {
			showNode(resourceUri)
		}
	}
	
	** Scrolls and expands the tree until the 'Resource' is visible.
	** This also selects the resource in the tree.
	Void showNode(Str resourceUri) {
		path := findNodePath(resourceUri)
		path.eachRange(0..-2) { tree.setExpanded(it, true) }
		tree.show(path.last)
		tree.select(path.last)
	}

	** Get and set the selected nodes.
	** 
	** Convenience for 'tree.selected()'
	Resource[] selected {
		get {
			((TreeNode[]) tree.selected).map { it.resource }
		}
		set {
			tree.selected = it.map { findNode(it.uri.toStr) }
		}
	}

	** Return the resource at the specified coordinate relative to this widget. 
	** Return 'null' if no resource at given coordinate.
	Resource? nodeAt(Point pos) {
		((TreeNode?) tree.nodeAt(pos))?.resource
	}
	
	private TreeNode findNode(Str resourceUri) {
		findNodePath(resourceUri).last
	}

	private TreeNode[] findNodePath(Str resourceUri) {
		nodePath	:= TreeNode[,]
		nodes		:= (TreeNode[]) tree.model.roots
		resPath		:= path(resourceUri)
		resPath.each |Str path| {
			node := nodes.find { it.resource.uri.toStr == path }
			if (node == null)
				throw ArgErr("Could not find node in tree: $path")
			nodePath.add(node)
			nodes = node.children
		}
		return nodePath
	}

	private Str[] path(Str? resourceUri) {
		path	:= Str[,]
		while (resourceUri != null) {
			path.add(resourceUri)
			resourceUri = reflux.resolve(resourceUri).parent
		}
		return path.reverse
	}
	
	private TreeModelAdapter treeModel() {
		tree.model
	}
}

** A model to customise the look of a 'ResourceTree'.
mixin ResourceTreeModel {

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

	** Returns the children (resource URIs) of the specified node.
	** If no children return an empty list.
	** 
	** Defaults to 'resource.children'.
	virtual Str[] children(Resource resource) { resource.children }
}

internal class ResourceTreeModelImpl : ResourceTreeModel { }

internal class TreeModelAdapter : TreeModel {
	override TreeNode[] roots
	ResourceTreeModel 	model
	Reflux				reflux
	
	new make(Reflux reflux, Resource[] roots, ResourceTreeModel model) {
		this.reflux	= reflux
		this.roots	= TreeNode.map(reflux, null, roots)
		this.model	= model
	}

	override Str	text		(Obj n) { model.text(res(n))	}
	override Image?	image		(Obj n) { model.image(res(n))	}
	override Font?	font		(Obj n) { model.font(res(n))	}
	override Color?	fg			(Obj n) { model.fg(res(n))		}
	override Color?	bg			(Obj n) { model.bg(res(n))		}
	override Bool	hasChildren	(Obj n) { node(n).hasChildren	}
	override Obj[]	children	(Obj n) { node(n).children		}
	
	Resource res(TreeNode n) { n.resource }
	TreeNode node(TreeNode n) { n }
}

internal class TreeNode {
	Reflux 		reflux
	TreeNode?	parent
	Resource	resource
	
	new make(Reflux reflux, TreeNode? parent, Resource resource) {
		this.reflux = reflux
		this.parent = parent
		this.resource = resource
	}
	
	Bool hasChildren() { !children.isEmpty }

	TreeNode[]? children {
		get {
			if (&children == null)
				&children = map(reflux, this, resource.children.map { resource.resolveChild(it) ?: reflux.resolve(it) })
			return &children
		}
	}

	Void refresh() {
		children = null
	}
	
//	override Str toStr() { return resource.toStr }

	static TreeNode[] map(Reflux reflux, TreeNode? parent, Resource[] resources) {
		resources.map { TreeNode(reflux, parent, it) }
	}
}
