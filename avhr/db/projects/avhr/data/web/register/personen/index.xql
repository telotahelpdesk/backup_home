xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $listPersons := <ul>{
    for $persName in collection($edweb:dataRegister)//tei:person/tei:persName[starts-with(edwebRegister:orderLabel(.), $edwebRegister:section)]
    let $surname :=
        if ($persName/tei:surname)
        then (normalize-space(string-join($persName/tei:surname/text())))
        else (normalize-space(string-join($persName/tei:name/text())))
     let $regName := 
        if ($persName[@type='alt']) 
        then (
            if ($persName/ancestor::tei:person/tei:persName[@type='reg']/tei:surname)
            then ($persName/ancestor::tei:person/tei:persName[@type='reg']/tei:surname, edweb:seperator($persName/ancestor::tei:person/tei:persName[@type='reg']/tei:forename,  ','))
            else ($persName/ancestor::tei:person/tei:persName[@type='reg']/tei:name)
        ) else ()
    let $forename := normalize-space(string-join($persName/tei:forename/text()))
    order by edwebRegister:orderLabel($surname)
    return  
    <li><a href="detail.xql?id={$persName/ancestor::tei:person/@xml:id}">
        { if ($regName) then concat($surname, ' &#x2192; ', string-join($regName)) else (concat($surname, edweb:seperator($forename, ',')))}</a></li>
    } </ul>
    
    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  <transferContainer>
                    <div id="subnavbar">
                        {edwebRegister:sectionNav('index')}
                    </div>
                    <h1>Personenregister - {$edwebRegister:section}</h1>
                    <p>{count($listPersons/li)} Personen</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_11 box whitebox">
                                    <div class="boxInner">
                                        {$listPersons}
                                    </div>
                                </div>
                                <div class="grid_5">
                                   {edwebRegister:indexHint('')}
                                </div>
                 </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register', edweb:pageTitle(('Personenregister - '||$edwebRegister:section), 'first'))

return
$output


