xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=html5 media-type=text/html";

(: Für das Login und Logout :)

let $login := edweb:login() 

let $p_id := request:get-parameter('id', ())
let $data := collection($edweb:data)//tei:TEI[@xml:id=$p_id]
let $base-uri := base-uri($data)

let $url :=
    if (matches($base-uri, 'Briefe'))
    then concat($edweb:baseURL||'/briefe/detail.xql?id=', $p_id)
    else if (matches($base-uri, 'Amtliche'))
    then concat($edweb:baseURL||'/amtliche-schriften/detail.xql?id=', $p_id)
    else $edweb:baseURL

return
response:redirect-to($url)
