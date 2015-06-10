xquery version "3.0";

module namespace app="http://wwp.northeastern.edu/templates";
declare namespace mtx="http://xplorator.org/metallix";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://wwp.northeastern.edu/config" at "config.xqm";
import module namespace transform="http://exist-db.org/xquery/transform";

(: Test string for XPath-ability. :)
(:declare %private function app:sanitize($xpath as xs:string) {
    
};:)

(:  :)
declare %private function app:reduce-text($item) as xs:string {
  let $allTxt := if ($item instance of element()) then string-join($item//text(),' ') else string($item)
  let $strLen := string-length($allTxt)
  return 
    if ($strLen > 40) then
      concat(substring($allTxt,1,20), ' ... ', substring($allTxt,$strLen - 20,$strLen))
    else $allTxt
};

(: Create a list of results. :)
declare %private function app:listify($xpath as xs:string) as node()* {
    let $pathedXPath := if (starts-with($xpath,'/')) then $xpath else concat('/',$xpath)
    return
      <div>
        <p>{$xpath}</p>
        <table>
          <tr>
            <th>Document</th>
            <!--<th>Text</th>-->
            <th>Result</th>
            <th>Select</th>
          </tr>
          {
            for $doc in ('partsOfAnXPath.xml','whyXPath.xml')
            let $onDoc := concat("doc('../resources/xml/",$doc,"')",$pathedXPath)
              for $result in ( util:eval($onDoc) )
              return
                <tr>
                  <td>{$doc}</td>
                  <!--<td>{app:reduce-text($result)}</td>-->
                  <td>
                      {
                        typeswitch($result)
                          case element() return replace(util:node-xpath($result),'\[[ @:-_.]+\]','')
                          case attribute() return string($result)
                          case text() return string($result)
                          case xs:decimal return string($result)
                          case comment() return string($result)
                          case processing-instruction() return string($result)
                          default return ""
                      }
                  </td>
                  <td>
                    <button type="button" class="btn btn-primary result-btn" data-toggle="button" aria-pressed="false"
                      data-target="{if ($result instance of element()) then concat($doc,'-',$result/string(@xml:id)) else ()}">&gt;</button>
                  </td>
                </tr>
          }
        </table>
      </div>
};

(: Run a user-defined XPath. :)
declare function app:runXPath($node as node(), $model as map(*), $xpath as xs:string?) {
    if ($xpath) then
      (: if local:tokenize($xpath) then... :)
      app:listify($xpath)
    else ()
};
