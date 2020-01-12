<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:as="http://amclark42.net/ns/functions"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="2.0">
  <!--
    ...
    
    Ashley M. Clark
    2020
  -->
  
  <xsl:output encoding="UTF-8" indent="no" method="xhtml"/>
  
  <!--  PARAMETERS  -->
  <xsl:param name="debug" select="false()" as="xs:boolean"/>
  <xsl:param name="standalone" select="false()" as="xs:boolean"/>
  
  <!--  GLOBAL VERIABLES  -->
  
  
  <!--  IDENTITY TEMPLATES  -->
  
  <xsl:template match="*" mode="#all">
    <span>
      <xsl:call-template name="element-data"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>
  
  <!-- Attributes become HTML data attributes. -->
  <xsl:template match="@*" mode="#all">
    <xsl:variable name="attName" select="name()"/>
    <xsl:variable name="dataAttName" select="lower-case(local-name())"/>
    <xsl:attribute name="data-{$dataAttName}">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <!-- Preserve the original attribute name. -->
    <xsl:if test="$attName ne $dataAttName">
      <xsl:attribute name="data-{$dataAttName}-name">
        <xsl:value-of select="$attName"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text() | comment() | processing-instruction()" mode="#all">
    <xsl:copy/>
  </xsl:template>
  
  
  <!--  TEMPLATES, #default mode  -->
  
  <xsl:template match="/">
    <xsl:variable name="content">
      <div id="viewer">
        <xsl:apply-templates/>
      </div>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$standalone">
        <html>
          <head>
            
          </head>
          <body>
            <xsl:copy-of select="$content"/>
          </body>
        </html>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!--  NAMED TEMPLATES  -->
  
  <!-- Create some data attributes with information about the XML element. -->
  <xsl:template name="element-data">
    <xsl:variable name="myNamespace" select="namespace-uri()"/>
    <xsl:variable name="myParent" select="parent::*"/>
    <xsl:attribute name="data-gi" select="name()"/>
    <!-- Don't bother listing the namespace URI unless it differs from this element's parent's 
      namespace URI. -->
    <xsl:if test="$myNamespace ne namespace-uri($myParent)">
      <xsl:attribute name="data-ns" select="namespace-uri()"/>
    </xsl:if>
    <xsl:attribute name="data-axis-parent" select="$myParent/name()"/>
    <xsl:attribute name="data-axis-children">
      <xsl:value-of select="as:list-nodes(node())"/>
    </xsl:attribute>
  </xsl:template>
  
  
  <!--  FUNCTIONS  -->
  
  <!-- Given a sequence of nodes, create a string list representation of the sequence. Names in the list 
    will be separated by commas. -->
  <xsl:function name="as:list-nodes" as="xs:string">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:variable name="nodeStrs" as="xs:string*">
      <xsl:for-each select="$nodes">
        <xsl:choose>
          <xsl:when test="self::*">
            <xsl:value-of select="name()"/>
          </xsl:when>
          <xsl:when test="self::text()">
            <xsl:text>text()</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="string-join($nodeStrs, ',')"/>
  </xsl:function>
  
</xsl:stylesheet>
