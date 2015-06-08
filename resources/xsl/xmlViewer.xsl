<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  version="2.0">

  <xsl:output indent="yes"/>
  <xsl:param name="debug" select="false()" as="xs:boolean"/>
  <xsl:variable name="gt">&gt;</xsl:variable>
  <xsl:variable name="lt">&lt;</xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="comment() | text()">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template name="xml-viewer">
    <xsl:variable name="name" select="name()"/>
    <xsl:variable name="attributes">
      <xsl:for-each select="@*">
        <xsl:text> </xsl:text>
        <xsl:value-of select="concat(name(),'=',.)"/>
      </xsl:for-each>
    </xsl:variable>
    
    <span class="xmldoc">
      <xsl:value-of select="concat($lt,$name)"/>
      <xsl:if test="$attributes">
        <xsl:value-of select="$attributes"/>
      </xsl:if>
      <xsl:value-of select="$gt"/>
    </span>
    <xsl:apply-templates/>
    <span class="xmldoc"><xsl:value-of select="concat($lt,'/',$name,$gt)"/></span>
  </xsl:template>
  
</xsl:stylesheet>
