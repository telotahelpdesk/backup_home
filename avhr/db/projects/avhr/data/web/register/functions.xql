xquery version "3.0";

module namespace edwebRegister = "http://www.bbaw.de/telota/ediarum/web/register";
import module namespace edweb = "http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";
(: namespaces for geo-services :)
declare namespace schema = "http://schema.org/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $edwebRegister:section := upper-case(request:get-parameter("section", 'A'));
declare variable $edwebRegister:id :=
if (matches(request:get-parameter("id", ()), 'zotero'))
then
    edweb:substring-afterlast(request:get-parameter("id", ()), '-')
else
    request:get-parameter("id", ());

declare function edwebRegister:indexElements($entry) as xs:string {
    typeswitch ($entry)
        case element(tei:person)
            return
                '(tei:rs|tei:persName)'
        case element(tei:place)
            return
                '(tei:rs|tei:placeName|tei:settlement)'
        case element(tei:org)
            return
                '(tei:rs|tei:orgName)'
        case element(tei:bibl)
            return
                'tei:bibl'
        case element(item)
            return
                '(tei:ref|tei:bibl)'
        default
            return
                ()
};

declare function edwebRegister:getEntry($indexType) {
    let $login := edweb:login()
    
    return
        if (matches($indexType, 'literatur|bibliographie|werke'))
        then
            (
            if (collection($edweb:dataZotero)//item[./key = $edwebRegister:id])
            then
                collection($edweb:dataZotero)//item[./key = $edwebRegister:id]
            else
                response:redirect-to(xs:anyURI($edweb:baseURL || '/register/' || $indexType || '/index.xql')))
        else
            if (collection($edweb:dataRegister)//(tei:org | tei:person | tei:place)[@xml:id = $edwebRegister:id])
            then
                (collection($edweb:dataRegister)//(tei:org | tei:person | tei:place)[@xml:id = $edwebRegister:id])
            else
                (
                response:redirect-to(xs:anyURI($edweb:baseURL || '/register/' || $indexType || '/index.xql'))
                )
};

declare function local:helperOrderBy($collection) {
    for $x in util:eval($collection)
        order by
        typeswitch ($x)
            case element(tei:person)
                return
                    (edweb:defaultOrderBy($x//tei:persName[@type = 'reg']/tei:surname/text()), edweb:defaultOrderBy($x//tei:persName[@type = 'reg']/tei:forename/text()))
            case element(tei:place)
                return
                    edweb:defaultOrderBy($x//tei:placeName[@type = 'reg'])
            case element(tei:org)
                return
                    edweb:defaultOrderBy($x//tei:orgName[@type = 'reg'])
            case element(tei:bibl)
                return
                    edweb:defaultOrderBy($x//tei:title)
            default
                return
                    ()
    return
        $x
};

declare function edwebRegister:prevNextEntries($entry as node()) {
    let $getEntries :=
    typeswitch ($entry)
        case element(tei:person)
            return
                (
                for $x in collection($edweb:dataRegister)//tei:person
                (: order by funzt nicht, weshalb auch immer :)
                    order by $x/tei:persName[@type = 'reg'][1]/tei:surname/text()
                return
                    $x)
        case element(tei:place)
            return
                (collection($edweb:dataRegister)//tei:place)
        case element(tei:org)
            return
                (collection($edweb:dataRegister)//tei:org)
        case element(tei:bibl)
            return
                (collection($edweb:dataRegister)//tei:bibl)
        default
            return
                ()
    let $prev := $getEntries[@xml:id = $entry/@xml:id]/preceding-sibling::tei:*[1]/@xml:id
    let $next := $getEntries[@xml:id = $entry/@xml:id]/following-sibling::tei:*[1]/@xml:id
    return
        <ul
            id="browselinks">
            {
                if ($prev) then
                    (<li><a
                            class="prev"
                            href="detail.xql?id={$prev}"><span>Vorangehender Eintrag</span></a></li>)
                else
                    (),
                if ($next) then
                    (<li><a
                            class="next"
                            href="detail.xql?id={$next}"><span>Nächster Eintrag</span></a></li>)
                else
                    ()
            }
        </ul>
};

declare function edwebRegister:getRelatedLetters($entry as element()) {
    (: 2019-06-05 Angepasst für amtliche Schriften :)
    let $allQueries :=
    map {
        'correspondent': concat('collection($edweb:data||"/Briefe")//tei:TEI[.//tei:correspAction//', edwebRegister:indexElements($entry), '[@key=$edwebRegister:id]]'),
        'correspondencePlace': 'collection($edweb:data||"/Briefe")//tei:TEI[.//tei:correspAction[@type="sent"]/tei:placeName[@key=$edwebRegister:id]]',
        'mentionedInLetters': concat('collection($edweb:data||"/Briefe")//tei:TEI[.//tei:correspDesc and (tei:text//', edwebRegister:indexElements($entry), '[matches(@*, $edwebRegister:id) and not(ancestor::tei:note[parent::tei:seg])] or tei:text//tei:index[substring(@corresp, 2)=$edwebRegister:id])]'),
        'mentionedInLetterComments': concat('collection($edweb:data||"/Briefe")//tei:TEI[.//tei:correspDesc and (.//tei:seg/tei:note//', edwebRegister:indexElements($entry), '[matches(@*, $edwebRegister:id)] or tei:text//tei:index[substring(@corresp, 2)=$edwebRegister:id])]'),
        'as-author': concat('collection($edweb:data||"/Amtliche%20Schriften")//tei:TEI[.//(tei:correspAction|tei:creation)//', edwebRegister:indexElements($entry), '[@key=$edwebRegister:id]]'),
        'as-mentionedInLetters': concat('collection($edweb:data||"/Amtliche%20Schriften")//tei:TEI[(tei:text//', edwebRegister:indexElements($entry), '[matches(@*, $edwebRegister:id) and not(ancestor::tei:note[parent::tei:seg])] or tei:text//tei:index[substring(@corresp, 2)=$edwebRegister:id])]'),
        'as-mentionedInLetterComments': concat('collection($edweb:data||"/Amtliche%20Schriften")//tei:TEI[(.//tei:seg/tei:note//', edwebRegister:indexElements($entry), '[matches(@*, $edwebRegister:id)] or tei:text//tei:index[substring(@corresp, 2)=$edwebRegister:id])]'),
        'commentary': concat('collection($edweb:dataCommentary)//tei:TEI[not(parent::tei:teiCorpus) and tei:text//', edwebRegister:indexElements($entry), '[matches(@*, $edwebRegister:id)]]')
    }
    let $allQueriesLabels :=
    map {
        'correspondent': 'Korrespondenz',
        'correspondencePlace': 'Schreibort',
        'mentionedInLetters': 'Erwähnt in Briefen',
        'mentionedInLetterComments': 'Erwähnt in Sacherläuterungen von Briefstellen',
        'as-correspondent': 'Amtliche Schriften',
        'as-mentionedInLetters': 'Erwähnt in amtlichen Schriften',
        'as-mentionedInLetterComments': 'Erwähnt in Sacherläuterungen in amtlichen Schriften',
        'commentary': 'Erwähnt in Einführungen',
        'authorOf': 'Autor folgender Titel im Literaturregister',
        'witness': 'Briefe'
    }
    let $allQueriesDesc :=
    map {
        'witness': 'Die folgenden Briefe, die in edition humboldt digital vorliegen, werden in dieser Publikation erwähnt oder sind dort als (Teil-)Druck enthalten:'
    }
    let $commonQueries := ('mentionedInLetters', 'mentionedInLetterComments', 'as-mentionedInLetters', 'as-mentionedInLetterComments')
    let $queries :=
    typeswitch ($entry)
        case element(tei:person)
            return
                ('correspondent', 'as-author', $commonQueries)
        case element(tei:place)
            return
                ('correspondencePlace', 'as-author', $commonQueries)
        case element(tei:org)
            return
                ('correspondent', $commonQueries)
        case element(item)
            return
                ($commonQueries, 'witness')
        default
            return
                ()
    return
        for $query in $queries
        return
                edwebRegister:viewLetterTable(
                for $doc in util:eval($allQueries($query))
                    order by edweb:defaultOrderBy($doc)
                return
                    $doc,
                $allQueriesLabels($query),
                $allQueriesDesc($query),
                if (matches($query, 'as-')) then true() else false())

};

declare function edwebRegister:getRelatedEntries($entry) {
    let $allQueries :=
    map {
        'personIndex': concat('collection($edweb:dataRegister)//tei:person[.//', edwebRegister:indexElements($entry), '/@key=$edwebRegister:id]'),
        'orgIndex': concat('collection($edweb:dataRegister)//tei:org[.//', edwebRegister:indexElements($entry), '/@key=$edwebRegister:id]')
    }
    let $allQueriesLabels :=
    map {
        'personIndex': 'Erwähnungen im Personenregister',
        'orgIndex': 'Einrichtungen an diesem Ort'
    }
    let $queries :=
    typeswitch ($entry)
        case element(tei:org)
            return
                'personIndex'
        case element(tei:place)
            return
                ('orgIndex', 'personIndex')
        default
            return
                ()
    return
        for $query in $queries
        return
            edwebRegister:viewEntryList(
            for $e in util:eval($allQueries($query))
            return
                $e,
            $allQueriesLabels($query)
            )
};

declare function edwebRegister:sectionNav($currentName) {
    let $fullRange := 'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z'
    let $currentLetter :=
    if ($currentName != 'index')
    then
        (substring(string-join($currentName), 1, 1))
    else
        ($edwebRegister:section)
    
    let $nav :=
    <ul>
        {
            for $letter in tokenize($fullRange, ',')
            return
                <li>
                    {
                        if ($letter = $currentLetter) then
                            (<a
                                class="current"
                                href="index.xql?section={$letter}">{$letter}</a>)
                        else
                            (<a
                                href="index.xql?section={$letter}">{$letter}</a>)
                    }
                </li>
        }
    </ul>
    return
        $nav
};

declare function edwebRegister:orderLabel($label) {
    let $normalized := normalize-space($label)
    let $s := replace($normalized, 'š', 's')
    let $ö := replace($s, 'ö', 'oe')
    let $Ö := replace($ö, 'Ö', 'Oe')
    let $ä := replace($Ö, 'ä', 'ae')
    let $Ä := replace($ä, 'Ä', 'Ae')
    let $ü := replace($Ä, 'ü', 'ue')
    let $Ü := replace($ü, 'Ü', 'Ue')
    let $e := replace($Ü, 'é', 'e')
    let $e2 := replace($e, 'è', 'e')
    return
        $e2
};



declare function local:viewDate($date) {
    if (matches($date/@when, '\d\d\d\d-\d\d-\d\d'))
    then
        (format-date($date/@when, '[D01].[M01].[Y0001]'))
    else
        if (matches($date/@from, '\d\d\d\d-\d\d-\d\d') and matches($date/@to, '\d\d\d\d-\d\d-\d\d'))
        then
            (format-date($date/@from, '[D01].[M01].[Y0001]') || '&#x2013; ' || format-date($date/@to, '[D01].[M01].[Y0001]'))
        else
            if (matches($date/@notBefore, '\d\d\d\d-\d\d-\d\d') and matches($date/@notAfter, '\d\d\d\d-\d\d-\d\d'))
            then
                ('nach ' || format-date($date/@notBefore, '[D01].[M01].[Y0001]') || '&#x2013; vor ' || format-date($date/@notAfter, '[D01].[M01].[Y0001]'))
            else
                ()
};

declare function edwebRegister:viewBox($node) {
    if ($node) then
        (
        <div
            class="box whitebox">
            <div
                class="boxInner">
                {$node}
            </div>
        </div>
        )
    else
        ()
};

declare function edwebRegister:viewBox($node, $color, $type) {
    let $boxClass :=
    if ($type = 'gray')
    then
        (' graybox')
    else
        (' whitebox')
    let $boxInnerClass :=
    if ($type = 'hints')
    then
        (' hinweise')
    else
        ()
    return
        if ($node) then
            (
            <div
                class="box{$boxClass}">
                <div
                    class="boxInner{$boxInnerClass}">
                    {$node}
                </div>
            </div>
            )
        else
            ()
};

declare function edwebRegister:viewEntryList($nodes, $head) {
    let $list :=
    (element h3 {$head},
    element ul {
        for $node in $nodes
        return
            element li {
                if (local-name($node) = 'person')
                then
                    (<a
                        href="../personen/detail.xql?id={$node/@xml:id}">{edweb:persName($node/tei:persName[@type = 'reg'], 'surname')}</a>)
                else
                    if (local-name($node) = 'org')
                    then
                        (<a
                            href="../einrichtungen/detail.xql?id={$node/@xml:id}">{$node/tei:orgName[@type = 'reg']}</a>)
                    else
                        if (local-name($node) = 'place')
                        then
                            (<a
                                href="../orte/detail.xql?id={$node/@xml:id}">{$node/tei:placeName[@type = 'reg']}</a>)
                        else
                            ()
            }
    })
    return
        if ($list//li)
        then
            ($list)
        else
            ()
};

declare function edwebRegister:viewLetterTable($letters, $title, $desc, $as as xs:boolean) {
    let $login := edweb:login()
    let $table :=
    <div>
        <h3>{$title}</h3>
        {
            if ($desc) then
                (
                <p>{$desc}</p>
                )
            else
                ()
        }
        <table
            class="letters">
            <tr>
                <th>Datum</th>
                <th>Korrespondent</th>
                <th>Ort</th>
            </tr>{
                for $letter in $letters
                let $correspondent := 
                    if ($letter//tei:correspAction/(tei:persName|tei:orgName)[@key != 'prov_ztg_3sx_sr'] and (count($letter//tei:correspAction/(tei:persName|tei:orgName)) > 2))
                    then $letter//tei:correspAction/(tei:persName|tei:orgName)
                    else if ($letter//tei:correspAction/(tei:persName|tei:orgName)[@key != 'prov_ztg_3sx_sr'])
                    then $letter//tei:correspAction/(tei:persName|tei:orgName)[@key != 'prov_ztg_3sx_sr']
                    else $letter//(tei:correspAction|tei:creation)/tei:persName[@key='prov_ztg_3sx_sr']
                let $correspondentName :=
                    for $x in $correspondent
                    let $type :=
                    if ($x/parent::tei:correspAction/@type = 'sent')
                    then
                        ('Von ')
                    else
                        ('An ')
                    return
                        ($type,
                        for $y in collection($edweb:dataRegister)//id($x/@key)
                        return
                            if ($y/tei:orgName)
                            then $y/tei:orgName[@type='reg']/text()
                            else (edweb:persName($y/tei:persName[@type = 'reg'], 'forename'), <br/>))
                let $place :=
                    for $x in $letter//tei:correspAction[@type = 'sent']/tei:placeName
                    return
                        (collection($edweb:dataRegister)//id($x/@key)/tei:placeName[@type = 'reg']/text(), <br/>)
                let $conjectured :=
                    if (not($letter//tei:text//text()))
                    then (' conjectured')
                    else ()
                let $link :=
                    if ($as)
                    then '../../amtliche-schriften/detail.xql?id='||$letter/@xml:id
                    else '../../briefe/detail.xql?id='||$letter/@xml:id
                return
                    <tr
                        class="clickable-row{$conjectured}"
                        data-href="{$link}">
                        <td class="date">
                        {(:  *** Bugfix. Made XPath more specific. *** :)
                        (: local:viewDate($letter//tei:date) :)
                            local:viewDate($letter//tei:date[parent::tei:correspAction[@type="sent"]])
                        }
                        </td>
                        <td><a
                                class="{$conjectured}"
                                href="{$link}">{$correspondentName}</a></td>
                        <td>{$place}</td>
                    </tr>
            }</table></div>
    return
        if ($table//td)
        then
            ($table)
        else
            ()
};

declare function edwebRegister:viewDocList($docs, $head) {
    let $list :=
    element div {
        element h3 {$head},
        element ul {
            for $doc in $docs
            let $id := $doc/@xml:id
            let $title :=
            typeswitch ($doc)
                case element(tei:bibl)
                    return
                        normalize-space($doc//tei:title/text())
                default
                    return
                        string-join($doc//tei:titleStmt/tei:title/text())
            let $path :=
            if (matches(base-uri($doc), 'Dokumente'))
            then
                '../../themen/detail.xql'
            else
                if (matches(base-uri($doc), 'ART'))
                then
                    '../../reisetagebuecher/detail.xql'
                else
                    if (matches(base-uri($doc), 'Kommentar'))
                    then
                        '../../reisetagebuecher/text.xql'
                    else
                        if (matches(base-uri($doc), 'zotero'))
                        then
                            '../literatur/detail.xql'
                        else
                            ('../../index.xql')
                order by $title
            return
                element li {
                    (<a
                        href="{$path}?id={$id}">{$title}</a>)
                }
        }
    }
    return
        if ($list//li)
        then
            ($list)
        else
            ()
};

declare function edwebRegister:altNames($entry) {
    (if ($entry//tei:persName[@type = "birth" or @subtype = "birthname"]) then
        (
        element ul {
            attribute class {'altNames'},
            element span {'Geburtsname:&#x2002;'},
            let $count := count($entry//tei:persName[@type = "birth" or @subtype = "birthname"])
            for $x at $pos in $entry//tei:persName[@type = "birth" or @subtype = "birthname"]
            let $name := edweb:persName($x, 'forename')
                order by $x/@subtype/data(.),
                    $x/@type/data(.)
            return
                if ($pos = $count)
                then
                    (element li {$name})
                else
                    (element li {$name || '; '})
        })
    else
        (),
    if ($entry//(tei:persName | tei:placeName)[(@type = "alt" and not(@subtype = 'birthname')) or @type = "pseudonym"]) then
        (
        element ul {
            attribute class {'altNames'},
            element span {'Alternative Namen bzw. Schreibungen:&#x2002;'},
            let $count := count($entry//(tei:persName | tei:placeName)[@type = "alt" or @type = "pseudonym"])
            for $x at $pos in $entry//(tei:persName | tei:placeName)[@type = "alt" or @type = "pseudonym"]
            let $name :=
            if ($x[local-name() = 'persName'])
            then
                (edweb:persName($x, 'forename'))
            else
                ($x//text())
                order by $x/@subtype/data(.),
                    $x/@type/data(.)
            return
                if ($pos = $count)
                then
                    (element li {$name})
                else
                    (element li {$name || '; '})
        })
    else
        ())
};

(: AVHR :)
declare function edwebRegister:ptr($ptr) {
    let $number :=
    if ($ptr/@subtype = "comment")
    then
        (concat("[", substring-after($ptr/@target, '#'), "]"))
    else
        (substring-after($ptr/@target, '#'))
    let $string :=
    if ($ptr[@type = 'letter'])
    then
        (concat('Nr. ', $number))
    else
        if ($ptr[@type = 'document'])
        then
            (concat('Dok. ', $number))
        else
            if ($ptr[@type = 'page'])
            then
                (concat('S. ', $number))
            else
                ($number)
    return
        element li {
            if ($ptr/@subtyp = "sentFrom")
            then
                (
                attribute class {'bold'},
                $string
                )
            else
                ($string)
        }

};

declare function edwebRegister:events($id) {
    let $list :=
    <div>
        <h3>Erwähnungen in der Chronologie</h3>
        <ul>{
                for $event in collection($edweb:data)//tei:teiCorpus/tei:TEI[.//@key = $id or .//@sameAs = $id]
                    order by $event//tei:title/tei:date/(@when | @from | @notBefore)
                return
                    <li><a
                            href="../../chronologie/detail.xql?id={$event/@xml:id}">{$event//tei:title/tei:date/text()}</a></li>
            }
        </ul>
    </div>
    
    return
        if ($list//li)
        then
            ($list)
        else
            ()
};

declare function edwebRegister:cleanGeoName($id) {
    let $id := normalize-space($id)
    return
        if (matches($id, 'http://www.geonames.org/\d+/\w+\.html'))
        then
            substring-before(substring-after($id, 'http://www.geonames.org/'), '/')
        else
            if (matches($id, 'http://www.geonames.org/\d+/'))
            then
                substring-before(substring-after($id, 'http://www.geonames.org/'), '/')
            else
                (substring-after($id, 'http://www.geonames.org/'))
};

declare function edwebRegister:getGeoName($id) {
    let $record :=
    if (matches($id, 'http://www.geonames.org'))
    then
        (httpclient:get(xs:anyURI(concat('http://api.geonames.org/get?geonameId=', edwebRegister:cleanGeoName($id), '&amp;username=dumont&amp;style=SHORT')), true(), <headers></headers>)//geoname
        
        )
    else
        if (matches($id, 'http://vocab.getty.edu/tgn/'))
        then
            (doc(concat($id, '.rdf'))//rdf:RDF)
        else
            ()
    let $lat :=
    if (matches($id, 'http://www.geonames.org'))
    then
        ($record//lat/text())
    else
        if (matches($id, 'http://vocab.getty.edu/tgn/'))
        then
            ($record//schema:latitude/text())
        else
            ()
    
    let $lng :=
    if (matches($id, 'http://www.geonames.org'))
    then
        ($record//lng/text())
    else
        if (matches($id, 'http://vocab.getty.edu/tgn/'))
        then
            ($record//schema:longitude/text())
        else
            ()
    
    let $zoomLevel :=
    if ($record//fcl = 'S')
    then
        ('15')
    else
        if ($record//fcl = 'P')
        then
            ('6')
        else
            if ($record//fcode = 'CONT')
            then
                ('1')
            else
                ('4')
    
    let $mapID := substring-after($id, 'http://www.geonames.org/')
    
    let $map :=
    <div>
        <div
            id="map_{$mapID}"
            style="height: 300px;"></div>
        <script>
            var map = L.map('map_{$mapID}').setView([{$lat}, {$lng}], {$zoomLevel});
            L.tileLayer('https://&#123;s&#125;.tile.openstreetmap.org/&#123;z&#125;/&#123;x&#125;/&#123;y&#125;.png', &#123;
            maxZoom: 18,
            attribution: 'Map data © &#60;a href="http://openstreetmap.org"&#62;OpenStreetMap&#60;/a&#62; contributors, ' +
            '&#60;a href="http://creativecommons.org/licenses/by-sa/2.0/"&#62;CC-BY-SA&#60;/a&#62; ',
            id: 'mapbox.streets'
            &#125;).addTo(map);
            
            
            L.marker([{$lat}, {$lng}]).addTo(map)
            
            map.on('click', onMapClick);
        </script>
    </div>
    
    return
        if ($lat and $lng)
        then
            ($map)
        else
            (element p {'[ID wurde in Normdatei nicht gefunden]'})
};

declare function edwebRegister:printReferences($entry, $biblPath) {
    let $volumes := "02,04,05,06,07,0910,12,14,16,19,22,25,26,27,29,30,32,33,34,35,37,39,41,42,43"
    return
        (element h3 {'Nachweise in gedruckten Editionen'},
        element div {
            attribute id {"pageReferences"},
            attribute class {"accordion"},
            for $vol in tokenize($volumes, ',')
            let $bibl := doc($biblPath)//tei:bibl[@xml:id = concat('B', $vol)]
            return
                
                if ($entry/(tei:linkGrp | tei:listRef)//@target/substring-before(., '#') = $vol)
                then
                    (
                    element h4 {$bibl/@n/data(.)},
                    element div {
                        element p {$bibl/text()},
                        element ul {
                            attribute class {'pageReferences'},
                            for $ptr in $entry/(tei:linkGrp | tei:listRef)/tei:ptr[matches(@target, concat($vol, '#'))]
                            return
                                edwebRegister:ptr($ptr)
                        }
                    }
                    )
                else
                    ()
        })
};

declare function edwebRegister:zoteroAuthors($item) {
    string-join(
    for $author at $pos in $item
    let $count := count($item)
    let $name :=
    if ($pos = 1 and $author/firstName/text())
    then
        $author/lastName || ', ' || $author/firstName
    else
        if ($pos = 1 and not($author/firstName/text()))
        then
            $author/lastName
        else
            if ($pos > 1 and $author/firstName/text())
            then
                $author/firstName || ' ' || $author/lastName
            else
                $author/lastName
    return
        if ($pos > 1 and $pos = $count)
        then
            ' und ' || $name
        else
            if ($pos > 1)
            then
                ', ' || $name
            else
                $name)
};

declare function edwebRegister:indexHint($grid) {
    ()
};
