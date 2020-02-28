xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $org := edwebRegister:getEntry('einrichtungen')
        
let $locations := 
    if ($org/tei:location)
    then (
        for $location in $org/tei:location
        let $settlement := <a href="../orte/detail.xql?id={$location//tei:settlement/@key}">{$location//tei:settlement/text()}</a>
        let $note := $location//tei:note/text()
        let $date := if ($location/@from/data(.) or $location/@to/data(.)) then (<h4>{$location/@from/data(.)||'&#x2013;'||$location/@to/data(.)}</h4>) else ()
        return
        <div class="location">
            {$date}
            <p>
                {if ($note) 
                then ($settlement||', '||$note)
                else ($settlement)}
            </p>
            {if ($location//tei:idno/text()) then (edwebRegister:getGeoName($location//tei:idno/text())) else ()}
            {(: Refs auf bestimmte Orte einer Einrichtung :) if (edwebRegister:printReferences($location/tei:address, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($location/tei:address, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
        </div>
    
    ) else ()
       
(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($org/tei:orgName[@type='reg']/text())}
        </div>
        <h1>{$org/tei:orgName[@type='reg']/text()}</h1>
        <p>{$org/tei:location[1]//tei:settlement/text()}</p>
    </transferContainer>
                

let $content := 
    <transferContainer>
                    <div class="grid_11">
                    <div class="box whitebox">
                        <div class="boxInner">
                            <p>{transform:transform($org/tei:desc, doc('../register.xsl'), ())}</p>
                            {$locations}
                            {edwebRegister:getRelatedLetters($org)}
                            {edwebRegister:events($edwebRegister:id)}
                            {if (edwebRegister:printReferences($org, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($org, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
                        </div>
                    </div> 
                    {edwebRegister:indexHint('')}
                    </div>
                    <div class="grid_5">
                        {edwebRegister:viewBox(edwebRegister:getRelatedEntries($org), 'white', 'hints')}
                    </div>
                    {edwebRegister:prevNextEntries($org)}
     </transferContainer>



return 
edweb:transformHTML($header, $content, 'register', edweb:pageTitle($org, 'first'))
