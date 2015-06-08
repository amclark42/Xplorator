<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  version="2.0">

  <xsl:output indent="yes"/>
  <xsl:param name="debug" select="false()" as="xs:boolean"/>
  <xsl:variable name="gt">&gt;</xsl:variable>
  <xsl:variable name="lt">&lt;</xsl:variable>

  <xsl:template match="/">
    <xsl:call-template name="apply-templates"/>
  </xsl:template>
  <xsl:template match="comment() | text()">
    <xsl:copy/>
  </xsl:template>

  <!-- This is a temporary template, only meant for testing. -->
  <xsl:template match="*" mode="debug">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="xml-viewer">
        <xsl:with-param name="element" select="local-name()" as="xs:string"/>
        <xsl:with-param name="attributes">
          <xsl:for-each select="@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="concat(name(),'=',.)"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="apply-templates">
    <xsl:choose>
      <xsl:when test="$debug">
        <xsl:apply-templates mode="debug"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="xml-viewer">
    <xsl:param name="namespace"/>
    <xsl:param name="element" as="xs:string" required="yes"/>
    <xsl:param name="attributes" as="xs:string" required="yes"/>
    <xsl:variable name="node">
      <xsl:if test="string-length($namespace)>0">
        <xsl:value-of select="concat($namespace,':')"/>
      </xsl:if>
      <xsl:value-of select="$element"/>
    </xsl:variable>
    
    <span class="element">
      <xsl:attribute name="xml:id" select="@xml:id"></xsl:attribute>
      <span class="xmldoc">
        <xsl:value-of select="concat($lt,$node)"/>
        <xsl:value-of select="$gt"/>
      </span>
      <xsl:call-template name="apply-templates"/>
      <span class="xmldoc"><xsl:value-of select="concat($lt,'/',$node,$gt)"/></span>
    </span>
  </xsl:template>
  
</xsl:stylesheet>
