xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $local:uuid := 'c18f10d8-bec2-40f2-8f85-e58743e4427d';
declare variable $local:baseURL := 'http://megadigital.bbaw.de/briefe/detail.xql?id=';
declare variable $local:login := xmldb:login('/db/', 'admin', 'p14o02');

declare function local:correspAction($correspDesc, $type) {
let $orgNames :=
    for $orgName in  $correspDesc/tei:correspAction[@type=$type]/tei:orgName[@key]
    let $entry := collection($edweb:dataRegister)//tei:org[@xml:id=$orgName/@key]
    return
    if ($entry/tei:idno[matches(., 'gnd|viaf')])
    then <orgName ref="{$entry/tei:idno[matches(., 'gnd|viaf')]/text()}">{$entry/tei:orgName[@type='reg']/text()}</orgName>
    else <orgName>{$entry/tei:orgName[@type='reg']/text()}</orgName>
let $persNames :=    
    for $persName in  $correspDesc/tei:correspAction[@type=$type]/tei:persName[@key]
    let $entry := collection($edweb:dataRegister)//tei:person[@xml:id=$persName/@key]
    return
    if ($entry/tei:idno[matches(., 'gnd|viaf')])
    then <persName ref="{$entry/tei:idno[matches(., 'gnd|viaf')]/text()}">{edweb:persName($entry/tei:persName[@type='reg'], 'forename')}</persName>
    else <persName>{edweb:persName($entry/tei:persName[@type='reg'], 'forename')}</persName>
let $placeNames :=    
    for $placeName in  $correspDesc/tei:correspAction[@type=$type]/tei:placeName[@key]
    let $entry := collection($edweb:dataRegister)//tei:place[@xml:id=$placeName/@key]
    return
    if ($entry/tei:idno)
    then <placeName ref="{$entry/tei:idno/text()}">{$entry/tei:placeName[@type='reg']/text()}</placeName>
    else <placeName>{$entry/tei:placeName[@type='reg']/text()}</placeName>
let $dates :=
    $correspDesc/tei:correspAction[@type=$type]/tei:date
return
if ($orgNames or $persNames or $placeNames or $dates)
then
    <correspAction type="{$type}">
        {$orgNames,
        $persNames,
        $placeNames,
        $dates} 
    </correspAction>    
else ()    
};

declare function local:correspDesc() {
    for $letter in collection($edweb:data)//tei:TEI[.//tei:correspDesc]
    let $sent := local:correspAction($letter//tei:correspDesc, 'sent')
    let $received := local:correspAction($letter//tei:correspDesc, 'received')
    return
    if ($sent or $received)
    then
    <correspDesc source="#{$local:uuid}" xmlns="http://www.tei-c.org/ns/1.0" ref="{$local:baseURL||$letter/@xml:id}">
        {$sent,$received}
    </correspDesc>
    else ()
};

let $doLogin := $local:login

let $useCache := 
    if (doc-available('resources/cached_cmif.xml'))
    then (
        if(current-dateTime() < (xmldb:created(concat($edweb:apiDir, '/resources'), 'cached_cmif.xml') + xs:dayTimeDuration('P14D')))
        then (fn:true())
        else (fn:false())
    )
    else (fn:false())


let $cmif :=
    if (not($useCache))
    then (
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Index of MEGAdigital - Correspondence 1866</title>
                        <editor>Sascha Grabsch <email>grabsch@bbaw.de</email>
                        </editor>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>
                            <ref target="http://www.bbaw.de">Berlin-Brandenburg Academy of Sciences and Humanities</ref>
                        </publisher>
                        <date when="{current-dateTime()}"/>
                        <availability>
                            <licence target="https://creativecommons.org/licenses/by/4.0/">This file is licensed under the terms of the Creative-Commons-License CC-BY 4.0</licence>
                        </availability>
                        <idno type="url">http://megadigital.bbaw.de/api/cmif.xql</idno>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl type="online" xml:id="{$local:uuid}">
                            Marx-Engels-Gesamtausgabe digital. Hg. von der Internationalen Marx-Engels-Stiftung. Berlin-Brandenburgische Akademie der Wissenschaften, Berlin. URL: <ref target="http://megadigital.bbaw.de">http://megadigital.bbaw.de</ref>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
                <profileDesc>
                    {local:correspDesc()}
                </profileDesc>
            </teiHeader>
            <text/>
        </TEI>
    ) else ()

return
if ($useCache)
then (doc('resources/cached_cmif.xml'))
else (
    xmldb:store(concat($edweb:apiDir, '/resources'), 'cached_cmif.xml', $cmif),
    response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/api/cmif.xql'))))
