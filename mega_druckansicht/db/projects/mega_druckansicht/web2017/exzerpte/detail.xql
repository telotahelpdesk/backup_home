xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html media-type=text/html";


let $login := edweb:login()

let $section-id := request:get-parameter("id", ())
let $xml_id := request:get-parameter("id", ())

(: ########### HTML-Ausgabe ########### :)

let $h1 := <h1>Karl Marx: Exzerpte September 1868 bis Januar 1869</h1>
let $nachweis := <p id="nachweis">IISG, Marx-Engels-Nachlass, B 109/B 101</p>


let $content := <transferContainer>
                {
                    transform:transform(doc(concat($edweb:dataExcerpts, '/B101/B101.xml')), doc(concat($edweb:webDir, '/exzerpte/resources/excerptText.xsl')), <parameters>
            <param name="currentSection" value="exzerpte" />
            <param name="baseURL" value="{$edweb:baseURL}" />
            <param name="section-id" value="{$section-id}"/>
        </parameters>)
                }
                </transferContainer>
  
let $header :=  
    <transferContainer>
    <div
        class="outerLayer"
        id="header">
        <header
            class="container_16">
            <div
                class="grid_15">
                {$content/*:div[@class='subnavbar'], $h1}
                {$nachweis}
            </div>
        </header>
    </div>
    </transferContainer>
  
let $xslt_input :=  
    <transferContainer>
        {
        transform:transform($header, doc($edweb:htmlHeader), ()),
        transform:transform(<transferContainer>{$content/*[not(@class='subnavbar')]}</transferContainer>, doc($edweb:htmlContent), (<parameters><param name="columns" value="16" /></parameters>))
        }        
    </transferContainer>


let $output := 
    transform:transform(
        $xslt_input, 
        doc($edweb:html), 
        <parameters>
            <param name="currentSection" value="exzerpte" />
            <param name="baseURL" value="{$edweb:baseURL}" />
        </parameters>)

return 
$output