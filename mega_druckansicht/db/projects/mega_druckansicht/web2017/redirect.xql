xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login() 

let $id := request:get-parameter("id", ())
let $page := 
    if (request:get-parameter("page", ()))
    then ('#'||request:get-parameter("page", ()))
    else ()

let $filepath :=
    if (collection($edweb:data)//tei:TEI[@xml:id=$id])
    then base-uri(root(collection($edweb:data)//tei:TEI[@xml:id=$id]))
    else ()

let $url := 
        if (matches($filepath, 'Briefe'))
        then ($edweb:baseURL||'/briefe/detail.xql?id='||$id||$page)
        else if (matches($filepath, 'Dokumente'))
        then ($edweb:baseURL||'/themen/detail.xql?id='||$id||$page)
        else ($edweb:baseURL||'/index.xql') 

return
response:redirect-to($url)