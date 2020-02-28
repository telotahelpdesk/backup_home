xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $p_year := request:get-parameter("jahr", ())
let $p_person := request:get-parameter("person", ())
let $p_category := request:get-parameter("category", ())
let $p_limit := xs:int(request:get-parameter("limit", '20'))
let $p_offset := xs:int(request:get-parameter("offset", '1'))

let $currentCollection :=
    if ($p_category='adk')
    then $edweb:data||'/Amtliche%20Schriften/Akademie%20der%20K%C3%BCnste'
    else if ($p_category='adw')
    then $edweb:data||'/Amtliche%20Schriften/Akademie%20der%20Wissenschaften'
    else if ($p_category='baw')
    then $edweb:data||'/Amtliche%20Schriften/Bauakademie'
    else if ($p_category='mk')
    then $edweb:data||'/Amtliche%20Schriften/Museumskommission'
    else if ($p_category='s')
    then $edweb:data||'/Amtliche%20Schriften/Sonstiges'
    else $edweb:data||'/Amtliche%20Schriften' 

let $docs := 
    if ($p_year and $p_person) 
    then collection($currentCollection)//tei:TEI[ft:query(.//(tei:correspAction[@type='sent']|tei:creation)/(tei:persName|tei:orgName)/@key, $p_person) and ft:query(.//(tei:correspAction[@type='sent']|tei:creation)/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>)]
        else if ($p_person) 
        then collection($currentCollection)//tei:TEI[ft:query(.//(tei:correspAction[@type='sent']|tei:creation)/(tei:persName|tei:orgName)/@key, $p_person)]
             else if ($p_year) 
             then collection($currentCollection)//tei:TEI[ft:query(.//(tei:correspAction[@type='sent']|tei:creation)/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>)] 
                else collection($currentCollection)//tei:TEI

