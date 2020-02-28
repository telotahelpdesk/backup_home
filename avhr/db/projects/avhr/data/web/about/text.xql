xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html media-type=text/html";

let $login := edweb:login()

(: Parameter aus URL übernehmen :)
let $p_id := request:get-parameter("id", ())
let $p_searchTerms := request:get-parameter("searchTerms", ())

(: Pfad das aktuellen Briefs :)
let $letter := 
        if ($p_searchTerms)
        then 
            (if (collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)])
            then (kwic:expand(collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)]))
            else (collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')]))
        else (collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')])
        
(: Parameter für alle Transformationen :)
let $params := 
    <parameters>
        <param name="id" value="{$p_id}"/>
        <param name="view" value="c" />
        <param name="filename" value="none" />
        <param name="cacheLetterIndex" value="{$edweb:cacheLetterIndex}" />
    </parameters>

let $authorInfo :=
    <div class="grid_11 authorInfo">
    {if (count($letter//tei:author) > 1)
    then (<h2>Über die Autoren</h2>)
    else (<h2>Über den Autor</h2>)}
    {for $author in $letter//tei:author
    return
    <div>
        <a name="authorInfo">&#160;</a>
        <h3>{$author/tei:persName/text()}</h3>
        <p class="orgName">{$author/tei:affiliation/text()}</p>
        <p class="mail"><a href="mailto:{$author/tei:email/text()}">{$author/tei:email}</a></p>
        <p class="note">{transform:transform($author/tei:note, doc('../resources/xslt/transcription.xsl'), $params)}</p>
     </div>}
    </div>

(: Rendern der Transkription bzw. (wenn nur erschlossen) der Anmerkung zum Brief und ggf. Zusammenfassung :)
let $letterText := transform:transform($letter, doc("../resources/xslt/content-grid.xsl"), $params)
let $subnav :=
    <div id="subnavbar">
        <ul>
            {if ($p_id='aloys-hirt') 
            then (<li><a href="text.xql?id=aloys-hirt" class="current">Aloys Hirt</a></li>)
            else (<li><a href="text.xql?id=aloys-hirt">Aloys Hirt</a></li>),
            if ($p_id='projekt') 
            then (<li><a href="text.xql?id=projekt" class="current">Das Projekt</a></li>)
            else (<li><a href="text.xql?id=projekt">Das Projekt</a></li>),
            if ($p_id='zu_dieser_edition') 
            then (<li><a href="text.xql?id=zu_dieser_edition" class="current">Zu dieser Edition</a></li>)
            else (<li><a href="text.xql?id=zu_dieser_edition">Zu dieser Edition</a></li>)}
            {if ($p_id='editionsrichtlinien') 
            then (<li><a href="text.xql?id=editionsrichtlinien" class="current">Editionsrichtlinien</a></li>)
            else (<li><a href="text.xql?id=editionsrichtlinien">Editionsrichtlinien</a></li>)}
        </ul>
    </div>


let $toc :=
    if ($p_id='zeuske')
    then (
        <div class="grid_11">
        <ul class="toc">
        <h3>Inhaltsverzeichnis</h3>
        {for $head at $pos in $letter//tei:text//tei:head
        return
        <li><a href="#section{$pos}">{$head//text()}</a></li>}
        </ul></div>
    ) else ()

(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        {$subnav}
        <h1>{$letter//tei:titleStmt/tei:title[not(@type='sub')]/text()}</h1>
        {if ($letter//tei:titleStmt/tei:title[@type='sub']/text()) then (<h2>{$letter//tei:titleStmt/tei:title[@type='sub']/text()}</h2>) else ()}
        {for $author in $letter//tei:author
        return
        <p class="author">{$author/tei:persName/text()}</p>}
    </transferContainer>

let $content := 
    <transferContainer>
        {if ($letterText!='') then ($toc, $letterText)
        else (<div class="notfound"><p>Fehler!<br/>Es wurde kein entsprechendes Dokument in der Datenbank gefunden.</p></div>)}
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
            <param name="currentSection" value="commentary" />
            <param name="searchTerms" value="{$p_searchTerms}" />
            <param name="baseURL" value="{$edweb:baseURL}" />
        </parameters>)

return 
$output