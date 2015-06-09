xquery version "3.0";

module namespace app="http://wwp.northeastern.edu/templates";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://wwp.northeastern.edu/config" at "config.xqm";
import module namespace transform="http://exist-db.org/xquery/transform";

(: Test string for XPath-ability. :)
(:declare %private function app:sanitize($xpath as xs:string) {
    
};:)

(:  :)
declare %private function app:reduce-text($item as node()) as xs:string {
  let $allTxt := string-join($item//text(),' ')
  let $strLen := string-length($allTxt)
  return 
    if ($strLen > 40) then
      concat(substring($allTxt,1,20), ' ... ', substring($allTxt,$strLen - 20,$strLen))
    else $allTxt
};

(: Create a list of results. :)
declare %private function app:listify($xpath as xs:string) as node()* {
    <table>
      <tr>
        <th>Document</th>
        <th>Text</th>
        <th>Position</th>
        <th>Find node</th>
      </tr>
      {
        for $doc in ('xpathBasics','partsOfAnXPath','whyXPath')
        let $onDoc := concat("doc('../resources/xml/",$doc,".xml')",$xpath)
          for $result in util:eval($onDoc)
          return
            <tr>
              <td>{$doc}</td>
              <td>{app:reduce-text($result)}</td>
              <td>{util:node-xpath($result)}</td>
              <td></td>
            </tr>
      }
    </table>
};

(: Run a user-defined XPath. :)
declare function app:runXPath($node as node(), $model as map(*), $xpath as xs:string?) {
    if ($xpath) then
      (: if local:tokenize($xpath) then... :)
      app:listify($xpath)
    else ()
};
