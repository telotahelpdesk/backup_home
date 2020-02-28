xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";

(:let $briefdaten := collection('/db/schleiermacher/briefe')//tei:TEI[.//tei:creation/tei:date[@when] and .//tei:creation/tei:persName[@key='p2405']]
let $tageskalenderdaten := collection('/db/schleiermacher/tageskalender')//tei:TEI[.//tei:p//tei:date[@when]]


let $events := for $item in $briefdaten
               return
               <event
                    start="{$item//tei:creation/tei:date[1]/@when}"
                    title="{$item//tei:titleStmt/tei:title/text()}"
                    link="einzelbrief.xql?id={$item/@xml:id}" 
                    icon="">
                    {$item//tei:text//tei:p[1]/substring(., 1, 100)} [...]
               </event>
               
let $events2 := for $item in $tageskalenderdaten//tei:p[.//tei:date[@when]]
                order by $item//tei:date/@when
                return
                <event
                    start="{$item//tei:date/@when}"
                    title="{$item//tei:date}"
                    >
                    {$item/text()}
                </event>
                    
return
<data 
    date-time-format="iso8601">
    {$events}
</data>:)