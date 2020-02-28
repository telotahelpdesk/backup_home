<xsl:stylesheet xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei exist" version="2.0">
    <!-- ##### Strukturelemente ##### -->
    <xsl:param name="id"/>
    <xsl:param name="cacheLetterIndex"/>
    <xsl:template mode="#all" match="tei:p">
        <p>
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    <xsl:template match="tei:hi[@rendition='#u']" mode="kritischerText lesetext">
        <span class="unterstrichen">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:hi[@rendition='#sup']" mode="kritischerText lesetext">
        <span class="hochgestellt">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="leseText kritischerText" match="tei:pb">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:div">
                <div class="grid_16">
                    <p class="folio">
                        <a name="{./@n}">
                            <xsl:value-of select="./@n"/>
                        </a>
                        <xsl:if test="./@facs">
                            <br/>
                            <a class="facs" href="detail.xql?id={$id}&amp;view=f#{@facs}"></a>
                        </xsl:if>
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
    <xsl:template mode="#all" match="tei:lb">
        <br/>
    </xsl:template>
    <xsl:template mode="#all" match="tei:foreign">
        <span>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="#all" match="tei:list">
        <xsl:choose>
            <xsl:when test="@type='ordered'">
                <ol>
                    <xsl:for-each select="tei:item">
                        <li>
                            <xsl:apply-templates mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:for-each select="tei:item">
                        <li>
                            <xsl:apply-templates mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="#all" match="tei:note[@resp='Autor']">
        <span class="autorenfussnote">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="#all" match="tei:salute|tei:address">
        <p>
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    <xsl:template mode="#all" match="tei:dateline">
        <p style="text-align: right">
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    <xsl:template mode="#all" match="tei:table">
        <table>
            <xsl:for-each select="tei:row">
                <tr>
                    <xsl:choose>
                        <xsl:when test="@role='label'">
                            <xsl:for-each select="tei:cell">
                                <th>
                                    <xsl:apply-templates mode="#current"/>
                                </th>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="tei:cell">
                                <td>
                                    <xsl:apply-templates mode="#current"/>
                                </td>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>   
    <!-- ##### Indizierungen ##### -->
    <xsl:template mode="#all" match="tei:persName">
        <a href="../register/personen/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:placeName">
        <a href="../register/orte/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:rs[@type='person']">
        <a href="../register/personen/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:bibl[@sameAs]">
        <a href="../register/werke/detail.xql?id={./@sameAs}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:bibl[@type='bibelstelle']">
        <a href="http://www.bibleserver.com/go.php?lang=de&amp;bible=LUT&amp;ref={./@corresp}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:date">
        <a href="../zeit/zeitsuche_ergebnis.xql?datum={./@when}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <!-- ##### Verweise -->
    <xsl:template mode="#all" match="tei:rs[@type='letter']">
        <xsl:choose>
            <xsl:when test="@type='erschlossenerBrief'">
                <span class="rs">
                    <xsl:apply-templates mode="#current"/>
                    <a class="erschlossenerBrief" href="../briefe/detail.xql?id={@key}" title="Zum erschlossenen Brief">
                        <span>Zum erschlossenen Brief</span></a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="rs">
                    <xsl:apply-templates mode="#current"/>
                    <a class="brief" href="../briefe/detail.xql?id={@key}" title="Zum Volltext des Briefes">
                        <span>Zum Volltext des Briefes</span></a>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="#all" match="tei:ref">
        <xsl:variable name="letterID">
            <xsl:choose>
                <xsl:when test="matches(@target, '/')">
                    <xsl:value-of select="substring-before(@target, '/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@target"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="letterTitle">
            <xsl:value-of select="doc($cacheLetterIndex)//entry[@id=$letterID]/text()"/>
        </xsl:variable>
        <a href="detail.xql?id={$letterID}">
            <xsl:value-of select="."/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$letterTitle"/>
        </a>
    </xsl:template>
    <!-- ##### Sachanmerkungen ##### -->
    <xsl:template mode="#all" match="tei:seg">
        <span class="tooltip">
            <span class="fussnote">
                <span class="fussnotenpfeil"> </span>
                <xsl:apply-templates select="tei:note" mode="#current"/>
            </span>
            <xsl:apply-templates select="tei:orig" mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="#all" match="tei:note[not(@resp='Autor')]">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <!-- gesuchte Begriffe, die durch die Suchfunktion von exist markiert worden sin -->
    <xsl:template mode="#all" match="exist:match">
        <span class="highlight">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- ##### nicht auf der Website erscheinende Elemente ##### -->
    <xsl:template mode="#all" match="tei:index"/>
    <xsl:template mode="#all" match="tei:comment"/>
</xsl:stylesheet>