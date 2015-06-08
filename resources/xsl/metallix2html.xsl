<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mtx="http://xplorator.org/metallix"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs mtx"
  version="2.0">
  
  <xsl:import href="xmlViewer.xsl"/>
  <xsl:output media-type="text/html" omit-xml-declaration="yes"/>
  <xsl:variable name="filename" select="(tokenize(document-uri(.),'/'))[last()]"/>
  
  <xsl:template match="mtx:sc">
    <body id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </body>
  </xsl:template>
  
  <xsl:template match="mtx:rh">
    <h3 id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </h3>
  </xsl:template>
  
  <xsl:template match="mtx:ti">
    <div id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </div>
  </xsl:template>
  
  <xsl:template match="mtx:cr">
    <p id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </p>
  </xsl:template>
  
  <xsl:template match="mtx:ne">
    <ul id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </ul>
  </xsl:template>
  <xsl:template match="mtx:nb">
    <ol id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </ol>
  </xsl:template>
  <xsl:template match="mtx:mn">
    <li id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </li>
  </xsl:template>
  
  <xsl:template match="mtx:fe">
    <code id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </code>
  </xsl:template>
  
  <xsl:template match="mtx:pd">
    <span id="{concat($filename,'__',@xml:id)}" class="emph">
      <xsl:call-template name="xml-viewer"/>
    </span>
  </xsl:template>
  
  <xsl:template match="mtx:ir">
    <div id="{concat($filename,'__',@xml:id)}" class="popout">
      <xsl:call-template name="xml-viewer"/>
    </div>
  </xsl:template>
  
  <xsl:template match="mtx:zn">
    <a href="{@au}" id="{concat($filename,'__',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </a>
  </xsl:template>
  
  <xsl:template match="mtx:changelog">
    <xsl:call-template name="xml-viewer"/>
  </xsl:template>
  <xsl:template match="mtx:change">
    <xsl:call-template name="xml-viewer"/>
  </xsl:template>
  
</xsl:stylesheet>