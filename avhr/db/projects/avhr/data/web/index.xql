xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $header :=  <transferContainer>
                    <div class="alignRight">
                         <img src="resources/images/hirt.png" />
                         <div>
                             <h1><span>Aloys Hirt <br/>Briefwechsel und Amtliche Schriften</span></h1>
                             <p><span>Forschungsvorhaben an der Berlin-Brandenburgischen Akademie der Wissenschaften</span></p>
                             <p>Bearbeitet von Uta Motschmann</p>
                         </div>
                     </div>
                </transferContainer>

let $content := <transferContainer>
                                        <div class="grid_4 row1 notice">
                        <h3>BETA-Version</h3>
                        <p>Die digitale Edition ist derzeit noch „work in progress“: Weitere Briefe und Einzelstellenkommentare sowie die Endredaktion folgen; zusätzliche Funktionen werden noch implimentiert.</p> 
                        <p>Da die digitale Edition eine stetige Ergänzung und Überarbeitung ermöglicht, bittet die <a href="http://www.bbaw.de/die-akademie/mitarbeiter/motschmann">Bearbeiterin</a> die Nutzer und Nutzerinnen der Website freundlichst um hilfreiche Unterstützung und wäre für sachdienliche Hinweise sehr dankbar. Dies betrifft vor allem Hinweise auf mögliche neue Briefe und amtliche Schriften, aber auch Ergänzungen zur Kommentierung.</p>
                    </div>
                    <div class="grid_4">
                        <div class="row1">
                        <h3>Korrespondenz</h3>
                        <p>Das Briefkorpus besteht aus mehr als 250 privaten Briefen sowie ca. 250 erschlossenen Briefen aus den Jahren 1787 bis 1837, die erstmals im Gesamtzusammenhang ediert werden.</p>
                        <a class="button" href="briefe/index.xql">Briefwechsel aufschlagen</a>
                        </div>
                        <div id="search">
                        <h3>Suche</h3>
                        <form action="suche/ergebnis.xql" accept-charset="utf-8">
                            <label for="suchbegriff">Suchbegriff </label>
                            <input id="searchstring" name="q_text" placeholder="Suchbegriff hier eingeben"/>
                            <input name="doctype" value="briefe" type="hidden" />
                            <button type="submit" class="submit" value="Absenden">
                                Suchen
                            </button>
                        </form>
                        <p><a href="suche/index.xql">[Erweiterte Suche]</a></p>
                        </div>
                    </div>
                    <div class="grid_4 row1">
                        <div>
                            <h3>Amtliche Schriften</h3>
                            <p>Das Korpus besteht aus mehr als 300 Einzeldokumenten (u.a. Gutachten, Voten, Promemorien, amtlichen Schreiben) aus dem Zeitraum 1796 bis 1837, die den jeweiligen Amtsbereichen Akademie der Wissenschaften, Akademie der Künste, Bauakademie sowie Museumskommission zugeordnet sind.</p>
                            <a class="button" href="amtliche-schriften/index.xql">Amtliche Schriften aufschlagen</a>
                        </div>
                    </div>
                 </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc($edweb:htmlHeader), (<parameters><param name="columns" value="16" /></parameters>)),
                        transform:transform($content, doc($edweb:htmlContent), (<parameters><param name="columns" value="12" /></parameters>))}        
                    </transferContainer>

let $output := edweb:transformHTML($xslt_input, 'startseite', 'Startseite') 


return 
$output