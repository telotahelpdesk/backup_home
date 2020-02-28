xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebSearch="http://www.bbaw.de/telota/ediarum/web/search" at "../suche/forms.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html5 media-type=text/html";

declare function local:letterbar($type){
    let $fullRange := 'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z'
    let $letterbar :=
        <div class="letterbar">
            <p>Oder einen Buchstaben wählen:</p>
            <ul>
                { for $letter in tokenize($fullRange, ',')
                return
                <li><a href="{$type}/index.xql?section={$letter}">{$letter}</a></li> 
                }
            </ul>
        </div>
    
    return
    $letterbar
};

let $login := edweb:login()

let $personsRegister := 
    <form class="register" action="personen/detail.xql">
        <h3>Personen ({count(collection($edweb:dataRegister)//tei:person[not(@role='mythological')])}) </h3>
        <input id="personname" type="text" placeholder="Name hier eingeben" />
        <input type="hidden" id="personid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#personname" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=personen&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#personname" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#personname" ).val( ui.item.label );
                        $( "#personid" ).val( ui.item.value );
                        return false;
                    &#125;
                &#125;)
                .data( "ui-autocomplete" )._renderItem = function( ul, item ) &#123;
                return $( "&#x003c;li&#x003e;" )
                .append( "&#x003c;a&#x003e;" + item.label + "&#x003c;/a&#x003e;" )
                .appendTo( ul );
            &#125;;
            &#125;);
            </script>
            <input type="reset" value="x" />
            <input type="submit" value="Aufschlagen"/>
            {local:letterbar('personen')}
    </form>
    
let $mythRegister := 
    <form class="register" action="mythologie/detail.xql">
        <h3>Mythologische Namen ({count(collection($edweb:dataRegister)//tei:person[@role='mythological'])}) </h3>
        <input id="mythname" type="text" placeholder="Name hier eingeben" />
        <input type="hidden" id="mythid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#mythname" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=myth&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#mythname" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#mythname" ).val( ui.item.label );
                        $( "#mythid" ).val( ui.item.value );
                        return false;
                    &#125;
                &#125;)
                .data( "ui-autocomplete" )._renderItem = function( ul, item ) &#123;
                return $( "&#x003c;li&#x003e;" )
                .append( "&#x003c;a&#x003e;" + item.label + "&#x003c;/a&#x003e;" )
                .appendTo( ul );
            &#125;;
            &#125;);
            </script>
            <input type="reset" value="x" />
            <input type="submit" value="Aufschlagen"/>
            {local:letterbar('mythologie')}
    </form>    
                    
let $placesRegister := 
    <form class="register" action="orte/detail.xql">
        <h3>Ortsnamen ({count(collection($edweb:dataRegister)//tei:place)})</h3>
        <input id="ortsname" type="text" placeholder="Ortsname hier eingeben" />
        <input type="hidden" id="ortsid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#ortsname" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=orte&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#ortsname" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#ortsname" ).val( ui.item.label );
                        $( "#ortsid" ).val( ui.item.value );
                        return false;
                    &#125;
                &#125;)
                .data( "ui-autocomplete" )._renderItem = function( ul, item ) &#123;
                return $( "&#x003c;li&#x003e;" )
                .append( "&#x003c;a&#x003e;" + item.label + "&#x003c;/a&#x003e;" )
                .appendTo( ul );
            &#125;;
            &#125;);
            </script>
        <input type="reset" value="x" />
        <input type="submit" value="Aufschlagen"/>
        {local:letterbar('orte')}
    </form>

let $keywordRegister := 
    <form class="register" action="objekt/detail.xql">
        <h3>Artefakte ({count(collection($edweb:dataRegister)//telota:artwork)})</h3>
        <input id="sachbegriff" type="text" placeholder="Sachbegriff hier eingeben" />
        <input type="hidden" id="sachbegriffid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#sachbegriff" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=objekte&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#werktitel" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#werktitel" ).val( ui.item.label );
                        $( "#werkid" ).val( ui.item.value );
                        return false;
                    &#125;
                &#125;)
                .data( "ui-autocomplete" )._renderItem = function( ul, item ) &#123;
                return $( "&#x003c;li&#x003e;" )
                .append( "&#x003c;a&#x003e;" + item.label + "&#x003c;/a&#x003e;" )
                .appendTo( ul );
            &#125;;
            &#125;);
            </script>
        <input type="reset" value="x" />    
        <input type="submit" value="Aufschlagen"/>
        {local:letterbar('objekte')}
    </form>
                    
let $worksRegister := 
    <form class="register" action="werke/detail.xql">
        <h3>Werke</h3>
        <input id="werktitel" type="text" placeholder="Werktitel hier eingeben" />
        <input type="hidden" id="werkid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#werktitel" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=werke&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#werktitel" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#werktitel" ).val( ui.item.label );
                        $( "#werkid" ).val( ui.item.value );
                        return false;
                    &#125;
                &#125;)
                .data( "ui-autocomplete" )._renderItem = function( ul, item ) &#123;
                return $( "&#x003c;li&#x003e;" )
                .append( "&#x003c;a&#x003e;" + item.label + "&#x003c;/a&#x003e;" )
                .appendTo( ul );
            &#125;;
            &#125;);
            </script>
        <input type="reset" value="x" />    
        <input type="submit" value="Aufschlagen"/>
        {local:letterbar('werke')}
    </form>

let $orgsRegister := 
    <form class="register" action="einrichtungen/detail.xql">
        <h3>Institutionen <span class="count">({count(collection($edweb:dataRegister)//tei:org)} Einträge)</span></h3>
        <input id="org" type="text" placeholder="Name der Institution hier eingeben" />
        <input type="hidden" id="orgid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#org" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=orgs&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#org" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#org" ).val( ui.item.label );
                        $( "#orgid" ).val( ui.item.value );
                        return false;
                    &#125;
                &#125;)
                .data( "ui-autocomplete" )._renderItem = function( ul, item ) &#123;
                return $( "&#x003c;li&#x003e;" )
                .append( "&#x003c;a&#x003e;" + item.label + "&#x003c;/a&#x003e;" )
                .appendTo( ul );
            &#125;;
            &#125;);
            </script>
        <input type="reset" value="x" />    
        <input type="submit" value="Aufschlagen"/>
        {local:letterbar('einrichtungen')}
    </form>
                   
let $header :=  
    <transferContainer>
        <h1>Register</h1>
        <p></p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_4 box whitebox">
            <div class="boxInner">
                    {$personsRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox">
            <div class="boxInner">
                    {$mythRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox">
            <div class="boxInner">
                    {$orgsRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox">
            <div class="boxInner">
                    {$placesRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox">
            <div class="boxInner">
                 {$keywordRegister}   
            </div>
        </div>
        <div class="grid_4 box whitebox">
            <div class="boxInner">
                 {$worksRegister}
            </div>
        </div>
     </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc('../resources/xslt/header.xsl'), ()),
                        transform:transform($content, doc('../resources/xslt/content.xsl'), (<parameters><param name="columns" value="12" /></parameters>))}        
                    </transferContainer>                    

let $output := edweb:transformHTML($xslt_input, 'register', 'Register')

return 
$output