xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebCorresp="http://www.bbaw.de/telota/ediarum/web/corresp" at "resources/functions-metadata.xql";
import module namespace edwebMeta="http://www.bbaw.de/telota/ediarum/web/metadata" at "../resources/functions-metadata.xql";
import module namespace csLink="http://correspSearch.bbaw.de/link" at "resources/csapi/functions.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html media-type=text/html";

declare function local:linkToSibling($type as xs:string, $view as xs:string, $id) {
    if ($id)
    then (
        <li>
            <a class="{$type}" href="{ concat('detail.xql?id=', $id, '&amp;view=', $view) }">
                <span> {
                    if ($type='prev') then ('Vorheriger Brief')
                    else if ($type='next') then ('Nächster Brief')
                    else ()}
                </span>
            </a>
        </li>
    ) else ()
};

let $login := edweb:login()

(: Parameter aus URL übernehmen :)
let $p_id := request:get-parameter("id", ())
let $p_year := request:get-parameter("jahr", ())
let $p_searchTerms := request:get-parameter("searchTerms", ())

(: Pfad das aktuellen Briefs :)
let $letter := 
        if ($p_searchTerms)
        then 
            (if (collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)])
            then (kwic:expand(collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)]))
            else (collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')]))
        else (collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')])
        
(: Erschlossener Brief? :)
(: *** Bugfix #11377 (HTTP Error 500 bei Regestbriefen) *** :)
(: *** Bugfix #10989 ***:)
(:let $conjectured := not($letter[.//tei:body//text()]):)
let $conjectured := not(normalize-space($letter//tei:body))

(: Aktuellen Jahrgang auslesen :)
let $person := $letter//tei:correspAction[not(.//@key='prov_ztg_3sx_sr')]/tei:persName/@key

let $currentYear := 
    if ($letter//tei:correspAction[@type='sent']/tei:date/@when) 
    then ($letter//tei:correspAction[@type='sent']/tei:date/@when/substring(., 1,4))
        else if ($letter//tei:correspAction[@type='sent']/tei:date/@from)
        then ($letter//tei:correspAction[@type='sent']/tei:date/@from/substring(., 1,4))
            else if ($letter//tei:correspAction[@type='sent']/tei:date/@notBefore)
            then ($letter//tei:correspAction[@type='sent']/tei:date/@notBefore/substring(., 1,4))
            else ()

(: Nächste und vorangehende Briefe :)
let $lettersListAbsolute := 
    element root {
        for $letter in collection($edweb:dataLetters)//tei:TEI
        order by edweb:defaultOrderBy($letter)
        return
        $letter
    }

let $nextLetter := $lettersListAbsolute/tei:TEI[@xml:id=$p_id]/following-sibling::tei:TEI[1]/@xml:id/data(.)
let $prevLetter := $lettersListAbsolute/tei:TEI[@xml:id=$p_id]/preceding-sibling::tei:TEI[1]/@xml:id/data(.)

let $lettersListCorrespondence :=
    element root {
        for $letter in $lettersListAbsolute//tei:TEI[.//tei:correspAction/tei:persName[@key=$person]]
        order by edweb:defaultOrderBy($letter)
        return
        $letter
    }               

let $nextLetterInCorresp := $lettersListCorrespondence/tei:TEI[@xml:id=$p_id]/following-sibling::tei:TEI[1]/@xml:id/data(.)
let $prevLetterInCorresp := $lettersListCorrespondence/tei:TEI[@xml:id=$p_id]/preceding-sibling::tei:TEI[1]/@xml:id/data(.)  

(: Parameter für alle Transformationen :)
let $params := 
    <parameters>
        <param name="jahr" value="{$p_year}"/>
        <param name="id" value="{$p_id}"/>
        <param name="view" value="{$edweb:p_view}" />
        <param name="cacheLetterIndex" value="{$edweb:cacheLetterIndex}" />
        {if ($conjectured)
        then (<param name="erschlossen" value="true" />)
        else (<param name="erschlossen" value="false" />)
        }
    </parameters>

(: Metaangaben ("Weitere Angaben") nur platzieren, wenn Brief transkribiert vorliegt :) 
let $meta := transform:transform($letter, doc("resources/meta.xsl"), $params)

(:Nachweis, d.h. Archiv und Signatur :)
 let $nachweis :=
    if (not($letter//tei:msDesc//tei:idno[@type="shelfmark"]/text()))
    then (
        <p id="nachweis">Erschlossener Brief</p>
    )
    else (
        <p id="nachweis">
            {if ($letter//tei:sourceDesc/tei:msDesc[@rend='manuscript'])
            then ('H: ')
            else if ($letter//tei:sourceDesc/tei:msDesc[@rend='copy'])
            then ('h: ')
            else ()}
            {concat($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:institution,
            edweb:seperator($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository/text(), ', '),
            edweb:seperator($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:collection/text(), ', '),
            edweb:seperator($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier//tei:idno[not(@type='uri')]/text(), ','))}
        </p> 
    ) 
    
    let $typeOfMs :=
    if ($letter//tei:msDesc[@rend='manuscript'])
    then 'H: '
    else if ($letter//tei:msDesc[@rend='concept' or @rend='copy'])
    then 'h: '
    else if ($letter//tei:witness)
    then 'D: '
    else ()
    
    let $nachweis :=
    if ($conjectured)
    then (
        <p id="nachweis">Erschlossener Brief</p>
    )
    else (
        <p id="nachweis">
            {if ($letter//tei:msDesc//tei:idno/text()!='') then (
                concat($typeOfMs, $letter//tei:msDesc[@rend='manuscript' or @rend='concept' or @rend='copy']/tei:msIdentifier/tei:institution,
                edweb:seperator($letter//tei:msDesc[@rend='manuscript' or @rend='concept' or @rend='copy']/tei:msIdentifier/tei:repository/text(), ', '),
                edweb:seperator($letter//tei:msDesc[@rend='manuscript' or @rend='concept' or @rend='copy']/tei:msIdentifier/tei:collection/text(), ', '),
                edweb:seperator($letter//tei:msDesc[@rend='manuscript' or @rend='concept' or @rend='copy']/tei:msIdentifier/tei:idno[not(@type='kalliope')]/text(), ','),
                edweb:seperator($letter//tei:msDesc[@rend='manuscript' or @rend='concept' or @rend='copy']/tei:msIdentifier/tei:idno/tei:idno[@type='shelfmark']/text(), ',')),
                if ($letter//tei:idno/@type='uri') then (<a class="kalliopelink" href="{$letter//tei:idno[@type='uri']/text()}">Katalog<i class="fa fa-external-link"/></a>) else ()
            ) else (
                if ($letter//tei:witness/@select='#this')
                then (concat($typeOfMs, $letter//tei:witness[@select='#this']/tei:bibl/text()))
                else (concat($typeOfMs, $letter//tei:witness[position()=last()]/tei:bibl/text()))
            )}
        </p> 
    )  
    
    (: Rendern der Transkription bzw. (wenn nur erschlossen) der Anmerkung zum Brief und ggf. Zusammenfassung :)
let $letterText :=
    if ($conjectured)
    then (transform:transform($letter, doc("resources/letterHeader.xsl"), $params))
    else (transform:transform($letter, doc("../resources/xslt/content-grid.xsl"), $params))
    
    
(: ########### HTML-Ausgabe ########### :)

let $header :=  
    <transferContainer>
        <div id="subnavbar">
            <ul>
                {local:linkToSibling('prev', $edweb:p_view, $prevLetter)}
                <li><a class="index" href="index.xql?jahr={$currentYear}&amp;view={$edweb:p_view}">Amtliche Schriften im Jahr {$currentYear}</a></li>
                {local:linkToSibling('next', $edweb:p_view, $nextLetter)}
            </ul>
            <hr class="clear" />
            <ul>
            {local:linkToSibling('prev', $edweb:p_view, $prevLetterInCorresp)}
            <li><a class="index" href="index.xql?person={$person}&amp;view={$edweb:p_view}">Dokumente von {edweb:persName(collection($edweb:dataRegister)//tei:person[@xml:id=$person][1]/tei:persName[not(./@type='alt')], 'forename')}</a></li>
            {local:linkToSibling('next', $edweb:p_view, $nextLetterInCorresp)}
            </ul>
        </div>
        <h1>{edweb:letterTitle($letter//tei:titleStmt)}</h1>
        {$nachweis}
        {edwebMeta:meta($letter)}
        <!-- {csLink:linkedLetters($letter, 'correspondent', $edweb:dataRegister)} -->
        <ul id="viewSwitch">
           {if ($conjectured)
            then ()
            else (
                if ($edweb:p_view='k')
                then (<li class="current"><a href="detail.xql?id={$p_id}&amp;view=k">Kritischer Text</a></li>)
                else (<li><a href="detail.xql?id={$p_id}&amp;view=k">Kritischer Text</a></li>),
                if ($edweb:p_view='l')
                then (<li class="current"><a href="detail.xql?id={$p_id}&amp;view=l">Lesetext</a></li>)
                else (<li><a href="detail.xql?id={$p_id}&amp;view=l">Lesetext</a></li>)
            )}
        </ul>
    </transferContainer>
    
let $content := 
    <transferContainer>
        {if ($letterText!='') then $letterText
        else (<div class="notfound"><p>Fehler!<br/>Es wurde kein entsprechendes Dokument in der Datenbank gefunden.</p></div>)}
        <ul xmlns="http://www.w3.org/1999/xhtml"id="browselinks">
        {local:linkToSibling('prev', $edweb:p_view, $prevLetterInCorresp),
         local:linkToSibling('next', $edweb:p_view, $nextLetterInCorresp)} 
        </ul>
    </transferContainer>

let $xslt_input :=  
    <transferContainer>
        {transform:transform($header, doc($edweb:htmlHeader), ()),
        transform:transform($content, doc($edweb:htmlContent), (<parameters><param name="columns" value="16" /></parameters>))}        
    </transferContainer>


let $output := 
    transform:transform(
        $xslt_input, 
        doc($edweb:html), 
        <parameters>
            <param name="currentSection" value="amtliche-schriften" />
            <param name="searchTerms" value="{$p_searchTerms}" />
            <param name="baseURL" value="{$edweb:baseURL}" />
        </parameters>)

return
$output


