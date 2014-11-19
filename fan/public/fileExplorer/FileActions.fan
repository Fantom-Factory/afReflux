using gfx


class FileActions {
}

class FileAction {
	Str 	name
	Str		ext
	File	program
	new make(|This|in) { in(this) }
}

class FileLauncher {	
	Str 	name
	Image	icon
	File	program
	new make(|This|in) { in(this) }
}