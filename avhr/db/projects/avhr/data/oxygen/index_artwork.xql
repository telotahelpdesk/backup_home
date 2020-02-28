xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../web/resources/functions.xql";
import module namespace edoxy="http://www.bbaw.de/telota/ediarum/oxygen" at "lib.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

let $login := edweb:login() 

let $list :=
element ul {
for $x in collection('/db/projects/hirt/data/Register')//telota:artwork
order by $x/tei:title/text()
return 
element li { 
    attribute id { $x/@xml:id/data(.) },
    element span { $x/tei:title/normalize-space(.) } }
}

return 
$list