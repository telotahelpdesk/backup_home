xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebSearch="http://www.bbaw.de/telota/ediarum/web/search" at "../suche/forms.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

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
        <h3>Namen ({count(collection($edweb:dataRegister)//tei:person)}) </h3>
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
                    
let $placesRegister := 
    <form class="register" action="orte/detail.xql">
        <h3>Orte (im Aufbau) <!--({count(collection($edweb:dataRegister)//tei:place)})--></h3>
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
        <input type="submit" value="Aufschlagen" style="margin-bottom:17px;"/>
        {local:letterbar('orte')}
    </form>

let $keywordRegister := 
    <form class="register" action="sachen/detail.xql">
        <h3>Themen</h3>
        <input id="sachbegriff" type="text" placeholder="Sachbegriff hier eingeben" />
        <input type="hidden" id="sachbegriffid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#sachbegriff" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=sachen&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#sachbegriff" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#sachbegriff" ).val( ui.item.label );
                        $( "#sachbegriffid" ).val( ui.item.value );
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
        <input type="submit" value="Aufschlagen" style="margin-bottom:10px;"/>
        <div style="font-family: PTSans; font-size: 0.9em;">
            <br/>
            <p><a href="sachen/index.xql">Liste der Themen</a></p>
        </div>
    </form>
    
let $orgsRegister := 
    <form class="register" action="einrichtungen/detail.xql">
        <h3>Firmen ({count(collection($edweb:dataRegister)//tei:org)})</h3>
        <input id="org" type="text" placeholder="Name der Einrichtung hier eingeben" />
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
                    
let $worksRegister := 
    <form class="register" action="periodika/detail.xql">
        <h3>Periodika (im Aufbau)</h3>
        <input id="periodika" type="text"/>
        <input type="hidden" id="werkid" name="id" value="" />
        <script>
            $(function() &#123;
                $( "#periodika" ).autocomplete(&#123;
                    minLength: 3,
                    dataType: "json",
                    source: "../suche/autocomplete.xql?register=periodika&amp;",
                    focus: function( event, ui ) &#123;
                        $( "#periodika" ).val( ui.item.label );
                        return false;
                    &#125;,
                    select: function( event, ui ) &#123;
                        $( "#periodika" ).val( ui.item.label );
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
        <input type="submit" value="Aufschlagen" style="margin-bottom:16px;"/>
        {local:letterbar('periodika')}
    </form>

                   
let $header :=  
    <transferContainer>
        <h1>Register</h1>
        <p></p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_4 box whitebox registerbox">
            <div class="boxInner">
                    {$personsRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox registerbox">
            <div class="boxInner">
                 {$orgsRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox registerbox">
            <div class="boxInner">
                    {$placesRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox registerbox" style="clear:both;">
            <div class="boxInner">
                 {$keywordRegister}   
            </div>
        </div>
        <div class="grid_4 box whitebox registerbox">
            <div class="boxInner">
                 {$worksRegister}
            </div>
        </div>
        <div class="grid_4 box whitebox registerbox">
            <div class="boxInner">
                <h3>Register durchsuchen</h3>
                {edwebSearch:formRegistersuche('')}                       
            </div>
        </div>    
     </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc('../resources/xslt/header.xsl'), ()),
                        transform:transform($content, doc('../resources/xslt/content.xsl'), (<parameters><param name="columns" value="12" /></parameters>))}        
                    </transferContainer>                    

let $output := edweb:transformHTML($xslt_input, 'register')

return 
$output