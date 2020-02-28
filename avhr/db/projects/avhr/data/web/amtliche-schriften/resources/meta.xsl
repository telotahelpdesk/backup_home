<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:param name="erschlossen"/>
    <xsl:param name="cacheLetterIndex"/>
    <xsl:template match="tei:teiHeader" mode="#all">
        <div id="meta">
            <div class="visible">
                <h2>
                    <span></span> Weitere Angaben zum Brief</h2>
            </div>
            <div class="invisible">
                <div id="correspDesc">
                    <xsl:if test="//tei:correspAction[@type='sent']/tei:persName[@key!='Humboldt_Alexander']">
                        <ul>
                            <h3>Absender</h3>
                            <xsl:for-each select="//tei:correspAction[@type='sent']/tei:persName[@key!='Humboldt_Alexander']">
                                <li>
                                    <a href="../register/personen/detail.xql?id={./@key}">
                                        <xsl:value-of select="./text()"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="//tei:correspAction[@type='sent']/tei:placeName">
                        <ul>
                            <h3>Schreibort</h3>
                            <xsl:for-each select="//tei:correspAction[@type='sent']/tei:placeName">
                                <li>
                                    <a href="../register/orte/detail.xql?id={./@key}">
                                        <xsl:value-of select="./text()"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="//tei:correspAction[@type='received']/tei:persName[@key!='Humboldt_Alexander']">
                        <ul>
                            <h3>Empfänger</h3>
                            <xsl:for-each select="//tei:correspAction[@type='received']/tei:persName[@key!='Humboldt_Alexander']">
                                <li>
                                    <a href="../register/personen/detail.xql?id={./@key}">
                                        <xsl:value-of select="./text()"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="//tei:correspAction[@type='received']/tei:placeName">
                        <ul>
                            <h3>Empfangsort</h3>
                            <xsl:for-each select="//tei:correspAction[@type='received']/tei:placeName">
                                <li>
                                    <a href="../register/orte/detail.xql?id={./@key}">
                                        <xsl:value-of select="./text()"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                </div>
                <xsl:if test="//tei:correspDesc/tei:note//text() and $erschlossen='false'">
                    <div id="note">
                        <h3>Anmerkungen zum Brief</h3>
                        <p>
                            <xsl:apply-templates select="//tei:correspDesc/tei:note"/>
                        </p>
                    </div>
                </xsl:if>
                <xsl:if test="//tei:physDesc//text()">
                    <div id="note">
                        <h3>Objektbeschreibung</h3>
                        <p>
                            <xsl:apply-templates select="//tei:physDesc"/>
                        </p>
                    </div>
                </xsl:if>
                <xsl:if test="(//tei:msIdentifier and //tei:sourceDesc//tei:witness) or (not(//tei:msIdentifier) and count(//tei:sourceDesc//tei:witness) &gt; 1)">
                    <h3>Weitere Überlieferung</h3>
                    <ul class="bibl">
                        <xsl:for-each select="//tei:sourceDesc//tei:bibl">
                            <xsl:variable name="counter">
                                <xsl:choose>
                                    <xsl:when test="count(//tei:sourceDesc//tei:bibl) &gt; 1">
                                        <xsl:text>D</xsl:text>
                                        <xsl:value-of select="position()"/>
                                        <xsl:text>: </xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>D: </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <li>
                                <i>
                                    <xsl:value-of select="$counter"/>
                                </i>
                                <xsl:apply-templates/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
            </div>
        </div>
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
</xsl:stylesheet>