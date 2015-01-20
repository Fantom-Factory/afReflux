
** (Service) - 
** Subclass to customise how dates and numbers are displayed in Reflux.
** 
** Override the default implementation with your own. In your 'AppModule':
**
**   static Void defineServices(ServiceDefinitions defs) {
**       defs.overrideByType(LocaleFormat#).withImpl(MyLocaleFormatImpl#)
**   }
** 
mixin LocaleFormat {
	
	** Defaults to 'DateTime.tolocale()'.
	virtual Str formatDateTime(DateTime? dateTime) {
		dateTime?.toLocale ?: ""
	}

	** Defaults to 'Date.tolocale()'.
	virtual Str formatDate(Date? date) {
		date?.toLocale ?: ""
	}

	** Defaults to 'Time.tolocale()'.
	virtual Str formatTime(Time? time) {
		time?.toLocale ?: ""
	}

	** Defaults to 'Int.tolocale("B")'.
	virtual Str formatFileSize(Int? bytes) {
		bytes?.toLocale("B") ?: ""		
	}
	
}

** The default implementation.
internal class LocaleFormatImpl : LocaleFormat { }
