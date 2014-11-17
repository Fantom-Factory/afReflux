
mixin LocaleFormat {
	
	virtual Str formatDateTime(DateTime? dateTime) {
		dateTime?.toLocale ?: ""
	}

	virtual Str formatFileSize(Int? bytes) {
		bytes?.toLocale("B") ?: ""		
	}
	
}

class LocaleFormatImpl : LocaleFormat {
	
	override Str formatDateTime(DateTime? dateTime) {
		dateTime?.toLocale("DD MMM YYYY hh:mm") ?: ""
	}

	private static const Float KB := 1024f
	private static const Float MB := 1024f * 1024f
	private static const Float GB := 1024f * 1024f * 1024f

	override Str formatFileSize(Int? bytes) {
		b := bytes?.toFloat
		if (b == null)	return ""
	    if (b < KB)		return bytes.toStr + " b"
	    if (b < 10*KB)	return b.div(KB).toLocale("#.#") + " Kb"
	    if (b < MB)		return b.div(KB).round.toLocale("#.#") + " Kb"
	    if (b < 10*MB)	return b.div(MB).toLocale("#.#") + " Mb"
	    if (b < GB)		return b.div(MB).round.toLocale("#.#") + " Mb"
	    if (b < 10*GB)	return b.div(GB).toLocale("#.#") + " Gb"
	    				return b.div(GB).round.toLocale("#,###.#") + " Gb"
	}
}