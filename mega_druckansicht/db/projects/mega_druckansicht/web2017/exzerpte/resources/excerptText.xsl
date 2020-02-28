<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    <xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN" indent="yes"/>
    <xsl:param name="file"/>
    <xsl:param name="baseURL"/>
    <xsl:param name="section-id"/>
    <xsl:param name="view"/>
    <xsl:include href="../../resources/xslt/transcription-excerpt.xsl"/>

    <xsl:key name="section-by-section-number" match="tei:div[@n]">
        <xsl:number level="multiple" count="tei:div[@n]"/>
    </xsl:key>

    <xsl:template match="/">
        <xsl:variable name="section" select="key('section-by-section-number', $section-id)"/>
        <div class="subnavbar">
            <ul>
                <xsl:for-each select="$section/ancestor-or-self::tei:div[@n]">
                    <li>
                        <a>
                            <xsl:value-of select="tei:head[last()]"/>
                        </a>
                        <xsl:if test="position() ne last()">
                            <xsl:text> / </xsl:text>
                        </xsl:if>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
        <div class="grid_11 box whitebox">
            <div class="boxInner transkription">
                <xsl:choose>
                    <xsl:when test="$section">
                        <xsl:apply-templates select="$section"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="notfound">
                            <p>Fehler!<br/>Es wurde kein entsprechendes Dokument in der Datenbank
                                gefunden.</p>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
        <div class="grid_5">
            <xsl:apply-templates select="//tei:body" mode="TOC"/>
        </div>
    </xsl:template>

    <xsl:template mode="TOC" match="tei:div[@n]" priority="3">
        <xsl:variable name="id">
            <xsl:number level="multiple" count="tei:div[@n]"/>
        </xsl:variable>
        <xsl:variable name="id-parts" select="tokenize($id, '\.')"/>
        <xsl:variable name="level" select="count($id-parts)" as="xs:integer"/>
        <xsl:variable name="issue-id" select="string-join(($id-parts[1], $id-parts[2]), '.')"/>
        <xsl:variable name="query-string" select="                 if ($level gt 2) then                     concat('id=', $issue-id, '#', $id)                 else                     concat('id=', $id)"/>
        <li class="toc-level{$level} toc-entry">
            <xsl:variable name="toggle-state" select="                     if ($level eq 1) then                         ('fa-caret-down', 'visible')                     else                         ('fa-caret-right', 'invisible')"/>
            <span class="toc-entry-title{if ($id eq $section-id) then ' current' else ''}">
                <xsl:if test="tei:div[@n]">
                    <i class="toggle fa {$toggle-state[1]}" aria-hidden="true"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <a href="{$baseURL}/exzerpte/detail.xql?{$query-string}" id="toc{$id}">
                    <xsl:apply-templates mode="#current" select="tei:head[last()]/node()"/>
                </a>
            </span>
            <xsl:if test="tei:div">
                <ul class="{$toggle-state[2]}">
                    <xsl:apply-templates mode="#current" select="tei:div"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template mode="TOC" match="tei:persName" priority="2">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template mode="TOC" match="*[tei:div | tei:head]" priority="2">
        <xsl:apply-templates mode="#current" select="tei:div | tei:head"/>
    </xsl:template>

    <xsl:template mode="TOC" match="*" priority="1">
        <xsl:apply-templates mode="#current" select="node()"/>
    </xsl:template>

    <xsl:template mode="TOC" match="text()[not(ancestor::tei:head)]">
        <!--  Delete -->
    </xsl:template>


</xsl:stylesheet>