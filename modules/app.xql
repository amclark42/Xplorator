xquery version "3.1";

  module namespace exp="http://amclark42.net/ns/xplorator/functions";
(:  LIBRARIES  :)
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
    %rest:path('xplorator')
    %output:method('xhtml')
  function exp:get-form() {
    let $form :=
      <form method="post" enctype="multipart/form-data">
        <div>
          <label for="title">Title:</label>
          <input type="text" id="title" name="title" spellcheck="false"></input>
        </div>
        <div>
          <label for="xml-file">XML file:</label>
          <input type="file" id="xml-file" name="xml-file"></input>
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
  

(:  SUPPORT FUNCTIONS  :)
  
  declare %private function exp:fill-template($title as xs:string?, $body as item()*) {
    <html>
      <head lang="en">
        <title>{ if ( $title ) then concat($title,' | ') else () }Xplorator</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      </head>
      <body>{ $body }</body>
    </html>
  };
