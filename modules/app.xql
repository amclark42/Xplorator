xquery version "3.0";

module namespace app="http://wwp.northeastern.edu/templates";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://wwp.northeastern.edu/config" at "config.xqm";
import module namespace transform="http://exist-db.org/xquery/transform";

(: Test string for XPath-ability. :)
(:declare %private function local:sanitize($xpath as xs:string) {
    
};:)

(: Create a list of results. :)
declare %private function local:listify($results as ) {
    
};

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
