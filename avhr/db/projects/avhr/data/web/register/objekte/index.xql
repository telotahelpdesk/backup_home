xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html5 media-type=text/html";

let $login :=edweb:login()

let $werkliste := <ul>{
    for $werk in collection($edweb:dataRegister)//telota:artwork[starts-with(edwebRegister:orderLabel(./tei:title), $edwebRegister:section)]
    order by edwebRegister:orderLabel($werk/tei:title)
    return
    <li><a href="detail.xql?id={$werk/@xml:id}">
        {$werk//tei:title/normalize-space(.)}
        </a></li>}
    </ul>
    
    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav('index')}
        </div>
        <h1>Objektregister - {$edwebRegister:section}</h1>
        <p>{count($werkliste/li)} Objekte</p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11 box whitebox">
                        <div class="boxInner">
                            {$werkliste}
                        </div>
                    </div>
                    <div class="grid_5">
                    </div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register', 'Register der Artefakte')

return
$output


