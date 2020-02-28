xquery version '3.0';

module namespace edweb="http://www.bbaw.de/telota/ediarum/web";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $edweb:config := doc('../../webconfig.xml');

(: Globale URL Parameter :)
declare variable $edweb:p_id := request:get-parameter("id", ());
declare variable $edweb:p_view := request:get-parameter("view", "k");
declare variable $edweb:p_searchTerms := request:get-parameter('searchTerms', ());
declare variable $edweb:p_version := request:get-parameter('v', ());

(: Interne oder externe Umgebung: ja/nein :)
declare variable $edweb:intern :=
    if ($edweb:config//intern/text()='yes')
    then (true())
    else (false());

(: BaseURL der Website :)
declare variable $edweb:baseURL := 
    if ($edweb:intern) 
    then ($edweb:config//web/baseurl[@type='intern']/text())
    else ($edweb:config//web/baseurl[@type='public']/text());

(: Verzeichnispfade :)
declare variable $edweb:data := $edweb:config//directory[@type='data']/text();
declare variable $edweb:dataLetters := $edweb:data;
declare variable $edweb:dataDiaries := concat($edweb:data, '/Tageskalender');
declare variable $edweb:dataLectures := concat($edweb:data, '/Vorlesungen');
declare variable $edweb:dataCommentary := $edweb:data||$edweb:config//directory[@type='commentary']/text();
declare variable $edweb:dataRegister := concat($edweb:data, '/Register');
declare variable $edweb:dataRegisterPersons := concat($edweb:dataRegister, '/Personen.xml');
declare variable $edweb:dataRegisterWorks := concat($edweb:dataRegister, '/Werke.xml');
declare variable $edweb:dataRegisterPlaces := concat($edweb:dataRegister, '/Orte.xml');
declare variable $edweb:dataExternal := $edweb:config//directory[@type='external_data']/text();
declare variable $edweb:dataCab := $edweb:dataExternal||'/dta-cab';
declare variable $edweb:dataZotero := $edweb:dataExternal||'/zotero';







(: Web :)
declare variable $edweb:webDir := $edweb:config//directory[@type='web'];
declare variable $edweb:apiDir := concat($edweb:webDir, '/api');
declare variable $edweb:html := concat($edweb:webDir, '/resources/xslt/html.xsl');
declare variable $edweb:htmlHeader := concat($edweb:webDir, '/resources/xslt/header.xsl');
declare variable $edweb:htmlContent := concat($edweb:webDir, '/resources/xslt/content.xsl');
declare variable $edweb:websiteTitle := $edweb:config//web/websiteTitle/text();

(: Caches :)
declare variable $edweb:cacheLetterIndex := concat($edweb:webDir, '/briefe/resources/letterIndex.xml');

(: CMIF :)
declare variable $edweb:permanentURLLetters := concat($edweb:baseURL, '/brief/id/'); 
declare variable $edweb:cmifCache := $edweb:config//api/cmif/cacheduration/text(); (: xs:dayTimeDuration :)

(: Versions :)
declare variable $edweb:archive := $edweb:config//directory[@type='archive']/text();
declare variable $edweb:versions := $edweb:config//versions;
declare variable $edweb:currentVersionNr := max($edweb:versions//version/@n); 
declare variable $edweb:currentVersionDate := format-date($edweb:versions//version[@n=$edweb:currentVersionNr]/@when/data(.), '[D01].[M01].[Y0001]');
declare variable $edweb:thisVersionNr := 
    if ($edweb:p_version)
    then (
        if ($edweb:p_version=$edweb:config//version/@n)
        then ($edweb:p_version)
        else ())
    else ($edweb:currentVersionNr);
declare variable $edweb:thisVersionDate := format-date($edweb:config//version[@n=$edweb:thisVersionNr]/@when/data(.), '[D01].[M01].[Y0001]');
declare variable $edweb:purl := $edweb:baseURL||'/v'||$edweb:thisVersionNr||'/'||$edweb:p_id;
declare variable $edweb:canonicalURL := $edweb:baseURL||'/'||$edweb:p_id;

(: BEACONS :)
(: Used Authority Controlled Files :)
declare variable $edweb:authorities :=
    map:new(
       for $authority in $edweb:config//authorities/authority 
       return
           map:entry($authority/@name/data(.), $authority/@prefix/data(.))
    );
declare variable $edweb:defaultAuthority := $edweb:config//authority[@default='true']/@name/data(.);
declare variable $edweb:beaconDir := concat($edweb:webDir, '/register/personen/beacon');

declare variable $edweb:beacons := $edweb:config//beacons; 
    
(: Zentrales Login für alle Skripte :)
declare function edweb:login(){
    xmldb:login($edweb:data, 'admin', '7LC4J3qMcs9XTtzdyxHogKjEuXbjh7t3')
};

declare function edweb:getDoc($id) {
    let $searchTerms :=
        <query>{
            for $term in $edweb:p_searchTerms
            return
            <bool><term>{$term}</term></bool>
        }</query>
        
    return        
    if ($edweb:p_searchTerms!='')
    then 
        (if (collection($edweb:data)//tei:TEI[@xml:id=concat($edweb:p_id, '')][ft:query(.//tei:text, $searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)])
        then (kwic:expand(collection($edweb:data)//tei:TEI[@xml:id=concat($edweb:p_id, '')][ft:query(.//tei:text, $searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)]))
        else (collection($edweb:data)//tei:TEI[@xml:id=concat($edweb:p_id, '')]))
    else if ($edweb:p_version) 
    then (
        if ($edweb:p_version=$edweb:versions//@n)
        then collection($edweb:archive||'/v'||$edweb:p_version)//tei:TEI[@xml:id=concat($edweb:p_id, '')]
        else ()) 
    else (collection($edweb:data)//tei:TEI[@xml:id=concat($edweb:p_id, '')])
};

declare function edweb:defaultOrderBy($brief){ 
                if ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date/@when) 
                then ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date[1]/@when)
                else ( 
                    if ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date/@from) 
                    then ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date[1]/@from)
                    else if ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date/@notBefore)
                        then ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date[1]/@notBefore)
                        else ($brief/@xml:id)
                )
};

declare function edweb:pageTitle($doc, $pageTitlePosition as xs:string) {
    let $pageTitle :=
        typeswitch($doc)
        case element(tei:TEI) return (
            if ($doc//tei:author)
            then (
                string-join(
                for $author in $doc//tei:author/tei:persName
                return
                edweb:persName($author/text(), 'surname'),
                ": "||
                string-join($doc//tei:titleStmt/tei:title[@type='main']/text()))
            )
            else if ($doc//tei:creation/tei:persName)
            then (
                for $key in $doc//tei:creation/tei:persName/@key
                return
                edweb:persName(collection($edweb:dataRegister)//tei:person[@xml:id=$key]/tei:persName[@type='reg'], 'surname'),
                ': ',
                string-join($doc//tei:titleStmt/tei:title/text())
            )
            else ($doc//tei:titleStmt/tei:title)
         )
         case element(tei:person) return (
            edweb:persName($doc//tei:persName[@type='reg'], 'surname')
         )
         case element(tei:org) return (
            $doc//tei:orgName[@type='reg']/text()
         )
         case element(tei:place) return (
            $doc//tei:placeName[@type='reg']/text()
         )
         case xs:string return $doc
         default return ()
    return
    if ($pageTitle!='' and $pageTitlePosition='first')
    then (string-join($pageTitle)||' – '||$edweb:websiteTitle)
    else if ($pageTitle!='' and $pageTitlePosition='last')
    then ($edweb:websiteTitle||' – '||string-join($pageTitle))
    else if ($pageTitle!='' and $pageTitlePosition='alone')
    then ($pageTitle)
    else ($edweb:websiteTitle)
};



declare variable $edweb:transformParams :=
   (<param name="baseURL" value="{$edweb:baseURL}" />,
    <param name="canonicalURL" value="{$edweb:canonicalURL}"/>,
    <param name="searchTerms" value="{$edweb:p_searchTerms}" />);

declare function edweb:transformHTML($input, $currentSection, $pageTitle as item()?) {
    transform:transform(
        $input, 
        doc($edweb:html), 
        <parameters>
            <param name="pageTitle" value="{edweb:pageTitle($pageTitle, 'alone')}" />
            <param name="currentSection" value="{$currentSection}" />
            {$edweb:transformParams}
        </parameters>
    )
};

declare function edweb:transformHTML($header, $content, $currentSection, $pageTitle) {
    transform:transform(
        <transferContainer>
            {transform:transform($header, doc($edweb:htmlHeader), ()),
            transform:transform($content, doc($edweb:htmlContent), ())}        
        </transferContainer>, 
        doc($edweb:html), 
        <parameters>
            <param name="pageTitle" value="{$pageTitle}" />
            <param name="currentSection" value="{$currentSection}" />
            {$edweb:transformParams}
        </parameters>
    )
};




declare function edweb:pagination($p_limit, $p_offset, $resultCount, $showCount) {
    
    let $numberOfPages := xs:int(ceiling($resultCount div $p_limit))
    let $URLqueryString := replace(request:get-query-string(), '&amp;offset=\d\d?\d?\d?', '')
    
    let $showCount := 
        if ($showCount='yes')
        then (true())
        else (false())
    
    let $labels :=
        map { 
            "noResult" := 1,
            "of" := 2
        }
        
    let $pageSelectBox :=
        element select {
            attribute onchange { 'location = this.options[this.selectedIndex].value;'},
            if ($numberOfPages = 1)
            then (attribute disabled {'disabled'} )
            else (),
            for $x in (1 to $numberOfPages)
            return
            if ($x = ceiling($p_offset div $p_limit))
            then (element option { attribute selected { '' }, attribute value { concat('?', $URLqueryString, '&amp;offset=', ((($x - 1) * $p_limit) + 1)) }, $x })
            else (element option { attribute value { concat('?', $URLqueryString, '&amp;offset=', ((($x - 1) * $p_limit) + 1)) }, $x })
        }

    let $pagination :=
        element span {
            attribute class { 'pageBrowser' },
            if ($pageSelectBox//option[@selected]/preceding-sibling::option)
            then (
                element a { attribute href { $pageSelectBox//option[@selected]/preceding-sibling::option[last()]/@value }, <i class="fa fa-angle-double-left"><span class="hidden">first</span></i> },
                element a { attribute href { $pageSelectBox//option[@selected]/preceding-sibling::option[1]/@value }, <i class="fa fa-angle-left"><span class="hidden">prev</span></i> }
            )
            else (
                <i class="fa fa-angle-double-left"><span class="hidden">first</span></i>,
                <i class="fa fa-angle-left"><span class="hidden">prev</span></i>
            ),
            $pageSelectBox,
            if ($pageSelectBox//option[@selected]/following-sibling::option)
            then (
                element a { attribute href { $pageSelectBox//option[@selected]/following-sibling::option[1]/@value }, <i class="fa fa-angle-right"><span class="hidden">next</span></i> },
                element a { attribute href { $pageSelectBox//option[@selected]/following-sibling::option[last()]/@value }, <i class="fa fa-angle-double-right"><span class="hidden">last</span></i> })
            else (
                <i class="fa fa-angle-right"><span class="hidden">next</span></i>,
                <i class="fa fa-angle-double-right"><span class="hidden">last</span></i>
            )
        }
    
    let $resultCounter :=
        if ($showCount)
        then (
            if ($resultCount = 0)
                then ($labels('noResult'))
                else (
                    if ($resultCount <= $p_limit)
                    then (element span { attribute class {'resultcount'}, concat($resultCount, ' Treffer') })
                    else (
                        if ($pagination//select/option[position()=last()]/@selected)
                        then (element span { attribute class {'resultcount'}, concat('Treffer ', $p_offset, '-', $resultCount, ' von ', $resultCount) } )
                        else (element span { attribute class {'resultcount'}, concat('Treffer ', $p_offset, '-', ($p_offset + $p_limit - 1), ' von ', $resultCount)} )
                    )
                )
         ) else ()
    
    return
    element div {
        attribute class {'pageNav'},
        $resultCounter,
        $pagination
    }
};

declare function edweb:letterTitle($titleStmt) {
    let $idno :=
        if ($titleStmt//tei:idno/text())
        then (<span class="idno">{concat($titleStmt//tei:idno/text(), '. ')}</span>)
        else ()
    return
    concat($idno, string-join($titleStmt/tei:title/text()))
};

declare function edweb:persName($persName, $rendFirst) {
    if ($persName/tei:name) 
    then ($persName/tei:name/text())
    else (
        if ($rendFirst='surname')
        then (
            if ($persName/tei:forename/text())
            then (concat($persName/tei:surname/text(), ', ', $persName/tei:forename/text()))
            else ($persName/tei:surname/text()))
        else (
            if ($persName/tei:forename/text())
            then (concat($persName/tei:forename/text(), ' ', $persName/tei:surname/text()))
            else ($persName/tei:surname/text())
        )
    )
};

declare function edweb:persNameLink($persName, $rendFirst) {
     if ($persName/@key)
     then (
        element a {
            attribute href { $edweb:baseURL||'/register/personen/detail.xql?id='||$persName/@key},
            edweb:persName($persName, $rendFirst)
        })
    else (edweb:persName($persName, $rendFirst))
};

declare function edweb:seperator($input, $seperator) {
    if ($input)
    then (concat($seperator, ' ', string-join($input)))
    else ()
};

declare function edweb:seperator($input, $seperator) {
    if ($input)
    then (concat($seperator, ' ', string-join($input)))
    else ()
};

declare function edweb:substring-afterlast($string as xs:string, $cut as xs:string){
  if (matches($string, $cut))
    then edweb:substring-afterlast(substring-after($string,$cut),$cut)
  else $string
};

declare function edweb:substring-beforelast($string as xs:string, $cut as xs:string){
  if (matches($string, $cut))
    then substring($string,1,string-length($string)-string-length(edweb:substring-afterlast($string,$cut))-string-length($cut))
  else $string
};

declare function edweb:citRer($doc) {
    let $author :=
        if ($doc//tei:titleStmt/tei:author)
        then (
            string-join(
            for $author in $doc//tei:author/tei:persName
            return
            edweb:persName($author, 'surname'))
            ||': '
        ) else if (not($doc//tei:correspDesc) or $doc//tei:creation/tei:persName/@key) 
        then (
            string-join(
            for $key in $doc//tei:creation/tei:persName/@key
            return
            edweb:persName(collection($edweb:dataRegister)//tei:person[@xml:id=$key]/tei:persName[@type='reg'], 'surname'))
            ||': ')
        else ()
    let $docTitle :=
        if ($doc//tei:titleStmt/tei:title/@type='main')
        then ($doc//tei:titleStmt/tei:title[@type='main']/text())
        else (string-join($doc//tei:titleStmt/tei:title/text()))
    let $editors :=
        if ($doc//tei:titleStmt/tei:editor)
        then (
            ' hg. v. '||
            string-join(
            for $editor at $pos in $doc//tei:titleStmt/tei:editor
            let $max := count($doc//tei:titleStmt/tei:editor)
            return
            if ($pos > 1 and $pos = $max)
            then ' und '||edweb:persName($editor/tei:persName, 'forename')
            else if ($pos > 1) 
            then ', '||edweb:persName($editor/tei:persName, 'forename')
            else edweb:persName($editor/tei:persName, 'forename'))
        ) else ()
    let $collaboration :=
        if ($doc//tei:respStmt//tei:note='Mitarbeit')
        then (
            ' unter Mitarbeit von '||
            string-join(
            for $col at $pos in $doc//tei:respStmt[.//tei:note='Mitarbeit']/tei:persName
            let $max := count($doc//tei:respStmt[.//tei:note='Mitarbeit']/tei:persName)
            return
            if ($pos > 1 and $pos = $max)
            then ' und '||edweb:persName($col, 'forename')
            else if ($pos > 1) 
            then ', '||edweb:persName($col, 'forename')
            else edweb:persName($col, 'forename'))
        ) else ()      
    return
    element citRec {
        $author||$docTitle||$editors||$collaboration||'. In: '||$edweb:config//citRec/title||', hg. v. '||$edweb:config//citRec/editor||'. '||$edweb:config//citRec/publisher||', '||$edweb:config//citRec/pubPlace||'. Version '||$edweb:thisVersionNr||' vom '||$edweb:thisVersionDate||'. URL: ',
        <a href="{$edweb:purl}">{$edweb:purl}</a>,
        <hr />,
        <h3>Download</h3>,
        <a href="{$edweb:baseURL||'/api/v1/tei-xml.xql?id='||$edweb:p_id}"><i class="fa fa-download"></i> Dieses Dokument als TEI-XML herunterladen</a>
    }
};  

declare function edweb:archivedVersions() {
    if (collection($edweb:archive)//@xml:id=$edweb:p_id)
    then (
        element ul {
        attribute class {'versions'},
        for $version in collection($edweb:archive)//tei:TEI[@xml:id=$edweb:p_id]
        let $vnr := substring-before(substring-after(base-uri($version), '/archive/v'), '/')
        let $date := format-date($edweb:versions//version[@n=$vnr]/@when/data(.), '[D01].[M01].[Y0001]')
        return
        <li><a href="detail.xql?id={$edweb:p_id}&amp;v={$vnr}">Version {$vnr} vom {$date}</a></li>}
    )
    else (),
    edweb:alertArchivedVersion()
};

declare function edweb:alertArchivedVersion() {
    if (xs:double($edweb:thisVersionNr) < $edweb:currentVersionNr)
    then (
        element alert {
            <i class="fa fa-exclamation-triangle">&#160;</i>,
            'Achtung! Bei diesem Dokument handelt es sich um die archivierte Version '||$edweb:currentVersionNr||' vom '||$edweb:thisVersionDate||'. Zur aktuellen Version '||$edweb:currentVersionNr||' vom '||$edweb:currentVersionDate||' gelangen Sie ',
            <a href="detail.xql?id={$edweb:p_id}">hier</a>,'.' 
        }
    )
    else ()
};


declare function edweb:viewMarkup($nodes as node()*) {
    (: SD, 2019-05-24: Aus edwebMeta hierher überführt zwecks Nachnutzung für Abstract-Darstellung :)
    for $node in $nodes
    return
    typeswitch($node)
        case element(tei:p)
            return
            element p {
                edweb:viewMarkup($node/node())
            }
        case element(tei:quote)
            return
            element span {
                attribute class { 'quote' },
                '„',edweb:viewMarkup($node/node()),'”'
            }
        case element(tei:persName) 
            return
            element a { 
                attribute href { $edweb:baseURL||'/register/personen/detail.xql?id='||$node/@key||'&amp;l='||$edweb:p_language },
                edweb:viewMarkup($node/node())
            }
        case element(tei:placeName) 
            return
            element a { 
                attribute href { $edweb:baseURL||'/register/orte/detail.xql?id='||$node/@key||'&amp;l='||$edweb:p_language },
                edweb:viewMarkup($node/node())
            }
        case element(tei:orgName) 
            return
            element a { 
                attribute href { $edweb:baseURL||'/register/einrichtungen/detail.xql?id='||$node/@key||'&amp;l='||$edweb:p_language },
                edweb:viewMarkup($node/node())
            }            
        case element(tei:bibl)
            return
            if ($node/@sameAs)
            then 
                (element a {
                    attribute href { '../register/literatur/detail.xql?id='||$node/@sameAs||'&amp;l='||$edweb:p_language },
                    if (matches($node/text(), ',')) then substring-before($node/text(), ',') else $node/text() },
                    if (matches($node/text(), ',')) then ', '||substring-after($node/text(), ',') else ())
            else (edweb:viewMarkup($node/node()))
        case element(tei:ref)
            return
            if (matches($node/@target, 'H\d{7}'))
            then element a {
                    attribute href { $edweb:baseURL||'/redirect.xql?id='||$node/@target/data(.) },
                    edweb:viewMarkup($node/node())}
            else if (matches($node/@target, '^http'))
            then element a {
                    attribute href { $node/@target/data(.) },
                    edweb:viewMarkup($node/node())}
            else if ($node/@type='siglum')
            then element a {
                    attribute href { $edweb:baseURL||'/register/siglen/index.xql'||$node/@target/data(.) },
                    edweb:viewMarkup($node/node())}                    
            else edweb:viewMarkup($node/node())
        case element(tei:hi)
            return
            if($node/@rendition='#i')
            then <i>{edweb:viewMarkup($node/node())}</i>
            else edweb:viewMarkup($node/node())            
        case text() 
            return $node
        default 
            return edweb:viewMarkup($node/node())
};

(: SD NEU 04/2019:)

declare function local:is-leap-year($year as xs:string) as xs:boolean {
    let $year := number($year)
    let $is-div-4 := not(matches(xs:string($year div 4), '\.'))
    let $is-not-century := not(matches(xs:string($year), '\d\d00'))
    let $is-century-div-400 := not(matches(xs:string($year div 400), '\.')) 

    return
    if ($is-div-4 and ($is-not-century or $is-century-div-400))
    then true()
    else false()
};

declare function local:validate-date($date as xs:string) as xs:boolean {
    let $year := substring-before($date, '-')
    let $month :=
        if (matches($date, '\d\d\d\d-\d\d-\d\d'))
        then substring-before(substring-after($date, '-'), '-')
        else substring-after($date, '-')
    let $day := 
        if (matches($date, '\d\d\d\d-\d\d-\d\d'))
        then substring-after(substring-after($date, '-'), '-')
        else ()

    let $base-pattern := '^(\d\d\d\d)(-\d\d)?(-\d\d)?$'
    let $year-regex := '^[0|1|2][0-9]{3}$'
    let $month-regex := '((0[1-9])|(1[0|1|2]))$'    
    let $day-regex :=
        if (matches($month, '(01|03|05|07|08|10|12)'))
        then '(0[1-9]|[1|2][0-9]|[30-31])'
        else if (matches($month, '(04|06|09|11)'))
        then '(0[1-9]|[1|2][0-9]|30)'
        else if (matches($month, '02') and local:is-leap-year($year))
        then '(0[1-9]|[1|2][0-9])'
        else if (matches($month, '02'))
        then '(0[1-9]|1[0-9]|2[0-8])'
        else ()
        
    let $year-test :=
        if ($year)
        then matches($year, $year-regex)
        else (false())
    let $month-test :=
        if ($month)
        then matches($month, $month-regex)
        else true()
    let $day-test :=
        if ($day)
        then matches($day, $day-regex)
        else true()
    return
    if (matches($date, $base-pattern))
    then
        if ($year-test and $month-test and $day-test)
        then true()
        else false()
    else false()
};

declare function local:format-date($date as xs:string) as xs:string {
    let $year-month-day-regex := '[0|1|2][0-9]{3}-((0[1-9])|(1[0|1|2]))-(0[1-9]|[1|2][0-9]|[30-31])'
    let $year-month-regex := '^[0|1|2][0-9]{3}-((0[1-9])|(1[0|1|2]))$'
    let $year-regex := '^[0|1|2][0-9]{3}$'
    return
    if (local:validate-date($date))
    then
        if (matches($date, $year-month-day-regex))
        then format-date($date, '[D01].[M01].[Y0001]')
        else if (matches($date, $year-month-regex))
        then format-date($date, '[M01].[Y0001]') 
        else if (matches($date, $year-regex))
        then format-date($date, '[Y0001]')
        else ($date||' (?)')
    else ('Invalid date: '||$date)
};

declare function edweb:viewDate($dates) {
    for $date at $pos in $dates
    let $formatted-date :=
        if ($date/@when)
        then (local:format-date($date/@when))
            else if ($date/@from and $date/@to)
            then (local:format-date($date/@from)||' &#x2013; '||local:format-date($date/@to))
                else if ($date/@notBefore and $date/@notAfter)
                then ('nach '||local:format-date($date/@notBefore)||' &#x2013; vor '||local:format-date($date/@notAfter))
                else ()
    return
    if ($pos = 1)
    then ($formatted-date)
    else (<br/>,$formatted-date)
};