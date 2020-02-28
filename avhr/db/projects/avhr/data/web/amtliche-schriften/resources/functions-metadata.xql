xquery version '3.0';

module namespace edwebCorresp="http://www.bbaw.de/telota/ediarum/web/corresp";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function edwebCorresp:viewFragment($fragments, $head) {
    typeswitch($fragments)
        case element(tei:person) 
            return
           (element h3 { $head },
            element ul {
                for $x in $fragments
                return
                element li { edwebCorresp:viewIndexLink($x) }
            })
        case element(tei:org)  
            return
           (element h3 { $head },
            element ul {
                for $x in $fragments
                return
                element li { edwebCorresp:viewIndexLink($x) }
            })
         case element(tei:place)
            return
           (element h3 { $head },
            element div {
                for $x in $fragments
                return
                element p { edwebCorresp:viewIndexLink($x) }
            })
         case element(tei:date)
            return
           (element h3 { $head },
            element div {
                element p { 
                if ($fragments/@when)
                then format-date($fragments/@when, '[D01].[M01].[Y0001]')
                else if ($fragments/@from)
                then format-date($fragments/@from, '[D01].[M01].[Y0001]')||'-'||format-date($fragments/@to, '[D01].[M01].[Y0001]')
                else if ($fragments/@notBefore)
                then 'ca. '||format-date($fragments/@notBefore, '[D01].[M01].[Y0001]')||' bis ca. '||format-date($fragments/@notAfter, '[D01].[M01].[Y0001]')
                else ()
                }
            })
           case element(tei:note)
            return 
(: *** Feature enhancement for Ticket #11377  *** :)
(: *** Bugfix #11377 (HTTP Error 500 bei Regestbriefen) *** :)
 if (normalize-space(string-join($fragments, ''))) 
 then (element h3 { $head },
    element div {
        for $x in $fragments
(: *** Bugfix #11377 (HTTP Error 500 bei Regestbriefen) *** :)
(:  element p { local:viewMarkup($x) }:)
        return element p { normalize-space($x) }
           })
else()
        default return ()
};

declare function edwebCorresp:viewIndexLink($entry) {
    typeswitch($entry)
        case element(tei:person)
            return 
            element a { 
                attribute href { $edweb:baseURL||'/register/personen/detail.xql?id='||$entry/@xml:id },
                edweb:persName($entry/tei:persName[@type='reg'], 'surname') 
            }    
        case element(tei:place)
            return 
            element a { 
                attribute href { $edweb:baseURL||'/register/orte/detail.xql?id='||$entry/@xml:id },
                $entry/tei:placeName[@type='reg'] 
            }
        default 
            return ()            
};

declare function edwebCorresp:meta($letter) {
    let $sender :=
        for $x in $letter//tei:correspAction[@type='sent']/tei:persName
        let $person := collection($edweb:dataRegister)//tei:person[@xml:id=$x/@key]
        return
        $person
    let $receiver :=
        for $x in $letter//tei:correspAction[@type='received']/tei:persName
        let $person := collection($edweb:dataRegister)//tei:person[@xml:id=$x/@key]
        return
        $person
    let $date :=  
            $letter//tei:correspAction[@type='sent']/tei:date
    let $placeSent :=
        for $x in $letter//tei:correspAction[@type='sent']/tei:placeName
        let $place := collection($edweb:dataRegister)//tei:place[@xml:id=$x/@key]
        return
        $place
    let $placeReceived :=
        for $x in $letter//tei:correspAction[@type='received']/tei:placeName
        let $place := collection($edweb:dataRegister)//tei:place[@xml:id=$x/@key]
        return
        $place
    let $note := $letter//tei:correspDesc/tei:note 
(:    let $physDesc := :)
(:        $letter//tei:physDesc :)
(:    let $witnesses :=:)
(:        for $x at $pos in $letter//tei:witness:)
(:        let $counter := count($letter//tei:witness):)
(:        return:)
(:        if ($counter > 1):)
(:        then 'D'||$pos||': '||$x:)
(:        else 'D: '||$x:)
    return
    <div id="meta">
        <div class="visible">
            <h2>
                <span></span> Weitere Angaben zum Brief</h2>
        </div>
        <div class="invisible">
            {edwebCorresp:viewFragment($sender, 'Absender'),
             edwebCorresp:viewFragment($date, 'Datum'),
             edwebCorresp:viewFragment($placeSent, 'Schreibort'),
             edwebCorresp:viewFragment($receiver, 'Empfänger'),
             edwebCorresp:viewFragment($placeReceived, 'Empfangsort'),
             edwebCorresp:viewFragment($note, 'Anmerkung zum Brief')
             }
        </div>
    </div>
};

(: *** Buggy function *** :)
declare function local:viewMarkup($node) {
    typeswitch($node)
        case text() 
            return $node
        case element() return 
            element {node-name($node)} {
                $node/@*, 
                local:viewMarkup($node/node())
            } 
(:  Causes error when $node is an empty sequence  :)
        default 
            return local:viewMarkup($node/node())
    
};