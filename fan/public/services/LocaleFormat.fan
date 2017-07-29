
** (Service) - 
** Subclass to customise how dates and numbers are displayed in Reflux.
** 
** Override the default implementation with your own. In your 'AppModule':
**
**   syntax: fantom
**   static Void defineServices(ServiceDefinitions defs) {
**       defs.overrideByType(LocaleFormat#).withImpl(MyLocaleFormatImpl#)
**   }
** 
@Js
mixin LocaleFormat {
	
	** Defaults to 'DateTime.tolocale()'.
	virtual Str dateTime(DateTime? dateTime) {
		dateTime?.toLocale ?: ""
	}

	** Defaults to 'Date.tolocale()'.
	virtual Str date(Date? date) {
		date?.toLocale ?: ""
	}

	** Defaults to 'Time.tolocale()'.
	virtual Str time(Time? time) {
		time?.toLocale ?: ""
	}

	** Defaults to 'Int.tolocale("B")'.
	virtual Str fileSize(Int? bytes) {
		bytes?.toLocale("B") ?: ""
	}
}

** The default implementation of 'LocaleFormat'.
@Js @NoDoc
internal class LocaleFormatImpl : LocaleFormat { }
