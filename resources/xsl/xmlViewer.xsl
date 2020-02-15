<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:as="http://amclark42.net/ns/functions"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="2.0">
  <!--
    Xplorator XML Viewer
    
    Converts a well-formed XML file into HTML5, with list items representing the tree structure.
    
    Ashley M. Clark
    2020
  -->
  
  <xsl:output encoding="UTF-8" indent="no" method="xhtml"/>
  
  <!--
    
    PARAMETERS
    
    -->
  
  <!-- Set $include-controller to false() in order to skip adding an XHTML snippet before the XML proxy. 
    By default, the output will contain an XHTML form with input controls. -->
  <xsl:param name="include-controller" select="true()" as="xs:boolean"/>
      <!--  -->
      <xsl:param name="controller" as="node()*">
        <div id="controller">
          <div id="controls" role="form">
            <div>
              <label for="xpath-code">XPath: </label>
              <input type="text" id="xpath-code" name="xpath-code" spellcheck="false"></input>
            </div>
            <button name="step">Next step</button>
          </div>
          <div id="summary">
            <div>
              <label for="current-xpath">Current XPath: </label>
              <output name="current-xpath" form="controls" for="xpath-code"></output>
            </div>
          </div>
        </div>
      </xsl:param>
  <!-- Set $standalone to true() in order to output a complete XHTML document. By default, only a 
    fragment is returned. -->
  <xsl:param name="standalone" select="false()" as="xs:boolean"/>
      <!--  -->
      <xsl:param name="assets-scripts" as="node()*">
        <script src="https://d3js.org/d3.v5.min.js"></script>
        <script src="resources/scripts/xplorator.js"></script>
      </xsl:param>
      <!--  -->
      <xsl:param name="assets-styles" as="node()*">
        <link rel="stylesheet"
           href="https://fonts.googleapis.com/css?family=Ubuntu+Mono&amp;display=swap"></link>
        <link rel="stylesheet" href="resources/css/style.css"></link>
      </xsl:param>
  
  
  <!--
    
    GLOBAL VERIABLES
    
    -->
  
  
  <!--
    
    IDENTITY TEMPLATES
    
    -->
  
  <xsl:template match="*" mode="#all">
    <xsl:variable name="isList" select="not(empty(node()))"/>
    <li>
      <xsl:attribute name="data-node-type" select="'element()'"/>
      <xsl:call-template name="name-data"/>
      <xsl:call-template name="axis-parent"/>
      <xsl:call-template name="axis-children"/>
      <xsl:call-template name="node-labels"/>
      <ol class="node-container">
        <xsl:apply-templates mode="#current"/>
      </ol>
    </li>
  </xsl:template>
  
  <!-- Attributes become HTML data attributes. -->
  <xsl:template match="@*" mode="#all">
    <xsl:variable name="attName" select="name()"/>
    <xsl:variable name="useQuoteMark">
      <xsl:variable name="double">
        <xsl:text>"</xsl:text>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains(., $double)">
          <xsl:text>'</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$double"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text> </xsl:text>
    <li class="code">
      <xsl:attribute name="data-node-type" select="'attribute()'"/>
      <xsl:call-template name="name-data"/>
      <xsl:value-of select="$attName"/>
      <xsl:text>=</xsl:text>
      <xsl:value-of select="$useQuoteMark"/>
      <xsl:value-of select="."/>
      <xsl:value-of select="$useQuoteMark"/>
    </li>
    <xsl:text> </xsl:text>
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
  
  
  <!--
    
    TEMPLATES, #default mode
    
    -->
  
  <xsl:template match="/">
    <div>
      <xsl:if test="$include-controller">
        <xsl:copy-of select="$controller"/>
      </xsl:if>
      <div id="viewer">
        <ol id="document-node" class="node-container">
          <xsl:attribute name="data-node-type" select="'document-node()'"/>
          <xsl:call-template name="axis-children"/>
          <xsl:apply-templates select="node()"/>
        </ol>
      </div>
    </div>
  </xsl:template>
  
  <!-- In standalone mode, build an HTML document around the representation of the XML document. -->
  <xsl:template match="document-node()[$standalone]">
    <html lang="en">
      <head>
        <xsl:copy-of select="$assets-styles"/>
        <xsl:copy-of select="$assets-scripts"/>
      </head>
      <body>
        <xsl:next-match/>
      </body>
    </html>
  </xsl:template>
  
  
  <!--
    
    NAMED TEMPLATES
    
    -->
  
  <!-- Identify the current node's children. -->
  <xsl:template name="axis-children">
    <xsl:variable name="children" select="( node() | comment() | processing-instruction() )"/>
    <xsl:attribute name="data-axis-children">
      <xsl:value-of select="as:list-nodes($children)"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Identify the current node's parent. -->
  <xsl:template name="axis-parent">
    <xsl:attribute name="data-axis-parent" select="parent::*/name()"/>
  </xsl:template>
  
  <!-- Create some data attributes with information about the XML element. -->
  <xsl:template name="name-data">
    <xsl:variable name="myNamespace" select="namespace-uri()"/>
    <xsl:attribute name="data-name" select="name()"/>
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
      <span class="attr-container">
        <!--<span class="heading">Attributes:</span>-->
        <ul>
          <xsl:apply-templates select="@*" mode="#current"/>
        </ul>
      </span>
    </span>
  </xsl:template>
  
  
  <!--
    
    FUNCTIONS
    
    -->
  
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
