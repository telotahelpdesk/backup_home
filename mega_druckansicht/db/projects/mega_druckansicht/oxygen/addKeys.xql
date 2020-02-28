xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $login := xmldb:login('/db/', 'admin', 'p14o02')

let $collection := '/db/projects/mega/data/'

return
for $placeName in collection($collection||'/Briefe')//tei:correspAction/tei:placeName[not(@key) and ./text()!='']
let $name := '^'||normalize-space($placeName/text())||'$'
let $key := doc($collection||'/Register/Orte.xml')//tei:place[matches(tei:placeName, $name)]/@xml:id/data(.)
return
(:element li { $placeName/text()||' - '||$key }:)
update insert attribute key { $key } into $placeName