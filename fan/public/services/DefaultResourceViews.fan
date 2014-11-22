using afBeanUtils

const class DefaultResourceViews {
	
	private const TypeLookup viewLookup
	
	internal new make(Type:Type mappings) {
		viewLookup = TypeLookup(mappings)
	}
	
	@Operator
	Type? getView(Type resourceType) {
		viewLookup.findParent(resourceType, false)
	}
}
