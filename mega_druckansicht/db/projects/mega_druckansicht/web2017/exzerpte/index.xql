xquery version "3.0";

import module namespace edweb = "http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebRegister = "http://www.bbaw.de/telota/ediarum/web/register" at "../register/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $h1 := <h1>Exzerpte und Notizen</h1>

let $intro_title := doc(concat($edweb:dataExcerpts, '/', 'B101_information.xml'))//tei:titleStmt/tei:title/string()

let $intro_doc_id := doc(concat($edweb:dataExcerpts, '/', 'B101_information.xml'))/tei:TEI/@xml:id

let $intro_text_short := doc(concat($edweb:dataExcerpts, '/', 'B101_information.xml'))//tei:hi[@ana = 'short']/string()

let $intro_contact_name := doc(concat($edweb:dataExcerpts, '/', 'B101_information.xml'))//tei:hi[@ana = 'contact']/string()

let $intro_contact_email := doc(concat($edweb:dataExcerpts, '/', 'B101_information.xml'))//tei:hi[@ana = 'email']/string()

let $persons := doc(concat($edweb:dataExcerpts, '/B101/B101.xml'))//tei:persName[@key]

let $persons :=
<div
    class="box graybox filter personen"><div
        class="boxInner"><h3>Personen</h3><ul
            id="filter_personen">
            <li><a
                    href="../register/personen/detail.xql?id=pdrPo.001.004.000001797">Gladstone, William Ewart</a></li>
            <li><a
                    href="../register/personen/detail.xql?id=pdrPo.001.004.000002374">Jevons, William Stanley</a></li>
            <li><a
                    href="../register/personen/detail.xql?id=pdrPo.001.004.000004092">Rothschild, Jakob Mayer, Freiherr von</a></li>
        </ul></div></div>

let $orgs :=
<div
    class="box graybox filter personen"><div
        class="boxInner"><h3>Einrichtungen</h3><ul
            id="filter_personen">
            <li><a
                    href="../register/einrichtungen/detail.xql?id=ed_ckh_gyv_m1b">Bank of England</a></li>
            <li><a
                    href="../register/einrichtungen/detail.xql?id=pdrPo.001.015.000090021">Banque de France</a></li>
        </ul></div></div>

let $xslt_input := <transferContainer>
    <div
        class="outerLayer"
        id="header">
        <header
            class="container_16">
            <div
                class="grid_15">
                {$h1}
            </div>
        </header>
    </div>
    <div
        class="outerLayer"
        id="content">
        <div
            class="container_16">
            {
                <div
                    class="grid_16"
                    id="year_information">
                    <div
                        class="box whitebox">
                        <div
                            class="boxInner">
                            <h2>{$intro_title}</h2>
                            <p>{$intro_text_short}&#160;<a
                                    href="../about/text.xql?id={$intro_doc_id}"
                                    title="Weiterlesen">mehr…</a></p>
                            <p>Ansprechpartnerin: <a
                                    href="mailto:{$intro_contact_email}"
                                    title="E-Mail">{$intro_contact_name}&#160;<i
                                        class="fa fa-envelope-o"
                                        aria-hidden="true"></i></a></p>
                        </div>
                    </div>
                </div>
            }
            <div
                class="grid_11">
                <div
                    class="box whitebox">
                    <div
                        class="boxInner index">
                        <div>
                            <table
                                class="letters">
                                <tr>
                                    <th>Exzerpthefte, <br/>Notizbücher</th>
                                    <th>Kurzbeschreibung des Inhalts</th>
                                </tr>
                                <tr>
                                    <td
                                        class="date">IISG, MEN, B 108</td>
                                    <td
                                        class="description">Notizen und Exzerpte Sept. bis Dez. 1868 aus 
                                        <br/>einem chemischen Lehrbuch,  
                                        <br/>„The Money Market Review“ und  
                                        <br/>„The Standard“,  
                                        <br/>Register zu „The Money Market Review“ 1866/67
                                    </td>
                                </tr>
                                <tr
                                    class="clickable-row"
                                    data-href="../../exzerpte/detail.xql?id=1">
                                    <td
                                        class="date">IISG, MEN, B 109</td>
                                    <td class="description"><a
                                            href="../exzerpte/detail.xql?id=1">Exzerpte Okt. 1868 bis Jan. 1869 aus  
                                            <br/>„The Economist“ und  
                                            <br/>„The Money Market Review“,  
                                            <br/>ein Zeitungsausschnitt aus „The Social Economist“,  
                                            <br/>Register zu „The Economist“ 1866/1867,  
                                            <br/>Register zu „The Money Market Review“ 1866/67
                                        </a></td>
                                </tr>
                                <tr>
                                    <td
                                        class="date">IISG, MEN, B 113</td>
                                    <td
                                        class="description">„1869 I. Heft“, Jan. bis Mai 1869  
                                        <br/>Wochenberichte der Bank of England 1868,  
                                        <br/>Exzerpte aus  
                                        <br/>„The Money Market Review“ und  
                                        <br/>„The Economist“,  
                                        <br/>Register zu „The Money Market Review“ 1868,
                                         <br/>Register zu „The Economist“ 1868,  
                                        <br/>Exzerpte aus  
                                        <br/>G.J. Goschen: The Theory of the Foreign Exchanges,
                                        <br/>einem Lehrbuch zur kaufmännischen Rechnung</td>
                                </tr>
                                <tr>
                                    <td
                                        class="date">IISG, MEN, B 114</td>
                                    <td
                                        class="description">„Heft II. 1869“, Exzerpte Febr. 1869 bis Aug. 1872 aus 
                                        <br/>einem Lehrbuch zur kaufmännischen Rechnung (Fortsetzung)
                                        <br/> J.L. Foster: An Essai on the Principle of Commercial Exchanges,
                                        <br/>O. Hausner: Vergleichende Statistik von Europa,  
                                        <br/>M.T. Sadler: Ireland; its Evils and their Remedies
                                    </td>
                                </tr>
                                <tr>
                                    <td
                                        class="date">RGASPI, f.1, op.1, d.2423</td>
                                    <td
                                        class="description">Notizkalender.
                                        <br/>Notizen wahrscheinlich März 1869 bis August 1871
                                    </td>
                                </tr>
                                <tr>
                                    <td
                                        class="date">IISG, MEN, P 1 </td>
                                    <td
                                        class="description">Heft mit Zeitungsausschnitten,
                                        <br/>Aufschrift "Trade and Finance 1868" (1868-1869)
                                    </td>
                                </tr>
                                <tr>
                                    <td
                                        class="date">IISG, MEN, P 2</td>
                                    <td
                                        class="description">Heft mit Zeitungsausschnitten,
                                        <br/>Aufschrift „Trade and Finance 1869“ (1869/70)</td>
                                </tr>
                                <tr>
                                    <td
                                        class="date">IISG, MEN, P 3</td>
                                    <td
                                        class="description">Schulheft mit Zeitungsausschnitten aus engl. Zeitungen, <br/>Aufschrift „Social Cases“ (1869)</td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div
                class="grid_5">
                {$persons}
            {$orgs}
            </div>
        
        </div>
    </div>
</transferContainer>

let $output := transform:transform(
$xslt_input,
doc($edweb:html),
<parameters>
    <param
        name="currentSection"
        value="exzerpte"/>
    <param
        name="pageTitle"
        value="{$h1/h1/text()}"/>
    <param
        name="baseURL"
        value="{$edweb:baseURL}"/>
</parameters>)

return
    $output
