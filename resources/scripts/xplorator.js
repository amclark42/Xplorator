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
  var classifyNode = function(el, ns) {
    var classedNode = null;
    if ( isElementProxy(el) ) {
      classedNode = new that.ElNode(el, ns);
    } else if ( isNodeProxy(el) ) {
      classedNode = new that.XmlNode(el);
    }
    return classedNode;
  }; // classifyNode()
  
  /*  */
  var getChildren = function(el, callback, context) {
    if ( el.hasChildNodes() ) {
      var children = el.childNodes;
      children.forEach(callback, context);
    }
    return children;
  }; // getChildren()
  
  /* Detemine if a given HTML element is serving as a proxy for an XML element node. */
  var isElementProxy = function(el) {
    return isHtmlElementNode(el) && el.hasAttribute("data-gi");
  }; // isElementProxy()
  
  /* Determine if a given HTML node is an element. XML proxies can only be HTML 
    elements. */
  var isHtmlElementNode = function(el) {
    return el.nodeType === 1;
  } // isHtmlElementNode()
  
  /* Detemine if a given HTML element is serving as a proxy for an XML node. */
  var isNodeProxy = function(el) {
    var isProxy = isHtmlElementNode(el);
    if ( isProxy ) {
      isProxy =  el.hasAttribute("data-node-type") || isElementProxy(el);
    }
    return isProxy;
  }; // is el.hasAttribute("data-node-type") || isElementProxy(el);NodeProxy()
  
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
  
  this.getHtmlElements = function(nodes) {
    var elSeq = [];
    if ( nodes !== undefined && nodes.constructor === Array ) {
      nodes.forEach( function(node) {
        elSeq.push(node.el);
      });
    }
    return elSeq;
  }; // this.getHtmlElements()
  
  this.nodesEqual = function(node1, node2) {
    var el1 = node1.el,
        el2 = node2.el;
    return el1 === el2;
  }; // this.nodesEqual()
  
  
  /*** Class definitions ***/
  
  this.Dispatcher = class {
    constructor(root) {
      this.node = root;
      this.xpath = null;
      this.queue = [];
      this.currentPlace = [];
      this.currentPlace.push(this.node);
    }
    
    manageQueue(e) {
      var xpathReq,
          form = d3.select(e.target.parentNode);
      xpathReq = form.select('#xpath-code').property('value');
      /* If the event indicates a new XPath has been input, clear the queue. */
      if ( xpathReq !== this.xpath ) {
        this.queue = [];
      }
      this.xpath = xpathReq;
      /* If the queue is empty, generate a new PathStep. */
      if ( this.queue.length === 0 ) {
        this.queue.push(new that.PathStep(this.xpath, this.currentPlace));
      /* If the current XPath expression is complete, remove it and get the next one. */
      } else if ( this.queue[0].isComplete() ) {
        var prev = this.queue.shift(),
            next = prev.nextPath;
        if ( next !== null ) {
          this.queue.push(next);
        }
      }
      console.log(this.queue[0]);
    } // dispatcher.manageQueue()
    
    clearVisuals() {
      var onLastStep = this.queue[0].isFinal(),
          hasIterated = this.queue[0].iteration > 0,
          prevMatches = d3.selectAll('.expr-match');
      // Restore previous non-matches to the default styling.
      d3.selectAll('.expr-nonmatch')
          .classed('expr-nonmatch', false);
      /* Clear previous matches, unless we're collecting matches on the final 
        expression. */
      if ( !onLastStep || (onLastStep && !hasIterated ) ) {
        prevMatches.classed('expr-match', false);
      }
    } // dispatcher.clearVisuals()
    
    stepInto(e) {
      this.manageQueue(e);
      if ( this.queue.length >= 1 ) {
        var nodeStep = this.queue[0],
            wasComplete = nodeStep.isComplete(),
            elSeqFull = [],
            elSeqMatched = [];
        this.clearVisuals();
        this.currentPlace = nodeStep.step(this.currentPlace);
        elSeqFull = that.getHtmlElements(nodeStep.axisPopulace);
        //console.log(elSeqFull);
        if ( !nodeStep.isFinal() || !wasComplete ) {
          d3.selectAll(elSeqFull)
              .classed('expr-nonmatch', true);
        }
        if ( this.currentPlace !== null && this.currentPlace.length >= 1 ) {
          elSeqMatched = that.getHtmlElements(this.currentPlace);
        }
        //console.log(elSeq);
        d3.selectAll(elSeqMatched)
            .classed('expr-nonmatch', false)
            .classed('expr-match', true);
      }
    } // dispatcher.stepInto()
  }; // Dispatcher
  
  this.PathStep = class {
    constructor (xpath, start) {
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
      this.axisPopulace = [];
      this.iteration = 0;
    }
    
    get nextPath() {
      var expr = null;
      if ( !this.isFinal() ) {
        expr = new that.PathStep(this.remainder);
      }
      return expr;
    } // pathStep.nextPath
    
    isComplete() {
      var bool;
      switch (this.axis) {
        case 'ancestor':
        case 'ancestor-or-self':
        case 'descendant':
        case 'descendant-or-self':
          bool = this.iteration >= 1 && this.axisPopulace.length === 0;
          break;
        default:
          bool = this.iteration === 1;
      }
      return bool;
    } // pathStep.isComplete()
    
    isFinal() {
      return this.remainder === '';
    } // pathStep.isFinal()
    
    step(nodeSeq) {
      var prevNodes,
          candidates = null;
      if ( !this.isComplete() ) {
        prevNodes = this.iteration === 0 ? nodeSeq : this.axisPopulace;
        prevNodes.forEach( function(node) {
          var nodeAxis = node.getAxis(this.axis);
          if ( nodeAxis !== null ) {
            /* Filter out nodes that already have been added to the axisPopulace. */
            nodeAxis = nodeAxis.filter( function(nodeA) {
              return !this.axisPopulace.some(nodeB => that.nodesEqual(nodeA, nodeB));
            }, this);
            this.axisPopulace = this.axisPopulace.concat(nodeAxis);
          }
        }, this);
        /* If no new nodes have been added to the axisPopulace, the expression is 
          complete. Otherwise, return the new nodes which are a positive match for 
          the expression. */
        if ( prevNodes.length === this.axisPopulace.length ) {
          this.axisPopulace = [];
        } else {
          candidates = this.axisPopulace.filter(this.test, this);
        }
        this.iteration++;
      }
      return candidates;
    } // pathStep.step()
    
    test(node) {
      var giMatch = this.gi === node.gi;
      return giMatch;
    } // pathStep.test()
  }; // PathStep
  
  this.XmlNode = class {
    constructor (el) {
      var data = el.dataset;
      this.el = el;
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
      switch (step) {
        case 'self':
          moveTo = this;
          break;
        case 'child':
        case 'descendant':
          moveTo = this.children;
          break;
        default:
          console.warn('Axis '+step+' not implemented');
      }
      return moveTo;
    } // xmlNode.getAxis()
  }; // XmlNode
  
  this.Doc = class extends this.XmlNode {
    constructor (el) {
      super(el);
      this.children = [];
      // Identify child XML proxies, and create classes for them.
      getChildren(el, function(child) {
        var classedChild = classifyNode(child);
        if ( classedChild !== null ) {
          this.children.push(classedChild);
        }
      }, this)
    }
  }; // Doc
  
  this.ElNode = class extends this.XmlNode {
    constructor(el, namespace) {
      super(el);
      this.types.unshift('element()');
      this.gi = el.dataset.gi;
      this.namespace = el.dataset.ns || namespace || null;
      this.children = [];
      /* Identify the child XML proxies inside a node container <ol>, and create 
        classes for them. */
      var nodeContainer;
      for (var elChild of el.children) {
        if ( elChild.localName === 'ol' && elChild.className === 'node-container' ) {
          nodeContainer = elChild;
        }
      }
      if ( nodeContainer !== undefined ) {
        getChildren(nodeContainer, function(elChild) {
          var classedChild = classifyNode(elChild, this.namespace);
          if ( classedChild !== null ) {
            this.children.push(classedChild);
          }
        }, this);
      }
    }
  }; // ElNode
}).apply(xplr); // Apply the namespace to the anonymous function.


// Create a callback function to be run when the entire document has loaded.
var onLoad = function() {
  var docNode = document.getElementById('document-node'),
      doc = new xplr.Doc(docNode),
      dispatch = new xplr.Dispatcher(doc),
      xCode = document.getElementById('xpath-code'),
      btnNext = d3.select('button[name="step"]'),
      testXPath = "/mtx:sc/mtx:ti//mtx:fe";
  console.log(doc);
  xCode.setRangeText(testXPath);
  btnNext.datum(dispatch)
      .on('click', function() {
        dispatch.stepInto(d3.event);
      });
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
