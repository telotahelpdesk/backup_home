xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace schema = "http://schema.org/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $place := edwebRegister:getEntry('orte')
let $placeName := $place/tei:placeName[@type='reg']/text()

let $redirect := 
if (not($place))
then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, 'register/orte/index.xql'))))
else () 

let $noteAndNames :=
if ($place/tei:note//text() or edwebRegister:altNames($place)//li) then (
<div class="box whitebox">
    <div class="boxInner">
        {if ($place/tei:note//text()) then (<p>{$place/tei:note//text()}</p>) else ()}
        {if (edwebRegister:altNames($place)//li) then (edwebRegister:altNames($place)) else ()}
    </div>
</div>
) else () 


(: ########### HTML-Ausgabe ########### :)
let $header :=  
<transferContainer>
    <div id="subnavbar">
        {edwebRegister:sectionNav($place/tei:placeName[@type='reg']/text())}
    </div>
    <h1>{$placeName}</h1>
    <p>{$place/parent::gruppe/ort[@type='grname']/ortsname}</p>
</transferContainer>


let $content := 
<transferContainer>
    <div class="grid_11">
        {if ($noteAndNames//(p|li)) then ($noteAndNames) else ()}
        <div class="box whitebox">
            <div class="boxInner">
                {edwebRegister:getRelatedLetters($place),
                edwebRegister:events($edwebRegister:id),
                if (edwebRegister:printReferences($place, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($place, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
            </div>
        </div>
        {edwebRegister:indexHint('')}
    </div>
    <div class="grid_5">
        {if ($place//tei:idno/text()) then (
        <div class="box whitebox">{
            (: *** Bugfix #8313 *** :)
            (: initial code leads to error page when multiple place with idno exists (e. g. 'prov_vkl_ndl_js' in Orte.xml) :)
            (: edwebRegister:getGeoName($place//tei:idno/text()) :)
            edwebRegister:getGeoName(normalize-space($place/tei:idno))}</div>) else ()
        }
        {edwebRegister:viewBox(edwebRegister:getRelatedEntries($place), 'white', 'hints')}
    </div>
</transferContainer>

let $output := edweb:transformHTML($header, $content, 'register', edweb:pageTitle($place, 'first'))

return 
$output