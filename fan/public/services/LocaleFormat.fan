
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
		formatDateTime(dateTime)
	}

	** Defaults to 'Date.tolocale()'.
	virtual Str date(Date? date) {
		formatDate(date)
	}

	** Defaults to 'Time.tolocale()'.
	virtual Str time(Time? time) {
		formatTime(time)
	}

	** Defaults to 'Int.tolocale("B")'.
	virtual Str fileSize(Int? bytes) {
		formatFileSize(bytes)		
	}

	@NoDoc @Deprecated { msg="Use dateTime() instead" }
	virtual Str formatDateTime(DateTime? dateTime) {
		dateTime?.toLocale ?: ""
	}

	@NoDoc @Deprecated { msg="Use date() instead" }
	virtual Str formatDate(Date? date) {
		date?.toLocale ?: ""
	}

	@NoDoc @Deprecated { msg="Use time() instead" }
	virtual Str formatTime(Time? time) {
		time?.toLocale ?: ""
	}

	@NoDoc @Deprecated { msg="Use fileSize() instead" }
	virtual Str formatFileSize(Int? bytes) {
		bytes?.toLocale("B") ?: ""		
	}
	
}

** The default implementation.
@Js
internal class LocaleFormatImpl : LocaleFormat { }
