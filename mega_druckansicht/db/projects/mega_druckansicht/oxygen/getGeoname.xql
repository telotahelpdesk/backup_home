xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $place := request:get-parameter('place', ())
let $continentCode := request:get-parameter('continentCode', ())
let $featureClass := request:get-parameter('featureClass', ())
let $fuzzy := request:get-parameter('fuzzy', ())

let $paramPlace := replace($place, '_', ' ')

let $paramFeatureClass :=
    if ($featureClass!='ALL')
    then (concat('&amp;featureClass=', $featureClass))
    else ()
let $paramContinentCode :=
    if ($continentCode!='ALL')
    then (concat('&amp;continentCode=', $continentCode))
    else ()
let $paramFuzzy :=
    if ($fuzzy!='')
    then ('&amp;fuzzy=0.8')
    else ()

let $queryURL := concat('http://api.geonames.org/search?', 'name=', $paramPlace, $paramFeatureClass, $paramContinentCode, $paramFuzzy, '&amp;style=FULL&amp;username=dumont')

let $featureClassNames :=
    map {
        "P" := "Stadt, Dorf",
        "A" := "Land, Region",
        "H" := "Fluss, See",
        "T" := "Berg, Hügel",
        "V" := "Wald",
        "L" := "Parks",
        "S" := "Gebäude"
    }
    
let $list :=
    element ul {
        (: element li { element span { $place } }, :)
        for $geoname in doc($queryURL)//geoname
        let $name := $geoname//name
        let $geonameId := concat('http://www.geonames.org/', $geoname//geonameId)
        let $countryName := $geoname//countryName
        let $adminName1 := 
            if ($geoname//adminName1/text())
            then (concat(', ', $geoname//adminName1))
            else ()
        let $adminName2 := 
            if ($geoname//adminName2/text())
            then (concat(', ', $geoname//adminName2))
            else ()
        let $fcl :=
            if ($featureClass='ALL')
            then (concat(' [', $featureClassNames($geoname//fcl), ']'))
            else ()
        return
        element li {
            attribute id { $geonameId },
            element span { concat($name, ' (', $countryName, $adminName1, $adminName2, $fcl, ')') }
        }        
    }
    
return
if ($list//li)
then ($list)
else (<ul><li><span>Keine Treffer</span></li></ul>)