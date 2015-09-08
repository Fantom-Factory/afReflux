
@NoDoc @Js
@Serializable
class RefluxPrefs {
	Uri			homeUri			:= `file:/`
	Bool 		viewTabsOnTop	:= true
	Type:Obj	panelPrefAligns	:= Type:Obj[:]

	new make(|This|? f := null) {
		f?.call(this)
	}
}