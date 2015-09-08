using gfx
using fwt

** (Widget) - A table widget that displays 'Resources'. 'ResourceTable' is a wrapper around the FWT 
** [Table]`fwt::Table` widget with the following enhancements:
** 
**  - A 'Resource' specific table model. 
**  - Event data return the 'Resource' that's been actioned.
**  
** Because 'ResourceTable' does not extend 'fwt:Widget' it can not be added directly. 
** Instead, add the 'table' field which returns the wrapped FWT Table instance.
** 
**   syntax: fantom
** 
**   table := ResourceTable(reflux)
**   ContentPane() {
**       it.content = table.table
**   }
@Js
class ResourceTable {
	private Reflux reflux
	
	** The underlying FWT Table widget.
	Table table

	** The model that customises the look of the table. Leave as is for default behaviour.
	** 
	** You should call 'refreshAll' after setting a new model.
	ResourceTableModel model := ResourceTableModelImpl() {
		set {
			table.model = TableModelAdapter(reflux, roots, it)
			&model = it			
		}
	}
	
	** The root resources of the table.
	** 
	** You should call 'refreshAll' after setting new roots.
	Resource[] roots := Resource#.emptyList {
		set {
			table.model = TableModelAdapter(reflux, it, model)
			&roots = it
		}
	}

	** Creates a 'ResourceTable'. Use the ctor to pass in a table:
	**   syntax: fantom
	**   ResourceTable(reflux) {
	**       it.table = Table {
	**           it.border = false
	**       }
	**       it.roots = myRoots
	**       it.model = MyModel()
	**   }
	** 
	** Note that, as shown above, the 'table' must be set before the model and / or roots. 
	new make(Reflux reflux, |This|? in := null) {
		this.reflux = reflux
		table = Table()
		in(this)
		table.onAction.add |Event e| {
			e.data = e.index != null ? roots[e.index] : null
			onAction.fire(e)
			e.data = null
		}

		table.onSelect.add |Event e| {
			e.data = e.index != null ? roots[e.index] : null
			onSelect.fire(e)
			e.data = null
		}

		table.onPopup.add |Event e| {
			e.data = e.index != null ? roots[e.index] : null
			onPopup.fire(e)
			e.data = null
		}
	}

	** Callback when a row is double clicked or Return/Enter key is pressed.
	**
	** Event id fired:
	**	 - 'EventId.modified'
	**
	** Event fields:
	**	 - 'Event.data': the 'Resource' actioned
	once EventListeners onAction() { EventListeners() }

	** Callback when the selected row changes.
	**
	** Event id fired:
	**	 - 'EventId.select'
	**
	** Event fields:
	**	 - 'Event.data': the 'Resource' selected, or 'null' if nothing is selected.
	once EventListeners onSelect() { EventListeners() }

	** Callback when user invokes a right click popup action. 
	** If the callback wishes to display a popup, then set the 'Event.popup' field with menu to open.
	** If multiple callbacks are installed, the first one to return a nonnull popup consumes the event.
	**
	** To show a menu created from the 'Resource', add the following:
	** 
	**   table.onPopup.add |Event event| {
	**       event.popup = (event.data as Resource)?.populatePopup(Menu())
	**   }
	** 
	** Event id fired:
	**	 - 'EventId.popup'
	**
	** Event fields:
	**	 - 'Event.data': the 'Resource' selected, or 'null' if this is a background popup.
	**	 - 'Event.pos': the mouse position of the popup.
	once EventListeners onPopup() { EventListeners() }

	** Update the entire table's contents from the model.
	Void refreshAll() {
		table.refreshAll		
	}
	
	** Updates the specified resources in the tables
	Void refreshResources(Resource[] resources) {
		indices := resources.map { roots.index(it) }
		table.refreshRows(indices)
	}

	** Updates the specified resource in the model before showing it.
	Void refreshResourceUris(Uri[] resourceUris) {
		indices := resourceUris.map |uri->Int| { roots.findIndex { it.uri == uri } }
		table.refreshRows(indices)
	}

	** Get and set the selected nodes.
	** 
	** Convenience for 'table.selected()'
	Resource[] selected {
		get {
			table.selected.map { roots[it] }
		}
		set {
			table.selected = it.map { roots.index(it) }
		}
	}

	** Return the 'Resource' at the specified coordinate relative to this widget. 
	** Return 'null' if there is no 'Resource' at given coordinate.
	Resource? resourceAt(Point pos) {
		roots[table.rowAt(pos)]
	}
	
