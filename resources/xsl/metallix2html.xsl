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
    <body id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </body>
  </xsl:template>
  
  <xsl:template match="mtx:rh[parent::mtx:ir]">
    <h3 id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </h3>
  </xsl:template>
  <xsl:template match="mtx:rh">
    <xsl:variable name="hLvl" select="2+count(ancestor::*/preceding-sibling::mtx:rh)"/>
    <xsl:element name="h{$hLvl}">
      <xsl:attribute name="id" select="concat($filename,'-',@xml:id)"/>
      <xsl:call-template name="xml-viewer"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="mtx:ti">
    <div id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </div>
  </xsl:template>
  
  <xsl:template match="mtx:cr">
    <p id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </p>
  </xsl:template>
  
  <xsl:template match="mtx:ne | mtx:nb">
    <div id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </div>
  </xsl:template>
  <xsl:template match="mtx:ne/mtx:mn[not(../preceding-sibling::mtx:mn)]">
    <ul>
      <xsl:call-template name="list-item"/>
    </ul>
  </xsl:template>
  <xsl:template match="mtx:nb/mtx:mn[not(../preceding-sibling::mtx:mn)]">
    <ol>
      <xsl:call-template name="list-item"/>
    </ol>
  </xsl:template>
  <xsl:template match="mtx:mn" name="list-item">
    <li id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </li>
  </xsl:template>
  
  <xsl:template match="mtx:fe">
    <code id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </code>
  </xsl:template>
  
  <xsl:template match="mtx:pd">
    <span id="{concat($filename,'-',@xml:id)}" class="emph">
      <xsl:call-template name="xml-viewer"/>
    </span>
  </xsl:template>
  
  <xsl:template match="mtx:ir">
    <div id="{concat($filename,'-',@xml:id)}" class="popout">
      <xsl:call-template name="xml-viewer"/>
    </div>
  </xsl:template>
  
  <xsl:template match="mtx:zn">
    <a href="{@au}" id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </a>
  </xsl:template>
  
  <xsl:template match="mtx:changelog | mtx:change">
    <div class="xmldoc" id="{concat($filename,'-',@xml:id)}">
      <xsl:call-template name="xml-viewer"/>
    </div>
  </xsl:template>
  
</xsl:stylesheet>