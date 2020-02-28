xquery version "3.0";

module namespace cmif-api="http://correspSearch.net/apps/cmif-api";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function cmif-api:getRegisterData($node as element(), $static as element()) {
    let $entry :=
        if ($node/@key)
        then 
           (collection($static/config/data-register)//tei:*[@xml:id=$node/@key/data(.)])
        else ()
    let $id := $entry/@xml:id
    let $authority-id := $entry/tei:idno[1]/text()
    let $name :=
        typeswitch($entry)
            case element(tei:person)
                return
                edweb:persName($entry/tei:persName[@type='reg'], 'forename')
            case element(tei:org)
                return
                $entry/tei:orgName[@type='reg']/text()
            case element(tei:place)
                return
                $entry/tei:placeName[@type='reg']/text()
            default
                return
                ()
    return
       (if ($authority-id)
        then attribute ref { $authority-id }
        else if ($id) 
        then attribute ref { $static/config/base-url||$id }
        else (),
        $name)
};

declare function cmif-api:correspDesc($nodes as node()*, $id as xs:string, $static as element()) as node()* {
    for $node in $nodes
    return
        typeswitch($node)
            case element(tei:correspDesc)
                return
                element tei:correspDesc { 
                    attribute source { '#'||$static/tei:fileDesc/tei:sourceDesc/tei:bibl/@xml:id },
                    attribute ref {$static/config/base-url||$id}, 
                    cmif-api:correspDesc($node/node(), $id, $static) }
            case element(tei:correspAction)
                return
                element tei:correspAction {
                    attribute type { $node/@type },
                    cmif-api:correspDesc($node/node(), $id, $static) }
            case element(tei:persName)            
                return (
                    element tei:persName {
                        cmif-api:getRegisterData($node, $static)
                    }
                )
            case element(tei:orgName)            
                return (
                    element tei:orgName {
                       cmif-api:getRegisterData($node, $static)
                    }
                )                
            case element(tei:placeName)            
                return (
                    element tei:placeName {
                        cmif-api:getRegisterData($node, $static)
                    }
                )
            case element(tei:note)
                return
                ()
            case element(tei:correspContext)
                return
                ()                
            case text()
                return
                $node
            default
                return
                $node
};

declare function cmif-api:useCache() { 
    if (doc-available('resources/cached_cmif.xml'))
    then (
        if(current-dateTime() < (xmldb:created(concat($edweb:apiDir, '/resources'), 'cached_cmif.xml') + xs:dayTimeDuration('P1D')))
        then (fn:true())
        else (fn:false())
    )
    else (fn:false())
};   

declare function cmif-api:create-tei-xml($correspDesc as element()*, $static as element()) as element() {
     <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                {$static/tei:fileDesc}
                <profileDesc>
                    {$correspDesc}
                </profileDesc>
            </teiHeader>
            <text>
                <body>
                    <p/>
                </body>
            </text>
        </TEI>
};

declare function cmif-api:getLetters($static) {
        for $letter in collection($static/config/data-letters)//tei:TEI[.//tei:correspDesc]
        let $id := $letter/@xml:id
        let $correspDesc := $letter//tei:correspDesc
        return
        cmif-api:correspDesc($correspDesc, $id, $static)
};

(:if ($useCache)
then (doc('resources/cached_cmif.xml'))
else (
    xmldb:store(concat($edweb:apiDir, '/resources'), 'cached_cmif.xml', transform:transform($letters, doc('resources/cmif.xsl'), <parameter><param name="uuid" value="{$cmif-api:uuid}"></param></parameter>)),
    util:wait(5000),
    response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/api/v1.1/cmif.xql')))):)
    
declare function cmif-api:create($config, $fileDesc) {
    let $static := element static { $config, $fileDesc }
    return
    cmif-api:create-tei-xml(cmif-api:getLetters($static), $static)
};