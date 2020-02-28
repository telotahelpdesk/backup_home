xquery version "3.1";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare option exist:serialize "method=html media-type=text/html";

declare function local:viewDate($date) {
    if (matches($date, '\d\d\d\d-\d\d-\d\d'))
    then format-date($date, '[D01].[M01].[Y0001]')
    else $date
};

let $login := edweb:login()

(: Parameter aus URL übernehmen :)
let $p_id := request:get-parameter("id", ())
let $p_filepath := substring-after(request:get-parameter("file", ""), 'webdav')

let $doc :=
    if ($p_id)
    then collection('/db/projects/mega_druckansicht/data/')//tei:TEI[@xml:id=$p_id] 
    else doc($p_filepath)//tei:TEI

(: Parameter für alle Transformationen :)
let $params := 
    <parameters>
        <param name="id" value="{$p_id}"/>
        <param name="view" value="k" />
        <param name="print" value="yes" />
        <param name="cacheLetterIndex" value="{$edweb:cacheLetterIndex}" />
    </parameters>

let $document := transform:transform($doc, doc("resources/xslt/content-grid.xsl"), $params)
let $abstract := transform:transform($doc//tei:abstract, doc("resources/xslt/redaktionsansicht.xsl"), $params)

let $att_values :=
    map{
        "superlinear" := "Über der Zeile ergänzt",
        "sublinear" := "Unter der Zeile ergänzt",
        "intralinear" := "Innerhalb der Zeile ergänzt",
        "across" := "Über den ursprünglichen Text geschrieben",
        "left" := "Am linken Rand ergänzt",
        "right" := "Am rechten Rand ergänzt",
        "mTop" := "Am oberen Rand ergänzt",
        "mBottom" := "Am unteren Rand ergänzt",
        "lost" := "Zerstörung/Verlust",
        "empty" := "Leerraum",
        "illegible" := "unleserlich",
        "covered" := "durch Überschreibung",
        "fm" := "fremdsprachlicher Text",
        "insignificant" := "für den Korpus unwichtiger Text" ,
        "#ow" := "Tilgung durch Überschreibung des ursprünglichen Textes",
        "#s":="Tilgung durch Streichnung",
        "#erased":="Tilgung durch Radieren"
    }


let $sourceType :=
    concat(
        if ($doc//tei:msDesc/@rend='concept')
        then ('Entwurf')
        else if ($doc//tei:msDesc/@rend='officialCopy')
        then ('Ausfertigung')
        else if ($doc//tei:msDesc/@rend='manuscript')
        then ('Reinschrift')
        else if ($doc//tei:msDesc/@rend='print')
        then ('Druck')
        else if (not($doc//tei:msDesc/@rend))
        then ('Original(?)')
        else (),
        if ($doc//tei:msDesc/@subtype='copy')
        then (' (Abschrift)')
        else (),
        ': '
     )

let $categories :=
    if ($doc//tei:note[@type='keyword'])
    then <p id="nachweis">Kategorien: {
        for $cat in $doc//tei:note[@type='keyword']//text()
        return
        replace($cat, 'Kategorie:', '')}</p>
    else ()
    
let $creation :=
    if ($doc//tei:correspDesc)
    then 
        <p id="nachweis">
            {$doc//tei:correspAction[@type='sent']/tei:persName/text()||', '||local:viewDate($doc//tei:correspAction[@type='sent']/tei:date/(@when|@from|@notBefore)),
            if ($doc//tei:correspAction[@type='sent']/tei:date/(@to|@notAfter)) then ('-'||local:viewDate($doc//tei:correspAction[@type='sent']/tei:date/(@to|@notAfter))) else ()
        }</p>
    else (
        <p id="nachweis">
            {$doc//tei:creation/tei:persName/text()||', '||local:viewDate($doc//tei:creation/tei:date/(@when|@from|@notBefore)),
            if ($doc//tei:creation/tei:date/(@to|@notAfter)) then ('-'||local:viewDate($doc//tei:creation/tei:date/(@to|@notAfter))) else ()
        }</p>
    )

return
<html>
    <head>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="resources/css/transkription.css" type="text/css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="resources/css/print.css" type="text/css"/>
    </head>
    <body>
        <h1>{$doc//tei:teiHeader//tei:titleStmt/tei:title/text()}</h1>
        <h2>Zeugenbeschreibung</h2>
        <p style="font-style: italic;">{$doc//tei:teiHeader//tei:editionStmt/tei:edition/text()}</p>
         <h3>Metadaten:</h3>
        <p id="nachweis">
            {if ($doc//tei:msDesc//tei:idno/text()!='') then (
                concat($sourceType, $doc//tei:msDesc/tei:msIdentifier/tei:institution,
                edweb:seperator($doc//tei:msDesc/tei:msIdentifier/tei:repository/text(), ', '),
                edweb:seperator($doc//tei:msDesc/tei:msIdentifier/tei:collection/text(), ', '),
                edweb:seperator($doc//tei:msDesc/tei:msIdentifier/tei:idno//text(), ','))
            ) else (
                concat($sourceType, $doc//tei:witness[position()=last()]/tei:bibl/text())
            )}
        </p>
        {$creation}
        {$categories} 
        {if ($doc//tei:physDesc)
        then (<p>{$doc//tei:physDesc/tei:p}</p>)
        else (),
        
        if ($doc//tei:textClass/tei:keywords)
        then (
            element div {
                element h3 {'Themen:'}},
                
                for $term in $doc//tei:textClass/tei:keywords/tei:term
                return
                <li><a href="https://megadigital.bbaw.de/register/sachen/detail.xql?id={$term/@key}">{$term/text()}</a></li>
        )
        else (),
    
        if ($doc//tei:witness and $doc//tei:msDesc)
        then (
            element div {
            element h3 {'Textzeugen:'}, 
            for $wit in $doc//tei:listWit/tei:witness
            return
            <li>{$wit//text()}</li>
        }) else (),
        if ($doc//tei:correspDesc/tei:note)
        then (
            element div {
                
                element h3 {'Anmerkungen zum Brief:'},
                transform:transform($doc//tei:correspDesc/tei:note/node(),  doc("resources/xslt/redaktionsansicht.xsl"), $params)} )
        else (),
        if ($doc//tei:notesStmt/tei:note[@type='editorial'])
        then (
            element div {
                attribute style {'font-style: italic;'},
                element h3 {'Anmerkungen zum Text'},
                transform:transform($doc//tei:notesStmt/tei:note[@type='editorial']/node(), doc("resources/xslt/redaktionsansicht.xsl"), $params)} )
        else (),
        if ($doc//tei:abstract//text())
        then (
            element div {
                attribute class {'abstract'},
                attribute style {'font-style: italic;'},
                element h3 {'Zusammenfassung'},
                element p { $abstract }}
        )
        else ()}
        
        <h2>Text</h2>
        {$document,
        if ($doc//(tei:abstract|tei:text)//tei:seg/tei:note) then (
        <div id="comments" style="font-style: italic">
            <h3>Erläuterungen</h3>
            <ul>
            {for $comment at $pos in $doc//(tei:abstract|tei:text)//tei:seg/tei:note
             let $note := transform:transform($comment, doc("resources/xslt/redaktionsansicht.xsl"), $params)
             return
             <li><a name="fnote{$pos}" href="#fchar{$pos}"></a>{$note}</li>}
             </ul>
        </div>) else (),
        
        
        if ($doc//(tei:add|tei:gap)) then (
        <div id="critical" style="font-style: italic">
            <h3>Kritischer Apparat</h3>
           
             <ul>
       
       {for $check at $pos in ($doc//tei:gap | $doc//tei:add | $doc//tei:del)
       let $label := 
             if ($check/@reason!='' and $att_values($check/@reason))
              then $att_values($check/@reason) 
             else if ($check/@reason!='') 
                      then $check/@reason/data(.)
             else if ($check/@place!='' and $att_values($check/@place))
                then $att_values($check/@place)
              else if ($check/@rendition!='' and $att_values($check/@rendition))
                then $att_values($check/@rendition)
                    
             else ('[Keine gap Angabe]')
             return
             <li><a name="cnote{$pos}" href="#cchar{$pos}">{$label}</a></li>}
           
            </ul>
            
             </div>
        ) else ()}
    </body>
</html>
