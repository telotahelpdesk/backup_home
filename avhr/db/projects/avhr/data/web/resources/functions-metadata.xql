xquery version '3.0';

module namespace edwebMeta="http://www.bbaw.de/telota/ediarum/web/metadata";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:uncertain($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(tei:person) | element(tei:org) | element(tei:place)
                return
                element{'tei:'||local-name($node)} {
                    attribute cert { 'low' },
                    $node/attribute(),
                    $node/node()
                }                
            default
                return
                $node/node()
};

declare function edwebMeta:viewFragment($fragments as node()*, $head) {
let $content :=
    for $fragment in $fragments 
    return
        typeswitch($fragment)
         case element(tei:person) | element(tei:org)
            return
                element li { edwebMeta:viewIndexLink($fragment) }             
         case element(tei:place)
            return
                element p { edwebMeta:viewIndexLink($fragment) }
         case element(tei:date)
            return
                element p {
                edweb:viewDate($fragment)  
                }
          case element(tei:note)
            return
                element p { local:viewMarkup($fragment) }
          (: ergänzt 2019-06-06 :)                
          case element(tei:physDesc)
            return
                element p { local:viewMarkup($fragment/tei:p/node()) }                
          case element(editor)
            return
           (element div {
                attribute class {'editor'},
                element h3 { $head },
                $fragment/p 
            })
          case element(tei:list)
                return
                (element div {
                    element h3 { $head },
                    element ul {
                    for $x in $fragment/tei:item
                    return
                    if ($x/tei:ref)
                    then element li { edwebMeta:viewRef($x/node()) }
                    else element li { local:viewMarkup($x/node()) } 
                }})    
        default 
            return
            ()
return
if (local-name($content[1])='li')
then (
        element h3 { $head },
        element ul { $content }) 
else if (local-name($content[1])='p') 
then (
        element div {
            element h3 { $head },
           $content})
else if (local-name($content[1])='div') 
then (
     $content      
) else ()
};

declare function edwebMeta:viewRef($ref) {
    element span { 
        if ($ref/@type='prev')
        then 'Vorangehender Brief: '
        else 'Nachfolgender Brief: '
    },
    element a { 
        attribute href { $edweb:baseURL||'/briefe/detail.xql?id='||$ref/@target },
        collection($edweb:data)//tei:TEI[@xml:id=$ref/@target]//tei:titleStmt/tei:title/text() 
    }
};

