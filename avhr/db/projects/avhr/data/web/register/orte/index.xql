xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace beacon = "http://purl.org/net/beacon";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $listPlaces := <ul>{
    for $ort in collection($edweb:dataRegister)//tei:placeName[starts-with(edwebRegister:orderLabel(.), $edwebRegister:section)]
    order by edwebRegister:orderLabel($ort)
    return
    <li><a href="detail.xql?id={$ort/ancestor::tei:place[1]/@xml:id}">
        {if ($ort[@type='alt']) then (concat($ort, ' &#x2192; ', $ort/ancestor::tei:place[1]/tei:placeName[@type='reg']/text())) else ($ort)}
        </a></li>}
    </ul>
    
    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  <transferContainer>
                    <div id="subnavbar">
                        {edwebRegister:sectionNav('index')}
                    </div>
                    <h1>Ortsregister - {$edwebRegister:section}</h1>
                    <p>{count($listPlaces/li)} Einträge</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_11 box whitebox">
                                    <div class="boxInner">
                                        {$listPlaces}
                                    </div>
                                </div>
                                <div class="grid_5">
                                    {edwebRegister:indexHint('')}
                                </div>
                 </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register', edweb:pageTitle('Ortsregister -'||$edwebRegister:section, 'first'))

return
$output


