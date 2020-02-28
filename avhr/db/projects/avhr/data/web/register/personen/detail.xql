xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";
import module namespace ediarumBeacon="http://www.bbaw.de/telota/ediarum/beacon" at "beacon/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace beacon = "http://purl.org/net/beacon";

declare option exist:serialize "method=html5 media-type=text/html";

declare function local:ifEmpty($date) {
    if ($date/normalize-space()='')
    then ('?')
    else ($date/text())
};

let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $p_normid := request:get-parameter("normid", ())

let $personid := 
            if ($p_normid)
            then (collection($edweb:dataRegister)//tei:person[matches(tei:idno, $p_normid)]/@xml:id/data(.))
            else ($p_id)
            
let $redirect := 
        if ($personid='')
        then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/register/personen/index.xql'))))
        else ()            

let $person := collection($edweb:dataRegister)//tei:person[@xml:id=concat($personid, '')]

let $description := 
    edwebRegister:viewBox((
    for $x in $person//tei:note
    return
    transform:transform($x, doc('../register.xsl'), <parameters><param name="baseURL" value="{$edweb:baseURL}" /></parameters>),
    if (edwebRegister:altNames($person)//li) then (edwebRegister:altNames($person)) else ()
    )) 

let $cubaMentionPerson :=
    <div>
    <h3>Erwähnungen im Kuba-Tagebuch</h3>
    <ul class="folioReferences">{
    let $last := count(doc($edweb:data||'/ART/cuba_tagebuch_v1.0.xml')//tei:persName[@key=$p_id and not(ancestor::tei:note[parent::tei:seg])])
    for $entry at $pos in doc($edweb:data||'/ART/cuba_tagebuch_v1.0.xml')//tei:persName[@key=$p_id and not(ancestor::tei:note[parent::tei:seg])]
    let $page := $entry/preceding::tei:pb[1]/@n/data(.)
    return
    if ($pos = $last)
    then (<li><a href="../../reisetagebuecher/detail.xql?id=avhr_vwc_lsf_1w&amp;view=k#{$page}">{$page}</a></li>) 
    else (<li><a href="../../reisetagebuecher/detail.xql?id=avhr_vwc_lsf_1w&amp;view=k#{$page}">{$page}</a>,&#160;</li>)}
    </ul></div>

(: ############ WEITEREFÜHRENDE LINKS ################## :)
let $beaconLinks :=
    <div class="box whitebox">
        <div class="boxInner hinweise">
            <h3>Links zu externen Websites</h3>
                {if ($person/tei:idno/text())
                then (ediarumBeacon:beaconLinks($person/tei:idno/text()))
                else ()
                }
        </div>
    </div>


(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($person/tei:persName[@type='reg'][1]/tei:surname/text())}
        </div>
        <h1>{edweb:persName($person/tei:persName[@type='reg'], 'forename')}</h1>
        <p>{if ($person/tei:floruit) then (concat('Wirkungszeit: ', $person/tei:floruit/text())) else concat(local:ifEmpty($person/tei:birth[1]), '–', local:ifEmpty($person/tei:death[1]))}</p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11">
            {if ($description) then ($description) else ()}
            {edwebRegister:viewBox((
             if ($cubaMentionPerson//li) then ($cubaMentionPerson) else (),
             (:if ($lettersWrittenBy//td) then ($lettersWrittenBy) else (),
             if ($lettersMentionPerson//td) then ($lettersMentionPerson) else (),
             if ($lettersCommentsMentionPerson//td) then ($lettersCommentsMentionPerson) else (),:)
             edwebRegister:getRelatedLetters($person),
             edwebRegister:events($personid),
             if (edwebRegister:printReferences($person, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($person, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()))}
            {edwebRegister:indexHint('')}
        </div>
        <div class="grid_5">
            {if ($beaconLinks//li) then ($beaconLinks) else ()}
        </div>
        {edwebRegister:prevNextEntries($person)}
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register', edweb:pageTitle($person, 'first'))

return 
$output