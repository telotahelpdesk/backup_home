xquery version "3.0";

import module namespace cmif-api="http://correspSearch.net/apps/cmif-api" at "cmif-api.xqm";

let $config := 
    <config>
        <data-letters>/db/projects/hirt/data</data-letters>
        <data-register>/db/projects/hirt/data/Register</data-register>
        <base-url>http://aloys-hirt.bbaw.de/redirect.xql?id=</base-url>
    </config>

let $fileDesc := 
    <fileDesc xmlns="http://www.tei-c.org/ns/1.0">
        <titleStmt>
            <title>Aloys Hirt - Verzeichnis der Briefe und amtlichen Schriften</title>
            <editor>Stefan Dumont <email>dumont@bbaw.de</email>
            </editor>
        </titleStmt>
        <publicationStmt>
            <publisher>
                <ref target="http://www.bbaw.de">Berlin-Brandenburg Academy of Sciences and Humanities</ref>
            </publisher>
            <date when="2019-06-06"/><!-- last modification of correspDescs - not the current date!  -->
            <availability>
                <licence target="https://creativecommons.org/licenses/by/4.0/">This file is licensed under the terms of the Creative-Commons-License CC-BY 4.0</licence>
            </availability>
            <idno type="url">http://aloys-hirt.bbaw.de/api/cmif.xql</idno>
        </publicationStmt>
        <sourceDesc>
            <bibl type="online" xml:id="b5a85c01-d337-4c21-9825-3b4d9ff49241">
                Aloys Hirt. Briefwechsel und amtliche Schriften. Bearbeitet von Uta Motschmann. Berlin-Brandenburgische Akademie der Wissenschaften, Berlin 2016-2019.
                <ref target="https://aloys-hirt.bbaw.de">https://aloys-hirt.bbaw.de</ref>
            </bibl>
        </sourceDesc>
    </fileDesc>

return
cmif-api:create($config, $fileDesc)