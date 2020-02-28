xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login() 

let $datum := xs:date(request:get-parameter("datum", '1800-01-01'))
let $typ := request:get-parameter('typ', '')

let $xslt_input :=  <inner_container>
                        <div id="content">
                            <h2>Leben und Korrespondenzaktivität Schleiermachers</h2>
                            <div id="my-timeplot" style="height: 250px;"></div>
                        </div>
                    </inner_container>

let $output := transform:transform($xslt_input, doc('../resources/xslt/html.xsl'), (<parameters><param name="active_page" value="aktivitaet" /></parameters>))

return 
$output