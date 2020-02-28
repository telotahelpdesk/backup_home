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
                <title>Aloys Hirt. Briefwechsel und amtliche Schriften 1787–1837. Kritische und kommentierte Edition <xsl:value-of select="$titleAddOn"/>
                </title>
                <link rel="icon" href="{$baseURL}/resources/images/favicon.png" type="image/png"/>
                <xsl:call-template name="css"/>
                <xsl:call-template name="js"/>
            </head>
            <body>
                <div class="outerLayer" id="navbar">
                    <div class="container_16">
                        <div class="grid_6">
                            <a id="homelink" href="{$baseURL}/index.xql">
                                <h1>Aloys Hirt – Briefe &amp; amtliche Schriften</h1>
                            </a>
                            <img id="beta" src="{$baseURL}/resources/images/beta.png"/>
                        </div>
                        <div class="grid_10">
                            <nav>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'commentary')">
                                        <a class="current" href="{$baseURL}/about/text.xql?id=zu_dieser_edition">Über diese Edition</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/about/text.xql?id=zu_dieser_edition">Über diese Edition</a>
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
                                    <xsl:when test="matches($currentSection, 'amtliche-schriften')">
                                        <a class="current" href="{$baseURL}/amtliche-schriften/index.xql">Amtliche Schriften</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/amtliche-schriften/index.xql">Amtliche Schriften</a>
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
                    <footer class="container_16">
                        <div class="grid_4">
                            <ul>
                                <h3>Über das Vorhaben</h3>
                                <li>
                                    <a href="{$baseURL}/about/text.xql?id=projekt">Vorhaben</a>
                                </li>
                                <li>
                                    <a href="{$baseURL}/impressum.xql">Impressum &amp; Datenschutz</a>
                                </li>
                                <li>
                                    <a href="{$baseURL}/api/index.xql">Schnittstellen</a>
                                </li>
                            </ul>
                        </div>
                        <div class="grid_4">
                            <p> </p>
                        </div>
                        <div class="grid_4">
                            <h3>Träger des Forschungsvorhabens</h3>
                            <p class="italic">
                                »Aloys Hirt – Briefwechsel 1787–1837« ist ein Forschungsprojekt der Berlin-Brandenburgischen Akademie der Wissenschaften. <br/>Gefördert von der Deutschen Forschungsgemeinschaft.</p>
                        </div>
                        <div class="grid_4">
                            <a href="http://www.bbaw.de">
                                <img src="{$baseURL}/resources/images/bbaw_logo.png" title="Berlin-Brandeburgische Akademie der Wissenschaften" alt="Das Logo der Berlin-Brandenburgischen Akademie der Wissenschaften zeigt den Schriftzug neben einem Adler vor einem Sternenhimmel"/>
                                <br/>
                                <br/>
                                <img src="{$baseURL}/resources/images/dfg_logo_schriftzug_weiss.png" title="Gefördert von der Deutschen Forschungsgemeinschaft" alt="Gefördert von der Deutschen Forschungsgemeinschaft"/>
                            </a>
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
                    $('.tooltip').not('.add').not('.antiqua').not('.measure').mouseover(function(){
                    
                    //If this item is already selected, forget about it.
                    if ($(this).hasClass('active')) return;
                    
                    //Find the currently selected item, and remove the style class
                    $('.active').removeClass('active');
                    
                    //Add the style class to this item
                    $(this).addClass('active');
                    });
                    $('.close').click(function(){
                    $(".active").removeClass('active');
                    });
                </script>
                <script>
                    $(window).load(function () {
                    var hash = window.location.hash.substring(1);
                    if (hash) {
                    $('span.tooltip[id="'+hash+'"]').addClass('active');
                    }
                    });
                </script>
                <xsl:if test="matches($baseURL, 'aloys-hirt.bbaw.de')">
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
                        _paq.push(['setSiteId', '29']);
                        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
                        g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
                        })();
                    </script>
                    <noscript>
                        <img src="https://piwik.bbaw.de/piwik.php?idsite=29&amp;rec=1" style="border:0" alt=""/>
                    </noscript>
                    <!-- End Piwik Code -->
                </xsl:if>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="css">
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/reset.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/960.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/main.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/font-awesome.css"/>
        <!--    Updated Font Awesome    -->
        <!--    Related to: #8701 and #8732    -->
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/fonts/fontawesome-5.6.3/css/all.css"/>
        <xsl:if test="$currentSection='startseite'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/startseite.css"/>
        </xsl:if>
        <xsl:if test="$currentSection='briefe' or $currentSection='amtliche-schriften' or $currentSection='commentary' or $currentSection='vorlesungen'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="../resources/css/transkription.css" type="text/css"/>
        </xsl:if>
        <xsl:if test="$currentSection='tageskalender'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/jqzoom.css"/>
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/tageskalender.css"/>
        </xsl:if>
        <xsl:if test="$currentSection='tageskalender' or $currentSection='suche'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="../resources/css/kalendae.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentSection='suche'">
            <link rel="stylesheet" href="../resources/css/suche.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentPage='pdrRecherche'">
            <link rel="stylesheet" href="{$baseURL}/resources/css/pdrRecherche.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentSection='commentary'">
            <link rel="stylesheet" href="../resources/css/commentary.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" media="screen,projection" href="../resources/css/ui.totop.css"/>
    </xsl:template>
    <xsl:template name="js">
        <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery-1.7.2.min.js" type="text/javascript"> </script>
        <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery-ui-1.10.3.custom.js" type="text/javascript"> </script>
        <xsl:if test="$currentSection!='startseite'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery.ui.totop.js" type="text/javascript"> </script>
        </xsl:if>
        <xsl:if test="$currentSection='tageskalender'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jqzoom.js" type="text/javascript" charset="utf-8"> </script>
        </xsl:if>
        <link rel="stylesheet" href="{$baseURL}/resources/css/leaflet.css"/>
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