let $correspondents :=
    if ($p_year)
    then (collection($currentCollection)//tei:TEI[ft:query(.//(tei:correspAction[@type='sent']|tei:creation)/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>)]//tei:correspAction/(tei:persName|tei:orgName)/@key/data(.))
    else (collection($currentCollection)//tei:TEI//(tei:correspAction[@type='sent']|tei:creation)/(tei:persName|tei:orgName)/@key/data(.))        

let $sortedResult :=
    element list {
        for $x in $docs
        order by edweb:defaultOrderBy($x)
        return
        $x 
    }

let $resultCount := count($sortedResult//tei:TEI)
    
let $lettersList := 
    for $x in subsequence($sortedResult//tei:TEI, $p_offset, $p_limit)
    return
        <div class="box whitebox">
            <div class="boxInner index">
            <a href="detail.xql?id={$x/@xml:id}&amp;view={$edweb:p_view}">
                <h2>{
                    if ($x//tei:correspDesc) 
                    then edweb:letterTitle($x//tei:titleStmt)
                    else $x//tei:titleStmt/tei:title/text()}
                    </h2>
                {if ($x//tei:body//text() or $x//tei:abstract//text())
                then (
                    if ($x//tei:abstract//text())
                    then (<p class="summary">{transform:transform($x//tei:abstract, doc('../resources/xslt/transcr-teaser.xsl'), ())}</p>)
                    else (<p>{substring(transform:transform($x//tei:body/tei:div[1]//tei:p, doc('../resources/xslt/transcr-teaser.xsl'), ()), 1, 300)} [...]</p>))                else ()}
            </a>
            </div>
        </div>

let $categories := 
    map {
        'adk' : 'Akademie der Künste',
        'adw' : 'Akademie der Wissenschaften',
        'baw' : 'Bauakademie',
        'mk' : 'Museumskomission',
        's' : 'Sonstiges'
        }


let $available-categories :=
    distinct-values(
    for $doc in $docs
    let $category := 
        substring-before(substring-after(base-uri($doc), 'Schriften/'), '/')       
    return
    $category)
    
let $filterCategories :=
    <div class="box graybox filter jahre"><div class="boxInner"><h3>Nach Kategorie filtern</h3>
    <form action="index.xql">
        <select name="category" onchange="this.form.submit()">
            <option value="">Alle</option>
            {for $category in map:keys($categories)
            order by $category
            return
            if ($category=$p_category)
            then <option selected="selected" value="{$category}">{$categories($category)}</option>
            else if (($p_person or $p_year) and encode-for-uri($categories($category))!=$available-categories)
            then () 
            else <option value="{$category}">{$categories($category)}</option>}
        </select>
     {if ($p_person) then <input type="hidden" name="person" value="{$p_person}"/> else (),
      if ($p_year) then <input type="hidden" name="jahr" value="{$p_year}"/> else ()}
     </form>
     </div></div>

let $filterYearsQuery :=
    if ($p_person)
    then ('distinct-values($docs//tei:correspDesc[.//@key=$p_person]//tei:date/(@when|@from|@notBefore)/substring(., 1, 4))')
    else ('distinct-values($docs//tei:correspDesc//tei:date/(@when|@from|@notBefore)/substring(., 1, 4))')

let $filterYears := 
    <div class="box graybox filter jahre"><div class="boxInner"><h3>Nach Chronologie filtern</h3><ul id="filter_jahre">
    {   for $year in util:eval($filterYearsQuery)
        order by $year
        return
        if ($year=$p_year)
        then (<li class="current"><a href="index.xql?person={$p_person}">{$year}</a></li>)
        else (<li><a href="index.xql?jahr={$year}&amp;person={$p_person}">{$year}</a></li>)}
     </ul><hr class="clear" /></div></div>     

let $filterPersons := 
    <div class="box graybox filter personen"><div class="boxInner"><h3>Nach Verfasser filtern</h3><ul id="filter_personen"> 
    {
       for $person in collection($edweb:dataRegister)//tei:*[@xml:id/data(.)=$correspondents]
       let $name :=
            if ($person/tei:orgName)
            then $person/tei:orgName[@type='reg']/text()
            else edweb:persName($person/tei:persName[@type='reg'], 'surname')
       let $id := $person/@xml:id/data(.)
       order by $name
       return 
          if ($id=$p_person) 
          then (<li class="current"><a href="index.xql?jahr={$p_year}">{$name}</a></li>)
          else (<li><a href="index.xql?person={$id}&amp;jahr={$p_year}">{$name}</a></li>)
    }
    </ul></div></div>

let $h1 := 
    if ($p_year and $p_person) 
    then (<h1>Übersicht der amtlichen Schriften <br/>mit {edweb:persName(collection($edweb:dataRegister)//tei:person[@xml:id=$p_person]/tei:persName[@type='reg'], 'forename')} im Jahr {$p_year}</h1>)
    else if ($p_year) 
    then (<h1>Übersicht der amtlichen Schriften im Jahr {$p_year}</h1>)
        else if ($p_person) 
        then (<h1>Übersicht der amtlichen Schriften <br />mit {edweb:persName(collection($edweb:dataRegister)//tei:person[@xml:id=$p_person]/tei:persName[@type='reg'], 'forename')}</h1>)
            else (<h1>Übersicht der amtlichen Schriften</h1>)                      

let $xslt_input :=  <transferContainer>
                        <div class="outerLayer" id="header">
                            <header class="container_16">
                                <div class="grid_15">
                                    {$h1}
                                </div>
                            </header>
                        </div>
                        <div class="outerLayer" id="content">
                            <div class="container_16">
                                <div class="grid_11">
                                    {if ($lettersList) 
                                    then (edweb:pagination($p_limit, $p_offset, $resultCount, 'yes'), $lettersList, edweb:pagination($p_limit, $p_offset, $resultCount, 'no'))
                                    else (<div class="notfound"><p>Für diese Auswahl konnten keine Briefe in der Datenbank gefunden werden.<br/>Wählen Sie rechts ein anderes Jahr oder eine andere Person aus.</p></div>)}
                                </div>
                                <div class="grid_5">
                                    {$filterCategories}
                                    {$filterYears}
                                    {$filterPersons}
                                </div>
                           </div>
                        </div>
                    </transferContainer>

let $output := transform:transform(
                $xslt_input, 
                doc($edweb:html), 
                <parameters>
                    <param name="currentSection" value="amtliche-schriften" />
                    <param name="pageTitle" value="{$h1/h1/text()}" />
                    <param name="baseURL" value="{$edweb:baseURL}" />
                </parameters>)

return 
$output