<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Index of Aloys Hirt – Correspondence 1787–1837</title>
                        <editor>Stefan Dumont <email>dumont@bbaw.de</email>
                        </editor>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>
                            <ref target="http://www.bbaw.de">Berlin-Brandenburg Academy of Sciences and Humanities</ref>
                        </publisher>
                        <date when="{current-dateTime()}"/>
                        <availability>
                            <licence target="https://creativecommons.org/licenses/by/4.0/">This file is licensed under the terms of the Creative-Commons-License CC-BY 4.0</licence>
                        </availability>
                        <idno type="url">http://aloys-hirt.bbaw.de/briefe/cmif.xql</idno>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl type="online">
                            Aloys Hirt – Briefwechsel 1787–1837. Digitale Edition hrsg. von Uta Motschmann
                            <ref target="http://aloys-hirt.bbaw.de">http://aloys-hirt.bbaw.de</ref>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
                <profileDesc>
                    <xsl:copy-of select="."/>
                </profileDesc>
            </teiHeader>
            <text/>
        </TEI>
    </xsl:template>
</xsl:stylesheet>