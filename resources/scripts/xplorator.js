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
  
  /*  */
  var classifyNode = function(node) {
    var classedNode = null;
    if ( isElementProxy(node) ) {
      classedNode = new that.ElNode(node);
    } else if ( isNodeProxy(node) ) {
      classedNode = new that.XmlNode(node);
    }
    return classedNode;
  }; // classifyNode
  
  /*  */
  var getChildren = function(el, callback, context) {
    if ( el.hasChildNodes() ) {
      var childSeq = el.childNodes;
      childSeq.forEach(callback, context);
    }
    return childSeq;
  }; // getChildren()
  
  /* Detemine if a given HTML element is serving as a proxy for an XML element node. */
  var isElementProxy = function(el) {
    return el.hasAttribute("data-gi");
  }; // isElementProxy()
  
  /* Detemine if a given HTML element is serving as a proxy for an XML node. */
  var isNodeProxy = function(el) {
    return el.hasAttribute("data-node-type") || isElementProxy(el);
  }; // isNodeProxy()
  
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
      this.types = ['node()'];
      if ( data.nodeType !== undefined ) {
        this.types.unshift(data.nodeType);
      }
      this.children = null;
    }
    
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
      this.children = [];
      // Identify child XML proxies, and create classes for them.
      getChildren(node, function(child) {
        var classedChild = classifyNode(child);
        if ( classedChild !== null ) {
          this.children.push(classedChild);
        }
      }, this)
    }
  }; // this.Doc
  
  this.ElNode = class extends this.XmlNode {
    constructor(node, namespace) {
      super(node);
      this.gi = node.dataset.gi;
      this.namespace = node.dataset.ns || namespace || null;
      this.children = [];
      /* Identify the child XML proxies inside a node container <ol>, and create 
        classes for them. */
      var nodeContainer;
      for (var el of node.children) {
        if ( el.localName === 'ol' && el.className === 'node-container' ) {
          nodeContainer = el;
        }
      }
      if ( nodeContainer !== undefined ) {
        getChildren(nodeContainer, function(liChild) {
          var classedChild = classifyNode(liChild);
          if ( classedChild !== null ) {
            this.children.push(classedChild);
          }
        }, this);
      }
    }
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
