xquery version "3.0";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";

declare variable $project external;

declare function local:set-permission($uri as xs:string, $group as xs:string, $mode as xs:string) as xs:string {
    string-join(dbutil:scan(xs:anyURI($uri), function($collection, $resource) {
        if ($resource) then (
            sm:chgrp($resource, $group),
            sm:chmod($resource, $mode),
            "Updated: "||$resource
        )
        else (
            sm:chgrp($collection, $group),
            sm:chmod($collection, $mode),
            "Updated: "||$collection
        )
    }), '&#xA;')
};

let $druck := local:set-permission("/db/projects/"||$project||"/druck", "website", "rwxrwx---")
let $exist := local:set-permission("/db/projects/"||$project||"/exist", "dba", "rwxrwx---")
let $oxygen := local:set-permission("/db/projects/"||$project||"/oxygen", "oxygen", "rwxrwx---")
let $oxygen-ediarum := let $resource := "/db/projects/"||$project||"/oxygen/ediarum.xql"
    return (sm:chgrp($resource, "oxygen"), sm:chmod($resource, "rwsr-x---"), "Updated: "||$resource)
let $web := local:set-permission("/db/projects/"||$project||"/web", "website", "rwxrwx---")
let $config := let $resource := "/db/projects/"||$project||"/config.xml"
    return (sm:chgrp($resource, "dba"), "Updated: "||$resource)
let $webconfig := let $resource := "/db/projects/"||$project||"/webconfig.xml"
    return (sm:chgrp($resource, "website"), "Updated: "||$resource)
let $controller := let $resource := "/db/projects/"||$project||"/controller.xql"
    return (sm:chgrp($resource, "website"), sm:chmod($resource, "rwxr-xr-x"), "Updated: "||$resource)
let $scan := string-join(($druck,$exist,$oxygen,$oxygen-ediarum,$web,$config,$webconfig,$controller),"&#xA;")
return $scan

(:
xquery version "3.0";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";

( :declare variable $project external;: )
declare variable $project := "bibelexegese";

declare function local:set-permission($uri as xs:string, $group as xs:string, $mode as xs:string) as xs:string {
    string-join(dbutil:scan(xs:anyURI($uri), function($collection, $resource) {
        if ($resource) then (
            sm:chgrp($resource, $group),
            sm:chmod($resource, $mode),
            "Updated: "||$resource
        )
        else (
            sm:chgrp($collection, $group),
            sm:chmod($collection, $mode),
            "Updated: "||$collection
        )
    }), '&#xA;')
};

declare function local:delete_contents_xml($uri) {
    dbutil:scan(xs:anyURI($uri), function($collection, $resource) {
        if ($resource) then (
            let $res := xmldb:decode-uri($resource)
            let $col := util:collection-name($res)
            let $doc := util:document-name($res)
            return
                if ($doc = "__contents__.xml") then (
                    xmldb:remove($col, $doc)
                )
                else ()
        )
        else ()
    })
};

let $data := local:set-permission("/db/projects/"||$project||"/data", $project||"-nutzer", "rwxrwx---")
let $druck := local:set-permission("/db/projects/"||$project||"/druck", "website", "rwxrwx---")
let $exist := local:set-permission("/db/projects/"||$project||"/exist", "dba", "rwxrwx---")
let $oxygen := local:set-permission("/db/projects/"||$project||"/oxygen", "oxygen", "rwxrwx---")
let $oxygen-ediarum := let $resource := "/db/projects/"||$project||"/oxygen/ediarum.xql"
    return (sm:chgrp($resource, "oxygen"), sm:chmod($resource, "rwsr-x---"), "Updated: "||$resource)
let $web := local:set-permission("/db/projects/"||$project||"/web", "website", "rwxrwx---")
let $config := let $resource := "/db/projects/"||$project||"/config.xml"
    return (sm:chgrp($resource, "dba"), "Updated: "||$resource)
let $webconfig := let $resource := "/db/projects/"||$project||"/webconfig.xml"
    return (sm:chgrp($resource, "website"), "Updated: "||$resource)
let $delete-contents-xml := local:delete_contents_xml("/db/projects/"||$project||"/data")
let $scan := string-join(($data,$druck,$exist,$oxygen,$oxygen-ediarum,$web,$config,$webconfig),"&#xA;")
return $scan :)
