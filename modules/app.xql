xquery version "3.1";

  module namespace exp="http://amclark42.net/ns/xplorator/functions";
(:  LIBRARIES  :)
  import module namespace xpol="http://amclark42.net/ns/xpollinator";
(:  NAMESPACES  :)
  declare default element namespace "http://www.w3.org/1999/xhtml";
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace http="http://expath.org/ns/http-client";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  (: eXist has "request" bound to an eXist-specific URI. :)
  (:declare namespace request="http://exquery.org/ns/request";:)
  declare namespace rest="http://exquery.org/ns/restxq";

(:~
  Functions, RESTXQ and otherwise, for the Xplorator.
  
  @author Ashley M. Clark
  2020
 :)
 
(:  VARIABLES  :)
  

(:  FUNCTIONS  :)
  
  declare
    %rest:GET
    %rest:path('/xplorator')
    %output:method('xhtml')
  function exp:get-form() {
    let $form :=
      <form action="xplorator/browser" method="post" autocomplete="off" 
         enctype="multipart/form-data">
        <div>
          <label for="xmlfile">XML file:</label>
          <input type="file" id="xmlfile" name="xmlfile" required="true"
             accept=".xml,.tei,text/xml,application/xml,text/*+xml,application/*+xml" />
        </div>
        <button type="submit">Transform</button>
      </form>
    let $body := (
        attribute lang { 'en' },
        <div>
          { $form }
        </div>
      )
    return exp:fill-template((), $body)
  };
  
  declare
    %rest:POST
    %rest:path('/xplorator/browser')
    %rest:consumes('multipart/form-data')
    %rest:form-param('xmlfile', '{$xml-file}', '<fallback/>')
    %output:method('xhtml')
  function exp:submit-xml($xml-file) {
    let $input :=
      typeswitch ($xml-file)
        case node() return $xml-file
        case map(*) return
          for $filename in map:keys($xml-file)
          let $binary := $xml-file?($filename)
          let $str := bin:decode-string($binary)
          return try { parse-xml($str) } catch * { 'error' }
        default return
          try { parse-xml($xml-file)
          } catch * { 'error' }
    let $xslMap := map {
        'source-node': $input,
        'stylesheet-node': doc("../resources/xsl/xmlViewer.xsl")
      }
    let $result := xpol:transform($xslMap)
    return
      exp:fill-template((), $result?('output'))
  };
  
  declare
    %rest:GET
    %rest:path('/xplorator/resources/{$type}/{$filename}')
    %output:method('text')
  function exp:get-resource($type as xs:string, $filename as xs:string) {
    let $filepath := concat("../resources/",$type,"/",$filename)
    let $media-type :=
      switch ($type)
        case 'css' return 'text/css'
        case 'scripts' return 'application/javascript'
        case 'xml' return 'text/xml'
        case 'xsl' return 'application/xml'
        default return 'text/plain'
    return
      if ( $type ne 'images' and unparsed-text-available($filepath) ) then
      (
        <rest:response>
          <http:response status="200">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
            <http:header name="Content-Type" value="{$media-type}; charset=UTF-8"/>
          </http:response>
        </rest:response>,
        unparsed-text($filepath)
      )
      else
        <http:response status="404" message="Not found."/>
  };


(:  SUPPORT FUNCTIONS  :)
  
  declare %private function exp:fill-template($title as xs:string?, $body as item()*) {
    <html>
      <head lang="en">
        <title>{ if ( $title ) then concat($title,' | ') else () }Xplorator</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Ubuntu+Mono&amp;display=swap" />
        <link rel="stylesheet" href="resources/css/style.css" />
        <script src="https://d3js.org/d3.v5.min.js" />
        <script src="resources/scripts/xplorator.js" />
      </head>
      <body>{ $body }</body>
    </html>
  };
