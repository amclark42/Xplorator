<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mtx="http://xplorator.org/metallix"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="comment() | text()">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="body">
    <mtx:sc xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:sc>
  </xsl:template>
  
  <xsl:template match="head">
    <mtx:rh xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:rh>
  </xsl:template>
  
  <xsl:template match="div">
    <mtx:ti xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:ti>
  </xsl:template>
  
  <xsl:template match="p">
    <mtx:cr xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:cr>
  </xsl:template>
  
  <xsl:template match="ul">
    <mtx:ne xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:ne>
  </xsl:template>
  <xsl:template match="ol">
    <mtx:nb xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:nb>
  </xsl:template>
  <xsl:template match="li">
    <mtx:mn xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:mn>
  </xsl:template>
  
  <xsl:template match="code">
    <mtx:fe xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:fe>
  </xsl:template>
  
  <xsl:template match="hi">
    <mtx:pd xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:pd>
  </xsl:template>
  
  <xsl:template match="box">
    <mtx:ir xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:ir>
  </xsl:template>
  
  <xsl:template match="ref">
    <mtx:zn xml:id="{generate-id()}">
      <xsl:attribute name="au" select="@target"/>
      <xsl:apply-templates/>
    </mtx:zn>
  </xsl:template>
  
  <xsl:template match="changelog">
    <mtx:changelog xml:id="{generate-id()}">
      <xsl:apply-templates/>
    </mtx:changelog>
  </xsl:template>
  <xsl:template match="change">
    <mtx:change xml:id="{generate-id()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </mtx:change>
  </xsl:template>
  
  <xsl:template match="*">
    <DEBUG>
      <xsl:copy-of select="."/>
    </DEBUG>
  </xsl:template>
  
</xsl:stylesheet>