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
      /^\/(?<axis>\/)?\s?(?<gi>(?:(?<prefix>\w+|\*):)?[_\p{Letter}][\w_\.-]*)/u;
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
    from the beginning and end of the given string. Whitespace characters elsewhere 
    in the string is reduced to a single space.  */
  var normalizeSpace = function(str) {
    var trimmedStr,
        regexWsBetween = /\s{2,}/g,
        regexWsEnds = /(^\s+|\s+$)/g;
    trimmedStr = str.replace(regexWsEnds, '');
    return trimmedStr.replace(regexWsBetween, ' ');
  }; // normalizeSpace()
  
  
  /*** Public functions ***/
  
  
  /*** Class definitions ***/
  
  this.PathStep = class {
    constructor (xpath) {
      var regexStep, match, ns,
          useXPath = normalizeSpace(xpath);
      regexStep =
        /^\/(?<axis>\/)?\s?(?<gi>(?:(?<prefix>\w+|\*):)?[_\p{Letter}][\w_\.-]*)/u;
      match = regexStep.exec(useXPath);
      //console.log(match);
      this.remainder = useXPath.slice(match[0].length);
      // Recover from a string that doesn't match expectations about XPath.
      if ( match === null ) {
        this.msg = {
            'type': 'error',
            'say': "Cannot parse string '"+xpath+"' as XPath."
          };
      } else {
        this.axis = match.groups.axis || 'child';
        if ( this.axis === '/' ) {
          this.axis = 'descendant';
        }
        this.gi = match.groups.gi;
      }
    }
    
    get next() {
      var expr = null;
      if ( this.remainder !== '' ) {
        expr = new that.PathStep(this.remainder);
      }
      return expr;
    } // pathStep.next
    
    step(node) {
      var candidates = node.getAxis(this.axis);
      //candidates.filter(this.test, this);
      console.log(candidates);
    } // pathStep.step()
    
    test(node) {
      var giMatch = this.gi === node.gi;
      return giMatch;
    }
  }; // this.PathStep
  
  this.XmlNode = class {
    constructor (node) {
      var data = node.dataset;
      this.node = node;
      this.gi = data.gi;
      this.types = ['node()'];
      if ( data.nodeType !== undefined ) {
        this.types.unshift(data.nodeType);
      }
    }
    
    /* Since not every node type can have children, the "children" property is a 
      no-op for this generic class. */
    get children() {
      return undefined;
    } // xmlNode.children
    
    get nodeType() {
      return this.types[0];
    } // xmlNode.nodeType
    
    getAxis(step) {
      var moveTo;
      switch (step.axis) {
        case 'self':
          moveTo = this;
          break;
        case 'child':
        //case 'descendant':
          moveTo = this.children;
          break;
        default:
          console.log(step.axis);
      }
      return moveTo;
    } // xmlNode.getAxis()
  }; // this.XmlNode
  
  this.Doc = class extends this.XmlNode {
    constructor (node) {
      super(node);
      
    }
  }; // this.Doc
  
  this.ElNode = class extends this.XmlNode {
    
  }; // this.ElNode
}).apply(xplr); // Apply the namespace to the anonymous function.


// Create a callback function to be run when the entire document has loaded.
var onLoad = function() {
  var docNode = document.getElementById('document-node'),
      doc = new xplr.Doc(docNode),
      xpath = new xplr.PathStep("/mtx:sc/mtx:ti//mtx:fe");
  console.log(xpath);
  console.log(doc);
  xpath.step(doc);
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
