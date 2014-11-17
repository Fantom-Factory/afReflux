
mixin LocaleFormat {
	
	virtual Str formatDateTime(DateTime? dateTime) {
		dateTime?.toLocale ?: ""
	}

	virtual Str formatFileSize(Int? bytes) {
		bytes?.toLocale("B") ?: ""		
	}
	
}

** The default implementation.
internal class LocaleFormatImpl : LocaleFormat { }