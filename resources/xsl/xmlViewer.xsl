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
    <xsl:variable name="isList" select="not(empty(node()))"/>
    <li>
      <xsl:call-template name="element-data"/>
      <xsl:call-template name="axis-parent"/>
      <xsl:call-template name="axis-children"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="node-labels"/>
      <ol>
        <xsl:apply-templates mode="#current"/>
      </ol>
    </li>
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
  
  <xsl:template match="text()" mode="#all">
    <li>
      <xsl:attribute name="data-node-type" select="'text()'"/>
      <xsl:copy/>
    </li>
  </xsl:template>
  
  <xsl:template match="comment()" mode="#all">
    <li>
      <xsl:attribute name="data-node-type" select="'comment()'"/>
      <xsl:text><![CDATA[<!--]]></xsl:text>
      <xsl:value-of select="."/>
      <xsl:text><![CDATA[-->]]></xsl:text>
    </li>
  </xsl:template>
  
  
  <!--  TEMPLATES, #default mode  -->
  
  <xsl:template match="/">
    <xsl:variable name="content">
      <div id="viewer">
        <ol id="document-node">
          <xsl:attribute name="data-node-type" select="'document-node()'"/>
          <xsl:call-template name="axis-children"/>
          <xsl:apply-templates select="node()"/>
        </ol>
      </div>
    </xsl:variable>
    <xsl:choose>
      <!-- In standalone mode, build an HTML document around the representation of the XML document. -->
      <xsl:when test="$standalone">
        <html lang="en">
          <head>
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Ubuntu+Mono&amp;display=swap"></link>
            <link rel="stylesheet" href="resources/css/style.css"></link>
            <script src="https://d3js.org/d3.v5.min.js"></script>
            <script src="resources/scripts/xplorator.js"></script>
          </head>
          <body>
            <xsl:copy-of select="$content"/>
          </body>
        </html>
      </xsl:when>
      <!-- By default, simply output the <div> container. -->
      <xsl:otherwise>
        <xsl:copy-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!--  NAMED TEMPLATES  -->
  
  <!-- Identify the current node's children. -->
  <xsl:template name="axis-children">
    <xsl:variable name="children" 
      select="( node() | comment() | processing-instruction() )"/>
    <xsl:attribute name="data-axis-children">
      <xsl:value-of select="as:list-nodes($children)"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Identify the current node's parent. -->
  <xsl:template name="axis-parent">
    <xsl:attribute name="data-axis-parent" select="parent::*/name()"/>
  </xsl:template>
  
  <!-- Create some data attributes with information about the XML element. -->
  <xsl:template name="element-data">
    <xsl:variable name="myNamespace" select="namespace-uri()"/>
    <xsl:attribute name="data-gi" select="name()"/>
    <!-- Don't bother listing the namespace URI unless it differs from this element's parent's 
      namespace URI. -->
    <xsl:if test="$myNamespace ne namespace-uri(parent::*)">
      <xsl:attribute name="data-ns" select="namespace-uri()"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Create human-readable labels for this node's HTML representation. -->
  <xsl:template name="node-labels">
    <span class="container">
      <span class="code node-label">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
      </span>
    </span>
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
          <xsl:when test="self::comment()">
            <xsl:text>comment()</xsl:text>
          </xsl:when>
          <xsl:when test="self::processing-instruction()">
            <xsl:text>processing-instruction()</xsl:text>
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
