
@NoDoc @Serializable
class RefluxPrefs {
//	Uri			homeUri			:= `file:/`	// FIXME: kill me
	Uri			homeUri			:= `file:/C:/Projects/Fantom-Factory/Reflux/doc/`
	Bool 		viewTabsOnTop	:= true
	Type:Obj	panelPrefAligns	:= Type:Obj[:]

	new make(|This|? f := null) {
		f?.call(this)
	}
}