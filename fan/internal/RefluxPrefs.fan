
@NoDoc @Serializable
class RefluxPrefs {
	Bool 		viewTabsOnTop	:=	true
	Type:Obj	panelPrefAligns	:= Type:Obj[:]

	new make(|This|? f := null) {
		f?.call(this)
	}
}