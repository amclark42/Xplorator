<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">


    <xsl:output media-type="application/html" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="xpath">//*/name()</xsl:param>
    <xsl:template match="/">
        <xsl:variable name="results" as="item()*">
            <xsl:evaluate xpath="$xpath" context-item="."/>
        </xsl:variable>
    <!--<xsl:value-of select="not(empty($results))"></xsl:value-of>-->
        <xsl:choose>
            <xsl:when test="not(empty($results))">
        <!--<xsl:message>XPATH!: <xsl:value-of select="$xpath"/></xsl:message>-->
                <ul>
                    <xsl:for-each select="$results">
                        <li>
                            <xsl:value-of select="."/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>
        <!--<xsl:message>No XPath. ;_;</xsl:message>-->
                <p>No results found.</p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
