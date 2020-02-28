xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $datum := xs:date(request:get-parameter("datum", '1800-01-01'))
let $typ := request:get-parameter('typ', '')

let $xslt_input :=  <inner_container>
                       <div id="content">
                            <h2>Zeitlinie: Korrespondenz mit Henriette von Willich</h2>
                             <div id="my-timeline" style="height: 500px; border: 1px solid #aaa"></div>
                             <noscript>
                                 This page uses Javascript to show you a Timeline. Please enable Javascript in your browser to see the full page. Thank you.
                             </noscript>
                        </div>
                    </inner_container>

let $output := transform:transform($xslt_input, doc('../resources/xslt/html.xsl'), (<parameters><param name="active_page" value="zeitlinie" /></parameters>))


return 
$output