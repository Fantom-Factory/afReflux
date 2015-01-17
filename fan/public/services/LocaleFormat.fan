
mixin LocaleFormat {
	
	virtual Str formatDateTime(DateTime? dateTime) {
		dateTime?.toLocale ?: ""
	}

	virtual Str formatDate(Date? date) {
		date?.toLocale ?: ""
	}

	virtual Str formatTime(Time? time) {
		time?.toLocale ?: ""
	}

	virtual Str formatFileSize(Int? bytes) {
		bytes?.toLocale("B") ?: ""		
	}
	
}

** The default implementation.
internal class LocaleFormatImpl : LocaleFormat { }
