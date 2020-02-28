<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    
    <!-- ##### Textbearbeitungen durch den Autor ##### -->
    <xsl:template mode="lesetext" match="tei:del"/>
    <xsl:template mode="lesetext" match="tei:add">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- ##### Textbearbeitungen durch den Herausgeber ##### -->
    <xsl:template mode="lesetext" match="tei:ex">
        <em>
            <xsl:value-of select="."/>
        </em>
    </xsl:template>
    <xsl:template mode="lesetext" match="tei:unclear">
        <xsl:choose>
            <xsl:when test="child::*|text()">
                <span class="unclear">
                    <xsl:apply-templates mode="#current"/>
                    <span class="symbol"> (?)</span>
                </span>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="lesetext" match="tei:gap">
        <span class="gap"> [...] </span>
    </xsl:template>
    <xsl:template mode="lesetext" match="tei:supplied">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template mode="lesetext" match="tei:surplus"/>
    <xsl:template mode="lesetext" match="tei:choice[./tei:sic]">
        <xsl:apply-templates mode="#current" select="tei:corr"/>
    </xsl:template>
</xsl:stylesheet>