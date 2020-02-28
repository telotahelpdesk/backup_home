<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:template mode="faksimileText" match="tei:pb">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:div">
                <xsl:variable name="facsUrl_V">
                    <xsl:text>http://digilib.bbaw.de/digitallibrary/servlet/Scaler?fn=silo10/schleiermacher_edition/BBAW_SN437_Tageskalender_1808_</xsl:text>
                    <xsl:value-of select="@facs"/>
                    <xsl:text>.tif</xsl:text>
                </xsl:variable>
                <xsl:variable name="facsUrl_R">
                    <xsl:text>http://digilib.bbaw.de/digitallibrary/servlet/Scaler?fn=silo10/schleiermacher_edition/BBAW_SN437_Tageskalender_1808_</xsl:text>
                    <xsl:value-of select="number(replace(@facs, 'v|r', '')) + 1"/>
                    <xsl:text>.tif</xsl:text>
                </xsl:variable>
                <div class="grid_16 pagebreak">
                    <p class="folio">
                        <a name="{./@n}">
                            <xsl:value-of select="./@n"/>
                        </a>
                        <div id="faksimile">
                            <p>Faksimiles <xsl:value-of select="./@facs"/>-<xsl:value-of select="number(replace(@facs, 'v|r', '')) + 1"/>
                            </p>
                            <a href="{$facsUrl_V}&amp;dw=900" class="faksimileLeft">
                                <img src="{$facsUrl_V}&amp;dw=165" title="Faksimile von Folio {./@facs}"/>
                            </a>
                            <a href="{$facsUrl_R}&amp;dw=900" class="faksimileRight">
                                <img src="{$facsUrl_R}&amp;dw=165" title="Faksimile von Folio {number(replace(@facs, 'v|r', '')) + 1}"/>
                            </a>
                        </div>
                    </p>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="class">
                    <xsl:choose>
                        <xsl:when test="matches(@ed, 'Druck')">
                            <xsl:text>folio druck</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>folio</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="title">
                    <xsl:choose>
                        <xsl:when test="matches(@ed, 'Druck')">
                            <xsl:text>Seitenangabe der Druckausgabe</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Folioangabe aus dem Manuskript</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                | <xsl:if test="@n!=''">
                    <span class="{$class}" title="{$title}">
                        <a name="{./@n}">
                            <xsl:value-of select="./@n"/>
                        </a>
                    </span>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>