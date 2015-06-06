xquery version "3.0";

declare variable $letters := 'a-zA-Z';
declare variable $validName := 
  concat('[',$letters,'_][',$letters,'0-9.\-_]*'); (: left out the colon for now :)
(: Combiners and extenders are also valid XML names, see http://www.w3.org/TR/REC-xml/#NT-CombiningChar :)

declare %private function local:tokenizeOne($xpath as xs:string) {
  if ($xpath = '') then (
    (: Do nothing with an empty string. :)
  ) else if (matches($xpath,'^//')) then (
    (
      '//',
      local:tokenizeOne(replace($xpath,'^//',''))
    )
  ) else if (matches($xpath, '^/')) then (
    (
      '/',
      local:tokenizeOne(replace($xpath,'^/','')) 
    )
  ) else if (matches($xpath,'^\*')) then (
    (
      '*',
      local:tokenizeOne(replace($xpath,'^\*','')) 
    )
  ) else if (matches($xpath,concat('^',$validName))) then (
    (
      replace($xpath,concat('^(',$validName,').*'),'$1'),
      local:tokenizeOne(replace($xpath,concat('^',$validName),'')) 
    )
  ) else if (matches($xpath,concat('^@',$validName))) then (
    (
      replace($xpath,concat('^(@',$validName,').*'),'$1'),
      local:tokenizeOne(replace($xpath,concat('^@',$validName),'')) 
    )
  ) else (
    $xpath
  )
  
  (:tokenize($xpath,'/'):)
};

let $testXPaths := (
                    '//rudePers[parent::hamster or parent::*[@smells="of-elderberries"]]', 
                    'distinct-values(//persName/@ref)[1]',
                    '//skarmory[@desc="wicked"] |    //bellossom[@desc="sweet"]',
                    '/canon/superhero[@caped="true"]/name',
                    '//pkmn:trainer',
                    '//@uncommon',
                    'div div div',
                    '//someText[contains(text(),"\\")]',
                    'let $xq := ("nope", "not gonna work") return $xq'
                   )
return 
  <results>
    {
      for $string in $testXPaths
      return 
        <xpath testing="{$string}">
          {
            for $expr in local:tokenizeOne(normalize-space($string))
            return
              <component>{ $expr }</component>
          }
        </xpath>
    }
    </results>