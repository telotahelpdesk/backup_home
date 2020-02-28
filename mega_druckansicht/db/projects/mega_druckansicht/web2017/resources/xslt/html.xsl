<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="currentSection"/>
    <xsl:param name="currentPage"/>
    <xsl:param name="pageTitle"/>
    <xsl:param name="searchTerms"/>
    <xsl:param name="baseURL"/>
    <xsl:output method="html" media-type="text/html" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="titleAddOn">
        <xsl:if test="$pageTitle">
            <xsl:text> - </xsl:text>
            <xsl:value-of select="$pageTitle"/>
        </xsl:if>
    </xsl:variable>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>MEGAdigital. Online-Angebot der historisch-kritischen Gesamtausgabe von Karl Marx und Friedrich Engels<xsl:value-of select="$titleAddOn"/>
                </title>
                <link rel="icon" href="{$baseURL}/resources/images/favicon.png" type="image/png"/>
                <xsl:call-template name="css"/>
                <xsl:call-template name="js"/>
                <!-- Piwik -->
                <script type="text/javascript">
                    var _paq = _paq || [];
                    _paq.push(["setVisitorCookieTimeout", "604800"]);
                    _paq.push(["setSessionCookieTimeout", "0"]);
                    /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
                    _paq.push(['trackPageView']);
                    _paq.push(['enableLinkTracking']);
                    (function() {
                    var u="https://piwik.bbaw.de/";
                    _paq.push(['setTrackerUrl', u+'piwik.php']);
                    _paq.push(['setSiteId', '31']);
                    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
                    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
                    })();
                </script>
                <noscript>
                    <img src="https://piwik.bbaw.de/piwik.php?idsite=31&amp;rec=1" style="border:0" alt=""/>
                </noscript>
                <!-- End Piwik Code -->              
            </head>
            <body>
                <div class="outerLayer" id="navbar">
                    <div class="container_16">
                        <div class="grid_5">
                            <a id="homelink" href="{$baseURL}/index.xql">
                                <h1>MEGAdigital</h1>
                            </a>
                            <img id="beta" src="{$baseURL}/resources/images/beta.png"/>
                        </div>
                        <div class="grid_11">
                            <nav>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'commentary')">
                                        <a class="current" href="{$baseURL}/about/text.xql?id=aufbau_edition">Editorische Hinweise</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/about/text.xql?id=aufbau_edition">Editorische Hinweise</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!--<xsl:choose>
                                    <xsl:when test="matches($currentSection, 'kapital')">
                                        <a class="current" href="{$baseURL}/about/text.xql?id=aufbau_edition">„Das Kapital“</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="http://telota.bbaw.de/mega/">„Das Kapital“</a>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'kapital')">
                                        <a class="current" href="{$baseURL}/kapital/index.xql">Kapital</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="http://telota.bbaw.de/mega/">Kapital</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'briefe')">
                                        <a class="current" href="{$baseURL}/briefe/index.xql">Briefe</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/briefe/index.xql">Briefe</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'exzerpte')">
                                        <a class="current" href="{$baseURL}/exzerpte/index.xql">Exzerpte</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/exzerpte/index.xql">Exzerpte</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'register')">
                                        <a class="current" href="{$baseURL}/register/index.xql">Register</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/register/index.xql">Register</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'suche')">
                                        <a class="search current" href="{$baseURL}/suche/index.xql">
                                            <span>Suche</span>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a class="search" href="{$baseURL}/suche/index.xql">
                                            <span>Suche</span>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </nav>
                        </div>
                    </div>
                </div>
                <xsl:copy-of select="transferContainer/child::*"/>
                <div class="outerLayer" id="footer">
                    <footer class="container_12">
                        <div class="grid_4">
                            <ul>
                                <h3>Über das Vorhaben</h3>
                                <li>
                                    <a href="http://www.bbaw.de/forschung/mega">Vorhaben</a>
                                </li>
                                <li>
                                    <a href="{$baseURL}/impressum.xql">Impressum &amp; Datenschutz</a>
                                </li>
                                <li>
                                    <a href="mailto:roth@bbaw.de?subject=MEGAdigital">Kontakt</a>
                                </li>
                                <!-- <li>
                                    <a href="{$baseURL}/api/index.xql">Schnittstellen</a>
                                </li> -->
                            </ul>
                            <h3 style="margin-top: .75em;">
                                <a href="http://www.bbaw.de/telota/telota">Realisiert von der TELOTA-Gruppe der BBAW</a>
                            </h3>                            
                        </div>
                        <div class="grid_4">
                            <h3>
                                <a href="http://mega.bbaw.de/imes">Herausgegeben von der Internationalen Marx-Engels-Stiftung</a>
                            </h3>
                            <p>Das Akademienvorhaben „Marx-Engels-Gesamtausgabe“ ist Teil des von Bund und Ländern geförderten <a href="http://www.akademienunion.de/forschung/akademienprogramm/">Akademienprogramms</a>, das der Erhaltung, Sicherung und Vergegenwärtigung des kulturellen Erbes dient. Koordiniert wird das Programm von der <a href="http://www.akademienunion.de/akademienunion/ueber-uns/">Union der Deutschen Akademien der Wissenschaften</a>.</p>
                            <p style="clear:both;">
                                <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"/>
                                <br/>Dieses Werk ist lizenziert unter einer <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 4.0 International Lizenz</a>.</p>
                        </div>
                        <div class="grid_4">
                            <p>
                                <a style="float:right;" href="http://www.bbaw.de">
                                <img src="{$baseURL}/resources/images/bbaw_logo.png" title="Berlin-Brandeburgische Akademie der Wissenschaften" alt="Das Logo der Berlin-Brandenburgischen Akademie der Wissenschaften zeigt den Schriftzug neben einem Adler vor einem Sternenhimmel"/>
                            </a>
                            </p>
                        </div>
                        
                    </footer>
                </div>
                <xsl:if test="$currentSection!='startseite'">
                    <script type="text/javascript">
                        $(document).ready(function() {
                        /*
                        var defaults = {
                        containerID: 'toTop', // fading element id
                        containerHoverID: 'toTopHover', // fading element hover id
                        scrollSpeed: 1200,
                        easingType: 'linear' 
                        };
                        */
                        
                        $().UItoTop({ easingType: 'easeOutQuart' });
                        
                        });
                    </script>
                </xsl:if>
                <xsl:if test="$currentSection='tageskalender'">
                    <script type="text/javascript">
                    $(document).ready(function(){
                    
                        var options1 = {  
                        preloadImages: true,  
                        zoomWidth: 500,  
                        zoomHeight: 350,  
                        xOffset:10,
                        position:'left',
                        title: false
                        };
                        
                        var options2 = {  
                        preloadImages: true,  
                        zoomWidth: 500,  
                        zoomHeight: 350,  
                        xOffset:175,  
                        position:'left',
                        title: false
                        };
                        
                        $('.faksimileLeft').jqzoom(options1);
                        $('.faksimileRight').jqzoom(options2);
                    });
                </script>
                </xsl:if>
                <script type="text/javascript">
                    $('.tooltip').not('.add').not('.measure').mouseover(function(){
                    
                        //If this item is already selected, forget about it.
                        if ($(this).hasClass('active')) return;
                        
                        //Find the currently selected item and hide it, then and remove the style class 'active'
                        $(".active .fussnote").hide();
                        $('.active').removeClass('active');
                        
                        //Add the style class 'active' to this item, then show it
                        $(this).addClass('active');
                        $(".active .fussnote").show();
                    });

                    $('.close').click(function(){
                        $(".active .fussnote").hide();
                        $(".active").removeClass('active');
                    });
                </script>
                <script type="text/javascript">
                    $(document).on('click', '.toggle', function(evt){
                        var elem = $(evt.target);
                        var nextUl = elem.closest('.toc-entry-title').nextAll('ul').eq(0);
                        if (nextUl.hasClass('visible')){
                            elem.removeClass('fa-caret-down').addClass('fa-caret-right');
                            nextUl.removeClass('visible').addClass('invisible');
                        } else {
                            elem.removeClass('fa-caret-right').addClass('fa-caret-down');
                            nextUl.removeClass('invisible').addClass('visible');
                        }
                    });
                    
                    function expandTocItem(tocItem){
                        $('.current').removeClass('current');
                        tocItem.closest('.toc-entry-title').addClass('current');
                        $("nav a:contains('Exzerpte')").addClass('current');
                        tocItem.parents('ul').each(function(){
                        var ul = $(this);
                        ul.removeClass('invisible').addClass('visible');
                        ul.prevAll('.toc-entry-title')
                        .find('.fa')
                        .removeClass('fa-caret-right').addClass('fa-caret-down');
                        });
                    
                    };
                    
                    $(function() {
                        if (window.location.hash){
                        var tocItemSelector = window.location.hash.replace('#', '#toc').split('.').join('\\.');
                        var tocItem = $(tocItemSelector);
                        expandTocItem(tocItem);   
                        };
                        $(document).on('click', '.toc-entry-title', function(evt){ expandTocItem($(evt.target)); });
                        
                    });
                </script>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="css">
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/reset.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/960.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/main.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/fontawesome-5.7.2/css/all.min.css"/>
        <xsl:if test="$currentSection='startseite'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/startseite.css"/>
        </xsl:if>
        <xsl:if test="$currentSection='briefe' or $currentSection='tageskalender' or $currentSection='vorlesungen'or $currentSection='commentary' or $currentSection='exzerpte'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="{$baseURL}/resources/css/transkription.css" type="text/css"/>
        </xsl:if>
        <xsl:if test="$currentSection='tageskalender'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/jqzoom.css"/>
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/tageskalender.css"/>
        </xsl:if>
        <xsl:if test="$currentSection='tageskalender' or $currentSection='suche'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="{$baseURL}/resources/css/kalendae.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentSection='suche'">
            <link rel="stylesheet" href="{$baseURL}/resources/css/suche.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentPage='pdrRecherche'">
            <link rel="stylesheet" href="{$baseURL}/resources/css/pdrRecherche.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentSection='commentary'">
            <link rel="stylesheet" href="{$baseURL}/resources/css/commentary.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" media="screen,projection" href="{$baseURL}/resources/css/ui.totop.css"/>
    </xsl:template>
    <xsl:template name="js">
       <!--   <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/MathJax/MathJax.js?config=TeX-MML-AM_CHTML" type="text/javascript"> </script> -->
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML"> </script>
        <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery-1.7.2.min.js" type="text/javascript"> </script>
        <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery-ui-1.10.3.custom.js" type="text/javascript"> </script>
        <xsl:if test="$currentSection!='startseite'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery.ui.totop.js" type="text/javascript"> </script>
        </xsl:if>
        <xsl:if test="$currentSection='tageskalender'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jqzoom.js" type="text/javascript" charset="utf-8"> </script>
        </xsl:if>
        <xsl:if test="$currentSection='tageskalender' or $currentSection='suche'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="http://telotadev.bbaw.de/schleiermacher/website/js/kalendae.min.js" type="text/javascript" charset="utf-8"/>
        </xsl:if>
        <!--  Die CSS-Ressource wird nicht mehr in der https-Seite geladen. -> Das Skript wurde lokal gespeichert.  -->
        <!--  <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css"/>  -->
        <link rel="stylesheet" href="{$baseURL}/resources/css/leaflet.css"/>
        <!--  Die JS-Ressource wird nicht mehr in der https-Seite geladen. -> Das Skript wurde lokal gespeichert.  -->
        <!--  <script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js"> </script>-->
        <script src="{$baseURL}/resources/js/leaflet.js"> </script>
        <script>
            $(function() {
            $( ".accordion" ).accordion({
                heightStyle: "content",
            });
            });
        </script>
    </xsl:template>
</xsl:stylesheet>