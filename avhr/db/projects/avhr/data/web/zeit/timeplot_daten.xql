xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=text media-type=text/plain";

let $login := edweb:login()

let $briefdaten := collection($edweb:dataLetters)/tei:TEI[.//tei:creation/tei:date[@when]]

let $events := <kwberechnung> 
                {for $item in $briefdaten
                order by $item//tei:creation/tei:date[1]/@when
                return
                <briefdatum>{$item//tei:creation/tei:date[1]/@when/data(.)}</briefdatum>
                }
                </kwberechnung>

let $inhalt := <root>{transform:transform($events, doc('datum.xsl'), ())}</root>

let $inhalt2 := <root>{transform:transform($inhalt, doc('datum.xsl'), ())}</root>

let $inhalt3 := for $item in $inhalt2/group
                order by $item/kw
                return
                <li><kw>{$item/kw/text()}</kw>, <briefe>{count($item/daten)}</briefe>&#10;</li>
               
return
<ul>
{$inhalt3}
</ul>