declare function edwebMeta:viewIndexLink($entry) {
    typeswitch($entry)
        case element(tei:person)
            return 
            element a { 
                attribute href { $edweb:baseURL||'/register/personen/detail.xql?id='||$entry/@xml:id },
                edweb:persName($entry/tei:persName[@type='reg'], 'surname'),
                if ($entry/@cert='low') then ' (?)' else ()
            }
        case element(tei:org)
            return 
            element a { 
                attribute href { $edweb:baseURL||'/register/einrichtungen/detail.xql?id='||$entry/@xml:id },
                $entry/tei:orgName[@type='reg']/text() 
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

declare function edwebMeta:seperator($persName, $pos, $count) {
    if ($pos = 1)
    then $persName
    else if ($pos = $count)
    then ' und '||$persName
    else $persName||', '
};

declare function edwebMeta:meta($letter) {
    let $doctype := 
        if ($letter//tei:correspDesc)
        then 'Brief'
        else 'Dokument'
    let $author :=
        if($letter//tei:creation/tei:persName) then (
            for $x in $letter//tei:creation/tei:persName
            let $person := collection($edweb:dataRegister)//tei:person[@xml:id=$x/@key]
            return
            $person
        ) else (
            for $x in $letter//tei:creation/tei:orgName
            let $org := collection($edweb:dataRegister)//tei:org[@xml:id=$x/@key]
            return
            $org    
        )
    let $sender :=
        for $x in $letter//tei:correspAction[@type='sent']/(tei:persName|tei:orgName)
        let $record := collection($edweb:dataRegister)//(tei:person|tei:org)[@xml:id=$x/@key]
        let $person :=
            if ($x/@cert='low')
            then (local:uncertain($record))
            else ($record)
        return
        $person
    let $receiver :=
        for $x in $letter//tei:correspAction[@type='received']/(tei:persName|tei:orgName)
        let $record := collection($edweb:dataRegister)//(tei:person|tei:org)[@xml:id=$x/@key]
        let $person :=
            if ($x/@cert='low')
            then (local:uncertain($record))
            else ($record)
        return
        $person
    let $date :=  
            if ($letter//tei:correspAction)
            then $letter//tei:correspAction[@type='sent']/tei:date
            else $letter//tei:creation/tei:date
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
    let $placeCreated :=
        for $x in $letter//tei:creation/tei:placeName
        let $place := collection($edweb:dataRegister)//tei:place[@xml:id=$x/@key]
        return
        $place        
    let $noteLetter := 
        $letter//tei:correspDesc/tei:note
    let $noteDocument :=        
        $letter//tei:notesStmt/tei:note
    let $physDesc := 
        $letter//tei:physDesc 
    let $witnesses :=
        if ($letter//tei:witness)
        then
            element tei:list {
            for $x at $pos in $letter//tei:witness
            let $counter := count($letter//tei:witness)
            (: Handgeschriebe Abschrift mit msDesc berücksichtigen :)
            return
                element tei:item {
                if ($counter > 1)
                then ('D'||$pos||': ', $x/node())
                else ('D: ', $x/node())}}
        else ()
    let $correspContext :=
        if ($letter//tei:correspContext/tei:ref)
        then 
            element tei:list {
                for $ref in $letter//tei:correspContext/tei:ref
                return
                element tei:item { 
                    element tei:ref { 
                        attribute type { $ref/@type/data(.) },
                        attribute target { $ref/@target/data(.) }
                    }   
                }
            }
        else ()        
    let $editors :=
        if ($letter//tei:titleStmt/tei:editor|$letter//tei:titleStmt/tei:respStmt)
        then ( 
          element editor {
          element p {
          for $x at $pos in $letter//tei:titleStmt/tei:editor
          let $count := count($letter//tei:titleStmt/tei:editor)
          return
          edwebMeta:seperator(edweb:persName($x/tei:persName, 'forename'), $pos, $count),
          if ($letter//tei:respStmt//tei:note='Mitarbeit')
          then ( 
            ' unter Mitarbeit von ',
            for $x at $pos in $letter//tei:respStmt[.//tei:note='Mitarbeit']/tei:persName
            let $count := count($letter//tei:respStmt[.//tei:note='Mitarbeit'])
            return
            edwebMeta:seperator(edweb:persName($x, 'forename'), $pos, $count)
          ) else ()},
          if ($letter//tei:respStmt//tei:note='Redaktionelle Mitarbeit')
          then 
            element p { 
                'Redaktionelle Mitarbeit: ', 
                for $x at $pos in $letter//tei:respStmt[.//tei:note='Redaktionelle Mitarbeit']/tei:persName
                let $count := count($letter//tei:respStmt[.//tei:note='Redaktionelle Mitarbeit'])
                return
                edwebMeta:seperator(edweb:persName($x, 'forename'), $pos, $count)
            }   
          else ()}
        ) else ()         
    return
    <div id="meta">
        <div class="visible">
            <h2><i class="fa fa-info-circle fa-lg"></i> Weitere Angaben zum {$doctype}</h2>
        </div>
        <div class="invisible">
            {edwebMeta:viewFragment($author, 'Autor'),
             edwebMeta:viewFragment($sender, 'Absender'),
             edwebMeta:viewFragment($date, 'Datum'),
             edwebMeta:viewFragment($placeSent, 'Schreibort'),
             edwebMeta:viewFragment($placeCreated, 'Schreibort'),
             edwebMeta:viewFragment($receiver, 'Empfänger'),
             edwebMeta:viewFragment($placeReceived, 'Empfangsort'),
             edwebMeta:viewFragment($physDesc, 'Objektbeschreibung'),
             edwebMeta:viewFragment($witnesses, 'Weitere Überlieferung'),
             edwebMeta:viewFragment($noteLetter, 'Anmerkung zum Brief'),
             edwebMeta:viewFragment($correspContext, 'Korrespondenzkontext'),
             edwebMeta:viewFragment($noteDocument, 'Anmerkung zum Text'),
             edwebMeta:viewFragment($editors, 'Herausgeber')
             }
        </div>
    </div>
};

declare function local:viewMarkup($nodes as node()*) {
    for $node in $nodes
    return
    typeswitch($node)
        case element(tei:quote)
            return
            element span {
                attribute class { 'quote' },
                '„',local:viewMarkup($node/node()),'”'
            }
        case element(tei:persName) 
            return
            element a { 
                attribute href { $edweb:baseURL||'/register/personen/detail.xql?id='||$node/@key },
                local:viewMarkup($node/node())
            }
        case element(tei:placeName) 
            return
            element a { 
                attribute href { $edweb:baseURL||'/register/orte/detail.xql?id='||$node/@key },
                local:viewMarkup($node/node())
            }
        case element(tei:orgName) 
            return
            element a { 
                attribute href { $edweb:baseURL||'/register/einrichtungen/detail.xql?id='||$node/@key },
                local:viewMarkup($node/node())
            }
        case element(tei:ref)
            return
                if ($node/@target)
                then
                element a {
                    attribute href { $edweb:baseURL||'/redirect.xql?id='||$node/@target},
                    local:viewMarkup($node/node())
                }
                else ()
        case element(tei:bibl)
            return
            if ($node/@sameAs)
            then 
                if (matches($node/text(), ','))
                then
                (element a {
                    attribute href { '../register/werke/detail.xql?id='||$node/@sameAs },   
                    substring-before($node/text(), ',') },
                ', '||substring-after($node/text(), ','))
                else 
                (element a {
                    attribute href { '../register/werke/detail.xql?id='||$node/@sameAs },   
                    $node/text() })
            else (local:viewMarkup($node/node()))
        case element(tei:hi)
            return
            if ($node/@rendition='#sup')
            then element span {
                attribute class {'hochgestellt'},
                local:viewMarkup($node/node())}
            else local:viewMarkup($node/node())
        case element(tei:ref)
            return
            if ($node/@type='hasAttachment')
            then element a {
                attribute href {$edweb:baseURL||'/redirect.xql?id='||$node/@target},
                local:viewMarkup($node/node())}
            else local:viewMarkup($node/node())
        case text() 
            return $node
        default 
            return local:viewMarkup($node/node())
    
};