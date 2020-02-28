xquery version "3.0";

module namespace edoxy="http://www.bbaw.de/telota/ediarum/oxygen";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota="http://www.telota.de";

(: variables to set :)
declare variable $edoxy:projectName := 'mega';
declare variable $edoxy:user := 'admin';
declare variable $edoxy:password := 'al06hi27';

(: static variables :)
declare variable $edoxy:data := '/db/projects/'||$edoxy:projectName||'/data';
declare variable $edoxy:dataRegister := $edoxy:data||'/Register';
declare variable $edoxy:dataRegisterPersons := $edoxy:dataRegister||'/Personen/';
declare variable $edoxy:dataRegisterPlaces := $edoxy:dataRegister||'/Orte/';
declare variable $edoxy:keywordRegister := $edoxy:dataRegister||'/Sachregister.xml';

(: parameters :)
(: URL Parameter :)
declare variable $edoxy:index := request:get-parameter('name', ()); 
declare variable $edoxy:showDetails := tokenize(request:get-parameter('showDetails', ()), ',');

declare function edoxy:login() {
    xmldb:login($edoxy:data, $edoxy:user, $edoxy:password)
};

declare function edoxy:getPersonList() {
let $p_letter := request:get-parameter('letter', ())
let $alphabet := tokenize('A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z', ',')

let $letter := 
    if (upper-case($p_letter)=$alphabet)
    then(upper-case($p_letter))
    else ()

let $login := edoxy:login()

let $persons :=
    if ($letter)
    then (doc(concat($edoxy:dataRegisterPersons, $letter, '.xml')))
    else (collection($edoxy:dataRegister))

let $ul :=
    element ul {
        for $x in $persons//tei:person 
        let $name := 
            if ($x/tei:persName[@type='reg'][1]/tei:forename)
            then (concat(string-join($x/tei:persName[@type='reg'][1]/tei:surname/normalize-space()), ', ', string-join($x/tei:persName[@type='reg'][1]/tei:forename/normalize-space())))
            else ($x/tei:persName[@type='reg'][1]/tei:name[1]/normalize-space())
        let $lifedate :=
            if ($x/tei:floruit)
            then (concat(' (', $x/tei:floruit, ')'))
            else if ($x/tei:birth)
                then (concat(' (', $x/tei:birth[1], '-', $x/tei:death[1], ')'))
                else ()
        let $note := 
            if ($x/tei:note//text() and $edoxy:showDetails='note')
            then (concat(' (', $x/tei:note//normalize-space(), ')'))
            else ()
        order by $name
        return
        element li {
            attribute xml:id { $x/@xml:id},
            element span {
                concat($name, $lifedate, $note)
            }
        }
    }
    
return
$ul
};

declare function edoxy:getPlaceList() {
let $p_letter := request:get-parameter('letter', ())
let $alphabet := tokenize('A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z', ',')

let $letter := 
    if (upper-case($p_letter)=$alphabet)
    then(upper-case($p_letter))
    else ()

let $login := edoxy:login()

let $persons :=
    if ($letter)
    then (doc(concat($edoxy:dataRegisterPlaces, $letter, '.xml')))
    else (collection($edoxy:dataRegister))


let $ul :=
    element ul {
        for $place in collection($edoxy:dataRegister)//tei:place
        let $name :=
            if ($place[ancestor::tei:place])
            then ($place/ancestor::tei:place/tei:placeName[@type='reg'][1]/normalize-space()||' - '||$place/tei:placeName[@type='reg'][1]/normalize-space())
            else ($place/tei:placeName[@type='reg'][1]/normalize-space())
        let $altname :=
            if ($place/tei:placeName[@type='alt'] and $edoxy:showDetails='altname')
            then (' ['||
                string-join(
                    for $altname at $pos in $place/tei:placeName[@type='alt']
                    return
                    if ($pos=1)
                    then ($altname/normalize-space())
                    else (', '||$altname/normalize-space())
                )
            ||']')
            else ()
        let $note :=
            if ($place/tei:note//text() and $edoxy:showDetails='note')
            then (concat(' (', $place/tei:note[1]//normalize-space(), ')'))
            else ()
        order by $name[1]
        return
        element li {
            attribute xml:id { $place/@xml:id},
            element span { 
                ($name||$altname||$note)
            }
        }
    }
    
return
$ul
};

declare function edoxy:getItemList() {
let $login := edoxy:login()

let $ul :=
    element ul {
        for $item in collection($edoxy:dataRegister)//tei:item
        let $name :=
            if ($item[ancestor::tei:item])
            then ($item/ancestor::tei:item/tei:label[@type='reg'][1]/normalize-space()||' - '||$item/tei:label[@type='reg'][1]/normalize-space())
            else ($item/tei:label[@type='reg'][1]/normalize-space())
        order by $name[1]
        return
        element li {
            attribute xml:id { $item/@xml:id},
            element span { 
                $name
            }
        }
    }
    
return
$ul
};

declare function edoxy:getOrgList() {
let $login := edoxy:login()

let $ul :=
    element ul {
        for $org in collection($edoxy:dataRegister)//tei:org
        let $name := $org/tei:orgName[@type='reg'][1]/normalize-space()
        order by $name[1]
        return
        element li {
            attribute xml:id { $org/@xml:id},
            element span { 
                $name
            }
        }
    }
    
return
$ul
};

declare function edoxy:getBiblList() {
let $login := edoxy:login()
let $ul :=
    element ul {
        for $x in collection($edoxy:dataRegister)//tei:bibl
        let $author :=
            if ($x/tei:author[1]/tei:persName[1]/tei:surname/normalize-space())
            then (concat($x/tei:author[1]/tei:persName[1]/tei:surname/normalize-space(), ', '))
            else ()
        let $title := $x/tei:title/normalize-space()
        order by $author, $title
        return
        element li {
            attribute xml:id { $x/@xml:id},
            element span { 
                concat($author, $title)
            }
        }
    } 
return
$ul
};

declare function edoxy:getLetterList() {
let $login := edoxy:login()
let $ul :=
    element ul {
        for $x in collection($edoxy:data)//tei:TEI[.//tei:correspAction]
        let $title := $x//tei:titleStmt/tei:title/normalize-space()
        order by $x//tei:correspAction[@type='sent']/tei:date/(@when|@from|@notBefore)/data(.)
        return
        element li {
            attribute xml:id { $x/@xml:id/data(.)},
            element span { 
                $title
            }
        }
    }
return
$ul
};

declare function edoxy:getCommentsList() {
let $login := edoxy:login()
let $ul :=
    element ul {
        for $x in collection($edoxy:data)//tei:TEI
        let $fileName := substring-after(base-uri($x), 'data/')
        order by $fileName
        return
            for $note in $x//tei:seg/tei:note
            return
            element li {
                attribute id { $x/@xml:id/data(.)||'/#'||$note/@xml:id/data(.)},
                element span { 
                    $fileName||' - '||substring($note//normalize-space(), 0, 100)
                }
            }
    }
return
$ul
};

declare function edoxy:getKeywordList() {
let $login := edoxy:login()

let $ul :=
    element ul {
        for $item in doc($edoxy:keywordRegister)//tei:item
        let $name :=
            if ($item[ancestor::tei:item])
            then ($item/ancestor::tei:item/tei:label[@type='reg'][1]/normalize-space()||' - '||$item/tei:label[@type='reg'][1]/normalize-space())
            else ($item/tei:label[@type='reg'][1]/normalize-space())
        order by $name[1]
        return
        element li {
            attribute xml:id { $item/@xml:id},
            element span { 
                $name
            }
        }
    }
    
return
$ul
};