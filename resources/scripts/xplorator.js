// xplorator.js

// Set up Xplorator namespace.
var xplr = xplr || {};
//xplr.subns = {};

// Create an anonymous function to hold functions to be namespaced.
(function() {
  /* Capture the current context so these functions can refer to themselves even 
    when the context changes. */
  var that = this;
  
  
  /*** Private functions ***/
  
  /* Given a string assumed to be XPath, determine the next step of the query. */
  var identifyStep = function(xpath) {
    var regexStep, match, ns,
        stepInfo = {};
    regexStep =
      /^\/(?<axis>\/)?\s?(?<gi>(?:(?<prefix>\w+):)?[_\p{Letter}][\w_\.-]*)/u;
    match = regexStep.exec(xpath);
    // Recover from a string that doesn't match expectations about XPath.
    if ( match === null ) {
      stepInfo['msg'] = {
          'type': 'error',
          'say': "Cannot parse string '"+xpath+"' as XPath."
        };
    } else {
      stepInfo['axis'] = match.groups.axis || 'child';
      if ( stepInfo.axis === '/' ) {
        stepInfo['axis'] = 'descendant';
      }
      stepInfo['gi'] = match.groups.gi;
    }
    return stepInfo;
  }; // identifyStep()
  
  /* A Javascript version of XPath's fn:normalize-space(). Whitespace is deleted 
    from the beginning and end of the given string. Whitespace elsewhere in the 
    string is reduced to a single space.  */
  var normalizeSpace = function(str) {
    var trimmedStr,
        regexWsBetween = /\s{2,}/g,
        regexWsEnds = /(^\s+|\s+$)/g;
    trimmedStr = str.replace(regexWsEnds, '');
    return trimmedStr.replace(regexWsBetween, ' ');
  }; // normalizeSpace()
  
  
  /*** Public functions ***/
  
  /* Run a given XPath. */
  this.execute = function(xpath) {
    var normStr = normalizeSpace(xpath),
        step1 = identifyStep(normStr);
    console.log(normStr);
    return step1;
  }; // this.execute()
  
  
  /*** Class definitions ***/
  
  this.XmlDoc = class {
    constructor () { }
  };
}).apply(xplr); // Apply the namespace to the anonymous function.


// Create a callback function to be run when the entire document has loaded.
var onLoad = function() {
  var test = xplr.execute("/mtx:sc/mtx:ti//mtx:fe");
  console.log(test);
};

/* Ensure that the callback function above is run, whether or not the DOM has 
  already been loaded. Solution by Julian Kühnel: 
  https://www.sitepoint.com/jquery-document-ready-plain-javascript/ */
if ( document.readyState === 'complete' 
   || ( document.readyState !== 'loading' && !document.documentElement.doScroll ) 
   ) {
  onLoad();
} else {
  document.addEventListener('DOMContentLoaded', onLoad);
}
