using afIoc
using gfx
using fwt

@NoDoc
class FoldersPanel : Panel, RefluxEvents {
	
	@Inject		private Registry			registry
	@Inject		private Reflux				reflux
	@Inject		private RefluxIcons			icons
	@Inject		private UriResolvers		uriResolvers
	@Inject		private FileExplorer		fileExplorer
	@Autobuild	private FoldersTreeModel	model
	
	override Obj	prefAlign	:= Halign.left
	
	private Combo combo	:= Combo() { it.onModify.add |e| { this->onModify(e) } }
	private Str:Uri shortcuts
	private Int lastComboIndex
	
	private Tree tree
		
	protected new make(|This| in) : super(in) {
		
		tree = Tree {
			it.model = this.model
			it.border = false
			it.onSelect.add |e| { this->onSelect(e) }
			it.onPopup.add	|e| { this->onPopup(e) }
		}
		
		content = EdgePane {
			top = InsetPane(2, 0, 2, 2) { it.add(combo) }
			center = BorderPane {
				it.content	= tree
				it.border	= Border("1, 1, 0, 0 $Desktop.sysNormShadow")
			}
		}
		
		shortcuts = fileExplorer.options.shortcuts		
		combo.items = shortcuts.keys
	}

	internal Void onModify(Event event)	{
		if (isActive && combo.selectedIndex >= 0) {
			// this event fires when we switch tabs - then errs when we're not attached! Grr...
			if (lastComboIndex != combo.selectedIndex) {
				lastComboIndex  = combo.selectedIndex				
				reflux.load(shortcuts[combo.selected])
			}
		}
	}

	internal Void onSelect(Event event) {
		file := ((FileNode) event.data).file		
		reflux.load(file.normalize.uri)
	}

	internal Void onPopup(Event event) {
		if (event.data == null) return
		file := ((FileNode) event.data).file
		res	 := uriResolvers.resolve(file.normalize.uri)
		event.popup = res.populatePopup(Menu())
	}

	override Void onLoad(Resource resource) {
		// FIXME: don't want to specify this line in every panel!
		if (!isShowing || !isActive) return
		
		if (resource isnot FileResource || !resource.uri.isAbs) return
		fileResource := (FileResource) resource

		showFile(fileResource.uri)
	}

	override Void onRefresh(Resource resource)	{
		// FIXME: don't want to specify this line in every panel!
		if (!isShowing || !isActive) return
		if (resource isnot FileResource || !resource.uri.isAbs) return
		fileResource := (FileResource) resource

		tree.model = model = registry.autobuild(FoldersTreeModel#)
		tree.refreshAll
		Desktop.callLater(50ms) |->| {
			showFile(fileResource.uri)
		}
	}
	
	private Void showFile(Uri uri) {
		// it may be ugly, but if it aint broke - don't fix it!
		file	:= (FileNode?) null
		files	:= model.roots
		path	:= uri.path
		path.eachWhile |Str s, Int i->Obj?| {
			found := files.eachWhile |FileNode f->Obj?| {
				if (f.name == s) {
					file = f
					files = model.children(f)
					if (i+1 < path.size) {
						tree.setExpanded(f, true)
					}
					return true
				}
				return null
			}
			return found == true ? null : false
		}
		
		if (file != null) {
			tree.select(file)
			tree.show(file)
		}		
	}
}

internal class FoldersTreeModel : TreeModel {
	@Inject	private  FileResolver	fileResolver
	@Inject	private  FileExplorer	fileExplorer
			override FileNode[]		roots
			private	 Color			hiddenColour

	new make(|This|in) {
		in(this)
		this.roots = FileNode.map(fileExplorer, File.osRoots.map { it.normalize })
		this.hiddenColour = Desktop.sysListFg.lighter(0.5f)
	}
	override Str	text(Obj node)			{ n(node).name		}
	override Image?	image(Obj node)			{ fileResolver.fileToIcon(n(node).file) }
	override Bool 	hasChildren(Obj node)	{ n(node).hasChildren	}
	override FileNode[]	children(Obj node)	{ n(node).children	}
	override Color? fg(Obj node)			{ fileExplorer.options.isHidden(n(node).file) ? hiddenColour : null  }
	private  FileNode n(FileNode node)		{ node }
}

internal class FileNode {
	FileExplorer fe
	File file
	new make(FileExplorer fe, File file) { this.fe = fe; this.file = file }
	Str name() { file.name }
	Bool hasChildren() { !children.isEmpty }
	FileNode[]? children {
		get {
			if (&children == null)
				&children = map(fe, file.listDirs.sort |f1, f2->Int| { f1.name <=> f2.name }. exclude { fe.options.shouldHide(it) })
			return &children
		}
	}
	Void refresh() {
		children = null
	}
	override Str toStr() { return file.toStr }
	static FileNode[] map(FileExplorer fe, File[] files) {
		files.map { FileNode(fe, it) }
	}
}
