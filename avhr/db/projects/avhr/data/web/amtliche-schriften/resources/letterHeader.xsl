<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:param name="erschlossen"/>
    <xsl:param name="cacheLetterIndex"/>
    <!-- Auswahl ob transkribierter oder erschlossener Brief -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$erschlossen='true'">
                <xsl:apply-templates mode="erschlossenerBrief"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="transkribierterBrief"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- HTML für erschlossenen Brief -->
    <xsl:template match="tei:teiHeader" mode="erschlossenerBrief">
        <xsl:if test="//tei:abstract//text()">
            <div class="grid_11 box whitebox">
                <div class="boxInner erschlossen summary">
                    <p>
                        <span class="label">Regest: </span>
                        <xsl:apply-templates select="//tei:abstract" mode="#current"/>
                    </p>
                </div>
            </div>
        </xsl:if>
        <xsl:if test="//tei:correspDesc/tei:note">
            <div class="grid_11 box whitebox">
                <div class="boxInner erschlossen note">
                    <span class="fussnotenpfeil"> </span>
                    <p>
                        <span class="label">Anmerkung: </span>
                        <xsl:apply-templates select="//tei:correspDesc/tei:note" mode="#current"/>
                    </p>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- Weitere Regeln -->
    <xsl:template mode="#all" match="tei:teiHeader//tei:ref">
        <xsl:variable name="class">
            <xsl:if test="matches(@target, 'zotero')">
                <xsl:text>zotero</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="target">
            <xsl:choose>
                <xsl:when test="matches(@target, 'http://') or matches(@target, 'https://')">
                    <xsl:value-of select="@target"/>
                </xsl:when>
                <xsl:when test="matches(@target, '/')">
                    <xsl:text>detail.xql?id=</xsl:text>
                    <xsl:value-of select="substring-before(@target, '/')"/>
                    <xsl:value-of select="substring-after(@target, '/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>detail.xql?id=</xsl:text>
                    <xsl:value-of select="@target"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="letterTitle">
            <!-- TODO: cacheIndex aktivieren -->
            <!-- <xsl:value-of select="doc($cacheLetterIndex)//entry[@id=$letterID]/text()"/> -->
        </xsl:variable>
        <a class="{$class}" href="{$target}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:persName">
        <xsl:variable name="id">
            <xsl:value-of select="@key"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@cert='low'">
                <span class="tooltip">
                    <span class="fussnote">
                        <span class="fussnotenpfeil"> </span>
                        <xsl:text>Identifizierung der Person unsicher</xsl:text>
                    </span>
                    <a href="../register/personen/detail.xql?id={$id}">
                        <xsl:apply-templates mode="#current"/>
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <a href="../register/personen/detail.xql?id={$id}">
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="#all" match="tei:orgName">
        <a href="../register/einrichtungen/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:placeName">
        <a href="../register/orte/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:rs[@type='place']">
        <a href="../register/orte/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <!-- Hirt -->
    <xsl:template mode="#all" match="tei:rs[@type='artwork']">
        <a href="../register/objekte/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:rs[@type='person']">
        <xsl:variable name="id">
            <xsl:value-of select="@key"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@cert='low'">
                <span class="tooltip">
                    <span class="fussnote">
                        <span class="fussnotenpfeil"> </span>
                        <xsl:text>Identifizierung der Person unsicher</xsl:text>
                    </span>
                    <a href="../register/personen/detail.xql?id={$id}">
                        <xsl:apply-templates mode="#current"/>
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <a href="../register/personen/detail.xql?id={$id}">
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="#all" match="tei:bibl[@sameAs and not(ancestor::tei:seg and ancestor::tei:note)]">
        <a href="../register/werke/detail.xql?id={./@sameAs}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:bibl[@sameAs and ancestor::tei:seg and ancestor::tei:note]">
        <a class="bibl" href="../register/werke/detail.xql?id={./@sameAs}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
</xsl:stylesheet>