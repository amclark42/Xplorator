xquery version "3.0";

module namespace app="http://wwp.northeastern.edu/templates";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://wwp.northeastern.edu/config" at "config.xqm";
import module namespace transform="http://exist-db.org/xquery/transform";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated). 
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

(: Test string for XPath-ability. :)
(:declare %private function local:sanitize($xpath as xs:string) {
    
};:)

(: Create a list of results. :)
(:declare %private function local:listify($results as ) {
    
};:)

(: Run a user-defined XPath. :)
declare function app:runXPath($node as node(), $model as map(*), $xpath as xs:string?) {
    let $testDoc := "doc('../resources/xml/whyXPath.xml')"
    (:let $tester := doc('../resources/xsl/xpathTester.xsl'):)
    let $allPath := concat($testDoc,$xpath)
    return
      <div class="results"> {
        if ($xpath) then (
          <p>{$xpath}</p>,
          (:$testDoc:)
          util:eval($allPath)
          )
        else ()
        }
      </div>
};
