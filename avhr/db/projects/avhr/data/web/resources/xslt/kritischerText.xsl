<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    
    <!-- ##### Textbearbeitungen durch den Autor ##### -->
    <xsl:template mode="kritischerText faksimileText" match="tei:del">
        <span class="del">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="kritischerText faksimileText" match="tei:add">
        <xsl:choose>
            <xsl:when test="@place!=''">
                <span class="add tooltip">
                    <span class="place fussnote">
                        <span class="fussnotenpfeil"> </span>
                        <xsl:value-of select="@place"/>
                    </span>
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="add">
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <!-- ##### Textbearbeitungen durch den Herausgeber ##### -->
    <xsl:template mode="kritischerText faksimileText" match="tei:ex">
        <em>
            <xsl:value-of select="."/>
        </em>
    </xsl:template>
    <xsl:template mode="kritischerText faksimileText" match="tei:unclear">
        <xsl:choose>
            <xsl:when test="child::*|text()">
                <span class="unclear">
                    <xsl:apply-templates mode="#current"/>
                    <span class="symbol"> (?)</span>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="unclear">
                    [...]<span class="symbol"> (?)</span>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="kritischerText faksimileText" match="tei:gap">
        <span class="gap"> [...] </span>
    </xsl:template>
    <xsl:template mode="kritischerText faksimileText" match="tei:supplied">
        <span class="supplied">[<xsl:apply-templates mode="#current"/>]</span>
    </xsl:template>
    <xsl:template mode="kritischerText faksimileText" match="tei:surplus">
        <span class="surplus">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="kritischerText faksimileText" match="tei:choice[./tei:sic]">
        <span class="choice">
            <span class="sic">
                <xsl:apply-templates mode="#current" select="tei:sic"/>
            </span>
            <span class="corr">
                <xsl:apply-templates mode="#current" select="tei:corr"/>
            </span>
        </span>
    </xsl:template>
</xsl:stylesheet>