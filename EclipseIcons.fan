using afSizzle
using afButter
using concurrent
using afBounce
using afHtmlParser

class EclipseIcons {
	
	static Void main() {
		butt := Butter.churnOut
		res  := butt.get(`http://eclipse-icons.i24.cc/`)
		
		html := res.asStr
		tabs := html.indexr("<table")
		tabe := html.index("</table>")
		xml := HtmlParser().parseDoc(html[tabs..<tabe+8])
		
		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc(xml)
		
		no:=0
		Element("td.thumbs img").list.each |img| {
			src := `http://eclipse-icons.i24.cc/` + img["src"].toUri
			
			out := File.os("C:\\Temp\\icons-eclipse2").plus(img["src"].toUri).out
			butt.get(src).asInStream.pipe(out)
			out.close

			no++
			echo(src)
		}
		
		echo(no)
		
		// download 1247 files to 815 images = 432 dups
	}
}
