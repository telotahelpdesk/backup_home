xquery version "3.0"; 

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../register/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $p_year := request:get-parameter("jahr", ())
let $p_person := request:get-parameter("person", ())
let $p_options := request:get-parameter("options", ())
let $p_no-regests := lower-case(request:get-parameter("no-regests", ()))
let $p_marx-engels-only := lower-case(request:get-parameter("marx-engels-only", ()))

let $p_file := request:get-parameter("akte", ())
let $p_limit := xs:int(request:get-parameter("limit", '40'))
let $p_offset := xs:int(request:get-parameter("offset", '1'))



let $currentCollection :=
                    if ($p_year and $p_person) 
                     then collection($edweb:dataLetters)//tei:TEI[ft:query(.//tei:correspAction/(tei:persName|tei:orgName)/@key, $p_person) and ft:query(.//tei:correspAction/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>) and @telota:doctype='letter mega']
                        else if ($p_person) 
                        then collection($edweb:dataLetters)//tei:TEI[ft:query(.//tei:correspAction/(tei:persName|tei:orgName)/@key, $p_person) and @telota:doctype='letter mega']
                             else if ($p_year) 
                             then collection($edweb:dataLetters)//tei:TEI[ft:query(.//(tei:correspAction|tei:creation)/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>) and @telota:doctype='letter mega' and not(.//tei:correspDesc/tei:note/tei:ref[@type='attachedTo'])] 
                                else (collection($edweb:dataLetters)//tei:TEI[@telota:doctype='letter mega' and not(.//tei:correspDesc/tei:note/tei:ref[@type='attachedTo'])])

let $filteredCollectionNoRegests :=
    if ($p_no-regests = 'true')
    then $currentCollection[descendant::tei:idno[@type="shelfmark"]/text()]
    else $currentCollection

let $filteredCollection :=
    if ($p_marx-engels-only = 'true')
    then $filteredCollectionNoRegests[descendant::tei:correspAction/tei:persName/@key='ed_ats_ysj_wx' and descendant::tei:correspAction/tei:persName/@key='ed_eyg_crj_sx']
    else $filteredCollectionNoRegests

let $correspondents :=
    if ($p_year)
    then (collection($edweb:dataLetters)//tei:TEI[.//tei:correspAction/tei:persName and ft:query(.//tei:correspAction/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>)]//tei:correspAction/tei:persName/@key/data(.))
    else (collection($edweb:dataLetters)//tei:TEI[.//tei:correspAction/(tei:persName|tei:orgName)]//tei:correspAction/(tei:persName|tei:orgName)/@key/data(.))        

let $sortedResult :=
    element list {
        for $x in $filteredCollection
        order by edweb:defaultOrderBy($x)
        return
        $x 
    }

let $resultCount := count($sortedResult//tei:TEI)
    
let $lettersList := 
    <div class="box whitebox">
            <div class="boxInner index">
            {edwebRegister:viewLetterTableIndex(
        for $brief in subsequence($sortedResult//tei:TEI[@telota:doctype='letter mega'], $p_offset, $p_limit)
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        '')}
        </div></div>
     
let $filterYearsQuery :=
    if ($p_person and $p_year)
    then ('distinct-values(collection($edweb:dataLetters)//tei:correspDesc[.//@key=$p_person]//tei:date/(@when|@from|@notBefore)/substring(., 1, 4))')
    else ('distinct-values(collection($edweb:dataLetters)//tei:correspDesc//tei:date/(@when|@from|@notBefore)/substring(., 1, 4))')

let $filterYears := 
    <div class="box graybox filter jahre"><div class="boxInner"><h3>Nach Chronologie filtern</h3><ul id="filter_jahre">
    {   for $year in util:eval($filterYearsQuery)
        order by $year
        return
        if ($year=$p_year)
        then (<li class="current"><a href="index.xql?person={$p_person}&amp;marx-engels-only={$p_marx-engels-only}&amp;no-regests={$p_no-regests}">{$year}</a></li>)
        else (<li><a href="index.xql?jahr={$year}&amp;person={$p_person}&amp;marx-engels-only={$p_marx-engels-only}&amp;no-regests={$p_no-regests}">{$year}</a></li>)}
     </ul><hr class="clear" /></div></div>     

let $filterOptions :=
    <div class="box graybox filter options">
        <div class="boxInner">
            <h3>Optionen</h3>
            <ul id="filter_auswahl">
                {
                if ($p_marx-engels-only='true')
                    then (<li class="current"><a href="index.xql?jahr={$p_year}&amp;no-regests={$p_no-regests}">Nur Briefwechsel Marx-Engels zeigen</a></li>)
                    else (<li><a href="index.xql?jahr={$p_year}&amp;marx-engels-only=true&amp;no-regests={$p_no-regests}">Nur Briefwechsel Marx-Engels zeigen</a></li>)
                }
                {
                if ($p_no-regests='true')
                    then (<li class="current"><a href="index.xql?person={$p_person}&amp;jahr={$p_year}&amp;marx-engels-only={$p_marx-engels-only}">Nur überlieferte Briefe anzeigen</a></li>)
                    else (<li><a href="index.xql?person={$p_person}&amp;jahr={$p_year}&amp;no-regests=true&amp;marx-engels-only={$p_marx-engels-only}">Nur überlieferte Briefe anzeigen</a></li>)
                }
            </ul>
        </div>
    </div>

let $filterPersons := 
    <div class="box graybox filter personen"><div class="boxInner"><h3>Nach Korrespondenzpartner filtern</h3><ul id="filter_personen"> 
    {
       for $person in (collection($edweb:dataRegister)//tei:person[@xml:id/data(.)=$correspondents] | doc($edweb:dataRegisterOrgs)//tei:org[@xml:id/data(.)=$correspondents])
       let $name := 
            if (boolean($person/tei:persName[@type='reg']))
            then (edweb:persName($person/tei:persName[@type='reg'], 'surname'))
            else ($person/tei:orgName[@type='reg'])
       let $id := $person/@xml:id/data(.) 
       order by $name
       return 
          if ($id=$p_person) 
          then (<li class="current"><a href="index.xql?jahr={$p_year}&amp;marx-engels-only={$p_marx-engels-only}&amp;no-regests={$p_no-regests}">{$name}</a></li>)
          else (<li><a href="index.xql?person={$id}&amp;jahr={$p_year}&amp;no-regests={$p_no-regests}">{$name}</a></li>)
    }
    </ul></div></div>

let $correspondent_label:=
    if ((collection($edweb:dataRegister)//tei:person[@xml:id=$p_person]/tei:persName[@type='reg']))
    then (edweb:persName(collection($edweb:dataRegister)//tei:person[@xml:id=$p_person]/tei:persName[@type='reg'], 'forename'))
    else (doc($edweb:dataRegisterOrgs)//tei:org[@xml:id=$p_person]/tei:orgName[@type='reg'])

let $h1 := 
    if ($p_year and $p_person)
    then (<h1>Briefwechsel insgesamt <br/>mit {$correspondent_label} im Jahr {$p_year}</h1>)
    else if ($p_year) 
    then (<h1>Briefwechsel insgesamt im Jahr {$p_year}</h1>)
        else if ($p_person) 
        then (<h1>Briefwechsel insgesamt <br />mit {$correspondent_label}</h1>)
            else (<h1>Briefwechsel insgesamt</h1>)                      

let $year_information_title :=
    if ($p_year)
    then (doc(concat($edweb:dataLetters, '/', $p_year, '_information.xml'))//tei:titleStmt/tei:title/text())
    else ('Missing')

let $year_information_text :=
    if ($p_year)
    then (doc(concat($edweb:dataLetters, '/', $p_year, '_information.xml'))//tei:hi[@ana='short']/text())
    else ('Missing')

let $year_information_contact_name :=
    if ($p_year)
    then (doc(concat($edweb:dataLetters, '/', $p_year, '_information.xml'))//tei:hi[@ana='contact']/text())
    else()

let $year_information_contact_email :=
    if ($p_year)
    then (doc(concat($edweb:dataLetters, '/', $p_year, '_information.xml'))//tei:hi[@ana='email']/text())
    else()

let $year_information_doc_id :=
    if ($p_year)
    then (doc(concat($edweb:dataLetters, '/', $p_year, '_information.xml'))/tei:TEI/@xml:id)
    else()

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
                                {
                                if ($p_year and not($p_person))
                                    then (
                                    <div class="grid_16" id="year_information">
                                    <div class="box whitebox">
                                            <div class="boxInner">
                                                <h2>{$year_information_title}</h2>
                                                <p>{$year_information_text}&#160;<a href="../about/text.xql?id={$year_information_doc_id}" title="Weiterlesen">mehr…</a></p>
                                                <p>Ansprechpartner: <a href="mailto:{$year_information_contact_email}" title="E-Mail">{$year_information_contact_name}&#160;<i class="fa fa-envelope-o" aria-hidden="true"></i></a></p>
                                            </div>
                                        </div>
                                    </div>
                                    )
                                    else (
                                    <div class="grid_16 general-publication-information">
                                        <div class="box whitebox">
                                            <div class="boxInner">
                                                <p>Die digitale Ausgabe der Briefe von und an Karl Marx und Friedrich Engels beginnt mit dem <a href="?jahr=1866" title="Alle Briefe des Jahres 1866 anzeigen">Jahrgang 1866</a>. Die ersten 13 Bände, die chronologisch von 1837 bis 1865 reichen, <a href="http://mega.bbaw.de/struktur/abteilung_iii">liegen bereits gedruckt vor</a>. Die digitalen Briefe können chronologisch oder nach Korrespondenzpartnern angeordnet werden. Ebenso ist eine thematische Zusammenstellung über ein <a href="../register/sachen/index.xql">Register der Themen</a> möglich. Knappe Annotationen zu in den Briefen direkt oder indirekt erwähnten Personen sowie literarische und mythologische Gestalten können über das <a href="../register/personen/index.xql">Register der Namen</a>, erwähnte Unternehmen über das <a href="../register/einrichtungen/index.xql">Register der Firmen</a> ermittelt werden. Von den Korrespondenten benutzte und erwähnte Quellen sind im <a href="../register/werke/index.xql">Register Literatur</a> recherchierbar.</p>
                                            </div>
                                        </div>
                                    </div>
                                    )
                                }
                                
                                <div class="grid_11">
                                    {if ($lettersList) 
                                    then (edweb:pagination($p_limit, $p_offset, $resultCount, 'yes'), $lettersList, edweb:pagination($p_limit, $p_offset, $resultCount, 'no'))
                                    else (<div class="notfound"><p>Für diese Auswahl konnten keine Briefe in der Datenbank gefunden werden.<br/>Wählen Sie rechts ein anderes Jahr oder eine andere Person aus.</p></div>)}
                                </div>
                                <div class="grid_5">
                                    {$filterOptions}
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
                    <param name="currentSection" value="briefe" />
                    <param name="pageTitle" value="{$h1/h1/text()}" />
                    <param name="baseURL" value="{$edweb:baseURL}" />
                </parameters>)

return 
$output