//	** Return if the given column is visible.  All columns are
//	** visible by default and can be toggled via `setColVisible`.
//	Bool isColVisible(Int col) { view.isColVisible(col) }
//
//	** Show or hide the given column.  Changing visibility of columns
//	** does not modify the indexing of TableModel, it only changes how
//	** the model is viewed.  See `isColVisible`.  This method does not
//	** automatically refresh table, call `refreshAll` when complete.
//	Void setColVisible(Int col, Bool visible) { view.setColVisible(col, visible) }
//
//	** The column index by which the table is currently sorted, or null
//	** if the table is not currently sorted by a column.  See `sort`.
//	Int? sortCol() { view.sortCol }
//
//	** Return if the table is currently sorting up or down.  See `sort`.
//	SortMode sortMode() { view.sortMode }
//
//	** Sort a table by the given column index. If col is null, then
//	** the table is ordered by its natural order of the table model.
//	** Sort order is determined by `TableModel.sortCompare`.  Sorting
//	** does not modify the indexing of TableModel, it only changes how
//	** the model is viewed.  Also see `sortCol` and `sortMode`.  This
//	** method automatically refreshes the table.
//	Void sort(Int? col, SortMode mode := SortMode.up)
	
	private TableModelAdapter tableModel() {
		table.model
	}
}

** A model to customise the look of a 'ResourceTable'.
@Js
mixin ResourceTableModel {

	** Get number of columns in table.  Default returns 1.
	virtual Int numCols() { 1 }
	
	** Get the header text for specified column.
	virtual Str header(Int col) { "Header $col" }
	
	** Get the horizontal alignment for specified column.
	** Default is left.
	virtual Halign halign(Int col) { Halign.left }
	
	** Return the preferred width in pixels for this column.
	** Return null (the default) to use the Tables default
	** width.
	virtual Int? prefWidth(Int col) { null }
	
	** Get the text to display for the specified cell.
	virtual Str text(Resource resource, Int col) { "${resource.name}:${col}" }
	
	** Get the image to display for specified cell or null.
	** Defaults to 'resource.icon' for the first column.
	virtual Image? image(Resource resource, Int col) { col == 0 ? resource.icon : null }
	
	** Get the font used to render the text for this cell.
	** If null, use the default system font.
	virtual Font? font(Resource resource, Int col) { null }
	
	** Get the foreground color for this cell. If null, use
	** the default foreground color.
	virtual Color? fg(Resource resource, Int col) { null }
	
	** Get the background color for this cell. If null, use
	** the default background color.
	virtual Color? bg(Resource resource, Int col) { null }
	
	** Compare two cells when sorting the given col.  Return -1,
	** 0, or 1 according to the same semanatics as `sys::Obj.compare`.
	** Default behavior sorts `text` using `sys::Str.localeCompare`.
	** See `fwt::Table.sort`.
	virtual Int sortCompare(Resource resource1, Resource resource2, Int col) {
		text(resource1, col).localeCompare(text(resource2, col))
	}
}

@Js
internal class ResourceTableModelImpl : ResourceTableModel { }

@Js
internal class TableModelAdapter : TableModel {
	Resource[]			roots
	ResourceTableModel 	model
	Reflux				reflux
	
	new make(Reflux reflux, Resource[] roots, ResourceTableModel model) {
		this.reflux	= reflux
		this.roots	= roots
		this.model	= model
	}

	override Int	numRows()				{ roots.size					}
	override Int	numCols()				{ model.numCols					}
	override Str	header(Int col)			{ model.header(col)				}
	override Halign	halign(Int col)			{ model.halign(col)				}
	override Int?	prefWidth(Int col)		{ model.prefWidth(col)			}
	override Str 	text(Int col, Int row)	{ model.text(res(row), col)		}
	override Image?	image(Int col, Int row)	{ model.image(res(row), col)	}
	override Font?	font(Int col, Int row)	{ model.font(res(row), col)		}
	override Color?	fg(Int col, Int row)	{ model.fg(res(row), col)		}
	override Color?	bg(Int col, Int row)	{ model.bg(res(row), col)		}
	override Int	sortCompare(Int col, Int row1, Int row2) {
		model.sortCompare(res(row1), res(row2), col)
	}
	
	Resource res(Int row) { roots[row] }
}
