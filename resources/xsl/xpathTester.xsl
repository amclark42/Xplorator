<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:output media-type="application/html" indent="yes"
    omit-xml-declaration="yes"/>
  
  <xsl:param name="xpath">//@uncommon</xsl:param>
  
  <xsl:variable name="letters">a-zA-Z</xsl:variable>
  <xsl:variable name="validNameChars" select="concat('[',$letters,'_][',$letters,'0-9.-_]*')"/>
  
  <xsl:template match="/">
    <wrapper>
      <xsl:call-template name="tokenizeOne">
        <xsl:with-param name="input" select="$xpath"/>
      </xsl:call-template>
    </wrapper>
  </xsl:template>
  
  <xsl:template name="tokenizeOne">
    <xsl:param name="input" as="xs:string" required="yes"/>
    
    <xsl:choose>
      <xsl:when test="$input=''"/>
      <xsl:when test="matches($input,'^//')">
        <item>//</item>
        <xsl:call-template name="tokenizeOne">
          <xsl:with-param name="input" select="replace($input,'^//','')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($input, '^/')">
        <item>/</item>
        <xsl:call-template name="tokenizeOne">
          <xsl:with-param name="input" select="replace($input,'^/','')"/>
        </xsl:call-template>
      </xsl:when>
      
      <xsl:when test="matches($input,string(concat('^@',$validNameChars)))">
        <item>yes</item>
        <xsl:call-template name="tokenizeOne">
          <xsl:with-param name="input" select="replace($input,concat('^@',$validNameChars),'')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <item><xsl:value-of select="$input"/></item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="allowedFunction">
    <xsl:param name="term"></xsl:param>
    <xsl:variable name="functName" select="substring-before($term,'(')"/>
    <xsl:variable name="params" select="replace(substring($term,string-length($functName)),').*$','')"/>
    <debug><xsl:value-of select="$params"/></debug>
    <!--<xsl:choose>
      <xsl:when test="">
        
      </xsl:when>
    </xsl:choose>-->
  </xsl:template>
  
</xsl:stylesheet>
