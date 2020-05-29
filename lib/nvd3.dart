library nvd3;


 /* nvd3 version 1.8.6-dev (https://github.com/novus/nvd3) 2018-07-01 */
 ( ( ) {
 // set up main nv object
 var nv = { } ;
 // the major global objects under the nv namespace
 nv . dev = false ; nv . tooltip = nv . tooltip || { } ; nv . utils = nv . utils || { } ; nv . models = nv . models || { } ; nv . charts = { } ; nv . logs = { } ; nv . dom = { } ;
 // Node/CommonJS - require D3
 if ( ! identical ( , "undefined" ) && ! identical ( , "undefined" ) && == "undefined" ) { d3 = require ( "d3" ) ; } nv . dispatch = d3 . dispatch ( "start" , "end" ) ; d3 . functor = functor ( v ) { return identical ( , "function" ) ? v : ( ) { return v ; } ; } ; d3 . rebind = rebind ( target , source , method ) { return ( ) { var value = method . apply ( source , arguments ) ; return identical ( value , source ) ? target : value ; } ; } ;
 // Function bind polyfill

 // Needed ONLY for phantomJS as it's missing until version 2.0 which is unreleased as of this comment

 // https://github.com/ariya/phantomjs/issues/10522

 // http://kangax.github.io/compat-table/es5/#Function.prototype.bind

 // phantomJS is used for running the test suite
 if ( ! Function . prototype . bind ) { Function . prototype . bind = ( oThis ) { if ( ! identical ( , "function" ) ) {
 // closest thing possible to the ECMAScript 5 internal IsCallable function
 throw new TypeError ( "Function.prototype.bind - what is trying to be bound is not callable" ) ; } var aArgs = Array . prototype . slice . call ( arguments , 1 ) , fToBind = this , fNOP = ( ) { } , fBound = ( ) { return fToBind . apply ( this is fNOP && oThis ? this : oThis , aArgs . concat ( Array . prototype . slice . call ( arguments ) ) ) ; } ; fNOP . prototype = this . prototype ; fBound . prototype = new fNOP ( ) ; return fBound ; } ; }
 //  Development render timers - disabled if dev = false
 if ( nv . dev ) { nv . dispatch . on ( "start" , ( e ) { nv . logs . startTime = + new Date ( ) ; } ) ; nv . dispatch . on ( "end" , ( e ) { nv . logs . endTime = + new Date ( ) ; nv . logs . totalTime = nv . logs . endTime - nv . logs . startTime ; nv . log ( "total" , nv . logs . totalTime ) ; } ) ; }
 // Logs all arguments, and returns the last so you can test things in place

 // Note: in IE8 console.log is an object not a function, and if modernizr is used

 // then calling Function.prototype.bind with with anything other than a function

 // causes a TypeError to be thrown.
 nv . log = ( ) { if ( nv . dev && window . console && console . log && console . log . apply ) console . log . apply ( console , arguments ) ; else if ( nv . dev && window . console && == "function" && Function . prototype . bind ) { var log = Function . prototype . bind . call ( console . log , console ) ; log . apply ( console , arguments ) ; } return arguments [ arguments . length - 1 ] ; } ;
 // print console warning, should be used by deprecated functions
 nv . deprecated = ( name , info ) { if ( console && console . warn ) { console . warn ( "nvd3 warning: `" + name + "` has been deprecated. " , info || "" ) ; } } ;
 // The nv.render function is used to queue up chart rendering

 // in non-blocking async functions.

 // When all queued charts are done rendering, nv.dispatch.end is invoked.
 nv . render = render ( step ) {
 // number of graphs to generate in each timeout loop
 step = step || 1 ; nv . render . active = true ; nv . dispatch . call ( "start" ) ; var renderLoop = ( ) { var chart , graph ; for ( var i = 0 ; i < step && ( graph = nv . render . queue [ i ] ) ; i ++ ) { chart = graph . generate ( ) ; if ( == ) graph . callback ( chart ) ; } nv . render . queue . splice ( 0 , i ) ; if ( nv . render . queue . length ) { setTimeout ( renderLoop ) ; } else { nv . dispatch . call ( "end" ) ; nv . render . active = false ; } } ; setTimeout ( renderLoop ) ; } ; nv . render . active = false ; nv . render . queue = [ ] ;
 /*
Adds a chart to the async rendering queue. This method can take arguments in two forms:
nv.addGraph({
    generate: <Function>
    callback: <Function>
})

or

nv.addGraph(<generate Function>, <callback Function>)

The generate function should contain code that creates the NVD3 model, sets options
on it, adds data to an SVG element, and invokes the chart model. The generate function
should return the chart model.  See examples/lineChart.html for a usage example.

The callback function is optional, and it is called when the generate function completes.
*/
 nv . addGraph = ( obj ) { if ( identical ( , ) ) { obj = { "generate" : arguments [ 0 ] , "callback" : arguments [ 1 ] } ; } nv . render . queue . push ( obj ) ; if ( ! nv . render . active ) { nv . render ( ) ; } } ;
 // Node/CommonJS exports
 if ( ! identical ( , "undefined" ) && ! identical ( , "undefined" ) ) { module . exports = nv ; } if ( ! identical ( , "undefined" ) ) { window . nv = nv ; }
 /* Facade for queueing DOM write operations
 * with Fastdom (https://github.com/wilsonpage/fastdom)
 * if available.
 * This could easily be extended to support alternate
 * implementations in the future.
 */
 nv . dom . write = ( callback ) { if ( ! identical ( window . fastdom , undefined ) ) { return fastdom . mutate ( callback ) ; } return callback ( ) ; } ;
 /* Facade for queueing DOM read operations
 * with Fastdom (https://github.com/wilsonpage/fastdom)
 * if available.
 * This could easily be extended to support alternate
 * implementations in the future.
 */
 nv . dom . read = ( callback ) { if ( ! identical ( window . fastdom , undefined ) ) { return fastdom . measure ( callback ) ; } return callback ( ) ; } ;
 /* Utility class to handle creation of an interactive layer.
 This places a rectangle on top of the chart. When you mouse move over it, it sends a dispatch
 containing the X-coordinate. It can also render a vertical line where the mouse is located.

 dispatch.elementMousemove is the important event to latch onto.  It is fired whenever the mouse moves over
 the rectangle. The dispatch is given one object which contains the mouseX/Y location.
 It also has 'pointXValue', which is the conversion of mouseX to the x-axis scale.
 */
 nv . interactiveGuideline = ( ) { "use strict" ; var margin = { "left" : 0 , "top" : 0 } , width = null , height = null , xScale = d3 . scale . linear ( ) , dispatch = d3 . dispatch ( "elementMousemove" , "elementMouseout" , "elementClick" , "elementDblclick" , "elementMouseDown" , "elementMouseUp" ) , showGuideLine = true , svgContainer = null , tooltip = nv . models . tooltip ( ) , isMSIE = window . ActiveXObject ; tooltip . duration ( 0 ) . hideDelay ( 0 ) . hidden ( false ) ; layer ( selection ) { selection . each ( ( data ) { var container = d3 . select ( this ) ; var availableWidth = ( width || 960 ) , availableHeight = ( height || 400 ) ; var wrap = container . selectAll ( "g.nv-wrap.nv-interactiveLineLayer" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , " nv-wrap nv-interactiveLineLayer" ) ; wrapEnter . append ( "g" ) . attr ( "class" , "nv-interactiveGuideLine" ) ; if ( ! svgContainer ) { return ; } mouseHandler ( ) { var mouseX = d3 . event . clientX - this . getBoundingClientRect ( ) . left ; var mouseY = d3 . event . clientY - this . getBoundingClientRect ( ) . top ; var subtractMargin = true ; var mouseOutAnyReason = false ; if ( isMSIE ) {
 /*
                     D3.js (or maybe SVG.getScreenCTM) has a nasty bug in Internet Explorer 10.
                     d3.mouse() returns incorrect X,Y mouse coordinates when mouse moving
                     over a rect in IE 10.
                     However, d3.event.offsetX/Y also returns the mouse coordinates
                     relative to the triggering <rect>. So we use offsetX/Y on IE.
                     */
 mouseX = d3 . event . offsetX ; mouseY = d3 . event . offsetY ;
 /*
                     On IE, if you attach a mouse event listener to the <svg> container,
                     it will actually trigger it for all the child elements (like <path>, <circle>, etc).
                     When this happens on IE, the offsetX/Y is set to where ever the child element
                     is located.
                     As a result, we do NOT need to subtract margins to figure out the mouse X/Y
                     position under this scenario. Removing the line below *will* cause
                     the interactive layer to not work right on IE.
                     */
 if ( ! identical ( d3 . event . target . tagName , "svg" ) ) { subtractMargin = false ; } if ( d3 . event . target . className . baseVal . match ( "nv-legend" ) ) { mouseOutAnyReason = true ; } } if ( subtractMargin ) { mouseX -= margin . left ; mouseY -= margin . top ; }
 /* If mouseX/Y is outside of the chart's bounds,
                 trigger a mouseOut event.
                 */
 if ( identical ( d3 . event . type , "mouseout" ) || mouseX < 0 || mouseY < 0 || mouseX > availableWidth || mouseY > availableHeight || ( d3 . event . relatedTarget && identical ( d3 . event . relatedTarget . ownerSVGElement , undefined ) ) || mouseOutAnyReason ) { if ( isMSIE ) { if ( d3 . event . relatedTarget && identical ( d3 . event . relatedTarget . ownerSVGElement , undefined ) && ( identical ( d3 . event . relatedTarget . className , undefined ) || d3 . event . relatedTarget . className . match ( tooltip . nvPointerEventsClass ) ) ) { return ; } } dispatch . elementMouseout ( mouseX : mouseX , mouseY : mouseY ) ; layer . renderGuideLine ( null ) ; tooltip . hidden ( true ) ; return ; } else { tooltip . hidden ( false ) ; } var scaleIsOrdinal = identical ( , "function" ) ; var pointXValue = undefined ;
 // Ordinal scale has no invert method
 if ( scaleIsOrdinal ) { var elementIndex = d3 . bisect ( xScale . range ( ) , mouseX ) - 1 ;
 // Check if mouseX is in the range band
 if ( xScale . range ( ) [ elementIndex ] + xScale . rangeBand ( ) >= mouseX ) { pointXValue = xScale . domain ( ) [ d3 . bisect ( xScale . range ( ) , mouseX ) - 1 ] ; } else { dispatch . elementMouseout ( mouseX : mouseX , mouseY : mouseY ) ; layer . renderGuideLine ( null ) ; tooltip . hidden ( true ) ; return ; } } else { pointXValue = xScale . invert ( mouseX ) ; } dispatch . elementMousemove ( mouseX : mouseX , mouseY : mouseY , pointXValue : pointXValue ) ;
 //If user double clicks the layer, fire a elementDblclick
 if ( identical ( d3 . event . type , "dblclick" ) ) { dispatch . elementDblclick ( mouseX : mouseX , mouseY : mouseY , pointXValue : pointXValue ) ; }
 // if user single clicks the layer, fire elementClick
 if ( identical ( d3 . event . type , "click" ) ) { dispatch . elementClick ( mouseX : mouseX , mouseY : mouseY , pointXValue : pointXValue ) ; }
 // if user presses mouse down the layer, fire elementMouseDown
 if ( identical ( d3 . event . type , "mousedown" ) ) { dispatch . elementMouseDown ( mouseX : mouseX , mouseY : mouseY , pointXValue : pointXValue ) ; }
 // if user presses mouse down the layer, fire elementMouseUp
 if ( identical ( d3 . event . type , "mouseup" ) ) { dispatch . elementMouseUp ( mouseX : mouseX , mouseY : mouseY , pointXValue : pointXValue ) ; } } svgContainer . on ( "touchmove" , mouseHandler ) . on ( "mousemove" , mouseHandler , true ) . on ( "mouseout" , mouseHandler , true ) . on ( "mousedown" , mouseHandler , true ) . on ( "mouseup" , mouseHandler , true ) . on ( "dblclick" , mouseHandler ) . on ( "click" , mouseHandler ) ; layer . guideLine = null ;
 //Draws a vertical guideline at the given X postion.
 layer . renderGuideLine = ( x ) { if ( ! showGuideLine ) return ; if ( layer . guideLine && identical ( layer . guideLine . attr ( "x1" ) , x ) ) return ; nv . dom . write ( ( ) { var line = wrap . select ( ".nv-interactiveGuideLine" ) . selectAll ( "line" ) . data ( ( x != null ) ? [ nv . utils . NaNtoZero ( x ) ] : [ ] , String ) ; line . enter ( ) . append ( "line" ) . attr ( "class" , "nv-guideline" ) . attr ( "x1" , ( d ) { return d ; } ) . attr ( "x2" , ( d ) { return d ; } ) . attr ( "y1" , availableHeight ) . attr ( "y2" , 0 ) ; line . exit ( ) . remove ( ) ; } ) ; } ; } ) ; } layer . dispatch = dispatch ; layer . tooltip = tooltip ; layer . margin = ( _ ) { if ( ! arguments . length ) return margin ; margin . top = != "undefined" ? _ . top : margin . top ; margin . left = != "undefined" ? _ . left : margin . left ; return layer ; } ; layer . width = ( _ ) { if ( ! arguments . length ) return width ; width = _ ; return layer ; } ; layer . height = ( _ ) { if ( ! arguments . length ) return height ; height = _ ; return layer ; } ; layer . xScale = ( _ ) { if ( ! arguments . length ) return xScale ; xScale = _ ; return layer ; } ; layer . showGuideLine = ( _ ) { if ( ! arguments . length ) return showGuideLine ; showGuideLine = _ ; return layer ; } ; layer . svgContainer = ( _ ) { if ( ! arguments . length ) return svgContainer ; svgContainer = _ ; return layer ; } ; return layer ; } ;
 /* Utility class that uses d3.bisect to find the index in a given array, where a search value can be inserted.
 This is different from normal bisectLeft; this function finds the nearest index to insert the search value.

 For instance, lets say your array is [1,2,3,5,10,30], and you search for 28.
 Normal d3.bisectLeft will return 4, because 28 is inserted after the number 10.  But interactiveBisect will return 5
 because 28 is closer to 30 than 10.

 Unit tests can be found in: interactiveBisectTest.html

 Has the following known issues:
 * Will not work if the data points move backwards (ie, 10,9,8,7, etc) or if the data points are in random order.
 * Won't work if there are duplicate x coordinate values.
 */
 nv . interactiveBisect = ( values , searchVal , xAccessor ) { "use strict" ; if ( ! ( values is Array ) ) { return null ; } var _xAccessor ; if ( ! identical ( , "function" ) ) { _xAccessor = ( d ) { return d . x ; } ; } else { _xAccessor = xAccessor ; } var _cmp = ( d , v ) {
 // Accessors are no longer passed the index of the element along with

 // the element itself when invoked by d3.bisector.

 //

 // Starting at D3 v3.4.4, d3.bisector() started inspecting the

 // function passed to determine if it should consider it an accessor

 // or a comparator. This meant that accessors that take two arguments

 // (expecting an index as the second parameter) are treated as

 // comparators where the second argument is the search value against

 // which the first argument is compared.
 return _xAccessor ( d ) - v ; } ; var bisect = d3 . bisector ( _cmp ) . left ; var index = d3 . max ( [ 0 , bisect ( values , searchVal ) - 1 ] ) ; var currentValue = _xAccessor ( values [ index ] ) ; if ( identical ( , "undefined" ) ) { currentValue = index ; } if ( identical ( currentValue , searchVal ) ) { return index ; } var nextIndex = d3 . min ( [ index + 1 , values . length - 1 ] ) ; var nextValue = _xAccessor ( values [ nextIndex ] ) ; if ( identical ( , "undefined" ) ) { nextValue = nextIndex ; } if ( Math . abs ( nextValue - searchVal ) >= Math . abs ( currentValue - searchVal ) ) { return index ; } else { return nextIndex ; } } ;
 /*
 Returns the index in the array "values" that is closest to searchVal.
 Only returns an index if searchVal is within some "threshold".
 Otherwise, returns null.
 */
 nv . nearestValueIndex = ( values , searchVal , threshold ) { "use strict" ; var yDistMax = Infinity , indexToHighlight = null ; values . forEach ( ( d , i ) { var delta = Math . abs ( searchVal - d ) ; if ( d != null && delta <= yDistMax && delta < threshold ) { yDistMax = delta ; indexToHighlight = i ; } } ) ; return indexToHighlight ; } ;
 /* Model which can be instantiated to handle tooltip rendering.
 Example usage:
 var tip = nv.models.tooltip().gravity('w').distance(23)
 .data(myDataObject);

 tip();    //just invoke the returned function to render tooltip.
 */
 nv . models . tooltip = ( ) { "use strict" ;
 /*
    Tooltip data. If data is given in the proper format, a consistent tooltip is generated.
    Example Format of data:
    {
        key: "Date",
        value: "August 2009",
        series: [
            {key: "Series 1", value: "Value 1", color: "#000"},
            {key: "Series 2", value: "Value 2", color: "#00f"}
        ]
    }
    */
 var id = "nvtooltip-" + Math . floor ( Math . random ( ) * 100000 ) , data = null , gravity = "w" , distance = 25 , snapDistance = 0 , classes = null , hidden = true , hideDelay = 200 , tooltip = null , lastPosition = { "left" : null , "top" : null } , enabled = true , duration = 100 , headerEnabled = true , nvPointerEventsClass = "nv-pointer-events-none" ;
 // Format function for the tooltip values column.

 // d is value,

 // i is series index

 // p is point containing the value
 var valueFormatter = ( d , i , p ) { return d ; } ;
 // Format function for the tooltip header value.
 var headerFormatter = ( d ) { return d ; } ; var keyFormatter = ( d , i ) { return d ; } ;
 // By default, the tooltip model renders a beautiful table inside a DIV, returned as HTML

 // You can override this function if a custom tooltip is desired. For instance, you could directly manipulate

 // the DOM by accessing elem and returning false.
 var contentGenerator = ( d , elem ) { if ( identical ( d , null ) ) { return "" ; } var table = d3 . select ( document . createElement ( "table" ) ) ; if ( headerEnabled ) { var theadEnter = table . selectAll ( "thead" ) . data ( [ d ] ) . enter ( ) . append ( "thead" ) ; theadEnter . append ( "tr" ) . append ( "td" ) . attr ( "colspan" , 3 ) . append ( "strong" ) . classed ( "x-value" , true ) . html ( headerFormatter ( d . value ) ) ; } var tbodyEnter = table . selectAll ( "tbody" ) . data ( [ d ] ) . enter ( ) . append ( "tbody" ) ; var trowEnter = tbodyEnter . selectAll ( "tr" ) . data ( ( p ) { return p . series ; } ) . enter ( ) . append ( "tr" ) . classed ( "highlight" , ( p ) { return p . highlight ; } ) ; trowEnter . append ( "td" ) . classed ( "legend-color-guide" , true ) . append ( "div" ) . style ( "background-color" , ( p ) { return p . color ; } ) ; trowEnter . append ( "td" ) . classed ( "key" , true ) . classed ( "total" , ( p ) { return ! ! p . total ; } ) . html ( ( p , i ) { return keyFormatter ( p . key , i ) ; } ) ; trowEnter . append ( "td" ) . classed ( "value" , true ) . html ( ( p , i ) { return valueFormatter ( p . value , i , p ) ; } ) ; trowEnter . filter ( ( p , i ) { return ! identical ( p . percent , undefined ) ; } ) . append ( "td" ) . classed ( "percent" , true ) . html ( ( p , i ) { return "(" + d3 . format ( "%" ) ( p . percent ) + ")" ; } ) ; trowEnter . selectAll ( "td" ) . each ( ( p ) { if ( p . highlight ) { var opacityScale = d3 . scale . linear ( ) . domain ( [ 0 , 1 ] ) . range ( [ "#fff" , p . color ] ) ; var opacity = 0.6 ; d3 . select ( this ) . style ( "border-bottom-color" , opacityScale ( opacity ) ) . style ( "border-top-color" , opacityScale ( opacity ) ) ; } } ) ; var html = table . node ( ) . outerHTML ; if ( ! identical ( d . footer , undefined ) ) html += "<div class='footer'>" + d . footer + "</div>" ; return html ; } ;
 /*
     Function that returns the position (relative to the viewport/document.body)
     the tooltip should be placed in.
     Should return: {
        left: <leftPos>,
        top: <topPos>
     }
     */
 var position = ( ) { var pos = { "left" : ! identical ( d3 . event , null ) ? d3 . event . clientX : 0 , "top" : ! identical ( d3 . event , null ) ? d3 . event . clientY : 0 } ; if ( getComputedStyle ( document . body ) . transform != "none" ) {
 // Take the offset into account, as now the tooltip is relative

 // to document.body.
 var client = document . body . getBoundingClientRect ( ) ; pos . left -= client . left ; pos . top -= client . top ; } return pos ; } ; var dataSeriesExists = ( d ) { if ( d && d . series ) { if ( nv . utils . isArray ( d . series ) ) { return true ; }
 // if object, it's okay just convert to array of the object
 if ( nv . utils . isObject ( d . series ) ) { d . series = [ d . series ] ; return true ; } } return false ; } ;
 // Calculates the gravity offset of the tooltip. Parameter is position of tooltip

 // relative to the viewport.
 var calcGravityOffset = ( pos ) { var height = tooltip . node ( ) . offsetHeight , width = tooltip . node ( ) . offsetWidth , clientWidth = document . documentElement . clientWidth , clientHeight = document . documentElement . clientHeight , left , top , tmp ;
 // calculate position based on gravity
 switch ( gravity ) { case "e" : left = - width - distance ; top = - ( height / 2 ) ; if ( pos . left + left < 0 ) left = distance ; if ( ( tmp = pos . top + top ) < 0 ) top -= tmp ; if ( ( tmp = pos . top + top + height ) > clientHeight ) top -= tmp - clientHeight ; break ; case "w" : left = distance ; top = - ( height / 2 ) ; if ( pos . left + left + width > clientWidth ) left = - width - distance ; if ( ( tmp = pos . top + top ) < 0 ) top -= tmp ; if ( ( tmp = pos . top + top + height ) > clientHeight ) top -= tmp - clientHeight ; break ; case "n" : left = - ( width / 2 ) - 5 ; top = distance ; if ( pos . top + top + height > clientHeight ) top = - height - distance ; if ( ( tmp = pos . left + left ) < 0 ) left -= tmp ; if ( ( tmp = pos . left + left + width ) > clientWidth ) left -= tmp - clientWidth ; break ; case "s" : left = - ( width / 2 ) ; top = - height - distance ; if ( pos . top + top < 0 ) top = distance ; if ( ( tmp = pos . left + left ) < 0 ) left -= tmp ; if ( ( tmp = pos . left + left + width ) > clientWidth ) left -= tmp - clientWidth ; break ; case "center" : left = - ( width / 2 ) ; top = - ( height / 2 ) ; break ; default : left = 0 ; top = 0 ; break ; } return { "left" : left , "top" : top } ; } ;
 /*
     Positions the tooltip in the correct place, as given by the position() function.
     */
 var positionTooltip = ( ) { nv . dom . read ( ( ) { var pos = position ( ) , gravityOffset = calcGravityOffset ( pos ) , left = pos . left + gravityOffset . left , top = pos . top + gravityOffset . top ;
 // delay hiding a bit to avoid flickering
 if ( hidden ) { tooltip . interrupt ( ) . transition ( ) . delay ( hideDelay ) . duration ( 0 ) . style ( "opacity" , 0 ) ; } else {
 // using tooltip.style('transform') returns values un-usable for tween
 var old_translate = "translate(" + lastPosition . left + "px, " + lastPosition . top + "px)" ; var new_translate = "translate(" + Math . round ( left ) + "px, " + Math . round ( top ) + "px)" ; var translateInterpolator = d3 . interpolateString ( old_translate , new_translate ) ; var is_hidden = tooltip . style ( "opacity" ) < 0.1 ; tooltip . interrupt ( ) . transition ( ) . duration ( is_hidden ? 0 : duration ) . styleTween ( "transform" , ( d ) { return translateInterpolator ; } , "important" ) . styleTween ( "-webkit-transform" , ( d ) { return translateInterpolator ; } ) . style ( "-ms-transform" , new_translate ) . style ( "opacity" , 1 ) ; } lastPosition . left = left ; lastPosition . top = top ; } ) ; } ;
 // Creates new tooltip container, or uses existing one on DOM.
 initTooltip ( ) { if ( ! tooltip || ! tooltip . node ( ) ) {
 // Create new tooltip div if it doesn't exist on DOM.
 var data = [ 1 ] ; tooltip = d3 . select ( document . body ) . selectAll ( "#" + id ) . data ( data ) ; tooltip . enter ( ) . append ( "div" ) . attr ( "class" , "nvtooltip " + ( classes ? classes : "xy-tooltip" ) ) . attr ( "id" , id ) . style ( "top" , 0 ) . style ( "left" , 0 ) . style ( "opacity" , 0 ) . style ( "position" , "absolute" ) . selectAll ( "div, table, td, tr" ) . classed ( nvPointerEventsClass , true ) . classed ( nvPointerEventsClass , true ) ; tooltip . exit ( ) . remove ( ) ; } }
 // Draw the tooltip onto the DOM.
 nvtooltip ( ) { if ( ! enabled ) return ; if ( ! dataSeriesExists ( data ) ) return ; nv . dom . write ( ( ) { initTooltip ( ) ;
 // Generate data and set it into tooltip.

 // Bonus - If you override contentGenerator and return false, you can use something like

 //         Angular, React or Knockout to bind the data for your tooltip directly to the DOM.
 var newContent = contentGenerator ( data , tooltip . node ( ) ) ; if ( newContent ) { tooltip . node ( ) . innerHTML = newContent ; } positionTooltip ( ) ; } ) ; return nvtooltip ; } nvtooltip . nvPointerEventsClass = nvPointerEventsClass ; nvtooltip . options = nv . utils . optionsFunc . bind ( nvtooltip ) ; nvtooltip . _options = Object . create ( { } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; } } , gravity : { "get" : ( ) { return gravity ; } , "set" : ( _ ) { gravity = _ ; } } , distance : { "get" : ( ) { return distance ; } , "set" : ( _ ) { distance = _ ; } } , snapDistance : { "get" : ( ) { return snapDistance ; } , "set" : ( _ ) { snapDistance = _ ; } } , classes : { "get" : ( ) { return classes ; } , "set" : ( _ ) { classes = _ ; } } , enabled : { "get" : ( ) { return enabled ; } , "set" : ( _ ) { enabled = _ ; } } , hideDelay : { "get" : ( ) { return hideDelay ; } , "set" : ( _ ) { hideDelay = _ ; } } , contentGenerator : { "get" : ( ) { return contentGenerator ; } , "set" : ( _ ) { contentGenerator = _ ; } } , valueFormatter : { "get" : ( ) { return valueFormatter ; } , "set" : ( _ ) { valueFormatter = _ ; } } , headerFormatter : { "get" : ( ) { return headerFormatter ; } , "set" : ( _ ) { headerFormatter = _ ; } } , keyFormatter : { "get" : ( ) { return keyFormatter ; } , "set" : ( _ ) { keyFormatter = _ ; } } , headerEnabled : { "get" : ( ) { return headerEnabled ; } , "set" : ( _ ) { headerEnabled = _ ; } } , position : { "get" : ( ) { return position ; } , "set" : ( _ ) { position = _ ; } } , chartContainer : { "get" : ( ) { return document . body ; } , "set" : ( _ ) {
 // deprecated after 1.8.3
 nv . deprecated ( "chartContainer" , "feature removed after 1.8.3" ) ; } } , fixedTop : { "get" : ( ) { return null ; } , "set" : ( _ ) {
 // deprecated after 1.8.1
 nv . deprecated ( "fixedTop" , "feature removed after 1.8.1" ) ; } } , offset : { "get" : ( ) { return { "left" : 0 , "top" : 0 } ; } , "set" : ( _ ) {
 // deprecated after 1.8.1
 nv . deprecated ( "offset" , "use chart.tooltip.distance() instead" ) ; } } , hidden : { "get" : ( ) { return hidden ; } , "set" : ( _ ) { if ( hidden != _ ) { hidden = ! ! _ ; nvtooltip ( ) ; } } } , data : { "get" : ( ) { return data ; } , "set" : ( _ ) {
 // if showing a single data point, adjust data format with that
 if ( _ . point ) { _ . value = _ . point . x ; _ . series = _ . series || { } ; _ . series . value = _ . point . y ; _ . series . color = _ . point . color || _ . series . color ; } data = _ ; } } , node : { "get" : ( ) { return tooltip . node ( ) ; } , "set" : ( _ ) { } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { } } ) ; nv . utils . initOptions ( nvtooltip ) ; return nvtooltip ; } ;
 /*
Gets the browser window size

Returns object with height and width properties
 */
 nv . utils . windowSize = ( ) {
 // Sane defaults
 var size = { "width" : 640 , "height" : 480 } ;
 // Most recent browsers use
 if ( window . innerWidth && window . innerHeight ) { size . width = window . innerWidth ; size . height = window . innerHeight ; return ( size ) ; }
 // IE can use depending on mode it is in
 if ( document . compatMode == "CSS1Compat" && document . documentElement && document . documentElement . offsetWidth ) { size . width = document . documentElement . offsetWidth ; size . height = document . documentElement . offsetHeight ; return ( size ) ; }
 // Earlier IE uses Doc.body
 if ( document . body && document . body . offsetWidth ) { size . width = document . body . offsetWidth ; size . height = document . body . offsetHeight ; return ( size ) ; } return ( size ) ; } ;
 /* handle dumb browser quirks...  isinstance breaks if you use frames
typeof returns 'object' for null, NaN is a number, etc.
 */
 nv . utils . isArray = Array . isArray ; nv . utils . isObject = ( a ) { return ! identical ( a , null ) && identical ( , "object" ) ; } ; nv . utils . isFunction = ( a ) { return identical ( , "function" ) ; } ; nv . utils . isDate = ( a ) { return identical ( toString . call ( a ) , "[object Date]" ) ; } ; nv . utils . isNumber = ( a ) { return ! isNaN ( a ) && identical ( , "number" ) ; } ;
 /*
Binds callback function to run when window is resized
 */
 nv . utils . windowResize = ( handler ) { if ( window . addEventListener ) { window . addEventListener ( "resize" , handler ) ; } else { nv . log ( "ERROR: Failed to bind to window.resize with: " , handler ) ; }
 // return object with clear function to remove the single added callback.
 return { "callback" : handler , "clear" : ( ) { window . removeEventListener ( "resize" , handler ) ; } } ; } ;
 /*
Backwards compatible way to implement more d3-like coloring of graphs.
Can take in nothing, an array, or a function/scale
To use a normal scale, get the range and pass that because we must be able
to take two arguments and use the index to keep backward compatibility
*/
 nv . utils . getColor = ( color ) {
 //if you pass in nothing, get default colors back
 if ( identical ( color , undefined ) ) { return nv . utils . defaultColor ( ) ; } else if ( nv . utils . isArray ( color ) ) { var color_scale = d3 . scalePoint ( ) . range ( color ) ; return ( d , i ) { var key = identical ( i , undefined ) ? d : i ; return d . color || color_scale ( key ) ; } ; } else {
 //can't really help it if someone passes rubbish as color
 return color ; } } ;
 /*
Default color chooser uses a color scale of 20 colors from D3
 https://github.com/mbostock/d3/wiki/Ordinal-Scales#categorical-colors
 */
 nv . utils . defaultColor = ( ) {
 // get range of the scale so we'll turn it into our own function.
 return nv . utils . getColor ( d3 . scaleOrdinal ( d3 . schemeCategory20 ) . range ( ) ) ; } ;
 /*
Returns a color function that takes the result of 'getKey' for each series and
looks for a corresponding color from the dictionary
*/
 nv . utils . customTheme = ( dictionary , getKey , defaultColors ) {
 // use default series.key if getKey is undefined
 getKey = getKey || ( series ) { return series . key ; } ; defaultColors = defaultColors || d3 . scale . category20 ( ) . range ( ) ;
 // start at end of default color list and walk back to index 0
 var defIndex = defaultColors . length ; return ( series , index ) { var key = getKey ( series ) ; if ( nv . utils . isFunction ( dictionary [ key ] ) ) { return dictionary [ key ] ( ) ; } else if ( ! identical ( dictionary [ key ] , undefined ) ) { return dictionary [ key ] ; } else {
 // no match in dictionary, use a default color
 if ( ! defIndex ) {
 // used all the default colors, start over
 defIndex = defaultColors . length ; } defIndex = defIndex - 1 ; return defaultColors [ defIndex ] ; } } ; } ;
 /*
From the PJAX example on d3js.org, while this is not really directly needed
it's a very cool method for doing pjax, I may expand upon it a little bit,
open to suggestions on anything that may be useful
*/
 nv . utils . pjax = ( links , content ) { var load = ( href ) { d3 . html ( href , ( fragment ) { var target = d3 . select ( content ) . node ( ) ; target . parentNode . replaceChild ( d3 . select ( fragment ) . select ( content ) . node ( ) , target ) ; nv . utils . pjax ( links , content ) ; } ) ; } ; d3 . selectAll ( links ) . on ( "click" , ( ) { history . pushState ( this . href , this . textContent , this . href ) ; load ( this . href ) ; d3 . event . preventDefault ( ) ; } ) ; d3 . select ( window ) . on ( "popstate" , ( ) { if ( d3 . event . state ) { load ( d3 . event . state ) ; } } ) ; } ;
 /*
For when we want to approximate the width in pixels for an SVG:text element.
Most common instance is when the element is in a display:none; container.
Forumla is : text.length * font-size * constant_factor
*/
 nv . utils . calcApproxTextWidth = ( svgTextElem ) { if ( nv . utils . isFunction ( svgTextElem . style ) && nv . utils . isFunction ( svgTextElem . text ) ) { var fontSize = parseInt ( svgTextElem . style ( "font-size" ) . replace ( "px" , "" ) , 10 ) ; var textLength = svgTextElem . text ( ) . length ; return nv . utils . NaNtoZero ( textLength * fontSize * 0.5 ) ; } return 0 ; } ;
 /*
Numbers that are undefined, null or NaN, convert them to zeros.
*/
 nv . utils . NaNtoZero = ( n ) { if ( ! nv . utils . isNumber ( n ) || isNaN ( n ) || identical ( n , null ) || identical ( n , Infinity ) || identical ( n , - Infinity ) ) { return 0 ; } return n ; } ;
 /*
Add a way to watch for d3 transition ends to d3
*/
 d3 . selection . prototype . watchTransition = ( renderWatch ) { var args = [ this ] . concat ( [ ] . slice . call ( arguments , 1 ) ) ; return renderWatch . transition . apply ( renderWatch , args ) ; } ;
 /*
Helper object to watch when d3 has rendered something
*/
 nv . utils . renderWatch = ( dispatch , duration ) { if ( ! ( this is nv . utils . renderWatch ) ) { return new nv . utils . renderWatch ( dispatch , duration ) ; } var _duration = ! identical ( duration , undefined ) ? duration : 250 ; var renderStack = [ ] ; var self = this ; this . models = ( models ) { models = [ ] . slice . call ( arguments , 0 ) ; models . forEach ( ( model ) { model . ___rendered = false ; ( ( m ) { m . dispatch . on ( "renderEnd" , ( arg ) { m . ___rendered = true ; self . renderEnd ( "model" ) ; } ) ; } ) ( model ) ; if ( renderStack . indexOf ( model ) < 0 ) { renderStack . push ( model ) ; } } ) ; return this ; } ; this . reset = ( duration ) { if ( ! identical ( duration , undefined ) ) { _duration = duration ; } renderStack = [ ] ; } ; this . transition = ( selection , args , duration ) { args = arguments . length > 1 ? [ ] . slice . call ( arguments , 1 ) : [ ] ; if ( args . length > 1 ) { duration = args . pop ( ) ; } else { duration = ! identical ( _duration , undefined ) ? _duration : 250 ; } selection . ___rendered = false ; if ( renderStack . indexOf ( selection ) < 0 ) { renderStack . push ( selection ) ; } if ( identical ( duration , 0 ) ) { selection . ___rendered = true ; selection . delay = ( ) { return this ; } ; selection . duration = ( ) { return this ; } ; return selection ; } else { if ( identical ( selection . length , 0 ) ) { selection . ___rendered = true ; } else if ( selection . filter ( ( d ) { return ! d . length ; } ) ) { selection . ___rendered = true ; } else { selection . ___rendered = false ; } var n = 0 ; return selection . transition ( ) . duration ( duration ) . each ( ( ) { ++ n ; } ) . on ( "end" , ( d , i ) { if ( identical ( -- n , 0 ) ) { selection . ___rendered = true ; self . renderEnd . apply ( this , args ) ; } } ) ; } } ; this . renderEnd = ( ) { if ( renderStack . every ( ( d ) { return d . ___rendered ; } ) ) { renderStack . forEach ( ( d ) { d . ___rendered = false ; } ) ; dispatch . apply ( "renderEnd" , this , arguments ) ; } } ; } ;
 /*
Takes multiple objects and combines them into the first one (dst)
example:  nv.utils.deepExtend({a: 1}, {a: 2, b: 3}, {c: 4});
gives:  {a: 2, b: 3, c: 4}
*/
 nv . utils . deepExtend = ( dst ) { var sources = arguments . length > 1 ? [ ] . slice . call ( arguments , 1 ) : [ ] ; sources . forEach ( ( source ) { for ( var key in source ) { var isArray = nv . utils . isArray ( dst [ key ] ) ; var isObject = nv . utils . isObject ( dst [ key ] ) ; var srcObj = nv . utils . isObject ( source [ key ] ) ; if ( isObject && ! isArray && srcObj ) { nv . utils . deepExtend ( dst [ key ] , source [ key ] ) ; } else { dst [ key ] = source [ key ] ; } } } ) ; } ;
 /*
state utility object, used to track d3 states in the models
*/
 nv . utils . state = ( ) { if ( ! ( this is nv . utils . state ) ) { return new nv . utils . state ( ) ; } var state = { } ; var _self = this ; var _setState = ( ) { } ; var _getState = ( ) { return { } ; } ; var init = null ; var changed = null ; this . dispatch = d3 . dispatch ( "change" , "set" ) ; this . dispatch . on ( "set" , ( state ) { _setState ( state , true ) ; } ) ; this . getter = ( fn ) { _getState = fn ; return this ; } ; this . setter = ( fn , callback ) { if ( ! callback ) { callback = ( ) { } ; } _setState = ( state , update ) { fn ( state ) ; if ( update ) { callback ( ) ; } } ; return this ; } ; this . init = ( state ) { init = init || { } ; nv . utils . deepExtend ( init , state ) ; } ; var _set = ( ) { var settings = _getState ( ) ; if ( identical ( JSON . stringify ( settings ) , JSON . stringify ( state ) ) ) { return false ; } for ( var key in settings ) { if ( identical ( state [ key ] , undefined ) ) { state [ key ] = { } ; } state [ key ] = settings [ key ] ; changed = true ; } return true ; } ; this . update = ( ) { if ( init ) { _setState ( init , false ) ; init = null ; } if ( _set . call ( this ) ) { this . dispatch . change ( state ) ; } } ; } ;
 /*
Snippet of code you can insert into each nv.models.* to give you the ability to
do things like:
chart.options({
  showXAxis: true,
  tooltips: true
});

To enable in the chart:
chart.options = nv.utils.optionsFunc.bind(chart);
*/
 nv . utils . optionsFunc = ( args ) { if ( args ) { d3 . map ( args ) . forEach ( ( ( key , value ) { if ( nv . utils . isFunction ( this [ key ] ) ) { this [ key ] ( value ) ; } } ) . bind ( this ) ) ; } return this ; } ;
 /*
numTicks:  requested number of ticks
data:  the chart data

returns the number of ticks to actually use on X axis, based on chart data
to avoid duplicate ticks with the same value
*/
 nv . utils . calcTicksX = ( numTicks , data ) {
 // find max number of values from all data streams
 var numValues = 1 ; var i = 0 ; for ( i ; i < data . length ; i += 1 ) { var stream_len = data [ i ] && data [ i ] . values ? data [ i ] . values . length : 0 ; numValues = stream_len > numValues ? stream_len : numValues ; } nv . log ( "Requested number of ticks: " , numTicks ) ; nv . log ( "Calculated max values to be: " , numValues ) ;
 // make sure we don't have more ticks than values to avoid duplicates
 numTicks = numTicks > numValues ? numTicks = numValues - 1 : numTicks ;
 // make sure we have at least one tick
 numTicks = numTicks < 1 ? 1 : numTicks ;
 // make sure it's an integer
 numTicks = Math . floor ( numTicks ) ; nv . log ( "Calculating tick count as: " , numTicks ) ; return numTicks ; } ;
 /*
 returns number of ticks to actually use on Y axis, based on chart data
 */
 nv . utils . calcTicksY = ( numTicks , data , getY ) { if ( getY ) { var numValues = 1 ; for ( var i = 0 ; i < data . length ; i += 1 ) { var values = data [ i ] && data [ i ] . values ? data [ i ] . values : [ ] ; var maxValue ; for ( var j = 0 ; j < values . length ; j += 1 ) { maxValue = values [ j ] && getY ( values [ j ] ) ? getY ( values [ j ] ) : 0 ; numValues = maxValue > numValues ? maxValue : numValues ; } } nv . log ( "Requested number of ticks: " , numTicks ) ; nv . log ( "Calculated max values to be: " , numValues ) ;
 // make sure we don't have more ticks than values to avoid duplicates
 numTicks = numTicks > numValues ? numValues - 1 : numTicks ;
 // make sure we have at least one tick
 numTicks = numTicks < 1 ? 1 : numTicks ;
 // make sure it's an integer
 numTicks = Math . floor ( numTicks ) ; nv . log ( "Calculating tick count as: " , numTicks ) ; return numTicks ; } else { return nv . utils . calcTicksX ( numTicks , data ) ; } } ;
 /*
Add a particular option from an options object onto chart
Options exposed on a chart are a getter/setter function that returns chart
on set to mimic typical d3 option chaining, e.g. svg.option1('a').option2('b');

option objects should be generated via Object.create() to provide
the option of manipulating data via get/set functions.
*/
 nv . utils . initOption = ( chart , name ) {
 // if it's a call option, just call it directly, otherwise do get/set
 if ( chart . _calls && chart . _calls [ name ] ) { chart [ name ] = chart . _calls [ name ] ; } else { chart [ name ] = ( _ ) { if ( ! arguments . length ) return chart . _options [ name ] ; chart . _overrides [ name ] = true ; chart . _options [ name ] = _ ; return chart ; } ;
 // calling the option as _option will ignore if set by option already

 // so nvd3 can set options internally but the stop if set manually
 chart [ "_" + name ] = ( _ ) { if ( ! arguments . length ) return chart . _options [ name ] ; if ( ! chart . _overrides [ name ] ) { chart . _options [ name ] = _ ; } return chart ; } ; } } ;
 /*
Add all options in an options object to the chart
*/
 nv . utils . initOptions = ( chart ) { chart . _overrides = chart . _overrides || { } ; var ops = Object . getOwnPropertyNames ( chart . _options || { } ) ; var calls = Object . getOwnPropertyNames ( chart . _calls || { } ) ; ops = ops . concat ( calls ) ; for ( var i in ops ) { nv . utils . initOption ( chart , ops [ i ] ) ; } } ;
 /*
Inherit options from a D3 object
d3.rebind makes calling the function on target actually call it on source
Also use _d3options so we can track what we inherit for documentation and chained inheritance
*/
 nv . utils . inheritOptionsD3 = ( target , d3_source , oplist ) { target . _d3options = oplist . concat ( target . _d3options || [ ] ) ;
 // Find unique d3 options (string) and update d3options
 target . _d3options = ( target . _d3options || [ ] ) . filter ( ( item , i , ar ) { return identical ( ar . indexOf ( item ) , i ) ; } ) ; oplist . unshift ( d3_source ) ; oplist . unshift ( target ) ; d3 . rebind . apply ( this , oplist ) ; } ;
 /*
Remove duplicates from an array
*/
 nv . utils . arrayUnique = ( a ) { return a . sort ( ) . filter ( ( item , pos ) { return ! pos || item != a [ pos - 1 ] ; } ) ; } ;
 /*
Keeps a list of custom symbols to draw from in addition to d3.svg.symbol
Necessary since d3 doesn't let you extend its list -_-
Add new symbols by doing nv.utils.symbols.set('name', function(size){...});
*/
 nv . utils . symbolMap = d3 . map ( ) ;
 /*
Replaces d3.svg.symbol so that we can look both there and our own map
 */
 nv . utils . symbol = ( ) { var type , size = 64 ; symbol ( d , i ) { var t = type . call ( this , d , i ) ; var s = size . call ( this , d , i ) ;
 // TODO: Not sure if symbol('circle') would return a d3.symbolCircle. In v4 symbols are enums and not strings
 if ( identical ( nv . utils . symbolMap . get ( t ) , undefined ) ) { return d3 . symbol ( t ) ( s ) ; } else { return nv . utils . symbolMap . get ( t ) ( s ) ; } } symbol . type = ( _ ) { if ( ! arguments . length ) return type ; type = d3 . functor ( _ ) ; return symbol ; } ; symbol . size = ( _ ) { if ( ! arguments . length ) return size ; size = d3 . functor ( _ ) ; return symbol ; } ; return symbol ; } ;
 /*
Inherit option getter/setter functions from source to target
d3.rebind makes calling the function on target actually call it on source
Also track via _inherited and _d3options so we can track what we inherit
for documentation generation purposes and chained inheritance
*/
 nv . utils . inheritOptions = ( target , source ) {
 // inherit all the things
 var ops = Object . getOwnPropertyNames ( source . _options || { } ) ; var calls = Object . getOwnPropertyNames ( source . _calls || { } ) ; var inherited = source . _inherited || [ ] ; var d3ops = source . _d3options || [ ] ; var args = ops . concat ( calls ) . concat ( inherited ) . concat ( d3ops ) ; args . unshift ( source ) ; args . unshift ( target ) ; d3 . rebind . apply ( this , args ) ;
 // pass along the lists to keep track of them, don't allow duplicates
 target . _inherited = nv . utils . arrayUnique ( ops . concat ( calls ) . concat ( inherited ) . concat ( ops ) . concat ( target . _inherited || [ ] ) ) ; target . _d3options = nv . utils . arrayUnique ( d3ops . concat ( target . _d3options || [ ] ) ) ; } ;
 /*
Runs common initialize code on the svg before the chart builds
*/
 nv . utils . initSVG = ( svg ) { svg . classed ( "nvd3-svg" , true ) ; } ;
 /*
Sanitize and provide default for the container height.
*/
 nv . utils . sanitizeHeight = ( height , container ) { return ( height || parseInt ( container . style ( "height" ) , 10 ) || 400 ) ; } ;
 /*
Sanitize and provide default for the container width.
*/
 nv . utils . sanitizeWidth = ( width , container ) { return ( width || parseInt ( container . style ( "width" ) , 10 ) || 960 ) ; } ;
 /*
Calculate the available height for a chart.
*/
 nv . utils . availableHeight = ( height , container , margin ) { return Math . max ( 0 , nv . utils . sanitizeHeight ( height , container ) - margin . top - margin . bottom ) ; } ;
 /*
Calculate the available width for a chart.
*/
 nv . utils . availableWidth = ( width , container , margin ) { return Math . max ( 0 , nv . utils . sanitizeWidth ( width , container ) - margin . left - margin . right ) ; } ;
 /*
Clear any rendered chart components and display a chart's 'noData' message
*/
 nv . utils . noData = ( chart , container ) { var opt = chart . options ( ) , margin = opt . margin ( ) , noData = opt . noData ( ) , data = ( noData == null ) ? [ "No Data Available." ] : [ noData ] , height = nv . utils . availableHeight ( null , container , margin ) , width = nv . utils . availableWidth ( null , container , margin ) , x = margin . left + width / 2 , y = margin . top + height / 2 ;
 //Remove any previously created chart components
 container . selectAll ( "g" ) . remove ( ) ; var noDataText = container . selectAll ( ".nv-noData" ) . data ( data ) ; noDataText . enter ( ) . append ( "text" ) . attr ( "class" , "nvd3 nv-noData" ) . attr ( "dy" , "-.7em" ) . style ( "text-anchor" , "middle" ) ; noDataText . attr ( "x" , x ) . attr ( "y" , y ) . text ( ( t ) { return t ; } ) ; } ;
 /*
 Wrap long labels.
 */
 nv . utils . wrapTicks = ( text , width ) { text . each ( ( ) { var text = d3 . select ( this ) , words = text . text ( ) . split ( new RegExp ( r'\s+' ) ) . reverse ( ) , word , line = [ ] , lineNumber = 0 , lineHeight = 1.1 , y = text . attr ( "y" ) , dy = parseFloat ( text . attr ( "dy" ) ) , tspan = text . text ( null ) . append ( "tspan" ) . attr ( "x" , 0 ) . attr ( "y" , y ) . attr ( "dy" , dy + "em" ) ; while ( word = words . pop ( ) ) { line . push ( word ) ; tspan . text ( line . join ( " " ) ) ; if ( tspan . node ( ) . getComputedTextLength ( ) > width ) { line . pop ( ) ; tspan . text ( line . join ( " " ) ) ; line = [ word ] ; tspan = text . append ( "tspan" ) . attr ( "x" , 0 ) . attr ( "y" , y ) . attr ( "dy" , ++ lineNumber * lineHeight + dy + "em" ) . text ( word ) ; } } } ) ; } ;
 /*
Check equality of 2 array
*/
 nv . utils . arrayEquals = ( array1 , array2 ) { if ( identical ( array1 , array2 ) ) return true ; if ( ! array1 || ! array2 ) return false ;
 // compare lengths - can save a lot of time
 if ( array1 . length != array2 . length ) return false ; for ( var i = 0 , l = array1 . length ; i < l ; i ++ ) {
 // Check if we have nested arrays
 if ( array1 [ i ] is Array && array2 [ i ] is Array ) {
 // recurse into the nested arrays
 if ( ! nv . arrayEquals ( array1 [ i ] , array2 [ i ] ) ) return false ; } else if ( array1 [ i ] != array2 [ i ] ) {
 // Warning - two different object instances will never be equal: {x:20} != {x:20}
 return false ; } } return true ; } ;
 /*
 Check if a point within an arc
 */
 nv . utils . pointIsInArc = ( pt , ptData , d3Arc ) {
 // Center of the arc is assumed to be 0,0

 // (pt.x, pt.y) are assumed to be relative to the center
 var r1 = d3Arc . innerRadius ( ) ( ptData ) , r2 = d3Arc . outerRadius ( ) ( ptData ) , theta1 = d3Arc . startAngle ( ) ( ptData ) , theta2 = d3Arc . endAngle ( ) ( ptData ) ; var dist = pt . x * pt . x + pt . y * pt . y , angle = Math . atan2 ( pt . x , - pt . y ) ; angle = ( angle < 0 ) ? ( angle + Math . PI * 2 ) : angle ; return ( r1 * r1 <= dist ) && ( dist <= r2 * r2 ) && ( theta1 <= angle ) && ( angle <= theta2 ) ; } ; nv . models . axis = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var axis = d3 . svg . axis ( ) ; var scale = d3 . scale . linear ( ) ; var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 75 , height = 60 , axisLabelText = null , showMaxMin = true , rotateLabels = 0 , rotateYLabel = true , staggerLabels = false , isOrdinal = false , ticks = null , axisLabelDistance = 0 , fontSize = undefined , duration = 250 , dispatch = d3 . dispatch ( "renderEnd" ) , tickFormatMaxMin ; axis . scale ( scale ) . orient ( "bottom" ) . tickFormat ( ( d ) { return d ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var scale0 ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-axis" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-axis" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; if ( ! identical ( ticks , null ) ) axis . ticks ( ticks ) ; else if ( axis . orient ( ) == "top" || axis . orient ( ) == "bottom" ) axis . ticks ( Math . abs ( scale . range ( ) [ 1 ] - scale . range ( ) [ 0 ] ) / 100 ) ;
 //TODO: consider calculating width/height based on whether or not label is added, for reference in charts using this component
 g . watchTransition ( renderWatch , "axis" ) . call ( axis ) ; scale0 = scale0 || axis . scale ( ) ; var fmt = axis . tickFormat ( ) ; if ( fmt == null ) { fmt = scale0 . tickFormat ( ) ; } var axisLabel = g . selectAll ( "text.nv-axislabel" ) . data ( [ axisLabelText || null ] ) ; axisLabel . exit ( ) . remove ( ) ;
 //only skip when fontSize is undefined so it can be cleared with a null or blank string
 if ( ! identical ( fontSize , undefined ) ) { g . selectAll ( "g" ) . select ( "text" ) . style ( "font-size" , fontSize ) ; } var xLabelMargin ; var axisMaxMin ; var w ; switch ( axis . orient ( ) ) { case "top" : xLabelMargin = axisLabelDistance + 36 ; axisLabel . enter ( ) . append ( "text" ) . attr ( "class" , "nv-axislabel" ) ; w = 0 ; if ( identical ( scale . range ( ) . length , 1 ) ) { w = isOrdinal ? scale . range ( ) [ 0 ] * 2 + scale . rangeBand ( ) : 0 ; } else if ( identical ( scale . range ( ) . length , 2 ) ) { w = isOrdinal ? scale . range ( ) [ 0 ] + scale . range ( ) [ 1 ] + scale . rangeBand ( ) : scale . range ( ) [ 1 ] ; } else if ( scale . range ( ) . length > 2 ) { w = scale . range ( ) [ scale . range ( ) . length - 1 ] + ( scale . range ( ) [ 1 ] - scale . range ( ) [ 0 ] ) ; } ; axisLabel . attr ( "text-anchor" , "middle" ) . attr ( "y" , - xLabelMargin ) . attr ( "x" , w / 2 ) ; if ( showMaxMin ) { axisMaxMin = wrap . selectAll ( "g.nv-axisMaxMin" ) . data ( scale . domain ( ) ) ; axisMaxMin . enter ( ) . append ( "g" ) . attr ( "class" , ( d , i ) { return [ "nv-axisMaxMin" , "nv-axisMaxMin-x" , ( i == 0 ? "nv-axisMin-x" : "nv-axisMax-x" ) ] . join ( " " ) ; } ) . append ( "text" ) ; axisMaxMin . exit ( ) . remove ( ) ; axisMaxMin . attr ( "transform" , ( d , i ) { return "translate(" + nv . utils . NaNtoZero ( scale ( d ) ) + ",0)" ; } ) . select ( "text" ) . attr ( "dy" , "-0.5em" ) . attr ( "y" , - axis . tickPadding ( ) ) . attr ( "text-anchor" , "middle" ) . text ( ( d , i ) { var formatter = tickFormatMaxMin || fmt ; var v = formatter ( d ) ; return ( "" + v ) . match ( "NaN" ) ? "" : v ; } ) ; axisMaxMin . watchTransition ( renderWatch , "min-max top" ) . attr ( "transform" , ( d , i ) { return "translate(" + nv . utils . NaNtoZero ( scale . range ( ) [ i ] ) + ",0)" ; } ) ; } break ; case "bottom" : xLabelMargin = axisLabelDistance + 36 ; var maxTextWidth = 30 ; var textHeight = 0 ; var xTicks = g . selectAll ( "g" ) . select ( "text" ) ; var rotateLabelsRule = "" ; if ( rotateLabels % 360 ) {
 //Reset transform on ticks so textHeight can be calculated correctly
 xTicks . attr ( "transform" , "" ) ;
 //Calculate the longest xTick width
 xTicks . each ( ( d , i ) { var box = this . getBoundingClientRect ( ) ; var width = box . width ; textHeight = box . height ; if ( width > maxTextWidth ) maxTextWidth = width ; } ) ; rotateLabelsRule = "rotate(" + rotateLabels + " 0," + ( textHeight / 2 + axis . tickPadding ( ) ) + ")" ;
 //Convert to radians before calculating sin. Add 30 to margin for healthy padding.
 var sin = Math . abs ( Math . sin ( rotateLabels * Math . PI / 180 ) ) ; xLabelMargin = ( sin ? sin * maxTextWidth : maxTextWidth ) + 30 ;
 //Rotate all xTicks
 xTicks . attr ( "transform" , rotateLabelsRule ) . style ( "text-anchor" , rotateLabels % 360 > 0 ? "start" : "end" ) ; } else { if ( staggerLabels ) { xTicks . attr ( "transform" , ( d , i ) { return "translate(0," + ( i % 2 == 0 ? "0" : "12" ) + ")" ; } ) ; } else { xTicks . attr ( "transform" , "translate(0,0)" ) ; } } axisLabel . enter ( ) . append ( "text" ) . attr ( "class" , "nv-axislabel" ) ; w = 0 ; if ( identical ( scale . range ( ) . length , 1 ) ) { w = isOrdinal ? scale . range ( ) [ 0 ] * 2 + scale . rangeBand ( ) : 0 ; } else if ( identical ( scale . range ( ) . length , 2 ) ) { w = isOrdinal ? scale . range ( ) [ 0 ] + scale . range ( ) [ 1 ] + scale . rangeBand ( ) : scale . range ( ) [ 1 ] ; } else if ( scale . range ( ) . length > 2 ) { w = scale . range ( ) [ scale . range ( ) . length - 1 ] + ( scale . range ( ) [ 1 ] - scale . range ( ) [ 0 ] ) ; } ; axisLabel . attr ( "text-anchor" , "middle" ) . attr ( "y" , xLabelMargin ) . attr ( "x" , w / 2 ) ; if ( showMaxMin ) {
 //if (showMaxMin && !isOrdinal) {
 axisMaxMin = wrap . selectAll ( "g.nv-axisMaxMin" ) . data ( [ scale . domain ( ) [ 0 ] , scale . domain ( ) [ scale . domain ( ) . length - 1 ] ] ) ; axisMaxMin . enter ( ) . append ( "g" ) . attr ( "class" , ( d , i ) { return [ "nv-axisMaxMin" , "nv-axisMaxMin-x" , ( i == 0 ? "nv-axisMin-x" : "nv-axisMax-x" ) ] . join ( " " ) ; } ) . append ( "text" ) ; axisMaxMin . exit ( ) . remove ( ) ; axisMaxMin . attr ( "transform" , ( d , i ) { return "translate(" + nv . utils . NaNtoZero ( ( scale ( d ) + ( isOrdinal ? scale . rangeBand ( ) / 2 : 0 ) ) ) + ",0)" ; } ) . select ( "text" ) . attr ( "dy" , ".71em" ) . attr ( "y" , axis . tickPadding ( ) ) . attr ( "transform" , rotateLabelsRule ) . style ( "text-anchor" , rotateLabels ? ( rotateLabels % 360 > 0 ? "start" : "end" ) : "middle" ) . text ( ( d , i ) { var formatter = tickFormatMaxMin || fmt ; var v = formatter ( d ) ; return ( "" + v ) . match ( "NaN" ) ? "" : v ; } ) ; axisMaxMin . watchTransition ( renderWatch , "min-max bottom" ) . attr ( "transform" , ( d , i ) { return "translate(" + nv . utils . NaNtoZero ( ( scale ( d ) + ( isOrdinal ? scale . rangeBand ( ) / 2 : 0 ) ) ) + ",0)" ; } ) ; } break ; case "right" : axisLabel . enter ( ) . append ( "text" ) . attr ( "class" , "nv-axislabel" ) ; axisLabel . style ( "text-anchor" , rotateYLabel ? "middle" : "begin" ) . attr ( "transform" , rotateYLabel ? "rotate(90)" : "" ) . attr ( "y" , rotateYLabel ? ( - Math . max ( margin . right , width ) + 12 - ( axisLabelDistance || 0 ) ) : - 10 ) . attr ( "x" , rotateYLabel ? ( d3 . max ( scale . range ( ) ) / 2 ) : axis . tickPadding ( ) ) ; if ( showMaxMin ) { axisMaxMin = wrap . selectAll ( "g.nv-axisMaxMin" ) . data ( scale . domain ( ) ) ; axisMaxMin . enter ( ) . append ( "g" ) . attr ( "class" , ( d , i ) { return [ "nv-axisMaxMin" , "nv-axisMaxMin-y" , ( i == 0 ? "nv-axisMin-y" : "nv-axisMax-y" ) ] . join ( " " ) ; } ) . append ( "text" ) . style ( "opacity" , 0 ) ; axisMaxMin . exit ( ) . remove ( ) ; axisMaxMin . attr ( "transform" , ( d , i ) { return "translate(0," + nv . utils . NaNtoZero ( scale ( d ) ) + ")" ; } ) . select ( "text" ) . attr ( "dy" , ".32em" ) . attr ( "y" , 0 ) . attr ( "x" , axis . tickPadding ( ) ) . style ( "text-anchor" , "start" ) . text ( ( d , i ) { var formatter = tickFormatMaxMin || fmt ; var v = formatter ( d ) ; return ( "" + v ) . match ( "NaN" ) ? "" : v ; } ) ; axisMaxMin . watchTransition ( renderWatch , "min-max right" ) . attr ( "transform" , ( d , i ) { return "translate(0," + nv . utils . NaNtoZero ( scale . range ( ) [ i ] ) + ")" ; } ) . select ( "text" ) . style ( "opacity" , 1 ) ; } break ; case "left" :
 /*
                     //For dynamically placing the label. Can be used with dynamically-sized chart axis margins
                     var yTicks = g.selectAll('g').select("text");
                     yTicks.each(function(d,i){
                     var labelPadding = this.getBoundingClientRect().width + axis.tickPadding() + 16;
                     if(labelPadding > width) width = labelPadding;
                     });
                     */
 axisLabel . enter ( ) . append ( "text" ) . attr ( "class" , "nv-axislabel" ) ; axisLabel . style ( "text-anchor" , rotateYLabel ? "middle" : "end" ) . attr ( "transform" , rotateYLabel ? "rotate(-90)" : "" ) . attr ( "y" , rotateYLabel ? ( - Math . max ( margin . left , width ) + 25 - ( axisLabelDistance || 0 ) ) : - 10 ) . attr ( "x" , rotateYLabel ? ( - d3 . max ( scale . range ( ) ) / 2 ) : - axis . tickPadding ( ) ) ; if ( showMaxMin ) { axisMaxMin = wrap . selectAll ( "g.nv-axisMaxMin" ) . data ( scale . domain ( ) ) ; axisMaxMin . enter ( ) . append ( "g" ) . attr ( "class" , ( d , i ) { return [ "nv-axisMaxMin" , "nv-axisMaxMin-y" , ( i == 0 ? "nv-axisMin-y" : "nv-axisMax-y" ) ] . join ( " " ) ; } ) . append ( "text" ) . style ( "opacity" , 0 ) ; axisMaxMin . exit ( ) . remove ( ) ; axisMaxMin . attr ( "transform" , ( d , i ) { return "translate(0," + nv . utils . NaNtoZero ( scale0 ( d ) ) + ")" ; } ) . select ( "text" ) . attr ( "dy" , ".32em" ) . attr ( "y" , 0 ) . attr ( "x" , - axis . tickPadding ( ) ) . attr ( "text-anchor" , "end" ) . text ( ( d , i ) { var formatter = tickFormatMaxMin || fmt ; var v = formatter ( d ) ; return ( "" + v ) . match ( "NaN" ) ? "" : v ; } ) ; axisMaxMin . watchTransition ( renderWatch , "min-max right" ) . attr ( "transform" , ( d , i ) { return "translate(0," + nv . utils . NaNtoZero ( scale . range ( ) [ i ] ) + ")" ; } ) . select ( "text" ) . style ( "opacity" , 1 ) ; } break ; } axisLabel . text ( ( d ) { return d ; } ) ; if ( showMaxMin && ( identical ( axis . orient ( ) , "left" ) || identical ( axis . orient ( ) , "right" ) ) ) {
 //check if max and min overlap other values, if so, hide the values that overlap
 g . selectAll ( "g" ) . each ( ( d , i ) { d3 . select ( this ) . select ( "text" ) . attr ( "opacity" , 1 ) ; if ( scale ( d ) < scale . range ( ) [ 1 ] + 10 || scale ( d ) > scale . range ( ) [ 0 ] - 10 ) { if ( d > 1e-10 || d < - 1e-10 ) d3 . select ( this ) . attr ( "opacity" , 0 ) ; d3 . select ( this ) . select ( "text" ) . attr ( "opacity" , 0 ) ; } } ) ;
 //if Max and Min = 0 only show min, Issue #281
 if ( scale . domain ( ) [ 0 ] == scale . domain ( ) [ 1 ] && scale . domain ( ) [ 0 ] == 0 ) { wrap . selectAll ( "g.nv-axisMaxMin" ) . style ( "opacity" , ( d , i ) { return ! i ? 1 : 0 ; } ) ; } } if ( showMaxMin && ( identical ( axis . orient ( ) , "top" ) || identical ( axis . orient ( ) , "bottom" ) ) ) { var maxMinRange = [ ] ; wrap . selectAll ( "g.nv-axisMaxMin" ) . each ( ( d , i ) { try { if ( i ) maxMinRange . push ( scale ( d ) - this . getBoundingClientRect ( ) . width - 4 ) ; else maxMinRange . push ( scale ( d ) + this . getBoundingClientRect ( ) . width + 4 ) ; } catch ( err , err_stack ) { if ( i ) maxMinRange . push ( scale ( d ) - 4 ) ; else maxMinRange . push ( scale ( d ) + 4 ) ; } } ) ;
 // the g's wrapping each tick
 g . selectAll ( "g" ) . each ( ( d , i ) { if ( scale ( d ) < maxMinRange [ 0 ] || scale ( d ) > maxMinRange [ 1 ] ) { if ( d > 1e-10 || d < - 1e-10 ) d3 . select ( this ) . remove ( ) ; else d3 . select ( this ) . select ( "text" ) . remove ( ) ; } } ) ; }
 //Highlight zero tick line
 g . selectAll ( ".tick" ) . filter ( ( d ) {
 /*
                    The filter needs to return only ticks at or near zero.
                    Numbers like 0.00001 need to count as zero as well,
                    and the arithmetic trick below solves that.
                    */
 return ! parseFloat ( Math . round ( d * 100000 ) / 1000000 ) && ( ! identical ( d , undefined ) ) ; } ) . classed ( "zero" , true ) ;
 //store old scales for use in transitions on update
 scale0 = scale . copy ( ) ; } ) ; renderWatch . renderEnd ( "axis immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . axis = axis ; chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , axisLabelDistance : { "get" : ( ) { return axisLabelDistance ; } , "set" : ( _ ) { axisLabelDistance = _ ; } } , staggerLabels : { "get" : ( ) { return staggerLabels ; } , "set" : ( _ ) { staggerLabels = _ ; } } , rotateLabels : { "get" : ( ) { return rotateLabels ; } , "set" : ( _ ) { rotateLabels = _ ; } } , rotateYLabel : { "get" : ( ) { return rotateYLabel ; } , "set" : ( _ ) { rotateYLabel = _ ; } } , showMaxMin : { "get" : ( ) { return showMaxMin ; } , "set" : ( _ ) { showMaxMin = _ ; } } , axisLabel : { "get" : ( ) { return axisLabelText ; } , "set" : ( _ ) { axisLabelText = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , ticks : { "get" : ( ) { return ticks ; } , "set" : ( _ ) { ticks = _ ; } } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , fontSize : { "get" : ( ) { return fontSize ; } , "set" : ( _ ) { fontSize = _ ; } } , tickFormatMaxMin : { "get" : ( ) { return tickFormatMaxMin ; } , "set" : ( _ ) { tickFormatMaxMin = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } , scale : { "get" : ( ) { return scale ; } , "set" : ( _ ) { scale = _ ; axis . scale ( scale ) ; isOrdinal = identical ( , "function" ) ; nv . utils . inheritOptionsD3 ( chart , scale , [ "domain" , "range" , "rangeBand" , "rangeBands" ] ) ; } } ) ; nv . utils . initOptions ( chart ) ; nv . utils . inheritOptionsD3 ( chart , axis , [ "orient" , "tickValues" , "tickSubdivide" , "tickSize" , "tickPadding" , "tickFormat" ] ) ; nv . utils . inheritOptionsD3 ( chart , scale , [ "domain" , "range" , "rangeBand" , "rangeBands" ] ) ; return chart ; } ; nv . models . boxPlot = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , id = Math . floor ( Math . random ( ) * 10000 ) , xScale = d3 . scale . ordinal ( ) , yScale = d3 . scale . linear ( ) , getX = ( d ) { return d . label ; } , getQ1 = ( d ) { return d . values . Q1 ; } , getQ2 = ( d ) { return d . values . Q2 ; } , getQ3 = ( d ) { return d . values . Q3 ; } , getWl = ( d ) { return d . values . whisker_low ; } , getWh = ( d ) { return d . values . whisker_high ; } , getColor = ( d ) { return d . color ; } , getOlItems = ( d ) { return d . values . outliers ; } , getOlValue = ( d , i , j ) { return d ; } , getOlLabel = ( d , i , j ) { return d ; } , getOlColor = ( d , i , j ) { return undefined ; } , color = nv . utils . defaultColor ( ) , container = null , xDomain , xRange , yDomain , yRange , dispatch = d3 . dispatch ( "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) , duration = 250 , maxBoxWidth = null ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var xScale0 , yScale0 ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup Scales
 xScale . domain ( xDomain || data . map ( ( d , i ) { return getX ( d , i ) ; } ) ) . rangeBands ( xRange || [ 0 , availableWidth ] , 0.1 ) ;
 // if we know yDomain, no need to calculate
 var yData = [ ] ; if ( ! yDomain ) {
 // (y-range is based on quartiles, whiskers and outliers)
 var values = [ ] , yMin , yMax ; data . forEach ( ( d , i ) { var q1 = getQ1 ( d ) , q3 = getQ3 ( d ) , wl = getWl ( d ) , wh = getWh ( d ) ; var olItems = getOlItems ( d ) ; if ( olItems ) { olItems . forEach ( ( e , i ) { values . push ( getOlValue ( e , i , undefined ) ) ; } ) ; } if ( wl ) { values . push ( wl ) ; } if ( q1 ) { values . push ( q1 ) ; } if ( q3 ) { values . push ( q3 ) ; } if ( wh ) { values . push ( wh ) ; } } ) ; yMin = d3 . min ( values ) ; yMax = d3 . max ( values ) ; yData = [ yMin , yMax ] ; } yScale . domain ( yDomain || yData ) ; yScale . range ( yRange || [ availableHeight , 0 ] ) ;
 //store old scales if they exist
 xScale0 = xScale0 || xScale ; yScale0 = yScale0 || yScale . copy ( ) . range ( [ yScale ( 0 ) , yScale ( 0 ) ] ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var boxplots = wrap . selectAll ( ".nv-boxplot" ) . data ( ( d ) { return d ; } ) ; var boxEnter = boxplots . enter ( ) . append ( "g" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) ; boxplots . attr ( "class" , "nv-boxplot" ) . attr ( "transform" , ( d , i , j ) { return "translate(" + ( xScale ( getX ( d , i ) ) + xScale . rangeBand ( ) * 0.05 ) + ", 0)" ; } ) . classed ( "hover" , ( d ) { return d . hover ; } ) ; boxplots . watchTransition ( renderWatch , "nv-boxplot: boxplots" ) . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , 0.75 ) . delay ( ( d , i ) { return i * duration / data . length ; } ) . attr ( "transform" , ( d , i ) { return "translate(" + ( xScale ( getX ( d , i ) ) + xScale . rangeBand ( ) * 0.05 ) + ", 0)" ; } ) ; boxplots . exit ( ) . remove ( ) ;
 // ----- add the SVG elements for each boxPlot -----

 // conditionally append whisker lines
 boxEnter . each ( ( d , i ) { var box = d3 . select ( this ) ; [ getWl , getWh ] . forEach ( ( f ) { if ( ! identical ( f ( d ) , undefined ) && ! identical ( f ( d ) , null ) ) { var key = ( identical ( f , getWl ) ) ? "low" : "high" ; box . append ( "line" ) . style ( "stroke" , getColor ( d ) || color ( d , i ) ) . attr ( "class" , "nv-boxplot-whisker nv-boxplot-" + key ) ; box . append ( "line" ) . style ( "stroke" , getColor ( d ) || color ( d , i ) ) . attr ( "class" , "nv-boxplot-tick nv-boxplot-" + key ) ; } } ) ; } ) ; var box_width = ( ) { return ( identical ( maxBoxWidth , null ) ? xScale . rangeBand ( ) * 0.9 : Math . min ( 75 , xScale . rangeBand ( ) * 0.9 ) ) ; } ; var box_left = ( ) { return xScale . rangeBand ( ) * 0.45 - box_width ( ) / 2 ; } ; var box_right = ( ) { return xScale . rangeBand ( ) * 0.45 + box_width ( ) / 2 ; } ;
 // update whisker lines and ticks
 [ getWl , getWh ] . forEach ( ( f ) { var key = ( identical ( f , getWl ) ) ? "low" : "high" ; var endpoint = ( identical ( f , getWl ) ) ? getQ1 : getQ3 ; boxplots . select ( "line.nv-boxplot-whisker.nv-boxplot-" + key ) . watchTransition ( renderWatch , "nv-boxplot: boxplots" ) . attr ( "x1" , xScale . rangeBand ( ) * 0.45 ) . attr ( "y1" , ( d , i ) { return yScale ( f ( d ) ) ; } ) . attr ( "x2" , xScale . rangeBand ( ) * 0.45 ) . attr ( "y2" , ( d , i ) { return yScale ( endpoint ( d ) ) ; } ) ; boxplots . select ( "line.nv-boxplot-tick.nv-boxplot-" + key ) . watchTransition ( renderWatch , "nv-boxplot: boxplots" ) . attr ( "x1" , box_left ) . attr ( "y1" , ( d , i ) { return yScale ( f ( d ) ) ; } ) . attr ( "x2" , box_right ) . attr ( "y2" , ( d , i ) { return yScale ( f ( d ) ) ; } ) ; } ) ; [ getWl , getWh ] . forEach ( ( f ) { var key = ( identical ( f , getWl ) ) ? "low" : "high" ; boxEnter . selectAll ( ".nv-boxplot-" + key ) . on ( "mouseover" , ( d , i , j ) { d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( series : { "key" : f ( d ) , "color" : getColor ( d ) || color ( d , j ) } , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i , j ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( series : { "key" : f ( d ) , "color" : getColor ( d ) || color ( d , j ) } , e : d3 . event ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ; } ) ;
 // boxes
 boxEnter . append ( "rect" ) . attr ( "class" , "nv-boxplot-box" ) . on ( "mouseover" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( key : getX ( d ) , value : getX ( d ) , series : [ { "key" : "Q3" , "value" : getQ3 ( d ) , "color" : getColor ( d ) || color ( d , i ) } , { "key" : "Q2" , "value" : getQ2 ( d ) , "color" : getColor ( d ) || color ( d , i ) } , { "key" : "Q1" , "value" : getQ1 ( d ) , "color" : getColor ( d ) || color ( d , i ) } ] , data : d , index : i , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( key : getX ( d ) , value : getX ( d ) , series : [ { "key" : "Q3" , "value" : getQ3 ( d ) , "color" : getColor ( d ) || color ( d , i ) } , { "key" : "Q2" , "value" : getQ2 ( d ) , "color" : getColor ( d ) || color ( d , i ) } , { "key" : "Q1" , "value" : getQ1 ( d ) , "color" : getColor ( d ) || color ( d , i ) } ] , data : d , index : i , e : d3 . event ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ;
 // box transitions
 boxplots . select ( "rect.nv-boxplot-box" ) . watchTransition ( renderWatch , "nv-boxplot: boxes" ) . attr ( "y" , ( d , i ) { return yScale ( getQ3 ( d ) ) ; } ) . attr ( "width" , box_width ) . attr ( "x" , box_left ) . attr ( "height" , ( d , i ) { return Math . abs ( yScale ( getQ3 ( d ) ) - yScale ( getQ1 ( d ) ) ) || 1 ; } ) . style ( "fill" , ( d , i ) { return getColor ( d ) || color ( d , i ) ; } ) . style ( "stroke" , ( d , i ) { return getColor ( d ) || color ( d , i ) ; } ) ;
 // median line
 boxEnter . append ( "line" ) . attr ( "class" , "nv-boxplot-median" ) ; boxplots . select ( "line.nv-boxplot-median" ) . watchTransition ( renderWatch , "nv-boxplot: boxplots line" ) . attr ( "x1" , box_left ) . attr ( "y1" , ( d , i ) { return yScale ( getQ2 ( d ) ) ; } ) . attr ( "x2" , box_right ) . attr ( "y2" , ( d , i ) { return yScale ( getQ2 ( d ) ) ; } ) ;
 // outliers
 var outliers = boxplots . selectAll ( ".nv-boxplot-outlier" ) . data ( ( d ) { return getOlItems ( d ) || [ ] ; } ) ; outliers . enter ( ) . append ( "circle" ) . style ( "fill" , ( d , i , j ) { return getOlColor ( d , i , j ) || color ( d , j ) ; } ) . style ( "stroke" , ( d , i , j ) { return getOlColor ( d , i , j ) || color ( d , j ) ; } ) . style ( "z-index" , 9000 ) . on ( "mouseover" , ( d , i , j ) { d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( series : { "key" : getOlLabel ( d , i , j ) , "color" : getOlColor ( d , i , j ) || color ( d , j ) } , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i , j ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( series : { "key" : getOlLabel ( d , i , j ) , "color" : getOlColor ( d , i , j ) || color ( d , j ) } , e : d3 . event ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ; outliers . attr ( "class" , "nv-boxplot-outlier" ) ; outliers . watchTransition ( renderWatch , "nv-boxplot: nv-boxplot-outlier" ) . attr ( "cx" , xScale . rangeBand ( ) * 0.45 ) . attr ( "cy" , ( d , i , j ) { return yScale ( getOlValue ( d , i , j ) ) ; } ) . attr ( "r" , "3" ) ; outliers . exit ( ) . remove ( ) ;
 //store old scales for use in transitions on update
 xScale0 = xScale . copy ( ) ; yScale0 = yScale . copy ( ) ; } ) ; renderWatch . renderEnd ( "nv-boxplot immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , maxBoxWidth : { "get" : ( ) { return maxBoxWidth ; } , "set" : ( _ ) { maxBoxWidth = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , q1 : { "get" : ( ) { return getQ1 ; } , "set" : ( _ ) { getQ1 = _ ; } } , q2 : { "get" : ( ) { return getQ2 ; } , "set" : ( _ ) { getQ2 = _ ; } } , q3 : { "get" : ( ) { return getQ3 ; } , "set" : ( _ ) { getQ3 = _ ; } } , wl : { "get" : ( ) { return getWl ; } , "set" : ( _ ) { getWl = _ ; } } , wh : { "get" : ( ) { return getWh ; } , "set" : ( _ ) { getWh = _ ; } } , itemColor : { "get" : ( ) { return getColor ; } , "set" : ( _ ) { getColor = _ ; } } , outliers : { "get" : ( ) { return getOlItems ; } , "set" : ( _ ) { getOlItems = _ ; } } , outlierValue : { "get" : ( ) { return getOlValue ; } , "set" : ( _ ) { getOlValue = _ ; } } , outlierLabel : { "get" : ( ) { return getOlLabel ; } , "set" : ( _ ) { getOlLabel = _ ; } } , outlierColor : { "get" : ( ) { return getOlColor ; } , "set" : ( _ ) { getOlColor = _ ; } } , xScale : { "get" : ( ) { return xScale ; } , "set" : ( _ ) { xScale = _ ; } } , yScale : { "get" : ( ) { return yScale ; } , "set" : ( _ ) { yScale = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , y : { "get" : ( ) { console . warn ( "BoxPlot 'y' chart option is deprecated. Please use model overrides instead." ) ; return { } ; } , "set" : ( _ ) { console . warn ( "BoxPlot 'y' chart option is deprecated. Please use model overrides instead." ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . boxPlotChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var boxplot = nv . models . boxPlot ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) ; var margin = { "top" : 15 , "right" : 10 , "bottom" : 50 , "left" : 60 } , width = null , height = null , color = nv . utils . getColor ( ) , showXAxis = true , showYAxis = true , rightAlignYAxis = false , staggerLabels = false , tooltip = nv . models . tooltip ( ) , x , y , noData = "No Data Available." , dispatch = d3 . dispatch ( "beforeUpdate" , "renderEnd" ) , duration = 250 ; xAxis . orient ( "bottom" ) . showMaxMin ( false ) . tickFormat ( ( d ) { return d ; } ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) . tickFormat ( d3 . format ( ",.1f" ) ) ; tooltip . duration ( 0 ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( boxplot ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = ( width || parseInt ( container . style ( "width" ) ) || 960 ) - margin . left - margin . right ; var availableHeight = ( height || parseInt ( container . style ( "height" ) ) || 400 ) - margin . top - margin . bottom ; chart . update = ( ) { dispatch . beforeUpdate ( ) ; container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ;
 // TODO still need to find a way to validate quartile data presence using boxPlot callbacks.

 // Display No Data message if there's nothing to show. (quartiles required at minimum).
 if ( ! data || ! data . length ) { var noDataText = container . selectAll ( ".nv-noData" ) . data ( [ noData ] ) ; noDataText . enter ( ) . append ( "text" ) . attr ( "class" , "nvd3 nv-noData" ) . attr ( "dy" , "-.7em" ) . style ( "text-anchor" , "middle" ) ; noDataText . attr ( "x" , margin . left + availableWidth / 2 ) . attr ( "y" , margin . top + availableHeight / 2 ) . text ( ( d ) { return d ; } ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = boxplot . xScale ( ) ; y = boxplot . yScale ( ) . clamp ( true ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-boxPlotWithAxes" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-boxPlotWithAxes" ) . append ( "g" ) ; var defsEnter = gEnter . append ( "defs" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) . append ( "g" ) . attr ( "class" , "nv-zeroLine" ) . append ( "line" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-barsWrap" ) ; g . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 // Main Chart Component(s)
 boxplot . width ( availableWidth ) . height ( availableHeight ) ; var barsWrap = g . select ( ".nv-barsWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ; barsWrap . transition ( ) . call ( boxplot ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-x-label-clip-" + boxplot . id ( ) ) . append ( "rect" ) ; g . select ( "#nv-x-label-clip-" + boxplot . id ( ) + " rect" ) . attr ( "width" , x . rangeBand ( ) * ( staggerLabels ? 2 : 1 ) ) . attr ( "height" , 16 ) . attr ( "x" , - x . rangeBand ( ) / ( staggerLabels ? 1 : 2 ) ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) ; g . select ( ".nv-x.nv-axis" ) . call ( xAxis ) ; var xTicks = g . select ( ".nv-x.nv-axis" ) . selectAll ( "g" ) ; if ( staggerLabels ) { xTicks . selectAll ( "text" ) . attr ( "transform" , ( d , i , j ) { return "translate(0," + ( identical ( j % 2 , 0 ) ? "5" : "17" ) + ")" ; } ) ; } } if ( showYAxis ) { yAxis . scale ( y ) . ticks ( Math . floor ( availableHeight / 36 ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-y.nv-axis" ) . call ( yAxis ) ; }
 // Zero line
 g . select ( ".nv-zeroLine line" ) . attr ( "x1" , 0 ) . attr ( "x2" , availableWidth ) . attr ( "y1" , y ( 0 ) ) . attr ( "y2" , y ( 0 ) ) ; } ) ; renderWatch . renderEnd ( "nv-boxplot chart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 boxplot . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { tooltip . data ( evt ) . hidden ( false ) ; } ) ; boxplot . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . data ( evt ) . hidden ( true ) ; } ) ; boxplot . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . boxplot = boxplot ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , staggerLabels : { "get" : ( ) { return staggerLabels ; } , "set" : ( _ ) { staggerLabels = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , tooltipContent : { "get" : ( ) { return tooltip ; } , "set" : ( _ ) { tooltip = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; boxplot . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; boxplot . color ( color ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( ( _ ) ? "right" : "left" ) ; } } ) ; nv . utils . inheritOptions ( chart , boxplot ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 // Chart design based on the recommendations of Stephen Few. Implementation

 // based on the work of Clint Ivy, Jamie Love, and Jason Davies.

 // http://projects.instantcognition.com/protovis/bulletchart/
 nv . models . bullet = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , orient = "left" , reverse = false , ranges = ( d ) { return d . ranges ; } , markers = ( d ) { return d . markers ? d . markers : [ ] ; } , markerLines = ( d ) { return d . markerLines ? d . markerLines : [ 0 ] ; } , measures = ( d ) { return d . measures ; } , rangeLabels = ( d ) { return d . rangeLabels ? d . rangeLabels : [ ] ; } , markerLabels = ( d ) { return d . markerLabels ? d . markerLabels : [ ] ; } , markerLineLabels = ( d ) { return d . markerLineLabels ? d . markerLineLabels : [ ] ; } , measureLabels = ( d ) { return d . measureLabels ? d . measureLabels : [ ] ; } , forceX = [ 0 ] , width = 380 , height = 30 , container = null , tickFormat = null , color = nv . utils . getColor ( [ "#1f77b4" ] ) , dispatch = d3 . dispatch ( "elementMouseover" , "elementMouseout" , "elementMousemove" ) , defaultRangeLabels = [ "Maximum" , "Mean" , "Minimum" ] , legacyRangeClassNames = [ "Max" , "Avg" , "Min" ] , duration = 1000 ; sortLabels ( labels , values ) { var lz = labels . slice ( ) ; labels . sort ( ( a , b ) { var iA = lz . indexOf ( a ) ; var iB = lz . indexOf ( b ) ; return d3 . descending ( values [ iA ] , values [ iB ] ) ; } ) ; } ; chart ( selection ) { selection . each ( ( d , i ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var rangez = ranges . call ( this , d , i ) . slice ( ) , markerz = markers . call ( this , d , i ) . slice ( ) , markerLinez = markerLines . call ( this , d , i ) . slice ( ) , measurez = measures . call ( this , d , i ) . slice ( ) , rangeLabelz = rangeLabels . call ( this , d , i ) . slice ( ) , markerLabelz = markerLabels . call ( this , d , i ) . slice ( ) , markerLineLabelz = markerLineLabels . call ( this , d , i ) . slice ( ) , measureLabelz = measureLabels . call ( this , d , i ) . slice ( ) ;
 // Sort labels according to their sorted values
 sortLabels ( rangeLabelz , rangez ) ; sortLabels ( markerLabelz , markerz ) ; sortLabels ( markerLineLabelz , markerLinez ) ; sortLabels ( measureLabelz , measurez ) ;
 // sort values descending
 rangez . sort ( d3 . descending ) ; markerz . sort ( d3 . descending ) ; markerLinez . sort ( d3 . descending ) ; measurez . sort ( d3 . descending ) ;
 // Setup Scales

 // Compute the new x-scale.
 var x1 = d3 . scale . linear ( ) . domain ( d3 . extent ( d3 . merge ( [ forceX , rangez ] ) ) ) . range ( reverse ? [ availableWidth , 0 ] : [ 0 , availableWidth ] ) ;
 // Retrieve the old x-scale, if this is an update.
 var x0 = this . ___chart__ || d3 . scale . linear ( ) . domain ( [ 0 , Infinity ] ) . range ( x1 . range ( ) ) ;
 // Stash the new scale.
 this . ___chart__ = x1 ; var rangeMin = d3 . min ( rangez ) , rangeMax = d3 . max ( rangez ) , rangeAvg = rangez [ 1 ] ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-bullet" ) . data ( [ d ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-bullet" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; for ( var i = 0 , il = rangez . length ; i < il ; i ++ ) { var rangeClassNames = "nv-range nv-range" + i ; if ( i <= 2 ) { rangeClassNames = rangeClassNames + " nv-range" + legacyRangeClassNames [ i ] ; } gEnter . append ( "rect" ) . attr ( "class" , rangeClassNames ) ; } gEnter . append ( "rect" ) . attr ( "class" , "nv-measure" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var w0 = ( d ) { return Math . abs ( x0 ( d ) - x0 ( 0 ) ) ; } , w1 = ( d ) { return Math . abs ( x1 ( d ) - x1 ( 0 ) ) ; } ; var xp0 = ( d ) { return d < 0 ? x0 ( d ) : x0 ( 0 ) ; } , xp1 = ( d ) { return d < 0 ? x1 ( d ) : x1 ( 0 ) ; } ; for ( var i = 0 , il = rangez . length ; i < il ; i ++ ) { var range = rangez [ i ] ; g . select ( "rect.nv-range" + i ) . datum ( range ) . attr ( "height" , availableHeight ) . transition ( ) . duration ( duration ) . attr ( "width" , w1 ( range ) ) . attr ( "x" , xp1 ( range ) ) ; } g . select ( "rect.nv-measure" ) . style ( "fill" , color ) . attr ( "height" , availableHeight / 3 ) . attr ( "y" , availableHeight / 3 ) . on ( "mouseover" , ( ) { dispatch . elementMouseover ( value : measurez [ 0 ] , label : measureLabelz [ 0 ] || "Current" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mousemove" , ( ) { dispatch . elementMousemove ( value : measurez [ 0 ] , label : measureLabelz [ 0 ] || "Current" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( ) { dispatch . elementMouseout ( value : measurez [ 0 ] , label : measureLabelz [ 0 ] || "Current" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . transition ( ) . duration ( duration ) . attr ( "width" , measurez < 0 ? x1 ( 0 ) - x1 ( measurez [ 0 ] ) : x1 ( measurez [ 0 ] ) - x1 ( 0 ) ) . attr ( "x" , xp1 ( measurez ) ) ; var h3 = availableHeight / 6 ; var markerData = markerz . map ( ( marker , index ) { return { "value" : marker , "label" : markerLabelz [ index ] } ; } ) ; gEnter . selectAll ( "path.nv-markerTriangle" ) . data ( markerData ) . enter ( ) . append ( "path" ) . attr ( "class" , "nv-markerTriangle" ) . attr ( "d" , "M0," + h3 + "L" + h3 + "," + ( - h3 ) + " " + ( - h3 ) + "," + ( - h3 ) + "Z" ) . on ( "mouseover" , ( d ) { dispatch . elementMouseover ( value : d . value , label : d . label || "Previous" , color : d3 . select ( this ) . style ( "fill" ) , pos : [ x1 ( d . value ) , availableHeight / 2 ] ) ; } ) . on ( "mousemove" , ( d ) { dispatch . elementMousemove ( value : d . value , label : d . label || "Previous" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i ) { dispatch . elementMouseout ( value : d . value , label : d . label || "Previous" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) ; g . selectAll ( "path.nv-markerTriangle" ) . data ( markerData ) . transition ( ) . duration ( duration ) . attr ( "transform" , ( d ) { return "translate(" + x1 ( d . value ) + "," + ( availableHeight / 2 ) + ")" ; } ) ; var markerLinesData = markerLinez . map ( ( marker , index ) { return { "value" : marker , "label" : markerLineLabelz [ index ] } ; } ) ; gEnter . selectAll ( "line.nv-markerLine" ) . data ( markerLinesData ) . enter ( ) . append ( "line" ) . attr ( "cursor" , "" ) . attr ( "class" , "nv-markerLine" ) . attr ( "x1" , ( d ) { return x1 ( d . value ) ; } ) . attr ( "y1" , "2" ) . attr ( "x2" , ( d ) { return x1 ( d . value ) ; } ) . attr ( "y2" , availableHeight - 2 ) . on ( "mouseover" , ( d ) { dispatch . elementMouseover ( value : d . value , label : d . label || "Previous" , color : d3 . select ( this ) . style ( "fill" ) , pos : [ x1 ( d . value ) , availableHeight / 2 ] ) ; } ) . on ( "mousemove" , ( d ) { dispatch . elementMousemove ( value : d . value , label : d . label || "Previous" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i ) { dispatch . elementMouseout ( value : d . value , label : d . label || "Previous" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) ; g . selectAll ( "line.nv-markerLine" ) . data ( markerLinesData ) . transition ( ) . duration ( duration ) . attr ( "x1" , ( d ) { return x1 ( d . value ) ; } ) . attr ( "x2" , ( d ) { return x1 ( d . value ) ; } ) ; wrap . selectAll ( ".nv-range" ) . on ( "mouseover" , ( d , i ) { var label = rangeLabelz [ i ] || defaultRangeLabels [ i ] ; dispatch . elementMouseover ( value : d , label : label , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mousemove" , ( ) { dispatch . elementMousemove ( value : measurez [ 0 ] , label : measureLabelz [ 0 ] || "Previous" , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i ) { var label = rangeLabelz [ i ] || defaultRangeLabels [ i ] ; dispatch . elementMouseout ( value : d , label : label , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) ; } ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , ranges : { "get" : ( ) { return ranges ; } , "set" : ( _ ) { ranges = _ ; } } , markers : { "get" : ( ) { return markers ; } , "set" : ( _ ) { markers = _ ; } } , measures : { "get" : ( ) { return measures ; } , "set" : ( _ ) { measures = _ ; } } , forceX : { "get" : ( ) { return forceX ; } , "set" : ( _ ) { forceX = _ ; } } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , tickFormat : { "get" : ( ) { return tickFormat ; } , "set" : ( _ ) { tickFormat = _ ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , orient : { "get" : ( ) { return orient ; } , "set" : ( _ ) { orient = _ ; reverse = orient == "right" || orient == "bottom" ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 // Chart design based on the recommendations of Stephen Few. Implementation

 // based on the work of Clint Ivy, Jamie Love, and Jason Davies.

 // http://projects.instantcognition.com/protovis/bulletchart/
 nv . models . bulletChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var bullet = nv . models . bullet ( ) ; var tooltip = nv . models . tooltip ( ) ; var orient = "left" , reverse = false , margin = { "top" : 5 , "right" : 40 , "bottom" : 20 , "left" : 120 } , ranges = ( d ) { return d . ranges ; } , markers = ( d ) { return d . markers ? d . markers : [ ] ; } , measures = ( d ) { return d . measures ; } , width = null , height = 55 , tickFormat = null , ticks = null , noData = null , dispatch = d3 . dispatch ( ) ; tooltip . duration ( 0 ) . headerEnabled ( false ) ; chart ( selection ) { selection . each ( ( d , i ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = height - margin . top - margin . bottom , that = this ; chart . update = ( ) { chart ( selection ) ; } ; chart . container = this ;
 // Display No Data message if there's nothing to show.
 if ( ! d || ! ranges . call ( this , d , i ) ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; } var rangez = ranges . call ( this , d , i ) . slice ( ) . sort ( d3 . descending ) , markerz = markers . call ( this , d , i ) . slice ( ) . sort ( d3 . descending ) , measurez = measures . call ( this , d , i ) . slice ( ) . sort ( d3 . descending ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-bulletChart" ) . data ( [ d ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-bulletChart" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-bulletWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-titles" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // Compute the new x-scale.
 var x1 = d3 . scale . linear ( ) . domain ( [ 0 , Math . max ( rangez [ 0 ] , ( markerz [ 0 ] || 0 ) , measurez [ 0 ] ) ] ) . range ( reverse ? [ availableWidth , 0 ] : [ 0 , availableWidth ] ) ;
 // Retrieve the old x-scale, if this is an update.
 var x0 = this . ___chart__ || d3 . scale . linear ( ) . domain ( [ 0 , Infinity ] ) . range ( x1 . range ( ) ) ;
 // Stash the new scale.
 this . ___chart__ = x1 ; var w0 = ( d ) { return Math . abs ( x0 ( d ) - x0 ( 0 ) ) ; } , w1 = ( d ) { return Math . abs ( x1 ( d ) - x1 ( 0 ) ) ; } ; var title = gEnter . select ( ".nv-titles" ) . append ( "g" ) . attr ( "text-anchor" , "end" ) . attr ( "transform" , "translate(-6," + ( height - margin . top - margin . bottom ) / 2 + ")" ) ; title . append ( "text" ) . attr ( "class" , "nv-title" ) . text ( ( d ) { return d . title ; } ) ; title . append ( "text" ) . attr ( "class" , "nv-subtitle" ) . attr ( "dy" , "1em" ) . text ( ( d ) { return d . subtitle ; } ) ; bullet . width ( availableWidth ) . height ( availableHeight ) ; var bulletWrap = g . select ( ".nv-bulletWrap" ) ; d3 . transition ( bulletWrap ) . call ( bullet ) ;
 // Compute the tick format.
 var format = tickFormat || x1 . tickFormat ( availableWidth / 100 ) ;
 // Update the tick groups.
 var tick = g . selectAll ( "g.nv-tick" ) . data ( x1 . ticks ( ticks ? ticks : ( availableWidth / 50 ) ) , ( d ) { return this . textContent || format ( d ) ; } ) ;
 // Initialize the ticks with the old scale, x0.
 var tickEnter = tick . enter ( ) . append ( "g" ) . attr ( "class" , "nv-tick" ) . attr ( "transform" , ( d ) { return "translate(" + x0 ( d ) + ",0)" ; } ) . style ( "opacity" , 1e-6 ) ; tickEnter . append ( "line" ) . attr ( "y1" , availableHeight ) . attr ( "y2" , availableHeight * 7 / 6 ) ; tickEnter . append ( "text" ) . attr ( "text-anchor" , "middle" ) . attr ( "dy" , "1em" ) . attr ( "y" , availableHeight * 7 / 6 ) . text ( format ) ;
 // Transition the updating ticks to the new scale, x1.
 var tickUpdate = d3 . transition ( tick ) . transition ( ) . duration ( bullet . duration ( ) ) . attr ( "transform" , ( d ) { return "translate(" + x1 ( d ) + ",0)" ; } ) . style ( "opacity" , 1 ) ; tickUpdate . select ( "line" ) . attr ( "y1" , availableHeight ) . attr ( "y2" , availableHeight * 7 / 6 ) ; tickUpdate . select ( "text" ) . attr ( "y" , availableHeight * 7 / 6 ) ;
 // Transition the exiting ticks to the new scale, x1.
 d3 . transition ( tick . exit ( ) ) . transition ( ) . duration ( bullet . duration ( ) ) . attr ( "transform" , ( d ) { return "translate(" + x1 ( d ) + ",0)" ; } ) . style ( "opacity" , 1e-6 ) . remove ( ) ; } ) ; d3 . timer . flush ( ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 bullet . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt [ "series" ] = { "key" : evt . label , "value" : evt . value , "color" : evt . color } ; tooltip . data ( evt ) . hidden ( false ) ; } ) ; bullet . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; bullet . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . bullet = bullet ; chart . dispatch = dispatch ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , ranges : { "get" : ( ) { return ranges ; } , "set" : ( _ ) { ranges = _ ; } } , markers : { "get" : ( ) { return markers ; } , "set" : ( _ ) { markers = _ ; } } , measures : { "get" : ( ) { return measures ; } , "set" : ( _ ) { measures = _ ; } } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , tickFormat : { "get" : ( ) { return tickFormat ; } , "set" : ( _ ) { tickFormat = _ ; } } , ticks : { "get" : ( ) { return ticks ; } , "set" : ( _ ) { ticks = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , orient : { "get" : ( ) { return orient ; } , "set" : ( _ ) { orient = _ ; reverse = orient == "right" || orient == "bottom" ; } } ) ; nv . utils . inheritOptions ( chart , bullet ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . candlestickBar = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = null , height = null , id = Math . floor ( Math . random ( ) * 10000 ) , container , x = d3 . scale . linear ( ) , y = d3 . scale . linear ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , getOpen = ( d ) { return d . open ; } , getClose = ( d ) { return d . close ; } , getHigh = ( d ) { return d . high ; } , getLow = ( d ) { return d . low ; } , forceX = [ ] , forceY = [ ] , padData = false , clipEdge = true , color = nv . utils . defaultColor ( ) , interactive = false , xDomain , yDomain , xRange , yRange , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" , "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 chart ( selection ) { selection . each ( ( data ) { container = d3 . select ( this ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; nv . utils . initSVG ( container ) ;
 // Width of the candlestick bars.
 var barWidth = ( availableWidth / data [ 0 ] . values . length ) * .45 ;
 // Setup Scales
 x . domain ( xDomain || d3 . extent ( data [ 0 ] . values . map ( getX ) . concat ( forceX ) ) ) ; if ( padData ) x . range ( xRange || [ availableWidth * .5 / data [ 0 ] . values . length , availableWidth * ( data [ 0 ] . values . length - .5 ) / data [ 0 ] . values . length ] ) ; else x . range ( xRange || [ 5 + barWidth / 2 , availableWidth - barWidth / 2 - 5 ] ) ; y . domain ( yDomain || [ d3 . min ( data [ 0 ] . values . map ( getLow ) . concat ( forceY ) ) , d3 . max ( data [ 0 ] . values . map ( getHigh ) . concat ( forceY ) ) ] ) . range ( yRange || [ availableHeight , 0 ] ) ;
 // If scale's domain don't have a range, slightly adjust to make one... so a chart can show a single data point
 if ( identical ( x . domain ( ) [ 0 ] , x . domain ( ) [ 1 ] ) ) x . domain ( ) [ 0 ] ? x . domain ( [ x . domain ( ) [ 0 ] - x . domain ( ) [ 0 ] * 0.01 , x . domain ( ) [ 1 ] + x . domain ( ) [ 1 ] * 0.01 ] ) : x . domain ( [ - 1 , 1 ] ) ; if ( identical ( y . domain ( ) [ 0 ] , y . domain ( ) [ 1 ] ) ) y . domain ( ) [ 0 ] ? y . domain ( [ y . domain ( ) [ 0 ] + y . domain ( ) [ 0 ] * 0.01 , y . domain ( ) [ 1 ] - y . domain ( ) [ 1 ] * 0.01 ] ) : y . domain ( [ - 1 , 1 ] ) ;
 // Setup containers and skeleton of chart
 var wrap = d3 . select ( this ) . selectAll ( "g.nv-wrap.nv-candlestickBar" ) . data ( [ data [ 0 ] . values ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-candlestickBar" ) ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-ticks" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; container . on ( "click" , ( d , i ) { dispatch . chartClick ( data : d , index : i , pos : d3 . event , id : id ) ; } ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-chart-clip-path-" + id ) . append ( "rect" ) ; wrap . select ( "#nv-chart-clip-path-" + id + " rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; g . attr ( "clip-path" , clipEdge ? "url(#nv-chart-clip-path-" + id + ")" : "" ) ; var ticks = wrap . select ( ".nv-ticks" ) . selectAll ( ".nv-tick" ) . data ( ( d ) { return d ; } ) ; ticks . exit ( ) . remove ( ) ; var tickGroups = ticks . enter ( ) . append ( "g" ) ;
 // The colors are currently controlled by CSS.
 ticks . attr ( "class" , ( d , i , j ) { return ( getOpen ( d , i ) > getClose ( d , i ) ? "nv-tick negative" : "nv-tick positive" ) + " nv-tick-" + j + "-" + i ; } ) ; var lines = tickGroups . append ( "line" ) . attr ( "class" , "nv-candlestick-lines" ) . attr ( "transform" , ( d , i ) { return "translate(" + x ( getX ( d , i ) ) + ",0)" ; } ) . attr ( "x1" , 0 ) . attr ( "y1" , ( d , i ) { return y ( getHigh ( d , i ) ) ; } ) . attr ( "x2" , 0 ) . attr ( "y2" , ( d , i ) { return y ( getLow ( d , i ) ) ; } ) ; var rects = tickGroups . append ( "rect" ) . attr ( "class" , "nv-candlestick-rects nv-bars" ) . attr ( "transform" , ( d , i ) { return "translate(" + ( x ( getX ( d , i ) ) - barWidth / 2 ) + "," + ( y ( getY ( d , i ) ) - ( getOpen ( d , i ) > getClose ( d , i ) ? ( y ( getClose ( d , i ) ) - y ( getOpen ( d , i ) ) ) : 0 ) ) + ")" ; } ) . attr ( "x" , 0 ) . attr ( "y" , 0 ) . attr ( "width" , barWidth ) . attr ( "height" , ( d , i ) { var open = getOpen ( d , i ) ; var close = getClose ( d , i ) ; return open > close ? y ( close ) - y ( open ) : y ( open ) - y ( close ) ; } ) ; ticks . select ( ".nv-candlestick-lines" ) . transition ( ) . attr ( "transform" , ( d , i ) { return "translate(" + x ( getX ( d , i ) ) + ",0)" ; } ) . attr ( "x1" , 0 ) . attr ( "y1" , ( d , i ) { return y ( getHigh ( d , i ) ) ; } ) . attr ( "x2" , 0 ) . attr ( "y2" , ( d , i ) { return y ( getLow ( d , i ) ) ; } ) ; ticks . select ( ".nv-candlestick-rects" ) . transition ( ) . attr ( "transform" , ( d , i ) { return "translate(" + ( x ( getX ( d , i ) ) - barWidth / 2 ) + "," + ( y ( getY ( d , i ) ) - ( getOpen ( d , i ) > getClose ( d , i ) ? ( y ( getClose ( d , i ) ) - y ( getOpen ( d , i ) ) ) : 0 ) ) + ")" ; } ) . attr ( "x" , 0 ) . attr ( "y" , 0 ) . attr ( "width" , barWidth ) . attr ( "height" , ( d , i ) { var open = getOpen ( d , i ) ; var close = getClose ( d , i ) ; return open > close ? y ( close ) - y ( open ) : y ( open ) - y ( close ) ; } ) ; } ) ; return chart ; }
 //Create methods to allow outside functions to highlight a specific bar.
 chart . highlightPoint = ( pointIndex , isHoverOver ) { chart . clearHighlights ( ) ; container . select ( ".nv-candlestickBar .nv-tick-0-" + pointIndex ) . classed ( "hover" , isHoverOver ) ; } ; chart . clearHighlights = ( ) { container . select ( ".nv-candlestickBar .nv-tick.hover" ) . classed ( "hover" , false ) ; } ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , forceX : { "get" : ( ) { return forceX ; } , "set" : ( _ ) { forceX = _ ; } } , forceY : { "get" : ( ) { return forceY ; } , "set" : ( _ ) { forceY = _ ; } } , padData : { "get" : ( ) { return padData ; } , "set" : ( _ ) { padData = _ ; } } , clipEdge : { "get" : ( ) { return clipEdge ; } , "set" : ( _ ) { clipEdge = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , interactive : { "get" : ( ) { return interactive ; } , "set" : ( _ ) { interactive = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , open : { "get" : ( ) { return getOpen ( ) ; } , "set" : ( _ ) { getOpen = _ ; } } , close : { "get" : ( ) { return getClose ( ) ; } , "set" : ( _ ) { getClose = _ ; } } , high : { "get" : ( ) { return getHigh ; } , "set" : ( _ ) { getHigh = _ ; } } , low : { "get" : ( ) { return getLow ; } , "set" : ( _ ) { getLow = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = _ . top != undefined ? _ . top : margin . top ; margin . right = _ . right != undefined ? _ . right : margin . right ; margin . bottom = _ . bottom != undefined ? _ . bottom : margin . bottom ; margin . left = _ . left != undefined ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . cumulativeLineChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var lines = nv . models . line ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , legend = nv . models . legend ( ) , controls = nv . models . legend ( ) , interactiveLayer = nv . interactiveGuideline ( ) , tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 30 , "bottom" : 50 , "left" : 60 } , marginTop = null , color = nv . utils . defaultColor ( ) , width = null , height = null , showLegend = true , showXAxis = true , showYAxis = true , rightAlignYAxis = false , showControls = true , useInteractiveGuideline = false , rescaleY = true , x , y , id = lines . id ( ) , state = nv . utils . state ( ) , defaultState = null , noData = null , average = ( d ) { return d . average ; } , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) , transitionDuration = 250 , duration = 250 , noErrorCheck = false ; state . index = 0 ; state . rescaleY = rescaleY ; xAxis . orient ( "bottom" ) . tickPadding ( 7 ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) ; tooltip . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ; controls . updateState ( false ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var dx = d3 . scale . linear ( ) , index = { "i" : 0 , "x" : 0 } , renderWatch = nv . utils . renderWatch ( dispatch , duration ) , currentYDomain ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) , "index" : index . i , "rescaleY" : rescaleY } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . index , undefined ) ) index . i = state . index ; if ( ! identical ( state . rescaleY , undefined ) ) rescaleY = state . rescaleY ; if ( ! identical ( state . active , undefined ) ) data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } ; } ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( lines ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; container . classed ( "nv-chart-" + id , true ) ; var that = this ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { if ( identical ( duration , 0 ) ) container . call ( chart ) ; else container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 // DEPRECATED set state.disableddisabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } } var indexDrag = d3 . behavior . drag ( ) . on ( "dragstart" , dragStart ) . on ( "drag" , dragMove ) . on ( "dragend" , dragEnd ) ; dragStart ( d , i ) { d3 . select ( chart . container ) . style ( "cursor" , "ew-resize" ) ; } dragMove ( d , i ) { index . x = d3 . event . x ; index . i = Math . round ( dx . invert ( index . x ) ) ; updateZero ( ) ; } dragEnd ( d , i ) { d3 . select ( chart . container ) . style ( "cursor" , "auto" ) ;
 // update state and send stateChange with new index
 state . index = index . i ; dispatch . stateChange ( state ) ; }
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = lines . xScale ( ) ; y = lines . yScale ( ) ; dx . domain ( [ 0 , data [ 0 ] . values . length - 1 ] ) . range ( [ 0 , availableWidth ] ) . clamp ( true ) ; var data = indexify ( index . i , data ) ;
 // initialize the starting yDomain for the not-rescale case after indexify (to have calculated point.display)
 if ( identical ( , "undefined" ) ) { currentYDomain = getCurrentYDomain ( data ) ; } if ( ! rescaleY ) { lines . yDomain ( currentYDomain ) ; lines . clipEdge ( true ) ; } else { lines . yDomain ( null ) ; }
 // Setup containers and skeleton of chart
 var interactivePointerEvents = ( useInteractiveGuideline ) ? "none" : "all" ; var wrap = container . selectAll ( "g.nv-wrap.nv-cumulativeLine" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-cumulativeLine" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-interactive" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) . style ( "pointer-events" , "none" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-background" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-linesWrap" ) . style ( "pointer-events" , interactivePointerEvents ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-avgLinesWrap" ) . style ( "pointer-events" , "none" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-controlsWrap" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { legend . width ( availableWidth ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) ; }
 // Controls
 if ( ! showControls ) { g . select ( ".nv-controlsWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var controlsData = [ { "key" : "Re-scale y-axis" , "disabled" : ! rescaleY } ] ; controls . width ( 140 ) . color ( [ "#444" , "#444" , "#444" ] ) . rightAlign ( false ) . margin ( top : 5 , right : 0 , bottom : 5 , left : 20 ) ; g . select ( ".nv-controlsWrap" ) . datum ( controlsData ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) . call ( controls ) ; } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 // Show error if index point value is 0 (division by zero avoided)
 var tempDisabled = data . filter ( ( d ) { return d . tempDisabled ; } ) ; wrap . select ( ".tempDisabled" ) . remove ( ) ; if ( tempDisabled . length ) { wrap . append ( "text" ) . attr ( "class" , "tempDisabled" ) . attr ( "x" , availableWidth / 2 ) . attr ( "y" , "-.71em" ) . style ( "text-anchor" , "end" ) . text ( tempDisabled . map ( ( d ) { return d . key ; } ) . join ( ", " ) + " values cannot be calculated for this time period." ) ; }
 //Set up interactive layer
 if ( useInteractiveGuideline ) { interactiveLayer . width ( availableWidth ) . height ( availableHeight ) . margin ( left : margin . left , top : margin . top ) . svgContainer ( container ) . xScale ( x ) ; wrap . select ( ".nv-interactive" ) . call ( interactiveLayer ) ; } gEnter . select ( ".nv-background" ) . append ( "rect" ) ; g . select ( ".nv-background rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; lines . y ( ( d ) { return d . display . y ; } ) . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled && ! data [ i ] . tempDisabled ; } ) ) ; var linesWrap = g . select ( ".nv-linesWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled && ! d . tempDisabled ; } ) ) ; linesWrap . call ( lines ) ;
 //Store a series index number in the data array.
 data . forEach ( ( d , i ) { d . seriesIndex = i ; } ) ; var avgLineData = data . filter ( ( d ) { return ! d . disabled && ! ! average ( d ) ; } ) ; var avgLines = g . select ( ".nv-avgLinesWrap" ) . selectAll ( "line" ) . data ( avgLineData , ( d ) { return d . key ; } ) ; var getAvgLineY = ( d ) {
 //If average lines go off the svg element, clamp them to the svg bounds.
 var yVal = y ( average ( d ) ) ; if ( yVal < 0 ) return 0 ; if ( yVal > availableHeight ) return availableHeight ; return yVal ; } ; avgLines . enter ( ) . append ( "line" ) . style ( "stroke-width" , 2 ) . style ( "stroke-dasharray" , "10,10" ) . style ( "stroke" , ( d , i ) { return lines . color ( ) ( d , d . seriesIndex ) ; } ) . attr ( "x1" , 0 ) . attr ( "x2" , availableWidth ) . attr ( "y1" , getAvgLineY ) . attr ( "y2" , getAvgLineY ) ; avgLines . style ( "stroke-opacity" , ( d ) {
 //If average lines go offscreen, make them transparent
 var yVal = y ( average ( d ) ) ; if ( yVal < 0 || yVal > availableHeight ) return 0 ; return 1 ; } ) . attr ( "x1" , 0 ) . attr ( "x2" , availableWidth ) . attr ( "y1" , getAvgLineY ) . attr ( "y2" , getAvgLineY ) ; avgLines . exit ( ) . remove ( ) ;
 //Create index line
 var indexLine = linesWrap . selectAll ( ".nv-indexLine" ) . data ( [ index ] ) ; indexLine . enter ( ) . append ( "rect" ) . attr ( "class" , "nv-indexLine" ) . attr ( "width" , 3 ) . attr ( "x" , - 2 ) . attr ( "fill" , "red" ) . attr ( "fill-opacity" , .5 ) . style ( "pointer-events" , "all" ) . call ( indexDrag ) ; indexLine . attr ( "transform" , ( d ) { return "translate(" + dx ( d . i ) + ",0)" ; } ) . attr ( "height" , availableHeight ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 70 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) ; g . select ( ".nv-x.nv-axis" ) . call ( xAxis ) ; } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-y.nv-axis" ) . call ( yAxis ) ; }
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 updateZero ( ) { indexLine . data ( [ index ] ) ;
 //When dragging the index line, turn off line transitions.

 // Then turn them back on when done dragging.
 var oldDuration = chart . duration ( ) ; chart . duration ( 0 ) ; chart . update ( ) ; chart . duration ( oldDuration ) ; } g . select ( ".nv-background rect" ) . on ( "click" , ( ) { index . x = d3 . mouse ( this ) [ 0 ] ; index . i = Math . round ( dx . invert ( index . x ) ) ;
 // update state and send stateChange with new index
 state . index = index . i ; dispatch . stateChange ( state ) ; updateZero ( ) ; } ) ; lines . dispatch . on ( "elementClick" , ( e ) { index . i = e . pointIndex ; index . x = dx ( index . i ) ;
 // update state and send stateChange with new index
 state . index = index . i ; dispatch . stateChange ( state ) ; updateZero ( ) ; } ) ; controls . dispatch . on ( "legendClick" , ( d , i ) { d . disabled = ! d . disabled ; rescaleY = ! d . disabled ; state . rescaleY = rescaleY ; if ( ! rescaleY ) { currentYDomain = getCurrentYDomain ( data ) ; } dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) state [ key ] = newState [ key ] ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; interactiveLayer . dispatch . on ( "elementMousemove" , ( e ) { lines . clearHighlights ( ) ; var singlePoint , pointIndex , pointXLocation , allData = [ ] ; data . filter ( ( series , i ) { series . seriesIndex = i ; return ! ( series . disabled || series . tempDisabled ) ; } ) . forEach ( ( series , i ) { pointIndex = nv . interactiveBisect ( series . values , e . pointXValue , chart . x ( ) ) ; lines . highlightPoint ( i , pointIndex , true ) ; var point = series . values [ pointIndex ] ; if ( identical ( , "undefined" ) ) return ; if ( identical ( , "undefined" ) ) singlePoint = point ; if ( identical ( , "undefined" ) ) pointXLocation = chart . xScale ( ) ( chart . x ( ) ( point , pointIndex ) ) ; allData . push ( key : series . key , value : chart . y ( ) ( point , pointIndex ) , color : color ( series , series . seriesIndex ) ) ; } ) ;
 //Highlight the tooltip entry based on which point the mouse is closest to.
 if ( allData . length > 2 ) { var yValue = chart . yScale ( ) . invert ( e . mouseY ) ; var domainExtent = Math . abs ( chart . yScale ( ) . domain ( ) [ 0 ] - chart . yScale ( ) . domain ( ) [ 1 ] ) ; var threshold = 0.03 * domainExtent ; var indexToHighlight = nv . nearestValueIndex ( allData . map ( ( d ) { return d . value ; } ) , yValue , threshold ) ; if ( ! identical ( indexToHighlight , null ) ) allData [ indexToHighlight ] . highlight = true ; } var xValue = xAxis . tickFormat ( ) ( chart . x ( ) ( singlePoint , pointIndex ) , pointIndex ) ; interactiveLayer . tooltip . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d ) ; } ) . data ( value : xValue , series : allData ) ( ) ; interactiveLayer . renderGuideLine ( pointXLocation ) ; } ) ; interactiveLayer . dispatch . on ( "elementMouseout" , ( e ) { lines . clearHighlights ( ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } if ( ! identical ( , "undefined" ) ) { index . i = e . index ; index . x = dx ( index . i ) ; state . index = e . index ; indexLine . data ( [ index ] ) ; } if ( ! identical ( , "undefined" ) ) { rescaleY = e . rescaleY ; } chart . update ( ) ; } ) ; } ) ; renderWatch . renderEnd ( "cumulativeLineChart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 lines . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { var point = { "x" : chart . x ( ) ( evt . point ) , "y" : chart . y ( ) ( evt . point ) , "color" : evt . point . color } ; evt . point = point ; tooltip . data ( evt ) . hidden ( false ) ; } ) ; lines . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ;
 //============================================================

 // Functions

 //------------------------------------------------------------
 var indexifyYGetter = null ;
 /* Normalize the data according to an index point. */
 indexify ( idx , data ) { if ( ! indexifyYGetter ) indexifyYGetter = lines . y ( ) ; return data . map ( ( line , i ) { if ( ! line . values ) { return line ; } var indexValue = line . values [ idx ] ; if ( indexValue == null ) { return line ; } var v = indexifyYGetter ( indexValue , idx ) ;
 // avoid divide by zero
 if ( Math . abs ( v ) < 0.00001 && ! noErrorCheck ) { line . tempDisabled = true ; return line ; } line . tempDisabled = false ; line . values = line . values . map ( ( point , pointIndex ) { point . display = { "y" : ( indexifyYGetter ( point , pointIndex ) - v ) / v } ; return point ; } ) ; return line ; } ) ; } getCurrentYDomain ( data ) { var seriesDomains = data . filter ( ( series ) { return ! ( series . disabled || series . tempDisabled ) ; } ) . map ( ( series , i ) { return d3 . extent ( series . values , ( d ) { return d . display . y ; } ) ; } ) ; return [ d3 . min ( seriesDomains , ( d ) { return d [ 0 ] ; } ) , d3 . max ( seriesDomains , ( d ) { return d [ 1 ] ; } ) ] ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . lines = lines ; chart . legend = legend ; chart . controls = controls ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . interactiveLayer = interactiveLayer ; chart . state = state ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showControls : { "get" : ( ) { return showControls ; } , "set" : ( _ ) { showControls = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , average : { "get" : ( ) { return average ; } , "set" : ( _ ) { average = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , noErrorCheck : { "get" : ( ) { return noErrorCheck ; } , "set" : ( _ ) { noErrorCheck = _ ; } } , rescaleY : { "get" : ( ) { return rescaleY ; } , "set" : ( _ ) { rescaleY = _ ; chart . state . rescaleY = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; } } , useInteractiveGuideline : { "get" : ( ) { return useInteractiveGuideline ; } , "set" : ( _ ) { useInteractiveGuideline = _ ; if ( identical ( _ , true ) ) { chart . interactive ( false ) ; chart . useVoronoi ( false ) ; } } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( ( _ ) ? "right" : "left" ) ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; lines . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; renderWatch . reset ( duration ) ; } } ) ; nv . utils . inheritOptions ( chart , lines ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; "use strict" ; nv . models . differenceChart = ( ) { "use strict" ; var container = ; var multiChart = nv . models . multiChart ( ) ; var focus = nv . models . focus ( nv . models . line ( ) ) ;
 // const dispatch = d3.dispatch();

 // yAccessor for multi chart

 // Not modifiable by end user. They can

 // overload yAccessor which is used during the processData step
 var yForMultiChart = yForMultiChart ( d ) {
 // check if the data is for an area chart

 // which has y0 and y1 values
 if ( isDefined ( d . y0 ) ) { return d . y0 ; }
 // otherwise assume it's for a line chart
 return d . y ; } ; var xForMultiChart = xForMultiChart ( d ) { return d . x ; } ; var xAccessor = xAccessor ( d ) { return d . x ; } ; var keyForXValue = "x" ; var yAccessor = yAccessor ( d ) { return d . y ; } ; var duration = 300 ; var keyForActualLessThanPredicted = null ; var keyForActualGreaterThanPredicted = null ; var height = null ; var width = null ; var margin = { "top" : 30 , "right" : 50 , "bottom" : 20 , "left" : 70 } ; var focusMargin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } ; var showPredictedLine = true ; var interpolate = "linear" ; var strokeWidth = 1 ; var xScale = d3 . time . scale ( ) ; var tickFormat = d3 . time . format . multi ( [ [ "%I:%M" , ( d ) { return d . getMinutes ( ) ; } ] , [ "%I %p" , ( d ) { return d . getHours ( ) ; } ] , [ "%a %d" , ( d ) { return d . getDay ( ) && d . getDate ( ) != 1 ; } ] , [ "%b %d" , ( d ) { return d . getDate ( ) != 1 ; } ] , [ "%B" , ( d ) { return d . getMonth ( ) ; } ] , [ "%Y" , ( ) { return true ; } ] ] ) ; chart ( selection ) { selection . each ( ( data ) { container = d3 . select ( this ) ; var dataWithoutDisabledSeries = ( data || [ ] ) . filter ( ( dataset ) { return ! dataset . disabled ; } ) ; if ( ! data || ! dataWithoutDisabledSeries . length ) { nv . utils . noData ( chart , container ) ; return chart ; } var processedData = processData ( data ) ; var availableHeight = nv . utils . availableHeight ( height , container , margin ) - focus . height ( ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) ; container . attr ( "class" , "nv-differenceChart" ) ; nv . utils . initSVG ( container ) ; chart . container = this ; multiChart . margin ( margin ) . color ( d3 . scale . category10 ( ) . range ( ) ) . y ( yForMultiChart ) . width ( width ) . height ( availableHeight ) . interpolate ( interpolate ) . useInteractiveGuideline ( true ) ; multiChart . interactiveLayer . tooltip . valueFormatter ( ( value , i , datum ) { if ( identical ( datum . key , keyForActualGreaterThanPredicted ) || identical ( datum . key , keyForActualLessThanPredicted ) ) { var diff = Math . abs ( datum . data . y0 - datum . data . y1 ) ; if ( identical ( diff , 0 ) ) { return "-" ; } return diff ; } return value ; } ) ; multiChart . stack1 . areaY1 ( ( d ) { return multiChart . stack1 . scatter . yScale ( ) ( d . display . y ) ; } ) ; multiChart . stack1 . transformData ( ( d ) { d . display = { "y" : d . y1 , "y0" : d . y0 } ; } ) ; multiChart . xAxis . scale ( xScale ) ; multiChart . xAxis . tickFormat ( tickFormat ) ; var allValues = processedData . filter ( ( dataset ) { return ! dataset . disabled ; } ) . map ( ( dataset ) { return dataset . values ; } ) ; var dateExtent = d3 . extent ( d3 . merge ( allValues ) , ( d ) { return xForMultiChart ( d ) ; } ) ; multiChart . xAxis . domain ( dateExtent ) . range ( [ 0 , availableWidth ] ) ; var yExtent = d3 . extent ( d3 . merge ( allValues ) , ( d ) { return yForMultiChart ( d ) ; } ) ; multiChart . yDomain1 ( yExtent ) ; multiChart . yAxis1 . tickFormat ( d3 . format ( ",.1f" ) ) ; multiChart . yAxis2 . tickFormat ( d3 . format ( ",.1f" ) ) ; focus . width ( availableWidth ) ; focus . margin ( focusMargin ) ; focus . xScale ( xScale . copy ( ) ) ; focus . xAxis . tickFormat ( tickFormat ) ; focus . xAxis . rotateLabels ( 0 ) ; container . append ( "g" ) . attr ( "class" , "nv-focusWrap" ) . style ( "display" , "initial" ) . attr ( "transform" , "translate(" + margin . left + ", " + ( availableHeight + focus . margin ( ) . top ) + ")" ) . datum ( processedData . filter ( ( dataset ) { return identical ( dataset . type , "line" ) ; } ) ) . call ( focus ) ; container . datum ( processedData ) . call ( multiChart ) ; focus . dispatch . on ( "onBrush" , ( extent ) { var filteredData = processedData . map ( ( datum ) { var leftIndex = - 1 ; var rightIndex = - 1 ; datum . values . some ( ( val , index ) { if ( identical ( leftIndex , - 1 ) && val . x >= extent [ 0 ] ) { leftIndex = index ; } if ( identical ( rightIndex , - 1 ) && val . x >= extent [ 1 ] ) { rightIndex = index ; return true ; } return false ; } ) ; var filteredValues = datum . values . slice ( leftIndex , rightIndex ) ; var iterations = 0 ;
 // don't want to end up with an empty dataset as this will

 // break the viewfinder.
 while ( filteredValues . length < 2 && iterations < 5 ) { leftIndex -= 1 ; rightIndex += 1 ; filteredValues = datum . values . slice ( leftIndex , rightIndex ) ; iterations ++ ; } return Object . assign ( { } , datum , values : filteredValues ) ; } ) ; container . datum ( filteredData ) ; multiChart . xAxis . domain ( extent ) ; multiChart . update ( ) ; } ) ; chart . update = ( ) { container . selectAll ( "*" ) . remove ( ) ; if ( identical ( duration , 0 ) ) { container . call ( chart ) ; } else { container . transition ( ) . duration ( duration ) . call ( chart ) ; } } ; return chart ; } ) ; } chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : get ( ) { return width ; } , "set" : set ( _ ) { width = _ ; } } , height : { "get" : get ( ) { return height ; } , "set" : set ( _ ) { height = _ ; } } , strokeWidth : { "get" : get ( ) { return strokeWidth ; } , "set" : set ( _ ) { strokeWidth = _ ; } } , x : { "get" : get ( ) { return xAccessor ; } , "set" : set ( _ ) { xAccessor = _ ; } } , keyForXValue : { "get" : get ( ) { return keyForXValue ; } , "set" : set ( _ ) { keyForXValue = _ ; } } , y : { "get" : get ( ) { return yAccessor ; } , "set" : set ( _ ) { yAccessor = _ ; } } , xScale : { "get" : get ( ) { return xScale ; } , "set" : set ( _ ) { xScale = _ ; } } , keyForActualLessThanPredicted : { "get" : get ( ) { return keyForActualLessThanPredicted ; } , "set" : set ( _ ) { keyForActualLessThanPredicted = _ ; } } , keyForActualGreaterThanPredicted : { "get" : get ( ) { return keyForActualGreaterThanPredicted ; } , "set" : set ( _ ) { keyForActualGreaterThanPredicted = _ ; } } , showPredictedLine : { "get" : get ( ) { return showPredictedLine ; } , "set" : set ( _ ) { showPredictedLine = _ ; } } , tickFormat : { "get" : get ( ) { return tickFormat ; } , "set" : set ( _ ) { tickFormat = _ ; } } , interpolate : { "get" : get ( ) { return interpolate ; } , "set" : set ( _ ) { interpolate = _ ; } } , focusMargin : { "get" : get ( ) { return focusMargin ; } , "set" : set ( _ ) { focusMargin . top = ! identical ( _ . top , undefined ) ? _ . top : focusMargin . top ; focusMargin . right = ! identical ( _ . right , undefined ) ? _ . right : focusMargin . right ; focusMargin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : focusMargin . bottom ; focusMargin . left = ! identical ( _ . left , undefined ) ? _ . left : focusMargin . left ; } } , margin : { "get" : get ( ) { return margin ; } , "set" : set ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } ) ; processData ( data ) { var clonedData = data . slice ( 0 ) ; var allProcessed = clonedData . every ( ( dataset ) { return dataset . processed ; } ) ; var actualData = clonedData . filter ( ( dataSet ) { return identical ( dataSet . type , "actual" ) ; } ) ; var predictedData = clonedData . filter ( ( dataSet ) { return identical ( dataSet . type , "expected" ) ; } ) ; if ( allProcessed ) { return clonedData ; } else if ( ! actualData . length || ! predictedData . length ) { return [ ] ; } var defaultKeyForActualLessThanPredicted = predictedData [ 0 ] . key + " minus " + actualData [ 0 ] . key + " (Predicted > Actual)" ; var defaultKeyForActualGreaterThanPredicted = predictedData [ 0 ] . key + " minus " + actualData [ 0 ] . key + " (Predicted < Actual)" ;
 // processedData is mapped as follows:

 //  [0] => Savings (actual under predicted) area

 //  [1] => 'Loss' (actual over predicted) area

 //  [2] => Actual profile

 //  [3] => Predicted profile
 var processedData = [ { "key" : keyForActualLessThanPredicted || defaultKeyForActualLessThanPredicted , "type" : "area" , "values" : [ ] , "yAxis" : 1 , "color" : "rgba(44,160,44,.9)" , "processed" : true , "noHighlightSeries" : true } , { "key" : keyForActualGreaterThanPredicted || defaultKeyForActualGreaterThanPredicted , "type" : "area" , "values" : [ ] , "yAxis" : 1 , "color" : "rgba(234,39,40,.9)" , "processed" : true , "noHighlightSeries" : true } , { "key" : actualData [ 0 ] . key , "type" : "line" , "values" : [ ] , "yAxis" : 1 , "color" : "#666666" , "processed" : true , "strokeWidth" : strokeWidth } ] ; if ( showPredictedLine ) { processedData [ 3 ] = { "key" : predictedData [ 0 ] . key , "type" : "line" , "values" : [ ] , "yAxis" : 1 , "color" : "#aec7e8" , "processed" : true , "strokeWidth" : strokeWidth } ; } var actualDataAsMap = actualData [ 0 ] . values . reduce ( ( result , datum , idx ) { result [ xAccessor ( datum ) ] = yAccessor ( datum ) ; return result ; } , { } ) ; var predictedDataAsMap = predictedData [ 0 ] . values . reduce ( ( result , datum , idx ) { result [ xAccessor ( datum ) ] = yAccessor ( datum ) ; return result ; } , { } ) ; Object . keys ( actualDataAsMap ) . forEach ( ( stringifiedXValue , idx ) { var actualUsage = actualDataAsMap [ stringifiedXValue ] ; var predictedUsage = predictedDataAsMap [ stringifiedXValue ] ; var fakeDatumToGetProperXValue = { } ;
 // NB - stringifiedXValue will not be the correct data type

 // e.g. you might want to use a number/date. Pass the stringified

 // version back through xAccessor.
 fakeDatumToGetProperXValue [ keyForXValue ] = stringifiedXValue ; var correctlyFormattedXValue = xAccessor ( fakeDatumToGetProperXValue ) ; var predictedActualDelta = predictedUsage - actualUsage ;
 // The below code generates data for the difference chart.

 // We have four series: two for the area (processedData[0] and processedData[1]) charts

 // and two for the line charts ([2] and [3]). The way we achieve difference chart

 // is that for each datapoint, we calculate whether it represents a 'savings'

 // (actual less than predicted) or a 'loss' (actual greater than predicted).

 // The two areas are different colours (e.g. out of the box, a loss is red and a

 // saving is green).

 // If it's a loss, then we add an area datapoint in the loss dataset ranging from actual to predicted

 // (the area represents the magnitude of the loss).

 // At the same time, for the savings dataset, we make the datapoint equivalent to actual usage so that

 // a dot renders rather than a proper area. This basically makes the savings area invisible

 // when there is a loss.

 //

 // The opposite occurs when predicted is greater than savings (a saving).
 if ( isNaN ( predictedActualDelta ) ) {
 // if there is no predicted value for this point, just use actual usage
 processedData [ 1 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y0" : actualUsage , "y1" : actualUsage } ; processedData [ 0 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y0" : actualUsage , "y1" : actualUsage } ; } else if ( predictedActualDelta < 0 ) {
 // actual greater than predicted - this is a loss

 // add area for loss between actualUsage (y0) and predictedUsage(y1)
 processedData [ 1 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y0" : actualUsage , "y1" : predictedUsage } ;
 // for the saving data series, render a dot (y0 and y1) at actualUsage - need

 // this rather than NaN because otherwise if the next datapoint is a saving,

 // D3 won't be able to link the two areas together
 processedData [ 0 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y0" : actualUsage , "y1" : actualUsage } ; } else { processedData [ 0 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y0" : actualUsage , "y1" : predictedUsage } ; processedData [ 1 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y0" : actualUsage , "y1" : actualUsage } ; }
 // Set actual
 processedData [ 2 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y" : actualUsage } ;
 // Set predicted
 if ( showPredictedLine ) { processedData [ 3 ] . values [ idx ] = { "x" : correctlyFormattedXValue , "y" : predictedUsage } ; } } ) ; return processedData ; } isDefined ( thingToCheck ) {
 // NB: void 0 === undefined
 return ! identical ( thingToCheck , ) ; } chart . xAxis = multiChart . xAxis ; chart . yAxis = multiChart . yAxis1 ; chart . multiChart = multiChart ; chart . focus = focus ; chart . processData = processData ; nv . utils . inheritOptions ( chart , multiChart ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 //TODO: consider deprecating by adding necessary features to multiBar model
 nv . models . discreteBar = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , id = Math . floor ( Math . random ( ) * 10000 ) , container , x = d3 . scale . ordinal ( ) , y = d3 . scale . linear ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , forceY = [ 0 ] , color = nv . utils . defaultColor ( ) , cornerRadius = 0 , showValues = false , valueFormat = d3 . format ( ",.2f" ) , xDomain , yDomain , xRange , yRange , dispatch = d3 . dispatch ( "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) , rectClass = "discreteBar" , duration = 250 ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var x0 , y0 ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 //add series index to each data point for reference
 data . forEach ( ( series , i ) { series . values . forEach ( ( point ) { point . series = i ; } ) ; } ) ;
 // Setup Scales

 // remap and flatten the data for use in calculating the scales' domains
 var seriesData = ( xDomain && yDomain ) ? [ ] : data . map ( ( d ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d , i ) , "y" : getY ( d , i ) , "y0" : d . y0 } ; } ) ; } ) ; x . domain ( xDomain || d3 . merge ( seriesData ) . map ( ( d ) { return d . x ; } ) ) . rangeBands ( xRange || [ 0 , availableWidth ] , .1 ) ; y . domain ( yDomain || d3 . extent ( d3 . merge ( seriesData ) . map ( ( d ) { return d . y ; } ) . concat ( forceY ) ) ) ;
 // If showValues, pad the Y axis range to account for label height
 if ( showValues ) y . range ( yRange || [ availableHeight - ( y . domain ( ) [ 0 ] < 0 ? 12 : 0 ) , y . domain ( ) [ 1 ] > 0 ? 12 : 0 ] ) ; else y . range ( yRange || [ availableHeight , 0 ] ) ;
 //store old scales if they exist
 x0 = x0 || x ; y0 = y0 || y . copy ( ) . range ( [ y ( 0 ) , y ( 0 ) ] ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-discretebar" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-discretebar" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-groups" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 //TODO: by definition, the discrete bar should not have multiple groups, will modify/remove later
 var groups = wrap . select ( ".nv-groups" ) . selectAll ( ".nv-group" ) . data ( ( d ) { return d ; } , ( d ) { return d . key ; } ) ; groups . enter ( ) . append ( "g" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) ; groups . exit ( ) . watchTransition ( renderWatch , "discreteBar: exit groups" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) . remove ( ) ; groups . attr ( "class" , ( d , i ) { return "nv-group nv-series-" + i ; } ) . classed ( "hover" , ( d ) { return d . hover ; } ) ; groups . watchTransition ( renderWatch , "discreteBar: groups" ) . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , .75 ) ; var bars = groups . selectAll ( "g.nv-bar" ) . data ( ( d ) { return d . values ; } ) ; bars . exit ( ) . remove ( ) ; var barsEnter = bars . enter ( ) . append ( "g" ) . attr ( "transform" , ( d , i , j ) { return "translate(" + ( x ( getX ( d , i ) ) + x . rangeBand ( ) * .05 ) + ", " + y ( 0 ) + ")" ; } ) . on ( "mouseover" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "click" , ( d , i ) { var element = this ; dispatch . elementClick ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) , event : d3 . event , element : element ) ; d3 . event . stopPropagation ( ) ; } ) . on ( "dblclick" , ( d , i ) { dispatch . elementDblClick ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; d3 . event . stopPropagation ( ) ; } ) ; barsEnter . append ( "rect" ) . attr ( "height" , 0 ) . attr ( "width" , x . rangeBand ( ) * .9 / data . length ) ; if ( showValues ) { barsEnter . append ( "text" ) . attr ( "text-anchor" , "middle" ) ; bars . select ( "text" ) . text ( ( d , i ) { return valueFormat ( getY ( d , i ) ) ; } ) . watchTransition ( renderWatch , "discreteBar: bars text" ) . attr ( "x" , x . rangeBand ( ) * .9 / 2 ) . attr ( "y" , ( d , i ) { return getY ( d , i ) < 0 ? y ( getY ( d , i ) ) - y ( 0 ) + 12 : - 4 ; } ) ; } else { bars . selectAll ( "text" ) . remove ( ) ; } bars . attr ( "class" , ( d , i ) { return getY ( d , i ) < 0 ? "nv-bar negative" : "nv-bar positive" ; } ) . style ( "fill" , ( d , i ) { return d . color || color ( d , i ) ; } ) . style ( "stroke" , ( d , i ) { return d . color || color ( d , i ) ; } ) . select ( "rect" ) . attr ( "rx" , cornerRadius ) . attr ( "class" , rectClass ) . watchTransition ( renderWatch , "discreteBar: bars rect" ) . attr ( "width" , x . rangeBand ( ) * .9 / data . length ) ; bars . watchTransition ( renderWatch , "discreteBar: bars" ) . attr ( "transform" , ( d , i ) { var left = x ( getX ( d , i ) ) + x . rangeBand ( ) * .05 , top = getY ( d , i ) < 0 ? y ( 0 ) : y ( 0 ) - y ( getY ( d , i ) ) < 1 ? y ( 0 ) - 1 : y ( getY ( d , i ) ) ; return "translate(" + left + ", " + top + ")" ; } ) . select ( "rect" ) . attr ( "height" , ( d , i ) { return Math . max ( Math . abs ( y ( getY ( d , i ) ) - y ( 0 ) ) , 1 ) ; } ) ;
 //store old scales for use in transitions on update
 x0 = x . copy ( ) ; y0 = y . copy ( ) ; } ) ; renderWatch . renderEnd ( "discreteBar immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , forceY : { "get" : ( ) { return forceY ; } , "set" : ( _ ) { forceY = _ ; } } , showValues : { "get" : ( ) { return showValues ; } , "set" : ( _ ) { showValues = _ ; } } , cornerRadius : { "get" : ( ) { return cornerRadius ; } , "set" : ( _ ) { cornerRadius = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , valueFormat : { "get" : ( ) { return valueFormat ; } , "set" : ( _ ) { valueFormat = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , rectClass : { "get" : ( ) { return rectClass ; } , "set" : ( _ ) { rectClass = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . discreteBarChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var discretebar = nv . models . discreteBar ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , legend = nv . models . legend ( ) , tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 15 , "right" : 10 , "bottom" : 50 , "left" : 60 } , marginTop = null , width = null , height = null , color = nv . utils . getColor ( ) , showLegend = false , showXAxis = true , showYAxis = true , rightAlignYAxis = false , staggerLabels = false , wrapLabels = false , rotateLabels = 0 , x , y , noData = null , dispatch = d3 . dispatch ( "beforeUpdate" , "renderEnd" ) , duration = 250 ; xAxis . orient ( "bottom" ) . showMaxMin ( false ) . tickFormat ( ( d ) { return d ; } ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) . tickFormat ( d3 . format ( ",.1f" ) ) ; tooltip . duration ( 0 ) . headerEnabled ( false ) . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . keyFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( discretebar ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { dispatch . beforeUpdate ( ) ; container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ;
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = discretebar . xScale ( ) ; y = discretebar . yScale ( ) . clamp ( true ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-discreteBarWithAxes" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-discreteBarWithAxes" ) . append ( "g" ) ; var defsEnter = gEnter . append ( "defs" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) . append ( "g" ) . attr ( "class" , "nv-zeroLine" ) . append ( "line" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-barsWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; g . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { legend . width ( availableWidth ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } wrap . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) ; } if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 // Main Chart Component(s)
 discretebar . width ( availableWidth ) . height ( availableHeight ) ; var barsWrap = g . select ( ".nv-barsWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ; barsWrap . transition ( ) . call ( discretebar ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-x-label-clip-" + discretebar . id ( ) ) . append ( "rect" ) ; g . select ( "#nv-x-label-clip-" + discretebar . id ( ) + " rect" ) . attr ( "width" , x . rangeBand ( ) * ( staggerLabels ? 2 : 1 ) ) . attr ( "height" , 16 ) . attr ( "x" , - x . rangeBand ( ) / ( staggerLabels ? 1 : 2 ) ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + ( y . range ( ) [ 0 ] + ( ( discretebar . showValues ( ) && y . domain ( ) [ 0 ] < 0 ) ? 16 : 0 ) ) + ")" ) ; g . select ( ".nv-x.nv-axis" ) . call ( xAxis ) ; var xTicks = g . select ( ".nv-x.nv-axis" ) . selectAll ( "g" ) ; if ( staggerLabels ) { xTicks . selectAll ( "text" ) . attr ( "transform" , ( d , i , j ) { return "translate(0," + ( j % 2 == 0 ? "5" : "17" ) + ")" ; } ) ; } if ( rotateLabels ) { xTicks . selectAll ( ".tick text" ) . attr ( "transform" , "rotate(" + rotateLabels + " 0,0)" ) . style ( "text-anchor" , rotateLabels > 0 ? "start" : "end" ) ; } if ( wrapLabels ) { g . selectAll ( ".tick text" ) . call ( nv . utils . wrapTicks , chart . xAxis . rangeBand ( ) ) ; } } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data , discretebar . y ( ) ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-y.nv-axis" ) . call ( yAxis ) ; }
 // Zero line
 g . select ( ".nv-zeroLine line" ) . attr ( "x1" , 0 ) . attr ( "x2" , ( rightAlignYAxis ) ? - availableWidth : availableWidth ) . attr ( "y1" , y ( 0 ) ) . attr ( "y2" , y ( 0 ) ) ; } ) ; renderWatch . renderEnd ( "discreteBar chart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 discretebar . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt [ "series" ] = { "key" : chart . x ( ) ( evt . data ) , "value" : chart . y ( ) ( evt . data ) , "color" : evt . color } ; tooltip . data ( evt ) . hidden ( false ) ; } ) ; discretebar . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; discretebar . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . discretebar = discretebar ; chart . legend = legend ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , staggerLabels : { "get" : ( ) { return staggerLabels ; } , "set" : ( _ ) { staggerLabels = _ ; } } , rotateLabels : { "get" : ( ) { return rotateLabels ; } , "set" : ( _ ) { rotateLabels = _ ; } } , wrapLabels : { "get" : ( ) { return wrapLabels ; } , "set" : ( _ ) { wrapLabels = ! ! _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; discretebar . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; discretebar . color ( color ) ; legend . color ( color ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( ( _ ) ? "right" : "left" ) ; } } ) ; nv . utils . inheritOptions ( chart , discretebar ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . distribution = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 400 , size = 8 , axis = "x" , getData = ( d ) { return d [ axis ] ; } , color = nv . utils . defaultColor ( ) , scale = d3 . scale . linear ( ) , domain , duration = 250 , dispatch = d3 . dispatch ( "renderEnd" ) ;
 //============================================================

 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var scale0 ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ;
 //============================================================
 chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var availableLength = width - ( identical ( axis , "x" ) ? margin . left + margin . right : margin . top + margin . bottom ) , naxis = axis == "x" ? "y" : "x" , container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 //------------------------------------------------------------

 // Setup Scales
 scale0 = scale0 || scale ;
 //------------------------------------------------------------

 //------------------------------------------------------------

 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-distribution" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-distribution" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 //------------------------------------------------------------
 var distWrap = g . selectAll ( "g.nv-dist" ) . data ( ( d ) { return d ; } , ( d ) { return d . key ; } ) ; distWrap . enter ( ) . append ( "g" ) ; distWrap . attr ( "class" , ( d , i ) { return "nv-dist nv-series-" + i ; } ) . style ( "stroke" , ( d , i ) { return color ( d , i ) ; } ) ; var dist = distWrap . selectAll ( "line.nv-dist" + axis ) . data ( ( d ) { return d . values ; } ) ; dist . enter ( ) . append ( "line" ) . attr ( axis + "1" , ( d , i ) { return scale0 ( getData ( d , i ) ) ; } ) . attr ( axis + "2" , ( d , i ) { return scale0 ( getData ( d , i ) ) ; } ) ; renderWatch . transition ( distWrap . exit ( ) . selectAll ( "line.nv-dist" + axis ) , "dist exit" ) . attr ( axis + "1" , ( d , i ) { return scale ( getData ( d , i ) ) ; } ) . attr ( axis + "2" , ( d , i ) { return scale ( getData ( d , i ) ) ; } ) . style ( "stroke-opacity" , 0 ) . remove ( ) ; dist . attr ( "class" , ( d , i ) { return "nv-dist" + axis + " nv-dist" + axis + "-" + i ; } ) . attr ( naxis + "1" , 0 ) . attr ( naxis + "2" , size ) ; renderWatch . transition ( dist , "dist" ) . attr ( axis + "1" , ( d , i ) { return scale ( getData ( d , i ) ) ; } ) . attr ( axis + "2" , ( d , i ) { return scale ( getData ( d , i ) ) ; } ) ; scale0 = scale . copy ( ) ; } ) ; renderWatch . renderEnd ( "distribution immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . dispatch = dispatch ; chart . margin = ( _ ) { if ( ! arguments . length ) return margin ; margin . top = != "undefined" ? _ . top : margin . top ; margin . right = != "undefined" ? _ . right : margin . right ; margin . bottom = != "undefined" ? _ . bottom : margin . bottom ; margin . left = != "undefined" ? _ . left : margin . left ; return chart ; } ; chart . width = ( _ ) { if ( ! arguments . length ) return width ; width = _ ; return chart ; } ; chart . axis = ( _ ) { if ( ! arguments . length ) return axis ; axis = _ ; return chart ; } ; chart . size = ( _ ) { if ( ! arguments . length ) return size ; size = _ ; return chart ; } ; chart . getData = ( _ ) { if ( ! arguments . length ) return getData ; getData = d3 . functor ( _ ) ; return chart ; } ; chart . scale = ( _ ) { if ( ! arguments . length ) return scale ; scale = _ ; return chart ; } ; chart . color = ( _ ) { if ( ! arguments . length ) return color ; color = nv . utils . getColor ( _ ) ; return chart ; } ; chart . duration = ( _ ) { if ( ! arguments . length ) return duration ; duration = _ ; renderWatch . reset ( duration ) ; return chart ; } ;
 //============================================================
 return chart ; } ; nv . models . distroPlot = ( ) { "use strict" ;
 // IMPROVEMENTS:

 // - cleanup tooltip to look like candlestick example (don't need color square for everything)

 // - extend y scale range to min/max data better visually

 // - tips of violins need to be cut off if very long

 // - transition from box to violin not great since box only has a few points, and violin has many - need to generate box with as many points as violin

 // - when providing colorGroup, should color boxes by either parent or child group category (e.g. isolator)

 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , id = Math . floor ( Math . random ( ) * 10000 ) , xScale = d3 . scale . ordinal ( ) , yScale = d3 . scale . linear ( ) , getX = ( d ) { return d . label ; } , getY = ( d ) { return d . value ; } , getColor = ( d ) { return d . color ; } , getQ1 = ( d ) { return d . values . q1 ; } , getQ2 = ( d ) { return d . values . q2 ; } , getQ3 = ( d ) { return d . values . q3 ; } , getNl = ( d ) { return ( centralTendency == "mean" ? getMean ( d ) : getQ2 ( d ) ) - d . values . notch ; } , getNu = ( d ) { return ( centralTendency == "mean" ? getMean ( d ) : getQ2 ( d ) ) + d . values . notch ; } , getMean = ( d ) { return d . values . mean ; } , getWl = ( d ) { return d . values . wl [ whiskerDef ] ; } , getWh = ( d ) { return d . values . wu [ whiskerDef ] ; } , getMin = ( d ) { return d . values . min ; } , getMax = ( d ) { return d . values . max ; } , getDev = ( d ) { return d . values . dev ; } , getValsObj = ( d ) { return d . values . observations ; } , getValsArr = ( d ) { return d . values . observations . map ( ( e ) { return e . y ; } ) ; } , plotType , observationType = false , whiskerDef = "iqr" , hideWhiskers = false , notchBox = false , colorGroup = false , centralTendency = false , showOnlyOutliers = true , jitter = 0.7 , squash = true , bandwidth = "scott" , clampViolin = true , resolution = 50 , pointSize = 3 , color = nv . utils . defaultColor ( ) , container = null , xDomain , xRange , yDomain , yRange , dispatch = d3 . dispatch ( "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) , duration = 250 , maxBoxWidth = null ;
 //============================================================

 // Helper Functions

 //------------------------------------------------------------

 /* Returns the smaller of std(X, ddof=1) or normalized IQR(X) over axis 0.
     *
     * 
     *
     * 
     *
     * Source: https://github.com/statsmodels/statsmodels/blob/master/statsmodels/nonparametric/bandwidths.py#L9
     */
 select_sigma ( x ) { var sorted = x . sort ( d3 . ascending ) ; var normalize = 1.349 ; var IQR = ( d3 . quantile ( sorted , 0.75 ) - d3 . quantile ( sorted , 0.25 ) ) / normalize ; return d3 . min ( [ d3 . deviation ( sorted ) , IQR ] ) ; }
 /*
    Scott's Rule of Thumb

    Parameters
    ----------
    x : array-like
        Array for which to get the bandwidth
    type : string
           The type of estimate to use, must be one of scott or silverman

    Returns
    -------
    bw : float
        The estimate of the bandwidth

    Notes
    -----
    Returns 1.059 * A * n ** (-1/5.) where ::
       A = min(std(x, ddof=1), IQR/1.349)
       IQR = np.subtract.reduce(np.percentile(x, [75,25]))

    References
    ----------
    Scott, D.W. (1992) Multivariate Density Estimation: Theory, Practice, and
        Visualization.
     */
 calcBandwidth ( x , type ) { if ( identical ( , "undefined" ) ) type = "scott" ;
 // TODO: consider using https://github.com/jasondavies/science.js
 var A = select_sigma ( x ) ; var n = x . length ; return identical ( type , "scott" ) ? Math . pow ( 1.059 * A * n , - 0.2 ) : Math . pow ( .9 * A * n , - 0.2 ) ; }
 /*
     * Prep data for use with distroPlot by grouping data
     * by .x() option set by user and then calculating
     * count, sum, mean, q1, q2 (median), q3, lower whisker (wl)
     * upper whisker (wu), iqr, min, max, and standard dev.
     *
     * NOTE: preparing this data can be resource intensive, and
     *       is therefore only run once on plot load. It can
     *       manually be run by calling recalcData(). This should
     *       be re-run any time the axis accessors are changed or
     *       when bandwidth/resolution are updated.
     *
     * NOTE: this will also setup the individual vertical scales
     *       for the violins.
     *
     * 
     *   with an object key that must exist when accessed by getX()
     *
     * 
     * [{
     *    key : YY,
     *    values: {
     *      count: XX,
     *      sum: XX,
     *      mean: XX,
     *      q1: XX,
     *      q2: XX,
     *      q3: XX,
     *      wl: XX,
     *      wu: XX,
     *      iqr: XX,
     *      min: XX,
     *      max: XX,
     *      dev: XX,
     *      observations: [{y:XX,..},..],
     *      key: XX,
     *      kdeDat: XX,
     *      notch: XX,
     *    }
     *  },
     *  ...
     *  ]
     * for violin plotType:
     * [{
     *    key : YY,
     *    values: {
     *      original: [{y:XX,..},..]
     *    }
     *  },
     *  ...
     *  ]
     * where YY are those keys in dat that define the
     * x-axis and which are defined by .x()
     */
 prepData ( dat ) {
 // helper function to calcuate the various boxplot stats
 calcStats ( g , xGroup ) {
 // sort data by Y so we can calc quartiles
 var v = g . map ( ( d ) { if ( colorGroup ) allColorGroups . add ( colorGroup ( d ) ) ; return getY ( d ) ; } ) . sort ( d3 . ascending ) ; var q1 = d3 . quantile ( v , 0.25 ) ; var q3 = d3 . quantile ( v , 0.75 ) ; var iqr = q3 - q1 ; var upper = q3 + 1.5 * iqr ; var lower = q1 - 1.5 * iqr ;
 /* whisker definitions:
             *  - iqr: also known as Tukey boxplot, the lowest datum still within 1.5 IQR of the lower quartile, and the highest datum still within 1.5 IQR of the upper quartile
             *  - minmax: the minimum and maximum of all of the data
             *  - sttdev: one standard deviation above and below the mean of the data
             * Note that the central tendency type (median or mean) does not impact the whisker location
             */
 var wl = { "iqr" : d3 . max ( [ d3 . min ( v ) , d3 . min ( v . filter ( ( d ) { return d > lower ; } ) ) ] ) , "minmax" : d3 . min ( v ) , "stddev" : d3 . mean ( v ) - d3 . deviation ( v ) } ; var wu = { "iqr" : d3 . min ( [ d3 . max ( v ) , d3 . max ( v . filter ( ( d ) { return d < upper ; } ) ) ] ) , "minmax" : d3 . max ( v ) , "stddev" : d3 . mean ( v ) + d3 . deviation ( v ) } ; var median = d3 . median ( v ) ; var mean = d3 . mean ( v ) ; var observations = [ ] ;
 // d3-beeswarm library must be externally loaded if being used

 // https://github.com/Kcnarf/d3-beeswarm
 if ( ! identical ( , "undefined" ) ) { observations = d3 . beeswarm ( ) . data ( g . map ( ( e ) { return getY ( e ) ; } ) ) . radius ( pointSize + 1 ) . orientation ( "vertical" ) . side ( "symmetric" ) . distributeOn ( ( e ) { return yScale ( e ) ; } ) . arrange ( ) ;
 // add group info for tooltip
 observations . map ( ( e , i ) { e . key = xGroup ; e . object_constancy = g [ i ] . object_constancy ; e . isOutlier = ( e . datum < wl . iqr || e . datum > wu . iqr ) ; e . isOutlierStdDev = ( e . datum < wl . stddev || e . datum > wu . stddev ) ; e . randX = Math . random ( ) * jitter * ( Math . floor ( Math . random ( ) * 2 ) == 1 ? 1 : - 1 ) ; } ) ; } else { v . forEach ( ( e , i ) { observations . push ( object_constancy : e . object_constancy , datum : e , key : xGroup , isOutlier : ( e < wl . iqr || e > wu . iqr ) , isOutlierStdDev : ( e < wl . stddev || e > wu . stddev ) , randX : Math . random ( ) * jitter * ( Math . floor ( Math . random ( ) * 2 ) == 1 ? 1 : - 1 ) ) ; } ) ; }
 // calculate bandwidth if no number is provided
 if ( isNaN ( parseFloat ( bandwidth ) ) ) { var bandwidthCalc ; if ( [ "scott" , "silverman" ] . indexOf ( bandwidth ) != - 1 ) { bandwidthCalc = calcBandwidth ( v , bandwidth ) ; } else { bandwidthCalc = calcBandwidth ( v ) ; } } var kde = kernelDensityEstimator ( eKernel ( bandwidthCalc ) , yScale . ticks ( resolution ) ) ; var kdeDat = clampViolin ? clampViolinKDE ( kde ( v ) , d3 . extent ( v ) ) : kde ( v ) ;
 // make a new vertical scale for each group
 var tmpScale = d3 . scale . linear ( ) . domain ( [ 0 , d3 . max ( kdeDat , ( e ) { return e . y ; } ) ] ) . clamp ( true ) ; yVScale . push ( tmpScale ) ; var reformat = { "count" : v . length , "num_outlier" : observations . filter ( ( e ) { return e . isOutlier ; } ) . length , "sum" : d3 . sum ( v ) , "mean" : mean , "q1" : q1 , "q2" : median , "q3" : q3 , "wl" : wl , "wu" : wu , "iqr" : iqr , "min" : d3 . min ( v ) , "max" : d3 . max ( v ) , "dev" : d3 . deviation ( v ) , "observations" : observations , "key" : xGroup , "kde" : kdeDat , "notch" : 1.57 * iqr / Math . sqrt ( v . length ) } ; if ( colorGroup ) { reformatDatFlat . push ( key : xGroup , values : reformat ) ; } return reformat ; }
 // assign a unique identifier for each point for object constancy

 // this makes updating data possible
 dat . forEach ( ( d , i ) { d . object_constancy = i + "_" + getY ( d ) + "_" + getX ( d ) ; } ) ;
 // TODO not DRY

 // couldn't find a conditional way of doing the key() grouping
 var formatted ; if ( ! colorGroup ) { formatted = d3 . nest ( ) . key ( ( d ) { return getX ( d ) ; } ) . rollup ( ( v , i ) { return calcStats ( v ) ; } ) . entries ( dat ) ; } else { allColorGroups = d3 . set ( ) ; var tmp = d3 . nest ( ) . key ( ( d ) { return getX ( d ) ; } ) . key ( ( d ) { return colorGroup ( d ) ; } ) . rollup ( ( v ) { return calcStats ( v , getX ( v [ 0 ] ) ) ; } ) . entries ( dat ) ;
 // generate a final list of all x & colorGroup combinations

 // this is used to properly set the x-axis domain
 allColorGroups = allColorGroups . values ( ) ; var xGroups = tmp . map ( ( d ) { return d . key ; } ) ; var allGroups = [ ] ; for ( var i = 0 ; i < xGroups . length ; i ++ ) { for ( var j = 0 ; j < allColorGroups . length ; j ++ ) { allGroups . push ( xGroups [ i ] + "_" + allColorGroups [ j ] ) ; } } allColorGroups = allGroups ;
 // flatten the inner most level so that

 // the plot retains the same DOM structure

 // to allow for smooth updating between

 // all groups.
 formatted = [ ] ; tmp . forEach ( ( d ) { d . values . forEach ( ( e ) { e . key = d . key + "_" + e . key ; } ) ; formatted . push . apply ( formatted , d . values ) ; } ) ; } return formatted ; }
 // https://bl.ocks.org/mbostock/4341954
 kernelDensityEstimator ( kernel , X ) { return ( sample ) { return X . map ( ( x ) { var y = d3 . mean ( sample , ( v ) { return kernel ( x - v ) ; } ) ; return { "x" : x , "y" : y } ; } ) ; } ; }
 /*
     * Limit whether the density extends past the extreme datapoints
     * of the violin.
     *
     * 
     * 
     */
 clampViolinKDE ( kde , extent ) {
 // this handles the case when all the x-values are equal

 // which means no kde could be properly calculated

 // just return the kde data so we can continue plotting successfully
 if ( identical ( extent [ 0 ] , extent [ 1 ] ) ) return kde ; var clamped = kde . reduce ( ( res , d ) { if ( d . x >= extent [ 0 ] && d . x <= extent [ 1 ] ) res . push ( d ) ; return res ; } , [ ] ) ;
 // add the extreme data points back in
 if ( extent [ 0 ] < clamped [ 0 ] . x ) clamped . unshift ( x : extent [ 0 ] , y : clamped [ 0 ] . y ) ; if ( extent [ 1 ] > clamped [ clamped . length - 1 ] . x ) clamped . push ( x : extent [ 1 ] , y : clamped [ clamped . length - 1 ] . y ) ; return clamped ; }
 // https://bl.ocks.org/mbostock/4341954
 eKernel ( scale ) { return ( u ) { return Math . abs ( u /= scale ) <= 1 ? .75 * ( 1 - u * u ) / scale : 0 ; } ; }
 /**
     * Makes the svg polygon string for a boxplot in either a notched
     * or square version
     *
     * NOTE: this actually only draws the left half of the box, since
     * the shape is symmetric (and since this is how violins are drawn)
     * we can simply generate half the box and mirror it.
     *
     * 
     * 
     * 
     *      data for Q1, median, Q2, notch upper and notch lower
     * 
     */
 makeNotchBox ( boxLeft , notchLeft , boxCenter , dat ) { var boxPoints ; var y = centralTendency == "mean" ? getMean ( dat ) : getQ2 ( dat ) ; if ( notchBox ) { boxPoints = [ { "x" : boxCenter , "y" : yScale ( getQ1 ( dat ) ) } , { "x" : boxLeft , "y" : yScale ( getQ1 ( dat ) ) } , { "x" : boxLeft , "y" : yScale ( getNl ( dat ) ) } , { "x" : notchLeft , "y" : yScale ( y ) } , { "x" : boxLeft , "y" : yScale ( getNu ( dat ) ) } , { "x" : boxLeft , "y" : yScale ( getQ3 ( dat ) ) } , { "x" : boxCenter , "y" : yScale ( getQ3 ( dat ) ) } ] ; } else { boxPoints = [ { "x" : boxCenter , "y" : yScale ( getQ1 ( dat ) ) } , { "x" : boxLeft , "y" : yScale ( getQ1 ( dat ) ) } , { "x" : boxLeft , "y" : yScale ( y ) } , { "x" : boxLeft , "y" : yScale ( y ) } , { "x" : boxLeft , "y" : yScale ( y ) } , { "x" : boxLeft , "y" : yScale ( getQ3 ( dat ) ) } , { "x" : boxCenter , "y" : yScale ( getQ3 ( dat ) ) } ] ; } return boxPoints ; }
 /**
     * Given an x-axis group, return the available color groups within it
     * provided that colorGroups is set, if not, x-axis group is returned
     */
 getAvailableColorGroups ( x ) { if ( ! colorGroup ) return x ; var tmp = reformatDat . find ( ( d ) { return d . key == x ; } ) ; return tmp . values . map ( ( d ) { return d . key ; } ) . sort ( d3 . ascending ) ; }
 // return true if point is an outlier
 isOutlier ( d ) { return ( whiskerDef == "iqr" && d . isOutlier ) || ( whiskerDef == "stddev" && d . isOutlierStdDev ) ; }
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var allColorGroups = d3 . set ( ) ; var yVScale = [ ] , reformatDat , reformatDatFlat = [ ] ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; var availableWidth , availableHeight ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup y-scale so that beeswarm layout can use it in prepData()
 yScale . domain ( yDomain || d3 . extent ( data . map ( ( d ) { return getY ( d ) ; } ) ) ) . nice ( ) . range ( yRange || [ availableHeight , 0 ] ) ; if ( identical ( , "undefined" ) ) reformatDat = prepData ( data ) ;
 // Setup x-scale
 xScale . rangeBands ( xRange || [ 0 , availableWidth ] , 0.1 ) . domain ( xDomain || ( colorGroup && ! squash ) ? allColorGroups : reformatDat . map ( ( d ) { return d . key ; } ) ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap" ) . data ( [ reformatDat ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap" ) ; wrap . watchTransition ( renderWatch , "nv-wrap: wrap" ) . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var areaEnter , distroplots = wrap . selectAll ( ".nv-distroplot-x-group" ) . data ( ( d ) { return d ; } ) ;
 // rebind new data

 // we don't rebuild individual x-axis groups so that we can update transition them

 // however the data associated with each x-axis group needs to be updated

 // so we manually update it here
 distroplots . each ( ( d , i ) { d3 . select ( this ) . selectAll ( "line.nv-distroplot-middle" ) . datum ( d ) ; } ) ; areaEnter = distroplots . enter ( ) . append ( "g" ) . attr ( "class" , "nv-distroplot-x-group" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) . style ( "fill" , ( d , i ) { return getColor ( d ) || color ( d , i ) ; } ) . style ( "stroke" , ( d , i ) { return getColor ( d ) || color ( d , i ) ; } ) ; distroplots . exit ( ) . remove ( ) ; var rangeBand = ( ) { return xScale . rangeBand ( ) ; } ; var areaWidth = ( ) { return d3 . min ( [ maxBoxWidth , rangeBand ( ) * 0.9 ] ) ; } ; var areaCenter = ( ) { return areaWidth ( ) / 2 ; } ; var areaLeft = ( ) { return areaCenter ( ) - areaWidth ( ) / 2 ; } ; var areaRight = ( ) { return areaCenter ( ) + areaWidth ( ) / 2 ; } ; var tickLeft = ( ) { return areaCenter ( ) - areaWidth ( ) / 5 ; } ; var tickRight = ( ) { return areaCenter ( ) + areaWidth ( ) / 5 ; } ; areaEnter . attr ( "transform" , ( d ) { return "translate(" + ( xScale ( d . key ) + ( rangeBand ( ) - areaWidth ( ) ) * 0.5 ) + ", 0)" ; } ) ; distroplots . watchTransition ( renderWatch , "nv-distroplot-x-group: distroplots" ) . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , 0.5 ) . attr ( "transform" , ( d ) { return "translate(" + ( xScale ( d . key ) + ( rangeBand ( ) - areaWidth ( ) ) * 0.5 ) + ", 0)" ; } ) ;
 // set range for violin scale
 yVScale . map ( ( d ) { d . range ( [ areaWidth ( ) / 2 , 0 ] ) ; } ) ;
 // ----- add the SVG elements for each plot type -----

 // scatter plot type
 if ( ! plotType ) { showOnlyOutliers = false ; if ( ! observationType ) observationType = "random" ; }
 // conditionally append whisker lines
 areaEnter . each ( ( d , i ) { var box = d3 . select ( this ) ; [ getWl , getWh ] . forEach ( ( f ) { var key = ( identical ( f , getWl ) ) ? "low" : "high" ; box . append ( "line" ) . style ( "opacity" , ( ) { return ! hideWhiskers ? "0" : "1" ; } ) . attr ( "class" , "nv-distroplot-whisker nv-distroplot-" + key ) ; box . append ( "line" ) . style ( "opacity" , ( ) { return hideWhiskers ? "0" : "1" ; } ) . attr ( "class" , "nv-distroplot-tick nv-distroplot-" + key ) ; } ) ; } ) ;
 // update whisker lines and ticks
 [ getWl , getWh ] . forEach ( ( f ) { var key = ( identical ( f , getWl ) ) ? "low" : "high" ; var endpoint = ( identical ( f , getWl ) ) ? getQ1 : getQ3 ; distroplots . select ( "line.nv-distroplot-whisker.nv-distroplot-" + key ) . watchTransition ( renderWatch , "nv-distroplot-x-group: distroplots" ) . attr ( "x1" , areaCenter ( ) ) . attr ( "y1" , ( d ) { return plotType != "violin" ? yScale ( f ( d ) ) : yScale ( getQ2 ( d ) ) ; } ) . attr ( "x2" , areaCenter ( ) ) . attr ( "y2" , ( d ) { return plotType == "box" ? yScale ( endpoint ( d ) ) : yScale ( getQ2 ( d ) ) ; } ) . style ( "opacity" , ( ) { return hideWhiskers ? "0" : "1" ; } ) ; distroplots . select ( "line.nv-distroplot-tick.nv-distroplot-" + key ) . watchTransition ( renderWatch , "nv-distroplot-x-group: distroplots" ) . attr ( "x1" , ( d ) { return plotType != "violin" ? tickLeft ( ) : areaCenter ( ) ; } ) . attr ( "y1" , ( d , i ) { return plotType != "violin" ? yScale ( f ( d ) ) : yScale ( getQ2 ( d ) ) ; } ) . attr ( "x2" , ( d ) { return plotType != "violin" ? tickRight ( ) : areaCenter ( ) ; } ) . attr ( "y2" , ( d , i ) { return plotType != "violin" ? yScale ( f ( d ) ) : yScale ( getQ2 ( d ) ) ; } ) . style ( "opacity" , ( ) { return hideWhiskers ? "0" : "1" ; } ) ; } ) ; [ getWl , getWh ] . forEach ( ( f ) { var key = ( identical ( f , getWl ) ) ? "low" : "high" ; areaEnter . selectAll ( ".nv-distroplot-" + key ) . on ( "mouseover" , ( d , i , j ) { d3 . select ( this . parentNode ) . selectAll ( "line.nv-distroplot-" + key ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( value : key == "low" ? "Lower whisker" : "Upper whisker" , series : { "key" : f ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i , j ) { d3 . select ( this . parentNode ) . selectAll ( "line.nv-distroplot-" + key ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( value : key == "low" ? "Lower whisker" : "Upper whisker" , series : { "key" : f ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , e : d3 . event ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ; } ) ;
 // setup boxes as 4 parts: left-area, left-line, right-area, right-line,

 // this way we can transition to a violin
 areaEnter . each ( ( d , i ) { var violin = d3 . select ( this ) ; [ "left" , "right" ] . forEach ( ( side ) { [ "line" , "area" ] . forEach ( ( d ) { violin . append ( "path" ) . attr ( "class" , "nv-distribution-" + d + " nv-distribution-" + side ) . attr ( "transform" , "rotate(90,0,0)   translate(0," + ( side == "left" ? - areaWidth ( ) : 0 ) + ")" + ( side == "left" ? "" : " scale(1,-1)" ) ) ; } ) ; } ) ; areaEnter . selectAll ( ".nv-distribution-line" ) . style ( "fill" , "none" ) ; areaEnter . selectAll ( ".nv-distribution-area" ) . style ( "stroke" , "none" ) . style ( "opacity" , 0.7 ) ; } ) ;
 // transitions
 distroplots . each ( ( d , i ) { var violin = d3 . select ( this ) ; var objData = plotType == "box" ? makeNotchBox ( areaLeft ( ) , tickLeft ( ) , areaCenter ( ) , d ) : d . values . kde ; violin . selectAll ( "path" ) . datum ( objData ) ; var tmpScale = yVScale [ i ] ; var interp = plotType == "box" ? "linear" : "basis" ; if ( plotType == "box" || plotType == "violin" ) { [ "left" , "right" ] . forEach ( ( side ) {
 // line
 distroplots . selectAll ( ".nv-distribution-line.nv-distribution-" + side ) . attr ( "d" , d3 . svg . line ( ) . x ( ( e ) { return plotType == "box" ? e . y : yScale ( e . x ) ; } ) . y ( ( e ) { return plotType == "box" ? e . x : tmpScale ( e . y ) ; } ) . interpolate ( interp ) ) . attr ( "transform" , "rotate(90,0,0)   translate(0," + ( side == "left" ? - areaWidth ( ) : 0 ) + ")" + ( side == "left" ? "" : " scale(1,-1)" ) ) . style ( "opacity" , ! plotType ? "0" : "1" ) ;
 // area
 distroplots . selectAll ( ".nv-distribution-area.nv-distribution-" + side ) . attr ( "d" , d3 . svg . area ( ) . x ( ( e ) { return plotType == "box" ? e . y : yScale ( e . x ) ; } ) . y ( ( e ) { return plotType == "box" ? e . x : tmpScale ( e . y ) ; } ) . y0 ( areaWidth ( ) / 2 ) . interpolate ( interp ) ) . attr ( "transform" , "rotate(90,0,0)   translate(0," + ( side == "left" ? - areaWidth ( ) : 0 ) + ")" + ( side == "left" ? "" : " scale(1,-1)" ) ) . style ( "opacity" , ! plotType ? "0" : "1" ) ; } ) ; } else { distroplots . selectAll ( ".nv-distribution-area" ) . watchTransition ( renderWatch , "nv-distribution-area: distroplots" ) . style ( "opacity" , ! plotType ? "0" : "1" ) ; distroplots . selectAll ( ".nv-distribution-line" ) . watchTransition ( renderWatch , "nv-distribution-line: distroplots" ) . style ( "opacity" , ! plotType ? "0" : "1" ) ; } } ) ;
 // tooltip events
 distroplots . selectAll ( "path" ) . on ( "mouseover" , ( d , i , j ) { d = d3 . select ( this . parentNode ) . datum ( ) ; d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( key : d . key , value : "Group " + d . key + " stats" , series : [ { "key" : "max" , "value" : getMax ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "Q3" , "value" : getQ3 ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "Q2" , "value" : getQ2 ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "Q1" , "value" : getQ1 ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "min" , "value" : getMin ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "mean" , "value" : getMean ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "std. dev." , "value" : getDev ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "count" , "value" : d . values . count , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "num. outliers" , "value" : d . values . num_outlier , "color" : getColor ( d ) || color ( d , j ) } ] , data : d , index : i , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i , j ) { d3 . select ( this ) . classed ( "hover" , false ) ; d = d3 . select ( this . parentNode ) . datum ( ) ; dispatch . elementMouseout ( key : d . key , value : "Group " + d . key + " stats" , series : [ { "key" : "max" , "value" : getMax ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "Q3" , "value" : getQ3 ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "Q2" , "value" : getQ2 ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "Q1" , "value" : getQ1 ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "min" , "value" : getMin ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "mean" , "value" : getMean ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "std. dev." , "value" : getDev ( d ) . toFixed ( 2 ) , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "count" , "value" : d . values . count , "color" : getColor ( d ) || color ( d , j ) } , { "key" : "num. outliers" , "value" : d . values . num_outlier , "color" : getColor ( d ) || color ( d , j ) } ] , data : d , index : i , e : d3 . event ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ;
 // median/mean line
 areaEnter . append ( "line" ) . attr ( "class" , ( d ) { return "nv-distroplot-middle" ; } ) ; distroplots . selectAll ( "line.nv-distroplot-middle" ) . watchTransition ( renderWatch , "nv-distroplot-x-group: distroplots line" ) . attr ( "x1" , notchBox ? tickLeft : plotType != "violin" ? areaLeft : tickLeft ( ) ) . attr ( "y1" , ( d , i , j ) { return centralTendency == "mean" ? yScale ( getMean ( d ) ) : yScale ( getQ2 ( d ) ) ; } ) . attr ( "x2" , notchBox ? tickRight : plotType != "violin" ? areaRight : tickRight ( ) ) . attr ( "y2" , ( d , i ) { return centralTendency == "mean" ? yScale ( getMean ( d ) ) : yScale ( getQ2 ( d ) ) ; } ) . style ( "opacity" , centralTendency ? "1" : "0" ) ;
 // tooltip
 distroplots . selectAll ( ".nv-distroplot-middle" ) . on ( "mouseover" , ( d , i , j ) { if ( d3 . select ( this ) . style ( "opacity" ) == 0 ) return ; var fillColor = d3 . select ( this . parentNode ) . style ( "fill" ) ; d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( value : centralTendency == "mean" ? "Mean" : "Median" , series : { "key" : centralTendency == "mean" ? getMean ( d ) . toFixed ( 2 ) : getQ2 ( d ) . toFixed ( 2 ) , "color" : fillColor } , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i , j ) { if ( d3 . select ( this ) . style ( "opacity" ) == 0 ) return ; d3 . select ( this ) . classed ( "hover" , false ) ; var fillColor = d3 . select ( this . parentNode ) . style ( "fill" ) ; dispatch . elementMouseout ( value : centralTendency == "mean" ? "Mean" : "Median" , series : { "key" : centralTendency == "mean" ? getMean ( d ) . toFixed ( 2 ) : getQ2 ( d ) . toFixed ( 2 ) , "color" : fillColor } , e : d3 . event ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ;
 // setup observations

 // create DOMs even if not requested (and hide them), so that

 // we can do transitions on them
 var obsWrap = distroplots . selectAll ( "g.nv-distroplot-observation" ) . data ( ( d ) { return getValsObj ( d ) ; } , ( d ) { return d . object_constancy ; } ) ; var obsGroup = obsWrap . enter ( ) . append ( "g" ) . attr ( "class" , "nv-distroplot-observation" ) ; obsGroup . append ( "circle" ) . style ( { "opacity" : 0 } ) ; obsGroup . append ( "line" ) . style ( "stroke-width" , 1 ) . style ( { "stroke" : d3 . rgb ( 85 , 85 , 85 ) , "opacity" : 0 } ) ; obsWrap . exit ( ) . remove ( ) ; obsWrap . attr ( "class" , ( d ) { return "nv-distroplot-observation " + ( isOutlier ( d ) && plotType == "box" ? "nv-distroplot-outlier" : "nv-distroplot-non-outlier" ) ; } ) ;
 // transition observations
 if ( observationType == "line" ) { distroplots . selectAll ( "g.nv-distroplot-observation line" ) . watchTransition ( renderWatch , "nv-distrolot-x-group: nv-distoplot-observation" ) . attr ( "x1" , tickLeft ( ) + areaWidth ( ) / 4 ) . attr ( "x2" , tickRight ( ) - areaWidth ( ) / 4 ) . attr ( "y1" , ( d ) { return yScale ( d . datum ) ; } ) . attr ( "y2" , ( d ) { return yScale ( d . datum ) ; } ) ; } else { distroplots . selectAll ( "g.nv-distroplot-observation circle" ) . watchTransition ( renderWatch , "nv-distroplot: nv-distroplot-observation" ) . attr ( "cy" , ( d ) { return yScale ( d . datum ) ; } ) . attr ( "r" , pointSize ) ;
 // NOTE: this update can be slow when re-sizing window when many point visible 

 // TODO: filter selection down to only visible points, no need to update x-position

 //       of the hidden points
 distroplots . selectAll ( "g.nv-distroplot-observation circle" ) . watchTransition ( renderWatch , "nv-distroplot: nv-distroplot-observation" ) . attr ( "cx" , ( d ) { return observationType == "swarm" ? d . x + areaWidth ( ) / 2 : observationType == "random" ? areaWidth ( ) / 2 + d . randX * areaWidth ( ) / 2 : areaWidth ( ) / 2 ; } ) ; }
 // set opacity on outliers/non-outliers

 // any circle/line entering has opacity 0
 if ( ! identical ( observationType , false ) ) { if ( ! showOnlyOutliers ) { distroplots . selectAll ( observationType == "line" ? "line" : "circle" ) . watchTransition ( renderWatch , "nv-distroplot: nv-distroplot-observation" ) . style ( "opacity" , 1 ) ; } else { distroplots . selectAll ( ".nv-distroplot-outlier " + ( observationType == "line" ? "line" : "circle" ) ) . watchTransition ( renderWatch , "nv-distroplot: nv-distroplot-observation" ) . style ( "opacity" , 1 ) ; distroplots . selectAll ( ".nv-distroplot-non-outlier " + ( observationType == "line" ? "line" : "circle" ) ) . watchTransition ( renderWatch , "nv-distroplot: nv-distroplot-observation" ) . style ( "opacity" , 0 ) ; } }
 // hide all other observations
 distroplots . selectAll ( ".nv-distroplot-observation" + ( observationType == "line" ? " circle" : " line" ) ) . watchTransition ( renderWatch , "nv-distroplot: nv-distoplot-observation" ) . style ( "opacity" , 0 ) ;
 // tooltip events for observations
 distroplots . selectAll ( ".nv-distroplot-observation" ) . on ( "mouseover" , ( d , i , j ) { var pt = d3 . select ( this ) ; if ( showOnlyOutliers && plotType == "box" && ! isOutlier ( d ) ) return ; var fillColor = d3 . select ( this . parentNode ) . style ( "fill" ) ; pt . classed ( "hover" , true ) ; dispatch . elementMouseover ( value : ( plotType == "box" && isOutlier ( d ) ) ? "Outlier" : "Observation" , series : { "key" : d . datum . toFixed ( 2 ) , "color" : fillColor } , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i , j ) { var pt = d3 . select ( this ) ; var fillColor = d3 . select ( this . parentNode ) . style ( "fill" ) ; pt . classed ( "hover" , false ) ; dispatch . elementMouseout ( value : ( plotType == "box" && isOutlier ( d ) ) ? "Outlier" : "Observation" , series : { "key" : d . datum . toFixed ( 2 ) , "color" : fillColor } , e : d3 . event ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ; } ) ; renderWatch . renderEnd ( "nv-distroplot-x-group immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , maxBoxWidth : { "get" : ( ) { return maxBoxWidth ; } , "set" : ( _ ) { maxBoxWidth = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , plotType : { "get" : ( ) { return plotType ; } , "set" : ( _ ) { plotType = _ ; } } , observationType : { "get" : ( ) { return observationType ; } , "set" : ( _ ) { observationType = _ ; } } , whiskerDef : { "get" : ( ) { return whiskerDef ; } , "set" : ( _ ) { whiskerDef = _ ; } } , notchBox : { "get" : ( ) { return notchBox ; } , "set" : ( _ ) { notchBox = _ ; } } , hideWhiskers : { "get" : ( ) { return hideWhiskers ; } , "set" : ( _ ) { hideWhiskers = _ ; } } , colorGroup : { "get" : ( ) { return colorGroup ; } , "set" : ( _ ) { colorGroup = _ ; } } , centralTendency : { "get" : ( ) { return centralTendency ; } , "set" : ( _ ) { centralTendency = _ ; } } , bandwidth : { "get" : ( ) { return bandwidth ; } , "set" : ( _ ) { bandwidth = _ ; } } , clampViolin : { "get" : ( ) { return clampViolin ; } , "set" : ( _ ) { clampViolin = _ ; } } , resolution : { "get" : ( ) { return resolution ; } , "set" : ( _ ) { resolution = _ ; } } , xScale : { "get" : ( ) { return xScale ; } , "set" : ( _ ) { xScale = _ ; } } , yScale : { "get" : ( ) { return yScale ; } , "set" : ( _ ) { yScale = _ ; } } , showOnlyOutliers : { "get" : ( ) { return showOnlyOutliers ; } , "set" : ( _ ) { showOnlyOutliers = _ ; } } , jitter : { "get" : ( ) { return jitter ; } , "set" : ( _ ) { jitter = _ ; } } , squash : { "get" : ( ) { return squash ; } , "set" : ( _ ) { squash = _ ; } } , pointSize : { "get" : ( ) { return pointSize ; } , "set" : ( _ ) { pointSize = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , recalcData : { "get" : ( ) { reformatDat = prepData ( container . datum ( ) ) ; } } , itemColor : { "get" : ( ) { return getColor ; } , "set" : ( _ ) { getColor = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . distroPlotChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var distroplot = nv . models . distroPlot ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) ; var margin = { "top" : 25 , "right" : 10 , "bottom" : 40 , "left" : 60 } , width = null , height = null , color = nv . utils . getColor ( ) , showXAxis = true , showYAxis = true , rightAlignYAxis = false , staggerLabels = false , xLabel = false , yLabel = false , tooltip = nv . models . tooltip ( ) , x , y , noData = "No Data Available." , dispatch = d3 . dispatch ( "stateChange" , "beforeUpdate" , "renderEnd" ) , duration = 500 ; xAxis . orient ( "bottom" ) . showMaxMin ( false ) . tickFormat ( ( d ) { return d ; } ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) . tickFormat ( d3 . format ( ",.1f" ) ) ; tooltip . duration ( 0 ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; var colorGroup0 , marginTop0 = margin . top , x0 , y0 , resolution0 , bandwidth0 , clampViolin0 ; var dataCache ;
 // return true if data has changed somehow after

 // an .update() was called

 // works by comparing current data set to the

 // one previously cached

 // TODO - since we keep another version of the dataset

 // around for comparison, it doubles the memory usage :(
 dataHasChanged ( d ) { if ( arraysEqual ( d , dataCache ) ) { return false ; } else { dataCache = JSON . parse ( JSON . stringify ( d ) ) ; return true ; } }
 // return true if array of objects equivalent
 arraysEqual ( arr1 , arr2 ) { if ( ! identical ( arr1 . length , arr2 . length ) ) return false ; for ( var i = arr1 . length ; i -- ; ) { if ( ) ; if ( ) ; if ( ! objectEquals ( arr1 [ i ] , arr2 [ i ] ) ) { return false ; } } return true ; }
 // return true if objects are equivalent
 objectEquals ( a , b ) {
 // Create arrays of property names
 var aProps = Object . getOwnPropertyNames ( a ) ; var bProps = Object . getOwnPropertyNames ( b ) ;
 // If number of properties is different,

 // objects are not equivalent
 if ( aProps . length != bProps . length ) { return false ; } for ( var i = 0 ; i < aProps . length ; i ++ ) { var propName = aProps [ i ] ;
 // If values of same property are not equal,

 // objects are not equivalent
 if ( ! identical ( a [ propName ] , b [ propName ] ) ) { return false ; } } return true ; } chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( distroplot ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = ( width || parseInt ( container . style ( "width" ) ) || 960 ) - margin . left - margin . right ; var availableHeight = ( height || parseInt ( container . style ( "height" ) ) || 400 ) - margin . top - margin . bottom ; if ( identical ( , "undefined" ) ) { dataCache = JSON . parse ( JSON . stringify ( data ) ) ; } chart . update = ( ) { dispatch . beforeUpdate ( ) ; var opts = distroplot . options ( ) ; if ( ! identical ( colorGroup0 , opts . colorGroup ( ) ) || ! identical ( x0 , opts . x ( ) ) || ! identical ( y0 , opts . y ( ) ) || ! identical ( bandwidth0 , opts . bandwidth ( ) ) || ! identical ( resolution0 , opts . resolution ( ) ) || ! identical ( clampViolin0 , opts . clampViolin ( ) ) || dataHasChanged ( data ) ) { distroplot . recalcData ( ) ; } container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ; if ( ! identical ( , "function" ) && chart . options ( ) . observationType ( ) == "swarm" ) { var xPos = margin . left + availableWidth / 2 ; noData = "Please include the library https://github.com/Kcnarf/d3-beeswarm to use \"swarm\"." ; nv . utils . noData ( chart , container ) ; return chart ; } else if ( ! data || ! data . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = distroplot . xScale ( ) ; y = distroplot . yScale ( ) . clamp ( true ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-distroPlot" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-distroPlot" ) . append ( "g" ) ; var defsEnter = gEnter . append ( "defs" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) . append ( "g" ) . attr ( "class" , "nv-zeroLine" ) . append ( "line" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-distroWrap" ) ; gEnter . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; g . watchTransition ( renderWatch , "nv-wrap: wrap" ) . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 // Main Chart Component(s)
 distroplot . width ( availableWidth ) . height ( availableHeight ) ; var distroWrap = g . select ( ".nv-distroWrap" ) . datum ( data ) ; distroWrap . transition ( ) . call ( distroplot ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-x-label-clip-" + distroplot . id ( ) ) . append ( "rect" ) ; g . select ( "#nv-x-label-clip-" + distroplot . id ( ) + " rect" ) . attr ( "width" , x . rangeBand ( ) * ( staggerLabels ? 2 : 1 ) ) . attr ( "height" , 16 ) . attr ( "x" , - x . rangeBand ( ) / ( staggerLabels ? 1 : 2 ) ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) ; g . select ( ".nv-x.nv-axis" ) . call ( xAxis ) ;
 //g.select('.nv-x.nv-axis').select('.nv-axislabel')

 //    .style('font-size', d3.min([availableWidth * 0.05,20]) + 'px')
 var xTicks = g . select ( ".nv-x.nv-axis" ) . selectAll ( "g" ) ; if ( staggerLabels ) { xTicks . selectAll ( "text" ) . attr ( "transform" , ( d , i , j ) { return "translate(0," + ( identical ( j % 2 , 0 ) ? "5" : "17" ) + ")" ; } ) ; } } if ( showYAxis ) { yAxis . scale ( y ) . ticks ( Math . floor ( availableHeight / 36 ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-y.nv-axis" ) . call ( yAxis ) ; }
 // Zero line on chart bottom
 g . select ( ".nv-zeroLine line" ) . attr ( "x1" , 0 ) . attr ( "x2" , availableWidth ) . attr ( "y1" , y ( 0 ) ) . attr ( "y2" , y ( 0 ) ) ;
 // store original values so that we can

 // call 'recalcData()' if needed
 colorGroup0 = distroplot . options ( ) . colorGroup ( ) ; x0 = distroplot . options ( ) . x ( ) ; y0 = distroplot . options ( ) . y ( ) ; bandwidth0 = distroplot . options ( ) . bandwidth ( ) ; resolution0 = distroplot . options ( ) . resolution ( ) ; clampViolin0 = distroplot . options ( ) . clampViolin ( ) ; } ) ; renderWatch . renderEnd ( "nv-distroplot chart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 distroplot . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { tooltip . data ( evt ) . hidden ( false ) ; } ) ; distroplot . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . data ( evt ) . hidden ( true ) ; } ) ; distroplot . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . distroplot = distroplot ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , staggerLabels : { "get" : ( ) { return staggerLabels ; } , "set" : ( _ ) { staggerLabels = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , tooltipContent : { "get" : ( ) { return tooltip ; } , "set" : ( _ ) { tooltip = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; distroplot . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; distroplot . color ( color ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( ( _ ) ? "right" : "left" ) ; } } , xLabel : { "get" : ( ) { return xLabel ; } , "set" : ( _ ) { xLabel = _ ; xAxis . axisLabel ( xLabel ) ; } } , yLabel : { "get" : ( ) { return yLabel ; } , "set" : ( _ ) { yLabel = _ ; yAxis . axisLabel ( yLabel ) ; } } ) ; nv . utils . inheritOptions ( chart , distroplot ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . focus = ( content ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var content = content || nv . models . line ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , brush = d3 . svg . brush ( ) ; var margin = { "top" : 10 , "right" : 0 , "bottom" : 30 , "left" : 0 } , color = nv . utils . defaultColor ( ) , width = null , height = 70 , showXAxis = true , showYAxis = false , rightAlignYAxis = false , ticks = null , x , y , brushExtent = null , duration = 250 , dispatch = d3 . dispatch ( "brush" , "onBrush" , "renderEnd" ) , syncBrushing = true ; content . interactive ( false ) ; content . pointActive ( ( d ) { return false ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( content ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = height - margin . top - margin . bottom ; chart . update = ( ) { if ( identical ( duration , 0 ) ) { container . call ( chart ) ; } else { container . transition ( ) . duration ( duration ) . call ( chart ) ; } } ; chart . container = this ;
 // Setup Scales
 x = content . xScale ( ) ; y = content . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-focus" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-focus" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-background" ) . append ( "rect" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-contentWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-brushBackground" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-brush" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; } g . select ( ".nv-background rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; content . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; var contentWrap = g . select ( ".nv-contentWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ; d3 . transition ( contentWrap ) . call ( content ) ;
 // Setup Brush
 brush . x ( x ) . on ( "brush" , ( ) { onBrush ( syncBrushing ) ; } ) ; brush . on ( "brushend" , ( ) { if ( ! syncBrushing ) { dispatch . onBrush ( brush . empty ( ) ? x . domain ( ) : brush . extent ( ) ) ; } } ) ; if ( brushExtent ) brush . extent ( brushExtent ) ; var brushBG = g . select ( ".nv-brushBackground" ) . selectAll ( "g" ) . data ( [ brushExtent || brush . extent ( ) ] ) ; var brushBGenter = brushBG . enter ( ) . append ( "g" ) ; brushBGenter . append ( "rect" ) . attr ( "class" , "left" ) . attr ( "x" , 0 ) . attr ( "y" , 0 ) . attr ( "height" , availableHeight ) ; brushBGenter . append ( "rect" ) . attr ( "class" , "right" ) . attr ( "x" , 0 ) . attr ( "y" , 0 ) . attr ( "height" , availableHeight ) ; var gBrush = g . select ( ".nv-x.nv-brush" ) . call ( brush ) ; gBrush . selectAll ( "rect" ) . attr ( "height" , availableHeight ) ; gBrush . selectAll ( ".resize" ) . append ( "path" ) . attr ( "d" , resizePath ) ; onBrush ( true ) ; g . select ( ".nv-background rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) ; d3 . transition ( g . select ( ".nv-x.nv-axis" ) ) . call ( xAxis ) ; } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; d3 . transition ( g . select ( ".nv-y.nv-axis" ) ) . call ( yAxis ) ; } g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) ;
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------

 //============================================================

 // Functions

 //------------------------------------------------------------

 // Taken from crossfilter (http://square.github.com/crossfilter/)
 resizePath ( d ) { var e = + ( d == "e" ) , x = e ? 1 : - 1 , y = availableHeight / 3 ; return "M" + ( 0.5 * x ) + "," + y + "A6,6 0 0 " + e + " " + ( 6.5 * x ) + "," + ( y + 6 ) + "V" + ( 2 * y - 6 ) + "A6,6 0 0 " + e + " " + ( 0.5 * x ) + "," + ( 2 * y ) + "Z" + "M" + ( 2.5 * x ) + "," + ( y + 8 ) + "V" + ( 2 * y - 8 ) + "M" + ( 4.5 * x ) + "," + ( y + 8 ) + "V" + ( 2 * y - 8 ) ; } updateBrushBG ( ) { if ( ! brush . empty ( ) ) brush . extent ( brushExtent ) ; brushBG . data ( [ brush . empty ( ) ? x . domain ( ) : brushExtent ] ) . each ( ( d , i ) { var leftWidth = x ( d [ 0 ] ) - x . range ( ) [ 0 ] , rightWidth = availableWidth - x ( d [ 1 ] ) ; d3 . select ( this ) . select ( ".left" ) . attr ( "width" , leftWidth < 0 ? 0 : leftWidth ) ; d3 . select ( this ) . select ( ".right" ) . attr ( "x" , x ( d [ 1 ] ) ) . attr ( "width" , rightWidth < 0 ? 0 : rightWidth ) ; } ) ; } onBrush ( shouldDispatch ) { brushExtent = brush . empty ( ) ? null : brush . extent ( ) ; var extent = brush . empty ( ) ? x . domain ( ) : brush . extent ( ) ; dispatch . brush ( extent : extent , brush : brush ) ; updateBrushBG ( ) ; if ( shouldDispatch ) { dispatch . onBrush ( extent ) ; } } } ) ; renderWatch . renderEnd ( "focus immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------

 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . content = content ; chart . brush = brush ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , brushExtent : { "get" : ( ) { return brushExtent ; } , "set" : ( _ ) { brushExtent = _ ; } } , syncBrushing : { "get" : ( ) { return syncBrushing ; } , "set" : ( _ ) { syncBrushing = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; content . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; content . color ( color ) ; } } , interpolate : { "get" : ( ) { return content . interpolate ( ) ; } , "set" : ( _ ) { content . interpolate ( _ ) ; } } , xTickFormat : { "get" : ( ) { return xAxis . tickFormat ( ) ; } , "set" : ( _ ) { xAxis . tickFormat ( _ ) ; } } , yTickFormat : { "get" : ( ) { return yAxis . tickFormat ( ) ; } , "set" : ( _ ) { yAxis . tickFormat ( _ ) ; } } , x : { "get" : ( ) { return content . x ( ) ; } , "set" : ( _ ) { content . x ( _ ) ; } } , y : { "get" : ( ) { return content . y ( ) ; } , "set" : ( _ ) { content . y ( _ ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( rightAlignYAxis ? "right" : "left" ) ; } } ) ; nv . utils . inheritOptions ( chart , content ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . forceDirectedGraph = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 2 , "right" : 0 , "bottom" : 2 , "left" : 0 } , width = 400 , height = 32 , container = null , dispatch = d3 . dispatch ( "renderEnd" ) , color = nv . utils . getColor ( [ "#000" ] ) , tooltip = nv . models . tooltip ( ) , noData = null , linkStrength = 0.1 , friction = 0.9 , linkDist = 30 , charge = - 120 , gravity = 0.1 , theta = 0.8 , alpha = 0.1 , radius = 5 , nodeExtras = ( nodes ) { } , linkExtras = ( links ) { } , getX = d3 . functor ( 0.0 ) , getY = d3 . functor ( 0.0 ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; container . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ;
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . links || ! data . nodes ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; } container . selectAll ( "*" ) . remove ( ) ;
 // Collect names of all fields in the nodes
 var nodeFieldSet = new Set ( ) ; data . nodes . forEach ( ( node ) { var keys = Object . keys ( node ) ; keys . forEach ( ( key ) { nodeFieldSet . add ( key ) ; } ) ; } ) ; var force = d3 . layout . force ( ) . nodes ( data . nodes ) . links ( data . links ) . size ( [ availableWidth , availableHeight ] ) . linkStrength ( linkStrength ) . friction ( friction ) . linkDistance ( linkDist ) . charge ( charge ) . gravity ( gravity ) . theta ( theta ) . alpha ( alpha ) . start ( ) ; var link = container . selectAll ( ".link" ) . data ( data . links ) . enter ( ) . append ( "line" ) . attr ( "class" , "nv-force-link" ) . style ( "stroke-width" , ( d ) { return Math . sqrt ( d . value ) ; } ) ; var node = container . selectAll ( ".node" ) . data ( data . nodes ) . enter ( ) . append ( "g" ) . attr ( "class" , "nv-force-node" ) . call ( force . drag ) ; node . append ( "circle" ) . attr ( "r" , radius ) . style ( "fill" , ( d ) { return color ( d ) ; } ) . on ( "mouseover" , ( evt ) { container . select ( ".nv-series-" + evt . seriesIndex + " .nv-distx-" + evt . pointIndex ) . attr ( "y1" , evt . py ) ; container . select ( ".nv-series-" + evt . seriesIndex + " .nv-disty-" + evt . pointIndex ) . attr ( "x2" , evt . px ) ;
 // Add 'series' object to
 var nodeColor = color ( evt ) ; evt . series = [ ] ; nodeFieldSet . forEach ( ( field ) { evt . series . push ( color : nodeColor , key : field , value : evt [ field ] ) ; } ) ; tooltip . data ( evt ) . hidden ( false ) ; } ) . on ( "mouseout" , ( d ) { tooltip . hidden ( true ) ; } ) ; tooltip . headerFormatter ( ( d ) { return "Node" ; } ) ;
 // Apply extra attributes to nodes and links (if any)
 linkExtras ( link ) ; nodeExtras ( node ) ; force . on ( "tick" , ( ) { link . attr ( "x1" , ( d ) { return d . source . x ; } ) . attr ( "y1" , ( d ) { return d . source . y ; } ) . attr ( "x2" , ( d ) { return d . target . x ; } ) . attr ( "y2" , ( d ) { return d . target . y ; } ) ; node . attr ( "transform" , ( d ) { return "translate(" + d . x + ", " + d . y + ")" ; } ) ; } ) ; } ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , linkStrength : { "get" : ( ) { return linkStrength ; } , "set" : ( _ ) { linkStrength = _ ; } } , friction : { "get" : ( ) { return friction ; } , "set" : ( _ ) { friction = _ ; } } , linkDist : { "get" : ( ) { return linkDist ; } , "set" : ( _ ) { linkDist = _ ; } } , charge : { "get" : ( ) { return charge ; } , "set" : ( _ ) { charge = _ ; } } , gravity : { "get" : ( ) { return gravity ; } , "set" : ( _ ) { gravity = _ ; } } , theta : { "get" : ( ) { return theta ; } , "set" : ( _ ) { theta = _ ; } } , alpha : { "get" : ( ) { return alpha ; } , "set" : ( _ ) { alpha = _ ; } } , radius : { "get" : ( ) { return radius ; } , "set" : ( _ ) { radius = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = d3 . functor ( _ ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = d3 . functor ( _ ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , nodeExtras : { "get" : ( ) { return nodeExtras ; } , "set" : ( _ ) { nodeExtras = _ ; } } , linkExtras : { "get" : ( ) { return linkExtras ; } , "set" : ( _ ) { linkExtras = _ ; } } ) ; chart . dispatch = dispatch ; chart . tooltip = tooltip ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . furiousLegend = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 5 , "right" : 0 , "bottom" : 5 , "left" : 0 } , width = 400 , height = 20 , getKey = ( d ) { return d . key ; } , keyFormatter = ( d ) { return d ; } , color = nv . utils . getColor ( ) , maxKeyLength = 20 , align = true , padding = 28 , rightAlign = true , updateState = true , radioButtonMode = false , expanded = false , dispatch = d3 . dispatch ( "legendClick" , "legendDblclick" , "legendMouseover" , "legendMouseout" , "stateChange" ) , vers = "classic" ; chart ( selection ) { selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-legend" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-legend" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var series = g . selectAll ( ".nv-series" ) . data ( ( d ) { if ( vers != "furious" ) return d ; return d . filter ( ( n ) { return expanded ? true : ! n . disengaged ; } ) ; } ) ; var seriesEnter = series . enter ( ) . append ( "g" ) . attr ( "class" , "nv-series" ) ; var seriesShape ; if ( vers == "classic" ) { seriesEnter . append ( "circle" ) . style ( "stroke-width" , 2 ) . attr ( "class" , "nv-legend-symbol" ) . attr ( "r" , 5 ) ; seriesShape = series . select ( "circle" ) ; } else if ( vers == "furious" ) { seriesEnter . append ( "rect" ) . style ( "stroke-width" , 2 ) . attr ( "class" , "nv-legend-symbol" ) . attr ( "rx" , 3 ) . attr ( "ry" , 3 ) ; seriesShape = series . select ( "rect" ) ; seriesEnter . append ( "g" ) . attr ( "class" , "nv-check-box" ) . property ( "innerHTML" , "<path d=\"M0.5,5 L22.5,5 L22.5,26.5 L0.5,26.5 L0.5,5 Z\" class=\"nv-box\"></path><path d=\"M5.5,12.8618467 L11.9185089,19.2803556 L31,0.198864511\" class=\"nv-check\"></path>" ) . attr ( "transform" , "translate(-10,-8)scale(0.5)" ) ; var seriesCheckbox = series . select ( ".nv-check-box" ) ; seriesCheckbox . each ( ( d , i ) { d3 . select ( this ) . selectAll ( "path" ) . attr ( "stroke" , setTextColor ( d , i ) ) ; } ) ; } seriesEnter . append ( "text" ) . attr ( "text-anchor" , "start" ) . attr ( "class" , "nv-legend-text" ) . attr ( "dy" , ".32em" ) . attr ( "dx" , "8" ) ; var seriesText = series . select ( "text.nv-legend-text" ) ; series . on ( "mouseover" , ( d , i ) { dispatch . legendMouseover ( d , i ) ; } ) . on ( "mouseout" , ( d , i ) { dispatch . legendMouseout ( d , i ) ; } ) . on ( "click" , ( d , i ) { dispatch . legendClick ( d , i ) ;
 // make sure we re-get data in case it was modified
 var data = series . data ( ) ; if ( updateState ) { if ( vers == "classic" ) { if ( radioButtonMode ) {
 //Radio button mode: set every series to disabled,

 //  and enable the clicked series.
 data . forEach ( ( series ) { series . disabled = true ; } ) ; d . disabled = false ; } else { d . disabled = ! d . disabled ; if ( data . every ( ( series ) { return series . disabled ; } ) ) {
 //the default behavior of NVD3 legends is, if every single series

 // is disabled, turn all series' back on.
 data . forEach ( ( series ) { series . disabled = false ; } ) ; } } } else if ( vers == "furious" ) { if ( expanded ) { d . disengaged = ! d . disengaged ; d . userDisabled = d . userDisabled == undefined ? ! ! d . disabled : d . userDisabled ; d . disabled = d . disengaged || d . userDisabled ; } else if ( ! expanded ) { d . disabled = ! d . disabled ; d . userDisabled = d . disabled ; var engaged = data . filter ( ( d ) { return ! d . disengaged ; } ) ; if ( engaged . every ( ( series ) { return series . userDisabled ; } ) ) {
 //the default behavior of NVD3 legends is, if every single series

 // is disabled, turn all series' back on.
 data . forEach ( ( series ) { series . disabled = series . userDisabled = false ; } ) ; } } } dispatch . stateChange ( disabled : data . map ( ( d ) { return ! ! d . disabled ; } ) , disengaged : data . map ( ( d ) { return ! ! d . disengaged ; } ) ) ; } } ) . on ( "dblclick" , ( d , i ) { if ( vers == "furious" && expanded ) return ; dispatch . legendDblclick ( d , i ) ; if ( updateState ) {
 // make sure we re-get data in case it was modified
 var data = series . data ( ) ;
 //the default behavior of NVD3 legends, when double clicking one,

 // is to set all other series' to false, and make the double clicked series enabled.
 data . forEach ( ( series ) { series . disabled = true ; if ( vers == "furious" ) series . userDisabled = series . disabled ; } ) ; d . disabled = false ; if ( vers == "furious" ) d . userDisabled = d . disabled ; dispatch . stateChange ( disabled : data . map ( ( d ) { return ! ! d . disabled ; } ) ) ; } } ) ; series . classed ( "nv-disabled" , ( d ) { return d . userDisabled ; } ) ; series . exit ( ) . remove ( ) ; seriesText . attr ( "fill" , setTextColor ) . text ( ( d ) { return keyFormatter ( getKey ( d ) ) ; } ) ;
 //TODO: implement fixed-width and max-width options (max-width is especially useful with the align option)

 // NEW ALIGNING CODE, TODO: clean up
 var versPadding ; switch ( vers ) { case "furious" : versPadding = 23 ; break ; case "classic" : versPadding = 20 ; } if ( align ) { var seriesWidths = [ ] ; series . each ( ( d , i ) { var legendText ; if ( keyFormatter ( getKey ( d ) ) && keyFormatter ( getKey ( d ) ) . length > maxKeyLength ) { var trimmedKey = keyFormatter ( getKey ( d ) ) . substring ( 0 , maxKeyLength ) ; legendText = d3 . select ( this ) . select ( "text" ) . text ( trimmedKey + "..." ) ; d3 . select ( this ) . append ( "svg:title" ) . text ( keyFormatter ( getKey ( d ) ) ) ; } else { legendText = d3 . select ( this ) . select ( "text" ) ; } var nodeTextLength ; try { nodeTextLength = legendText . node ( ) . getComputedTextLength ( ) ;
 // If the legendText is display:none'd (nodeTextLength == 0), simulate an error so we approximate, instead
 if ( nodeTextLength <= 0 ) throw Error ( ) ; } catch ( e , e_stack ) { nodeTextLength = nv . utils . calcApproxTextWidth ( legendText ) ; } seriesWidths . push ( nodeTextLength + padding ) ; } ) ; var seriesPerRow = 0 ; var legendWidth = 0 ; var columnWidths = [ ] ; while ( legendWidth < availableWidth && seriesPerRow < seriesWidths . length ) { columnWidths [ seriesPerRow ] = seriesWidths [ seriesPerRow ] ; legendWidth += seriesWidths [ seriesPerRow ++ ] ; } if ( identical ( seriesPerRow , 0 ) ) seriesPerRow = 1 ; while ( legendWidth > availableWidth && seriesPerRow > 1 ) { columnWidths = [ ] ; seriesPerRow -- ; for ( var k = 0 ; k < seriesWidths . length ; k ++ ) { if ( seriesWidths [ k ] > ( columnWidths [ k % seriesPerRow ] || 0 ) ) columnWidths [ k % seriesPerRow ] = seriesWidths [ k ] ; } legendWidth = columnWidths . reduce ( ( prev , cur , index , array ) { return prev + cur ; } ) ; } var xPositions = [ ] ; for ( var i = 0 , curX = 0 ; i < seriesPerRow ; i ++ ) { xPositions [ i ] = curX ; curX += columnWidths [ i ] ; } series . attr ( "transform" , ( d , i ) { return "translate(" + xPositions [ i % seriesPerRow ] + "," + ( 5 + Math . floor ( i / seriesPerRow ) * versPadding ) + ")" ; } ) ;
 //position legend as far right as possible within the total width
 if ( rightAlign ) { g . attr ( "transform" , "translate(" + ( width - margin . right - legendWidth ) + "," + margin . top + ")" ) ; } else { g . attr ( "transform" , "translate(0" + "," + margin . top + ")" ) ; } height = margin . top + margin . bottom + ( Math . ceil ( seriesWidths . length / seriesPerRow ) * versPadding ) ; } else { var ypos = 5 , newxpos = 5 , maxwidth = 0 , xpos ; series . attr ( "transform" , ( d , i ) { var length = d3 . select ( this ) . select ( "text" ) . node ( ) . getComputedTextLength ( ) + padding ; xpos = newxpos ; if ( width < margin . left + margin . right + xpos + length ) { newxpos = xpos = 5 ; ypos += versPadding ; } newxpos += length ; if ( newxpos > maxwidth ) maxwidth = newxpos ; return "translate(" + xpos + "," + ypos + ")" ; } ) ;
 //position legend as far right as possible within the total width
 g . attr ( "transform" , "translate(" + ( width - margin . right - maxwidth ) + "," + margin . top + ")" ) ; height = margin . top + margin . bottom + ypos + 15 ; } if ( vers == "furious" ) {
 // Size rectangles after text is placed
 seriesShape . attr ( "width" , ( d , i ) { return seriesText [ 0 ] [ i ] . getComputedTextLength ( ) + 27 ; } ) . attr ( "height" , 18 ) . attr ( "y" , - 9 ) . attr ( "x" , - 15 ) ; } seriesShape . style ( "fill" , setBGColor ) . style ( "stroke" , ( d , i ) { return d . color || color ( d , i ) ; } ) ; } ) ; setTextColor ( d , i ) { if ( vers != "furious" ) return "#000" ; if ( expanded ) { return d . disengaged ? color ( d , i ) : "#fff" ; } else if ( ! expanded ) { return ! ! d . disabled ? color ( d , i ) : "#fff" ; } } setBGColor ( d , i ) { if ( expanded && vers == "furious" ) { return d . disengaged ? "#fff" : color ( d , i ) ; } else { return ! ! d . disabled ? "#fff" : color ( d , i ) ; } } return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , key : { "get" : ( ) { return getKey ; } , "set" : ( _ ) { getKey = _ ; } } , keyFormatter : { "get" : ( ) { return keyFormatter ; } , "set" : ( _ ) { keyFormatter = _ ; } } , align : { "get" : ( ) { return align ; } , "set" : ( _ ) { align = _ ; } } , rightAlign : { "get" : ( ) { return rightAlign ; } , "set" : ( _ ) { rightAlign = _ ; } } , maxKeyLength : { "get" : ( ) { return maxKeyLength ; } , "set" : ( _ ) { maxKeyLength = _ ; } } , padding : { "get" : ( ) { return padding ; } , "set" : ( _ ) { padding = _ ; } } , updateState : { "get" : ( ) { return updateState ; } , "set" : ( _ ) { updateState = _ ; } } , radioButtonMode : { "get" : ( ) { return radioButtonMode ; } , "set" : ( _ ) { radioButtonMode = _ ; } } , expanded : { "get" : ( ) { return expanded ; } , "set" : ( _ ) { expanded = _ ; } } , vers : { "get" : ( ) { return vers ; } , "set" : ( _ ) { vers = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 /* 
Improvements:
- consistenly apply no-hover classes to rect isntead of to containing g, see example CSS style for .no-hover rect, rect.no-hover
- row/column order (user specified) or 'ascending' / 'descending'
- I haven't tested for transitions between changing datasets
*/
 nv . models . heatMap = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , id = Math . floor ( Math . random ( ) * 10000 ) , container , xScale = d3 . scale . ordinal ( ) , yScale = d3 . scale . ordinal ( ) , colorScale = false , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , getCellValue = ( d ) { return d . value ; } , showCellValues = true , cellValueFormat = ( d ) { return identical ( , "number" ) ? d . toFixed ( 0 ) : d ; } , cellAspectRatio = false , cellRadius = 2 , cellBorderWidth = 4 , normalize = false , highContrastText = true , xDomain , yDomain , xMetaColorScale = nv . utils . defaultColor ( ) , yMetaColorScale = nv . utils . defaultColor ( ) , missingDataColor = "#bcbcbc" , missingDataLabel = "" , metaOffset = 5 , xRange , yRange , xMeta , yMeta , colorRange , colorDomain , dispatch = d3 . dispatch ( "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) , duration = 250 , xMetaHeight = ( d ) { return cellHeight / 3 ; } , yMetaWidth = ( d ) { return cellWidth / 3 ; } , showGrid = false ;
 //============================================================

 // Aux helper function for heatmap

 //------------------------------------------------------------

 // choose high contrast text color based on background

 // shameful steal: https://github.com/alexandersimoes/d3plus/blob/master/src/color/text.coffee
 cellTextColor ( bgColor ) { if ( highContrastText ) { var rgbColor = d3 . rgb ( bgColor ) ; var r = rgbColor . r ; var g = rgbColor . g ; var b = rgbColor . b ; var yiq = ( r * 299 + g * 587 + b * 114 ) / 1000 ; return yiq >= 128 ? "#404040" : "#EDEDED" ; } else { return "black" ; } }
 /* go through heatmap data and generate array of values
     * for each row/column or for entire dataset; for use in
     * calculating means/medians of data for normalizing
     * 
     *
     * 
     * note that if axis is not specified, the return will be
     * {0: [all values in heatmap]}
     */
 getHeatmapValues ( data , axis ) { var vals = { } ; data . forEach ( ( cell , i ) { if ( axis == "row" ) { if ( ! ( ) ) vals [ getIY ( cell ) ] = [ ] ; vals [ getIY ( cell ) ] . push ( getCellValue ( cell ) ) ; } else if ( axis == "col" ) { if ( ! ( ) ) vals [ getIX ( cell ) ] = [ ] ; vals [ getIX ( cell ) ] . push ( getCellValue ( cell ) ) ; } else if ( axis == null ) { if ( ! ( ) ) vals [ 0 ] = [ ] ; vals [ 0 ] . push ( getCellValue ( cell ) ) ; } } ) ; return vals ; }
 // calculate the median absolute deviation of the given array of data

 // https://en.wikipedia.org/wiki/Median_absolute_deviation

 // MAD = median(abs(Xi - median(X)))
 mad ( dat ) { var med = d3 . median ( dat ) ; var vals = dat . map ( ( d ) { return Math . abs ( d - med ) ; } ) ; return d3 . median ( vals ) ; }
 // set cell color based on cell value

 // depending on whether it should be normalized or not
 cellColor ( d ) { var colorVal = normalize ? getNorm ( d ) : getCellValue ( d ) ; return ( cellsAreNumeric ( ) && ! isNaN ( colorVal ) || ! identical ( , "undefined" ) ) ? colorScale ( colorVal ) : missingDataColor ; }
 // return the domain of the color data

 // if ordinal data is given for the cells, this will

 // return all possible cells values; otherwise it

 // returns the extent of the cell values

 // will take into account normalization if specified
 getColorDomain ( ) { if ( cellsAreNumeric ( ) ) { return normalize ? d3 . extent ( prepedData , ( d ) { return getNorm ( d ) ; } ) : d3 . extent ( uniqueColor ) ; } else if ( ! cellsAreNumeric ( ) ) { return uniqueColor ; } }
 // return true if cells are numeric

 // as opposed to categorical
 cellsAreNumeric ( ) { return identical ( , "number" ) ; }
 /*
     * Normalize input data
     *
     * normalize must be one of centerX, robustCenterX, centerScaleX, robustCenterScaleX, centerAll, 
     * robustCenterAll, centerScaleAll, robustCenterScaleAll where X is either 'Row' or 'Column'
     *
     * - centerX: subtract row/column mean from cell
     * - centerAll: subtract mean of whole data set from cell
     * - centerScaleX: scale so that row/column has mean 0 and variance 1 (Z-score)
     * - centerScaleAll: scale by overall normalization factor so that the whole data set has mean 0 and variance 1 (Z-score)
     * - robustCenterX: subtract row/column median from cell
     * - robustCenterScaleX: subtract row/column median from cell and then scale row/column by median absolute deviation
     * - robustCenterAll: subtract median of whole data set from cell
     * - robustCenterScaleAll: subtract overall median from cell and scale by overall median absolute deviation
     */
 normalizeData ( dat ) { var normTypes = [ "centerRow" , "robustCenterRow" , "centerScaleRow" , "robustCenterScaleRow" , "centerColumn" , "robustCenterColumn" , "centerScaleColumn" , "robustCenterScaleColumn" , "centerAll" , "robustCenterAll" , "centerScaleAll" , "robustCenterScaleAll" ] ; if ( normTypes . indexOf ( normalize ) != - 1 ) { var xVals = Object . keys ( uniqueX ) , yVals = Object . keys ( uniqueY ) ;
 // setup normalization options
 var scale = normalize . includes ( "Scale" ) ? true : false , agg = normalize . includes ( "robust" ) ? "median" : "mean" , axis = normalize . includes ( "Row" ) ? "row" : normalize . includes ( "Column" ) ? "col" : null , vals = getHeatmapValues ( dat , axis ) ;
 // calculate mean or median

 // calculate standard dev or median absolute deviation
 var stat = { } ; var dev = { } ; for ( var key in vals ) { stat [ key ] = agg == "mean" ? d3 . mean ( vals [ key ] ) : d3 . median ( vals [ key ] ) ; if ( scale ) dev [ key ] = agg == "mean" ? d3 . deviation ( vals [ key ] ) : mad ( vals [ key ] ) ; }
 // do the normalizing
 dat . forEach ( ( cell , i ) { if ( cellsAreNumeric ( ) ) { if ( axis == "row" ) { var key = getIY ( cell ) ; } else if ( axis == "col" ) { var key = getIX ( cell ) ; } else if ( axis == null ) { var key = 0 ; } var normVal = getCellValue ( cell ) - stat [ key ] ; if ( scale ) { cell . _cellPos . norm = normVal / dev [ key ] ; } else { cell . _cellPos . norm = normVal ; } } else { cell . _cellPos . norm = getCellValue ( cell ) ; } } ) ; } else { normalize = false ; } return dat ; }
 /*
     * Process incoming data for use with heatmap including:
     * - adding a unique key indexer to each data point (idx)
     * - getting a unique list of all x & y values
     * - generating a position index (x & y) for each data point
     * - sorting that data for correct traversal when generating rect
     * - generating placeholders for missing data
     *
     * In order to allow for the flexibility of the user providing either
     * categorical or quantitative data, we're going to position the cells
     * through indices that we increment based on previously seen data
     * this way we can use ordinal() axes even if the data is quantitative.
     *
     * When we generate the SVG elements, we assumes traversal occures from
     * top to bottom and from left to right.
     *
     * 
     *
     * 
     *           formatted as {idx: XXX, ix, XXX, iy: XXX}
     *           where idx is a global identifier; ix is an identifier
     *           within each column, and iy is an identifier within
     *           each row. 
     */
 prepData ( data ) {
 // reinitialize
 uniqueX = { } , uniqueY = { } , uniqueColor = [ ] , uniqueXMeta = [ ] , uniqueYMeta = [ ] , uniqueCells = [ ] ; var warnings = [ ] ; var sortedCells = { } ; var ix = 0 , iy = 0 ; var combo , idx = 0 ; data . forEach ( ( cell ) { var valX = getX ( cell ) , valY = getY ( cell ) , valColor = getCellValue ( cell ) ;
 // assemble list of unique values for each dimension
 if ( ! ( ) ) { uniqueX [ valX ] = ix ; ix ++ ; sortedCells [ valX ] = { } ; if ( identical ( , "function" ) ) uniqueXMeta . push ( xMeta ( cell ) ) ; } if ( ! ( ) ) { uniqueY [ valY ] = iy ; iy ++ ; sortedCells [ valX ] [ valY ] = { } ; if ( identical ( , "function" ) ) uniqueYMeta . push ( yMeta ( cell ) ) ; } if ( uniqueColor . indexOf ( valColor ) == - 1 ) uniqueColor . push ( valColor ) ;
 // for each data point, we generate an object of data

 // needed to properly position each cell
 cell . _cellPos = { "idx" : idx , "ix" : uniqueX [ valX ] , "iy" : uniqueY [ valY ] } ; idx ++ ;
 // keep track of row & column combinations we've already seen

 // this prevents the same cells from being generated when

 // the user hasn't provided proper data (one value for each

 // row & column).

 // if properly formatted data is not provided, only the first

 // row & column value is used (the rest are ignored)
 combo = [ valX , valY ] ; if ( ! isArrayInArray ( uniqueCells , combo ) ) { uniqueCells . push ( combo ) ; sortedCells [ valX ] [ valY ] = cell ; } else if ( warnings . indexOf ( valX + valY ) == - 1 ) { warnings . push ( valX + valY ) ; console . warn ( "The row/column position " + valX + "/" + valY + " has multiple values; ensure each cell has only a single value." ) ; } } ) ; uniqueColor = uniqueColor . sort ( ) ;
 // check in sortedCells that each x has all the y's

 // if not, generate an empty placeholder

 // this will also sort all cells from left to right

 // and top to bottom
 var reformatData = [ ] ; Object . keys ( uniqueY ) . forEach ( ( j ) { Object . keys ( uniqueX ) . forEach ( ( i ) { var cellVal = sortedCells [ i ] [ j ] ; if ( cellVal ) { reformatData . push ( cellVal ) ; } else { var cellPos = { "idx" : idx , "ix" : uniqueX [ i ] , "iy" : uniqueY [ j ] } ; idx ++ ; reformatData . push ( _cellPos : cellPos ) ; } } ) ; } ) ;
 // normalize data is needed
 return normalize ? normalizeData ( reformatData ) : reformatData ; }
 // https://stackoverflow.com/a/41661388/1153897
 isArrayInArray ( arr , item ) { var item_as_string = JSON . stringify ( item ) ; var contains = arr . some ( ( ele ) { return identical ( JSON . stringify ( ele ) , item_as_string ) ; } ) ; return contains ; } removeAllHoverClasses ( ) {
 // remove all hover classes
 d3 . selectAll ( ".cell-hover" ) . classed ( "cell-hover" , false ) ; d3 . selectAll ( ".no-hover" ) . classed ( "no-hover" , false ) ; d3 . selectAll ( ".row-hover" ) . classed ( "row-hover" , false ) ; d3 . selectAll ( ".column-hover" ) . classed ( "column-hover" , false ) ; }
 // return the formatted cell value if it is

 // a number, otherwise return missingDataLabel
 var cellValueLabel = ( d ) { var val = ! normalize ? cellValueFormat ( getCellValue ( d ) ) : cellValueFormat ( getNorm ( d ) ) ; return ( cellsAreNumeric ( ) && ! isNaN ( val ) || ! identical ( , "undefined" ) ) ? val : missingDataLabel ; } ;
 // https://stackoverflow.com/a/16794116/1153897

 // note this returns the obj keys
 sortObjByVals ( obj ) { return Object . keys ( obj ) . sort ( ( a , b ) { return obj [ a ] - obj [ b ] ; } ) ; }
 // https://stackoverflow.com/a/28191966/1153897
 getKeyByValue ( object , value ) {
 //return Object.keys(object).find(key => object[key] === value);
 return Object . keys ( object ) . filter ( ( key ) { return identical ( object [ key ] , value ) ; } ) [ 0 ] ; }
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var prepedData , cellHeight , cellWidth ; var uniqueX = { } , uniqueY = { } , uniqueColor = [ ] ; var uniqueXMeta = [ ] , uniqueYMeta = [ ] , uniqueCells = [ ] ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; var RdYlBu = [ "#a50026" , "#d73027" , "#f46d43" , "#fdae61" , "#fee090" , "#ffffbf" , "#e0f3f8" , "#abd9e9" , "#74add1" , "#4575b4" , "#313695" ] ; var getCellPos = ( d ) { return d . _cellPos ; } ; var getIX = ( d ) { return getCellPos ( d ) . ix ; } ; var getIY = ( d ) { return getCellPos ( d ) . iy ; } ; var getNorm = ( d ) { return getCellPos ( d ) . norm ; } ; var getIdx = ( d ) { return getCellPos ( d ) . idx ; } ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { prepedData = prepData ( data ) ; var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ;
 // available width/height set the cell dimenions unless

 // the aspect ratio is defined - in that case the cell

 // height is adjusted and availableHeight updated
 cellWidth = availableWidth / Object . keys ( uniqueX ) . length ; cellHeight = cellAspectRatio ? cellWidth / cellAspectRatio : availableHeight / Object . keys ( uniqueY ) . length ; if ( cellAspectRatio ) availableHeight = cellHeight * Object . keys ( uniqueY ) . length - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup Scales
 xScale . domain ( xDomain || sortObjByVals ( uniqueX ) ) . rangeBands ( xRange || [ 0 , availableWidth - cellBorderWidth / 2 ] ) ; yScale . domain ( yDomain || sortObjByVals ( uniqueY ) ) . rangeBands ( yRange || [ 0 , availableHeight - cellBorderWidth / 2 ] ) ; colorScale = cellsAreNumeric ( ) ? d3 . scale . quantize ( ) : d3 . scale . ordinal ( ) ; colorScale . domain ( colorDomain || getColorDomain ( ) ) . range ( colorRange || RdYlBu ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-heatMapWrap" ) . data ( [ prepedData ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-heatMapWrap" ) ; wrapEnter . append ( "g" ) . attr ( "class" , "cellWrap" ) ; wrap . watchTransition ( renderWatch , "nv-wrap: heatMapWrap" ) . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var gridWrap = wrapEnter . append ( "g" ) . attr ( "class" , "cellGrid" ) . style ( "opacity" , 1e-6 ) ; var gridLinesV = wrap . select ( ".cellGrid" ) . selectAll ( ".gridLines.verticalGrid" ) . data ( Object . values ( uniqueX ) . concat ( [ Object . values ( uniqueX ) . length ] ) ) ; gridLinesV . enter ( ) . append ( "line" ) . attr ( "class" , "gridLines verticalGrid" ) ; gridLinesV . exit ( ) . remove ( ) ; var gridLinesH = wrap . select ( ".cellGrid" ) . selectAll ( ".gridLines.horizontalGrid" ) . data ( Object . values ( uniqueY ) . concat ( [ Object . values ( uniqueY ) . length ] ) ) ; gridLinesH . enter ( ) . append ( "line" ) . attr ( "class" , "gridLines horizontalGrid" ) ; gridLinesH . exit ( ) . remove ( ) ; var cellWrap = wrap . select ( ".cellWrap" ) . selectAll ( ".nv-cell" ) . data ( ( d ) { return d ; } , ( e ) { return getIdx ( e ) ; } ) ; var xMetaWrap = wrapEnter . append ( "g" ) . attr ( "class" , "xMetaWrap" ) . attr ( "transform" , ( ) { return "translate(0," + ( - xMetaHeight ( ) - cellBorderWidth - metaOffset ) + ")" ; } ) ; var xMetas = wrap . select ( ".xMetaWrap" ) . selectAll ( ".x-meta" ) . data ( uniqueXMeta ) ; var xMetaEnter = xMetas . enter ( ) . append ( "rect" ) . attr ( "class" , "x-meta meta" ) . attr ( "width" , cellWidth - cellBorderWidth ) . attr ( "height" , xMetaHeight ( ) ) . attr ( "transform" , "translate(0,0)" ) . attr ( "fill" , ( d ) { return xMetaColorScale ( d ) ; } ) ; var yMetaWrap = wrapEnter . append ( "g" ) . attr ( "class" , "yMetaWrap" ) . attr ( "transform" , ( d , i ) { return "translate(" + ( - yMetaWidth ( ) - cellBorderWidth - metaOffset ) + ",0)" ; } ) ; var yMetas = wrap . select ( ".yMetaWrap" ) . selectAll ( ".y-meta" ) . data ( uniqueYMeta ) ; var yMetaEnter = yMetas . enter ( ) . append ( "rect" ) . attr ( "class" , "y-meta meta" ) . attr ( "width" , yMetaWidth ( ) ) . attr ( "height" , cellHeight - cellBorderWidth ) . attr ( "transform" , ( d , i ) { return "translate(0,0)" ; } ) . attr ( "fill" , ( d , i ) { return yMetaColorScale ( d ) ; } ) ; xMetas . exit ( ) . remove ( ) ; yMetas . exit ( ) . remove ( ) ;
 // CELLS    
 var cellsEnter = cellWrap . enter ( ) . append ( "g" ) . style ( "opacity" , 1e-6 ) . attr ( "transform" , ( d ) { return "translate(0," + getIY ( d ) * cellHeight + ")" ; } ) . attr ( "data-row" , ( d ) { return getIY ( d ) ; } ) . attr ( "data-column" , ( d ) { return getIX ( d ) ; } ) ; cellsEnter . append ( "rect" ) ; cellsEnter . append ( "text" ) . attr ( "text-anchor" , "middle" ) . attr ( "dy" , 4 ) . attr ( "class" , "cell-text" ) ;
 // transition cell (rect) size
 cellWrap . selectAll ( "rect" ) . watchTransition ( renderWatch , "heatMap: rect" ) . attr ( "width" , cellWidth - cellBorderWidth ) . attr ( "height" , cellHeight - cellBorderWidth ) . attr ( "rx" , cellRadius ) . attr ( "ry" , cellRadius ) . style ( "stroke" , ( d ) { return cellColor ( d ) ; } ) ;
 // transition cell (g) position, opacity and fill
 cellWrap . attr ( "class" , ( d ) { return isNaN ( getCellValue ( d ) ) ? "nv-cell cell-missing" : "nv-cell" ; } ) . watchTransition ( renderWatch , "heatMap: cells" ) . style ( { "opacity" : 1 , "fill" : ( d ) { return cellColor ( d ) ; } } ) . attr ( "transform" , ( d ) { return "translate(" + getIX ( d ) * cellWidth + "," + getIY ( d ) * cellHeight + ")" ; } ) . attr ( "class" , ( d ) { return isNaN ( getCellValue ( d ) ) ? "nv-cell cell-missing" : "nv-cell" ; } ) ; cellWrap . exit ( ) . remove ( ) ;
 // transition text position and fill
 cellWrap . selectAll ( "text" ) . watchTransition ( renderWatch , "heatMap: cells text" ) . text ( ( d ) { return cellValueLabel ( d ) ; } ) . attr ( "x" , ( d ) { return ( cellWidth - cellBorderWidth ) / 2 ; } ) . attr ( "y" , ( d ) { return ( cellHeight - cellBorderWidth ) / 2 ; } ) . style ( "fill" , ( d ) { return cellTextColor ( cellColor ( d ) ) ; } ) . style ( "opacity" , ( ) { return showCellValues ? 1 : 0 ; } ) ;
 // transition grid
 wrap . selectAll ( ".verticalGrid" ) . watchTransition ( renderWatch , "heatMap: gridLines" ) . attr ( "y1" , 0 ) . attr ( "y2" , availableHeight - cellBorderWidth ) . attr ( "x1" , ( d ) { return d * cellWidth - cellBorderWidth / 2 ; } ) . attr ( "x2" , ( d ) { return d * cellWidth - cellBorderWidth / 2 ; } ) ; var numHLines = Object . keys ( uniqueY ) . length ; wrap . selectAll ( ".horizontalGrid" ) . watchTransition ( renderWatch , "heatMap: gridLines" ) . attr ( "x1" , ( d ) { return ( d == 0 || d == numHLines ) ? - cellBorderWidth : 0 ; } ) . attr ( "x2" , ( d ) { return ( d == 0 || d == numHLines ) ? availableWidth : availableWidth - cellBorderWidth ; } ) . attr ( "y1" , ( d ) { return d * cellHeight - cellBorderWidth / 2 ; } ) . attr ( "y2" , ( d ) { return d * cellHeight - cellBorderWidth / 2 ; } ) ; wrap . select ( ".cellGrid" ) . watchTransition ( renderWatch , "heatMap: gridLines" ) . style ( { "stroke-width" : cellBorderWidth , "opacity" : ( ) { return showGrid ? 1 : 1e-6 ; } } ) ; var xMetaRect = wrap . selectAll ( ".x-meta" ) ; var yMetaRect = wrap . selectAll ( ".y-meta" ) ; var allMetaRect = wrap . selectAll ( ".meta" ) ;
 // transition meta rect size
 xMetas . watchTransition ( renderWatch , "heatMap: xMetaRect" ) . attr ( "width" , cellWidth - cellBorderWidth ) . attr ( "height" , xMetaHeight ( ) ) . attr ( "transform" , ( d , i ) { return "translate(" + ( i * cellWidth ) + ",0)" ; } ) ; yMetas . watchTransition ( renderWatch , "heatMap: yMetaRect" ) . attr ( "width" , yMetaWidth ( ) ) . attr ( "height" , cellHeight - cellBorderWidth ) . attr ( "transform" , ( d , i ) { return "translate(0," + ( i * cellHeight ) + ")" ; } ) ;
 // transition position of meta wrap g & opacity
 wrap . select ( ".xMetaWrap" ) . watchTransition ( renderWatch , "heatMap: xMetaWrap" ) . attr ( "transform" , ( d , i ) { return "translate(0," + ( - xMetaHeight ( ) - cellBorderWidth - metaOffset ) + ")" ; } ) . style ( "opacity" , ( ) { return ! identical ( xMeta , false ) ? 1 : 0 ; } ) ; wrap . select ( ".yMetaWrap" ) . watchTransition ( renderWatch , "heatMap: yMetaWrap" ) . attr ( "transform" , ( d , i ) { return "translate(" + ( - yMetaWidth ( ) - cellBorderWidth - metaOffset ) + ",0)" ; } ) . style ( "opacity" , ( ) { return ! identical ( yMeta , false ) ? 1 : 0 ; } ) ;
 // TOOLTIPS
 cellWrap . on ( "mouseover" , ( d , i ) { var idx = getIdx ( d ) ; var ix = getIX ( d ) ; var iy = getIY ( d ) ;
 // set the proper classes for all cells

 // hover row gets class .row-hover

 // hover column gets class .column-hover

 // hover cell gets class .cell-hover

 // all remaining cells get class .no-hover
 d3 . selectAll ( ".nv-cell" ) . each ( ( e ) { if ( idx == getIdx ( e ) ) { d3 . select ( this ) . classed ( "cell-hover" , true ) ; d3 . select ( this ) . classed ( "no-hover" , false ) ; } else { d3 . select ( this ) . classed ( "no-hover" , true ) ; d3 . select ( this ) . classed ( "cell-hover" , false ) ; } if ( ix == getIX ( e ) ) { d3 . select ( this ) . classed ( "no-hover" , false ) ; d3 . select ( this ) . classed ( "column-hover" , true ) ; } if ( iy == getIY ( e ) ) { d3 . select ( this ) . classed ( "no-hover" , false ) ; d3 . select ( this ) . classed ( "row-hover" , true ) ; } } ) ;
 // set hover classes for column metadata
 d3 . selectAll ( ".x-meta" ) . each ( ( e , j ) { if ( j == ix ) { d3 . select ( this ) . classed ( "cell-hover" , true ) ; d3 . select ( this ) . classed ( "no-hover" , false ) ; } else { d3 . select ( this ) . classed ( "no-hover" , true ) ; d3 . select ( this ) . classed ( "cell-hover" , false ) ; } } ) ;
 // set hover class for row metadata
 d3 . selectAll ( ".y-meta" ) . each ( ( e , j ) { if ( j == iy ) { d3 . select ( this ) . classed ( "cell-hover" , true ) ; d3 . select ( this ) . classed ( "no-hover" , false ) ; } else { d3 . select ( this ) . classed ( "no-hover" , true ) ; d3 . select ( this ) . classed ( "cell-hover" , false ) ; } } ) ; dispatch . elementMouseover ( value : getKeyByValue ( uniqueX , ix ) + " & " + getKeyByValue ( uniqueY , iy ) , series : { "value" : cellValueLabel ( d ) , "color" : d3 . select ( this ) . select ( "rect" ) . style ( "fill" ) } , e : d3 . event ) ; } ) . on ( "mouseout" , ( d , i ) {
 // allow tooltip to remain even when mouse is over the

 // space between the cell;

 // this prevents cells from "flashing" when transitioning

 // between cells
 var bBox = d3 . select ( this ) . select ( "rect" ) . node ( ) . getBBox ( ) ; var coordinates = d3 . mouse ( d3 . select ( ".nv-heatMap" ) . node ( ) ) ; var x = coordinates [ 0 ] ; var y = coordinates [ 1 ] ;
 // we only trigger mouseout when mouse moves outside of

 // .nv-heatMap
 if ( x + cellBorderWidth >= availableWidth || y + cellBorderWidth >= availableHeight || x < 0 || y < 0 ) {
 // remove all hover classes
 removeAllHoverClasses ( ) ; dispatch . elementMouseout ( e : d3 . event ) ; } } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ; allMetaRect . on ( "mouseover" , ( d , i ) {
 // true if hovering over a row metadata rect
 var isColMeta = d3 . select ( this ) . attr ( "class" ) . indexOf ( "x-meta" ) != - 1 ? true : false ;
 // apply proper .row-hover & .column-hover

 // classes to cells
 d3 . selectAll ( ".nv-cell" ) . each ( ( e ) { if ( isColMeta && i == getIX ( e ) ) { d3 . select ( this ) . classed ( "column-hover" , true ) ; d3 . select ( this ) . classed ( "no-hover" , false ) ; } else if ( ! isColMeta && i - uniqueXMeta . length == getIY ( e ) ) {
 // since allMetaRect selects all the meta rects, the index for the y's will

 // be offset by the number of x rects. TODO - write seperate tooltip sections

 // for x meta rect & y meta rect
 d3 . select ( this ) . classed ( "row-hover" , true ) ; d3 . select ( this ) . classed ( "no-hover" , false ) ; } else { d3 . select ( this ) . classed ( "no-hover" , true ) ; d3 . select ( this ) . classed ( "column-hover" , false ) ; d3 . select ( this ) . classed ( "row-hover" , false ) ; } d3 . select ( this ) . classed ( "cell-hover" , false ) ; } ) ;
 // apply proper .row-hover & .column-hover

 // classes to meta rects
 d3 . selectAll ( ".meta" ) . classed ( "no-hover" , true ) ; d3 . select ( this ) . classed ( "cell-hover" , true ) ; d3 . select ( this ) . classed ( "no-hover" , false ) ; dispatch . elementMouseover ( value : isColMeta ? "Column meta" : "Row meta" , series : { "value" : d , "color" : d3 . select ( this ) . style ( "fill" ) } ) ; } ) . on ( "mouseout" , ( d , i ) {
 // true if hovering over a row metadata rect
 var isColMeta = d3 . select ( this ) . attr ( "class" ) . indexOf ( "x-meta" ) != - 1 ? true : false ;
 // allow tooltip to remain even when mouse is over the

 // space between the cell;

 // this prevents cells from "flashing" when transitioning

 // between cells
 var bBox = d3 . select ( this ) . node ( ) . getBBox ( ) ; var coordinates = d3 . mouse ( d3 . select ( isColMeta ? ".xMetaWrap" : ".yMetaWrap" ) . node ( ) ) ; var x = coordinates [ 0 ] ; var y = coordinates [ 1 ] ; if ( y < 0 || x < 0 || ( isColMeta && x + cellBorderWidth >= availableWidth ) || ( ! isColMeta && y + cellBorderWidth >= availableHeight ) ) {
 // remove all hover classes
 removeAllHoverClasses ( ) ; dispatch . elementMouseout ( e : d3 . event ) ; } } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( e : d3 . event ) ; } ) ; } ) ; renderWatch . renderEnd ( "heatMap immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showCellValues : { "get" : ( ) { return showCellValues ; } , "set" : ( _ ) { showCellValues = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , cellValue : { "get" : ( ) { return getCellValue ; } , "set" : ( _ ) { getCellValue = _ ; } } , missingDataColor : { "get" : ( ) { return missingDataColor ; } , "set" : ( _ ) { missingDataColor = _ ; } } , missingDataLabel : { "get" : ( ) { return missingDataLabel ; } , "set" : ( _ ) { missingDataLabel = _ ; } } , xScale : { "get" : ( ) { return xScale ; } , "set" : ( _ ) { xScale = _ ; } } , yScale : { "get" : ( ) { return yScale ; } , "set" : ( _ ) { yScale = _ ; } } , colorScale : { "get" : ( ) { return colorScale ; } , "set" : ( _ ) { colorScale = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , colorRange : { "get" : ( ) { return colorRange ; } , "set" : ( _ ) { colorRange = _ ; } } , colorDomain : { "get" : ( ) { return colorDomain ; } , "set" : ( _ ) { colorDomain = _ ; } } , xMeta : { "get" : ( ) { return xMeta ; } , "set" : ( _ ) { xMeta = _ ; } } , yMeta : { "get" : ( ) { return yMeta ; } , "set" : ( _ ) { yMeta = _ ; } } , xMetaColorScale : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , yMetaColorScale : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , cellAspectRatio : { "get" : ( ) { return cellAspectRatio ; } , "set" : ( _ ) { cellAspectRatio = _ ; } } , cellRadius : { "get" : ( ) { return cellRadius ; } , "set" : ( _ ) { cellRadius = _ ; } } , cellHeight : { "get" : ( ) { return cellHeight ; } } , cellWidth : { "get" : ( ) { return cellWidth ; } } , normalize : { "get" : ( ) { return normalize ; } , "set" : ( _ ) { normalize = _ ; } } , cellBorderWidth : { "get" : ( ) { return cellBorderWidth ; } , "set" : ( _ ) { cellBorderWidth = _ ; } } , highContrastText : { "get" : ( ) { return highContrastText ; } , "set" : ( _ ) { highContrastText = _ ; } } , cellValueFormat : { "get" : ( ) { return cellValueFormat ; } , "set" : ( _ ) { cellValueFormat = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , metaOffset : { "get" : ( ) { return metaOffset ; } , "set" : ( _ ) { metaOffset = _ ; } } , xMetaHeight : { "get" : ( ) { return xMetaHeight ; } , "set" : ( _ ) { xMetaHeight = _ ; } } , yMetaWidth : { "get" : ( ) { return yMetaWidth ; } , "set" : ( _ ) { yMetaWidth = _ ; } } , showGrid : { "get" : ( ) { return showGrid ; } , "set" : ( _ ) { showGrid = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 /* Heatmap Chart Type

A heatmap is a graphical representation of data where the individual values
contained in a matrix are represented as colors within cells. Furthermore,
metadata can be associated with each of the matrix rows or columns. By grouping
these rows/columns together by a given metadata value, data trends can be spotted.

Format for input data should be:
var data = [
    {day: 'mo', hour: '1a', value: 16, timeperiod: 'early morning', weekperiod: 'week', category: 1},
    {day: 'mo', hour: '2a', value: 20, timeperiod: 'early morning', weekperiod: 'week', category: 2},
    {day: 'mo', hour: '3a', value: 0, timeperiod: 'early morning', weekperiod: 'week', category: 1},
    ...
]
where the keys 'day' and 'hour' specify the row/column of the heatmap, 'value' specifies the  cell
value and the keys 'timeperiod', 'weekperiod' and 'week' are extra metadata that can be associated
with rows/columns.


Options for chart:
*/
 nv . models . heatMapChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var heatMap = nv . models . heatMap ( ) , legend = nv . models . legend ( ) , legendRowMeta = nv . models . legend ( ) , legendColumnMeta = nv . models . legend ( ) , tooltip = nv . models . tooltip ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) ; var margin = { "top" : 20 , "right" : 10 , "bottom" : 50 , "left" : 60 } , marginTop = null , width = null , height = null , color = nv . utils . getColor ( ) , showLegend = true , staggerLabels = false , showXAxis = true , showYAxis = true , alignYAxis = "left" , alignXAxis = "top" , rotateLabels = 0 , title = false , x , y , noData = null , dispatch = d3 . dispatch ( "beforeUpdate" , "renderEnd" ) , duration = 250 ; xAxis . orient ( alignXAxis ) . showMaxMin ( false ) . tickFormat ( ( d ) { return d ; } ) ; yAxis . orient ( alignYAxis ) . showMaxMin ( false ) . tickFormat ( ( d ) { return d ; } ) ; tooltip . duration ( 0 ) . headerEnabled ( true ) . keyFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------

 // https://bl.ocks.org/mbostock/4573883

 // get max/min range for all the quantized cell values

 // returns an array where each element is [start,stop]

 // of color bin
 quantizeLegendValues ( ) { var e = heatMap . colorScale ( ) , legendVals ; if ( identical ( , "string" ) ) { legendVals = e . domain ( ) ; } else { legendVals = e . range ( ) . map ( ( color ) { var d = e . invertExtent ( color ) ; if ( identical ( d [ 0 ] , null ) ) d [ 0 ] = e . domain ( ) [ 0 ] ; if ( identical ( d [ 1 ] , null ) ) d [ 1 ] = e . domain ( ) [ 1 ] ; return d ; } ) ; } return legendVals ; }
 // return true if row metadata specified by user
 hasRowMeta ( ) { return identical ( , "function" ) ; }
 // return true if col metadata specified by user
 hasColumnMeta ( ) { return identical ( , "function" ) ; } var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( heatMap ) ; renderWatch . models ( xAxis ) ; renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { dispatch . beforeUpdate ( ) ; container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ;
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = heatMap . xScale ( ) ; y = heatMap . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-heatMap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; g . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; heatMap . width ( availableWidth ) . height ( availableHeight ) ; var heatMapWrap = g . select ( ".nv-heatMap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ; heatMapWrap . transition ( ) . call ( heatMap ) ; if ( heatMap . cellAspectRatio ( ) ) { availableHeight = heatMap . cellHeight ( ) * y . domain ( ) . length ; heatMap . height ( availableHeight ) ; }
 // Setup Axes
 xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; var axisX = g . select ( ".nv-x.nv-axis" ) ; axisX . call ( xAxis ) . watchTransition ( renderWatch , "heatMap: axisX" ) . selectAll ( ".tick" ) . style ( "opacity" , ( ) { return showXAxis ? 1 : 0 ; } ) ; var xTicks = axisX . selectAll ( "g" ) ; xTicks . selectAll ( ".tick text" ) . attr ( "transform" , ( d , i , j ) { var rot = rotateLabels != 0 ? rotateLabels : "0" ; var stagger = staggerLabels ? j % 2 == 0 ? "5" : "17" : "0" ; return "translate(0, " + stagger + ") rotate(" + rot + " 0,0)" ; } ) . style ( "text-anchor" , rotateLabels > 0 ? "start" : rotateLabels < 0 ? "end" : "middle" ) ;
 // position text in center of meta rects
 var yPos = - 5 ; if ( hasColumnMeta ( ) ) { axisX . selectAll ( "text" ) . style ( "text-anchor" , "middle" ) ; yPos = - heatMap . xMetaHeight ( ) ( ) / 2 - heatMap . metaOffset ( ) + 3 ; }
 // adjust position of axis based on presence of metadata group
 if ( alignXAxis == "bottom" ) { axisX . watchTransition ( renderWatch , "heatMap: axisX" ) . attr ( "transform" , "translate(0," + ( availableHeight - yPos ) + ")" ) ; if ( ! identical ( heatMap . xMeta ( ) , false ) ) { var pos = availableHeight + heatMap . metaOffset ( ) + heatMap . cellBorderWidth ( ) ; g . select ( ".xMetaWrap" ) . watchTransition ( renderWatch , "heatMap: xMetaWrap" ) . attr ( "transform" , ( d , i ) { return "translate(0," + pos + ")" ; } ) ; } } else { axisX . watchTransition ( renderWatch , "heatMap: axisX" ) . attr ( "transform" , "translate(0," + yPos + ")" ) ; } yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; var axisY = g . select ( ".nv-y.nv-axis" ) ; axisY . call ( yAxis ) . watchTransition ( renderWatch , "heatMap: axisY" ) . selectAll ( ".tick" ) . style ( "opacity" , ( ) { return showYAxis ? 1 : 0 ; } ) ;
 // position text in center of meta rects
 var xPos = - 5 ; if ( hasRowMeta ( ) ) { axisY . selectAll ( "text" ) . style ( "text-anchor" , "middle" ) ; xPos = - heatMap . yMetaWidth ( ) ( ) / 2 - heatMap . metaOffset ( ) ; }
 // adjust position of axis based on presence of metadata group
 if ( alignYAxis == "right" ) { axisY . attr ( "transform" , "translate(" + ( availableWidth - xPos ) + ",0)" ) ; if ( ! identical ( heatMap . yMeta ( ) , false ) ) { var pos = availableWidth + heatMap . metaOffset ( ) + heatMap . cellBorderWidth ( ) ; g . select ( ".yMetaWrap" ) . watchTransition ( renderWatch , "heatMap: yMetaWrap" ) . attr ( "transform" , ( d , i ) { return "translate(" + pos + ",0)" ; } ) ; } } else { axisY . attr ( "transform" , "translate(" + xPos + ",0)" ) ; }
 // Legend
 var legendWrap = g . select ( ".nv-legendWrap" ) ; legend . width ( availableWidth ) . color ( heatMap . colorScale ( ) . range ( ) ) ; var legendVal = quantizeLegendValues ( ) . map ( ( d ) { if ( Array . isArray ( d ) ) { return { "key" : d [ 0 ] . toFixed ( 1 ) + " - " + d [ 1 ] . toFixed ( 1 ) } ; } else { return { "key" : d } ; } } ) ; legendWrap . datum ( legendVal ) . call ( legend ) . attr ( "transform" , "translate(0," + ( alignXAxis == "top" ? availableHeight : - 30 ) + ")" ) ; legendWrap . watchTransition ( renderWatch , "heatMap: nv-legendWrap" ) . style ( "opacity" , ( ) { return showLegend ? 1 : 0 ; } ) ; } ) ;
 // axis don't have a flag for disabling the zero line, so we do it manually
 d3 . selectAll ( ".nv-axis" ) . selectAll ( "line" ) . style ( "stroke-opacity" , 0 ) ; d3 . select ( ".nv-y" ) . select ( "path.domain" ) . remove ( ) ; renderWatch . renderEnd ( "heatMap chart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 heatMap . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { tooltip . data ( evt ) . hidden ( false ) ; } ) ; heatMap . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; heatMap . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . heatMap = heatMap ; chart . legend = legend ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , staggerLabels : { "get" : ( ) { return staggerLabels ; } , "set" : ( _ ) { staggerLabels = _ ; } } , rotateLabels : { "get" : ( ) { return rotateLabels ; } , "set" : ( _ ) { rotateLabels = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; heatMap . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , alignYAxis : { "get" : ( ) { return alignYAxis ; } , "set" : ( _ ) { alignYAxis = _ ; yAxis . orient ( _ ) ; } } , alignXAxis : { "get" : ( ) { return alignXAxis ; } , "set" : ( _ ) { alignXAxis = _ ; xAxis . orient ( _ ) ; } } ) ; nv . utils . inheritOptions ( chart , heatMap ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 //TODO: consider deprecating and using multibar with single series for this
 nv . models . historicalBar = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = null , height = null , id = Math . floor ( Math . random ( ) * 10000 ) , container = null , x = d3 . scale . linear ( ) , y = d3 . scale . linear ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , forceX = [ ] , forceY = [ 0 ] , padData = false , clipEdge = true , color = nv . utils . defaultColor ( ) , xDomain , yDomain , xRange , yRange , dispatch = d3 . dispatch ( "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) , interactive = true ; var renderWatch = nv . utils . renderWatch ( dispatch , 0 ) ; chart ( selection ) { selection . each ( ( data ) { renderWatch . reset ( ) ; container = d3 . select ( this ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; nv . utils . initSVG ( container ) ;
 // Setup Scales
 x . domain ( xDomain || d3 . extent ( data [ 0 ] . values . map ( getX ) . concat ( forceX ) ) ) ; if ( padData ) x . range ( xRange || [ availableWidth * .5 / data [ 0 ] . values . length , availableWidth * ( data [ 0 ] . values . length - .5 ) / data [ 0 ] . values . length ] ) ; else x . range ( xRange || [ 0 , availableWidth ] ) ; y . domain ( yDomain || d3 . extent ( data [ 0 ] . values . map ( getY ) . concat ( forceY ) ) ) . range ( yRange || [ availableHeight , 0 ] ) ;
 // If scale's domain don't have a range, slightly adjust to make one... so a chart can show a single data point
 if ( identical ( x . domain ( ) [ 0 ] , x . domain ( ) [ 1 ] ) ) x . domain ( ) [ 0 ] ? x . domain ( [ x . domain ( ) [ 0 ] - x . domain ( ) [ 0 ] * 0.01 , x . domain ( ) [ 1 ] + x . domain ( ) [ 1 ] * 0.01 ] ) : x . domain ( [ - 1 , 1 ] ) ; if ( identical ( y . domain ( ) [ 0 ] , y . domain ( ) [ 1 ] ) ) y . domain ( ) [ 0 ] ? y . domain ( [ y . domain ( ) [ 0 ] + y . domain ( ) [ 0 ] * 0.01 , y . domain ( ) [ 1 ] - y . domain ( ) [ 1 ] * 0.01 ] ) : y . domain ( [ - 1 , 1 ] ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-historicalBar-" + id ) . data ( [ data [ 0 ] . values ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-historicalBar-" + id ) ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-bars" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; container . on ( "click" , ( d , i ) { dispatch . chartClick ( data : d , index : i , pos : d3 . event , id : id ) ; } ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-chart-clip-path-" + id ) . append ( "rect" ) ; wrap . select ( "#nv-chart-clip-path-" + id + " rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; g . attr ( "clip-path" , clipEdge ? "url(#nv-chart-clip-path-" + id + ")" : "" ) ; var bars = wrap . select ( ".nv-bars" ) . selectAll ( ".nv-bar" ) . data ( ( d ) { return d ; } , ( d , i ) { return getX ( d , i ) ; } ) ; bars . exit ( ) . remove ( ) ; bars . enter ( ) . append ( "rect" ) . attr ( "x" , 0 ) . attr ( "y" , ( d , i ) { return nv . utils . NaNtoZero ( y ( Math . max ( 0 , getY ( d , i ) ) ) ) ; } ) . attr ( "height" , ( d , i ) { return nv . utils . NaNtoZero ( Math . abs ( y ( getY ( d , i ) ) - y ( 0 ) ) ) ; } ) . attr ( "transform" , ( d , i ) { return "translate(" + ( x ( getX ( d , i ) ) - availableWidth / data [ 0 ] . values . length * .45 ) + ",0)" ; } ) . on ( "mouseover" , ( d , i ) { if ( ! interactive ) return ; d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i ) { if ( ! interactive ) return ; d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mousemove" , ( d , i ) { if ( ! interactive ) return ; dispatch . elementMousemove ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "click" , ( d , i ) { if ( ! interactive ) return ; var element = this ; dispatch . elementClick ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) , event : d3 . event , element : element ) ; d3 . event . stopPropagation ( ) ; } ) . on ( "dblclick" , ( d , i ) { if ( ! interactive ) return ; dispatch . elementDblClick ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; d3 . event . stopPropagation ( ) ; } ) ; bars . attr ( "fill" , ( d , i ) { return color ( d , i ) ; } ) . attr ( "class" , ( d , i , j ) { return ( getY ( d , i ) < 0 ? "nv-bar negative" : "nv-bar positive" ) + " nv-bar-" + j + "-" + i ; } ) . watchTransition ( renderWatch , "bars" ) . attr ( "transform" , ( d , i ) { return "translate(" + ( x ( getX ( d , i ) ) - availableWidth / data [ 0 ] . values . length * .45 ) + ",0)" ; } ) . attr ( "width" , ( availableWidth / data [ 0 ] . values . length ) * .9 ) ; bars . watchTransition ( renderWatch , "bars" ) . attr ( "y" , ( d , i ) { var rval = getY ( d , i ) < 0 ? y ( 0 ) : y ( 0 ) - y ( getY ( d , i ) ) < 1 ? y ( 0 ) - 1 : y ( getY ( d , i ) ) ; return nv . utils . NaNtoZero ( rval ) ; } ) . attr ( "height" , ( d , i ) { return nv . utils . NaNtoZero ( Math . max ( Math . abs ( y ( getY ( d , i ) ) - y ( 0 ) ) , 1 ) ) ; } ) ; } ) ; renderWatch . renderEnd ( "historicalBar immediate" ) ; return chart ; }
 //Create methods to allow outside functions to highlight a specific bar.
 chart . highlightPoint = ( pointIndex , isHoverOver ) { container . select ( ".nv-bars .nv-bar-0-" + pointIndex ) . classed ( "hover" , isHoverOver ) ; } ; chart . clearHighlights = ( ) { container . select ( ".nv-bars .nv-bar.hover" ) . classed ( "hover" , false ) ; } ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , forceX : { "get" : ( ) { return forceX ; } , "set" : ( _ ) { forceX = _ ; } } , forceY : { "get" : ( ) { return forceY ; } , "set" : ( _ ) { forceY = _ ; } } , padData : { "get" : ( ) { return padData ; } , "set" : ( _ ) { padData = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , clipEdge : { "get" : ( ) { return clipEdge ; } , "set" : ( _ ) { clipEdge = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , interactive : { "get" : ( ) { return interactive ; } , "set" : ( _ ) { interactive = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . historicalBarChart = ( bar_model ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var bars = bar_model || nv . models . historicalBar ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , legend = nv . models . legend ( ) , interactiveLayer = nv . interactiveGuideline ( ) , tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 90 , "bottom" : 50 , "left" : 90 } , marginTop = null , color = nv . utils . defaultColor ( ) , width = null , height = null , showLegend = false , showXAxis = true , showYAxis = true , rightAlignYAxis = false , useInteractiveGuideline = false , x , y , state = { } , defaultState = null , noData = null , dispatch = d3 . dispatch ( "tooltipHide" , "stateChange" , "changeState" , "renderEnd" ) , transitionDuration = 250 ; xAxis . orient ( "bottom" ) . tickPadding ( 7 ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) ; tooltip . duration ( 0 ) . headerEnabled ( false ) . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch , 0 ) ; chart ( selection ) { selection . each ( ( data ) { renderWatch . reset ( ) ; renderWatch . models ( bars ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { container . transition ( ) . duration ( transitionDuration ) . call ( chart ) ; } ; chart . container = this ;
 //set state.disabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display noData message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = bars . xScale ( ) ; y = bars . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-historicalBarChart" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-historicalBarChart" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-barsWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-interactive" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { legend . width ( availableWidth ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } wrap . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) ; } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 //Set up interactive layer
 if ( useInteractiveGuideline ) { interactiveLayer . width ( availableWidth ) . height ( availableHeight ) . margin ( left : margin . left , top : margin . top ) . svgContainer ( container ) . xScale ( x ) ; wrap . select ( ".nv-interactive" ) . call ( interactiveLayer ) ; } bars . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; var barsWrap = g . select ( ".nv-barsWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ; barsWrap . transition ( ) . call ( bars ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) ; g . select ( ".nv-x.nv-axis" ) . transition ( ) . call ( xAxis ) ; } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-y.nv-axis" ) . transition ( ) . call ( yAxis ) ; }
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 interactiveLayer . dispatch . on ( "elementMousemove" , ( e ) { bars . clearHighlights ( ) ; var singlePoint , pointIndex , pointXLocation , allData = [ ] ; data . filter ( ( series , i ) { series . seriesIndex = i ; return ! series . disabled ; } ) . forEach ( ( series , i ) { pointIndex = nv . interactiveBisect ( series . values , e . pointXValue , chart . x ( ) ) ; bars . highlightPoint ( pointIndex , true ) ; var point = series . values [ pointIndex ] ; if ( identical ( point , undefined ) ) return ; if ( identical ( singlePoint , undefined ) ) singlePoint = point ; if ( identical ( pointXLocation , undefined ) ) pointXLocation = chart . xScale ( ) ( chart . x ( ) ( point , pointIndex ) ) ; allData . push ( key : series . key , value : chart . y ( ) ( point , pointIndex ) , color : color ( series , series . seriesIndex ) , data : series . values [ pointIndex ] ) ; } ) ; var xValue = xAxis . tickFormat ( ) ( chart . x ( ) ( singlePoint , pointIndex ) ) ; interactiveLayer . tooltip . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d ) ; } ) . data ( value : xValue , index : pointIndex , series : allData ) ( ) ; interactiveLayer . renderGuideLine ( pointXLocation ) ; } ) ; interactiveLayer . dispatch . on ( "elementMouseout" , ( e ) { dispatch . tooltipHide ( ) ; bars . clearHighlights ( ) ; } ) ; legend . dispatch . on ( "legendClick" , ( d , i ) { d . disabled = ! d . disabled ; if ( ! data . filter ( ( d ) { return ! d . disabled ; } ) . length ) { data . map ( ( d ) { d . disabled = false ; wrap . selectAll ( ".nv-series" ) . classed ( "disabled" , false ) ; return d ; } ) ; } state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; dispatch . stateChange ( state ) ; selection . transition ( ) . call ( chart ) ; } ) ; legend . dispatch . on ( "legendDblclick" , ( d ) {
 //Double clicking should always enable current series, and disabled all others.
 data . forEach ( ( d ) { d . disabled = true ; } ) ; d . disabled = false ; state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } chart . update ( ) ; } ) ; } ) ; renderWatch . renderEnd ( "historicalBarChart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 bars . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt [ "series" ] = { "key" : chart . x ( ) ( evt . data ) , "value" : chart . y ( ) ( evt . data ) , "color" : evt . color } ; tooltip . data ( evt ) . hidden ( false ) ; } ) ; bars . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; bars . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . bars = bars ; chart . legend = legend ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . interactiveLayer = interactiveLayer ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; bars . color ( color ) ; } } , duration : { "get" : ( ) { return transitionDuration ; } , "set" : ( _ ) { transitionDuration = _ ; renderWatch . reset ( transitionDuration ) ; yAxis . duration ( transitionDuration ) ; xAxis . duration ( transitionDuration ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( ( _ ) ? "right" : "left" ) ; } } , useInteractiveGuideline : { "get" : ( ) { return useInteractiveGuideline ; } , "set" : ( _ ) { useInteractiveGuideline = _ ; if ( identical ( _ , true ) ) { chart . interactive ( false ) ; } } } ) ; nv . utils . inheritOptions ( chart , bars ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 // ohlcChart is just a historical chart with ohlc bars and some tweaks
 nv . models . ohlcBarChart = ( ) { var chart = nv . models . historicalBarChart ( nv . models . ohlcBar ( ) ) ;
 // special default tooltip since we show multiple values per x
 chart . useInteractiveGuideline ( true ) ; chart . interactiveLayer . tooltip . contentGenerator ( ( data ) {
 // we assume only one series exists for this chart
 var d = data . series [ 0 ] . data ;
 // match line colors as defined in nv.d3.css
 var color = d . open < d . close ? "2ca02c" : "d62728" ; return "" + "<h3 style=\"color: #" + color + "\">" + data . value + "</h3>" + "<table>" + "<tr><td>open:</td><td>" + chart . yAxis . tickFormat ( ) ( d . open ) + "</td></tr>" + "<tr><td>close:</td><td>" + chart . yAxis . tickFormat ( ) ( d . close ) + "</td></tr>" + "<tr><td>high</td><td>" + chart . yAxis . tickFormat ( ) ( d . high ) + "</td></tr>" + "<tr><td>low:</td><td>" + chart . yAxis . tickFormat ( ) ( d . low ) + "</td></tr>" + "</table>" ; } ) ; return chart ; } ;
 // candlestickChart is just a historical chart with candlestick bars and some tweaks
 nv . models . candlestickBarChart = ( ) { var chart = nv . models . historicalBarChart ( nv . models . candlestickBar ( ) ) ;
 // special default tooltip since we show multiple values per x
 chart . useInteractiveGuideline ( true ) ; chart . interactiveLayer . tooltip . contentGenerator ( ( data ) {
 // we assume only one series exists for this chart
 var d = data . series [ 0 ] . data ;
 // match line colors as defined in nv.d3.css
 var color = d . open < d . close ? "2ca02c" : "d62728" ; return "" + "<h3 style=\"color: #" + color + "\">" + data . value + "</h3>" + "<table>" + "<tr><td>open:</td><td>" + chart . yAxis . tickFormat ( ) ( d . open ) + "</td></tr>" + "<tr><td>close:</td><td>" + chart . yAxis . tickFormat ( ) ( d . close ) + "</td></tr>" + "<tr><td>high</td><td>" + chart . yAxis . tickFormat ( ) ( d . high ) + "</td></tr>" + "<tr><td>low:</td><td>" + chart . yAxis . tickFormat ( ) ( d . low ) + "</td></tr>" + "</table>" ; } ) ; return chart ; } ; nv . models . legend = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 5 , "right" : 0 , "bottom" : 5 , "left" : 0 } , width = 400 , height = 20 , getKey = ( d ) { return d . key ; } , keyFormatter = ( d ) { return d ; } , color = nv . utils . getColor ( ) , maxKeyLength = 20 , align = true , padding = 32 , rightAlign = true , updateState = true , enableDoubleClick = true , radioButtonMode = false , expanded = false , dispatch = d3 . dispatch ( "legendClick" , "legendDblclick" , "legendMouseover" , "legendMouseout" , "stateChange" ) , vers = "classic" ; chart ( selection ) { selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-legend" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-legend" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; if ( rightAlign ) wrap . attr ( "transform" , "translate(" + ( - margin . right ) + "," + margin . top + ")" ) ; else wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var series = g . selectAll ( ".nv-series" ) . data ( ( d ) { if ( vers != "furious" ) return d ; return d . filter ( ( n ) { return expanded ? true : ! n . disengaged ; } ) ; } ) ; var seriesEnter = series . enter ( ) . append ( "g" ) . attr ( "class" , "nv-series" ) ; var seriesShape ; var versPadding ; switch ( vers ) { case "furious" : versPadding = 23 ; break ; case "classic" : versPadding = 20 ; } if ( vers == "classic" ) { seriesEnter . append ( "circle" ) . style ( "stroke-width" , 2 ) . attr ( "class" , "nv-legend-symbol" ) . attr ( "r" , 5 ) ; seriesShape = series . select ( ".nv-legend-symbol" ) ; } else if ( vers == "furious" ) { seriesEnter . append ( "rect" ) . style ( "stroke-width" , 2 ) . attr ( "class" , "nv-legend-symbol" ) . attr ( "rx" , 3 ) . attr ( "ry" , 3 ) ; seriesShape = series . select ( ".nv-legend-symbol" ) ; seriesEnter . append ( "g" ) . attr ( "class" , "nv-check-box" ) . property ( "innerHTML" , "<path d=\"M0.5,5 L22.5,5 L22.5,26.5 L0.5,26.5 L0.5,5 Z\" class=\"nv-box\"></path><path d=\"M5.5,12.8618467 L11.9185089,19.2803556 L31,0.198864511\" class=\"nv-check\"></path>" ) . attr ( "transform" , "translate(-10,-8)scale(0.5)" ) ; var seriesCheckbox = series . select ( ".nv-check-box" ) ; seriesCheckbox . each ( ( d , i ) { d3 . select ( this ) . selectAll ( "path" ) . attr ( "stroke" , setTextColor ( d , i ) ) ; } ) ; } seriesEnter . append ( "text" ) . attr ( "text-anchor" , "start" ) . attr ( "class" , "nv-legend-text" ) . attr ( "dy" , ".32em" ) . attr ( "dx" , "8" ) ; var seriesText = series . select ( "text.nv-legend-text" ) ; series . on ( "mouseover" , ( d , i ) { dispatch . legendMouseover ( d , i ) ; } ) . on ( "mouseout" , ( d , i ) { dispatch . legendMouseout ( d , i ) ; } ) . on ( "click" , ( d , i ) { dispatch . legendClick ( d , i ) ;
 // make sure we re-get data in case it was modified
 var data = series . data ( ) ; if ( updateState ) { if ( vers == "classic" ) { if ( radioButtonMode ) {
 //Radio button mode: set every series to disabled,

 //  and enable the clicked series.
 data . forEach ( ( series ) { series . disabled = true ; } ) ; d . disabled = false ; } else { d . disabled = ! d . disabled ; if ( data . every ( ( series ) { return series . disabled ; } ) ) {
 //the default behavior of NVD3 legends is, if every single series

 // is disabled, turn all series' back on.
 data . forEach ( ( series ) { series . disabled = false ; } ) ; } } } else if ( vers == "furious" ) { if ( expanded ) { d . disengaged = ! d . disengaged ; d . userDisabled = d . userDisabled == undefined ? ! ! d . disabled : d . userDisabled ; d . disabled = d . disengaged || d . userDisabled ; } else if ( ! expanded ) { d . disabled = ! d . disabled ; d . userDisabled = d . disabled ; var engaged = data . filter ( ( d ) { return ! d . disengaged ; } ) ; if ( engaged . every ( ( series ) { return series . userDisabled ; } ) ) {
 //the default behavior of NVD3 legends is, if every single series

 // is disabled, turn all series' back on.
 data . forEach ( ( series ) { series . disabled = series . userDisabled = false ; } ) ; } } } dispatch . stateChange ( disabled : data . map ( ( d ) { return ! ! d . disabled ; } ) , disengaged : data . map ( ( d ) { return ! ! d . disengaged ; } ) ) ; } } ) . on ( "dblclick" , ( d , i ) { if ( enableDoubleClick ) { if ( vers == "furious" && expanded ) return ; dispatch . legendDblclick ( d , i ) ; if ( updateState ) {
 // make sure we re-get data in case it was modified
 var data = series . data ( ) ;
 //the default behavior of NVD3 legends, when double clicking one,

 // is to set all other series' to false, and make the double clicked series enabled.
 data . forEach ( ( series ) { series . disabled = true ; if ( vers == "furious" ) series . userDisabled = series . disabled ; } ) ; d . disabled = false ; if ( vers == "furious" ) d . userDisabled = d . disabled ; dispatch . stateChange ( disabled : data . map ( ( d ) { return ! ! d . disabled ; } ) ) ; } } } ) ; series . classed ( "nv-disabled" , ( d ) { return d . userDisabled ; } ) ; series . exit ( ) . remove ( ) ; seriesText . attr ( "fill" , setTextColor ) . text ( ( d ) { return keyFormatter ( getKey ( d ) ) ; } ) ;
 //TODO: implement fixed-width and max-width options (max-width is especially useful with the align option)

 // NEW ALIGNING CODE, TODO: clean up
 var legendWidth = 0 ; if ( align ) { var seriesWidths = [ ] ; series . each ( ( d , i ) { var legendText ; if ( keyFormatter ( getKey ( d ) ) && keyFormatter ( getKey ( d ) ) . length > maxKeyLength ) { var trimmedKey = keyFormatter ( getKey ( d ) ) . substring ( 0 , maxKeyLength ) ; legendText = d3 . select ( this ) . select ( "text" ) . text ( trimmedKey + "..." ) ; d3 . select ( this ) . append ( "svg:title" ) . text ( keyFormatter ( getKey ( d ) ) ) ; } else { legendText = d3 . select ( this ) . select ( "text" ) ; } var nodeTextLength ; try { nodeTextLength = legendText . node ( ) . getComputedTextLength ( ) ;
 // If the legendText is display:none'd (nodeTextLength == 0), simulate an error so we approximate, instead
 if ( nodeTextLength <= 0 ) throw Error ( ) ; } catch ( e , e_stack ) { nodeTextLength = nv . utils . calcApproxTextWidth ( legendText ) ; } seriesWidths . push ( nodeTextLength + padding ) ; } ) ; var seriesPerRow = 0 ; var columnWidths = [ ] ; legendWidth = 0 ; while ( legendWidth < availableWidth && seriesPerRow < seriesWidths . length ) { columnWidths [ seriesPerRow ] = seriesWidths [ seriesPerRow ] ; legendWidth += seriesWidths [ seriesPerRow ++ ] ; } if ( identical ( seriesPerRow , 0 ) ) seriesPerRow = 1 ; while ( legendWidth > availableWidth && seriesPerRow > 1 ) { columnWidths = [ ] ; seriesPerRow -- ; for ( var k = 0 ; k < seriesWidths . length ; k ++ ) { if ( seriesWidths [ k ] > ( columnWidths [ k % seriesPerRow ] || 0 ) ) columnWidths [ k % seriesPerRow ] = seriesWidths [ k ] ; } legendWidth = columnWidths . reduce ( ( prev , cur , index , array ) { return prev + cur ; } ) ; } var xPositions = [ ] ; for ( var i = 0 , curX = 0 ; i < seriesPerRow ; i ++ ) { xPositions [ i ] = curX ; curX += columnWidths [ i ] ; } series . attr ( "transform" , ( d , i ) { return "translate(" + xPositions [ i % seriesPerRow ] + "," + ( 5 + Math . floor ( i / seriesPerRow ) * versPadding ) + ")" ; } ) ;
 //position legend as far right as possible within the total width
 if ( rightAlign ) { g . attr ( "transform" , "translate(" + ( width - margin . right - legendWidth ) + "," + margin . top + ")" ) ; } else { g . attr ( "transform" , "translate(0" + "," + margin . top + ")" ) ; } height = margin . top + margin . bottom + ( Math . ceil ( seriesWidths . length / seriesPerRow ) * versPadding ) ; } else { var ypos = 5 , newxpos = 5 , maxwidth = 0 , xpos ; series . attr ( "transform" , ( d , i ) { var length = d3 . select ( this ) . select ( "text" ) . node ( ) . getComputedTextLength ( ) + padding ; xpos = newxpos ; if ( width < margin . left + margin . right + xpos + length ) { newxpos = xpos = 5 ; ypos += versPadding ; } newxpos += length ; if ( newxpos > maxwidth ) maxwidth = newxpos ; if ( legendWidth < xpos + maxwidth ) { legendWidth = xpos + maxwidth ; } return "translate(" + xpos + "," + ypos + ")" ; } ) ;
 //position legend as far right as possible within the total width
 g . attr ( "transform" , "translate(" + ( width - margin . right - maxwidth ) + "," + margin . top + ")" ) ; height = margin . top + margin . bottom + ypos + 15 ; } if ( vers == "furious" ) {
 // Size rectangles after text is placed
 seriesShape . attr ( "width" , ( d , i ) { return seriesText [ 0 ] [ i ] . getComputedTextLength ( ) + 27 ; } ) . attr ( "height" , 18 ) . attr ( "y" , - 9 ) . attr ( "x" , - 15 ) ;
 // The background for the expanded legend (UI)
 gEnter . insert ( "rect" , ":first-child" ) . attr ( "class" , "nv-legend-bg" ) . attr ( "fill" , "#eee" ) . attr ( "opacity" , 0 ) ; var seriesBG = g . select ( ".nv-legend-bg" ) ; seriesBG . transition ( ) . duration ( 300 ) . attr ( "x" , - versPadding ) . attr ( "width" , legendWidth + versPadding - 12 ) . attr ( "height" , height + 10 ) . attr ( "y" , - margin . top - 10 ) . attr ( "opacity" , expanded ? 1 : 0 ) ; } seriesShape . style ( "fill" , setBGColor ) . style ( "fill-opacity" , setBGOpacity ) . style ( "stroke" , setBGColor ) ; } ) ; setTextColor ( d , i ) { if ( vers != "furious" ) return "#000" ; if ( expanded ) { return d . disengaged ? "#000" : "#fff" ; } else if ( ! expanded ) { if ( ! d . color ) d . color = color ( d , i ) ; return ! ! d . disabled ? d . color : "#fff" ; } } setBGColor ( d , i ) { if ( expanded && vers == "furious" ) { return d . disengaged ? "#eee" : d . color || color ( d , i ) ; } else { return d . color || color ( d , i ) ; } } setBGOpacity ( d , i ) { if ( expanded && vers == "furious" ) { return 1 ; } else { return ! ! d . disabled ? 0 : 1 ; } } return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , key : { "get" : ( ) { return getKey ; } , "set" : ( _ ) { getKey = _ ; } } , keyFormatter : { "get" : ( ) { return keyFormatter ; } , "set" : ( _ ) { keyFormatter = _ ; } } , align : { "get" : ( ) { return align ; } , "set" : ( _ ) { align = _ ; } } , maxKeyLength : { "get" : ( ) { return maxKeyLength ; } , "set" : ( _ ) { maxKeyLength = _ ; } } , rightAlign : { "get" : ( ) { return rightAlign ; } , "set" : ( _ ) { rightAlign = _ ; } } , padding : { "get" : ( ) { return padding ; } , "set" : ( _ ) { padding = _ ; } } , updateState : { "get" : ( ) { return updateState ; } , "set" : ( _ ) { updateState = _ ; } } , enableDoubleClick : { "get" : ( ) { return enableDoubleClick ; } , "set" : ( _ ) { enableDoubleClick = _ ; } } , radioButtonMode : { "get" : ( ) { return radioButtonMode ; } , "set" : ( _ ) { radioButtonMode = _ ; } } , expanded : { "get" : ( ) { return expanded ; } , "set" : ( _ ) { expanded = _ ; } } , vers : { "get" : ( ) { return vers ; } , "set" : ( _ ) { vers = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . line = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var scatter = nv . models . scatter ( ) ; var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , container = null , strokeWidth = 1.5 , color = nv . utils . defaultColor ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , defined = ( d , i ) { return ! isNaN ( getY ( d , i ) ) && ! identical ( getY ( d , i ) , null ) ; } , isArea = ( d ) { return d . area ; } , clipEdge = false , x , y , interpolate = "linear" , curve = d3 . curveBasis , duration = 250 , dispatch = d3 . dispatch ( "elementClick" , "elementMouseover" , "elementMouseout" , "renderEnd" ) ; scatter . pointSize ( 16 ) . pointDomain ( [ 16 , 256 ] ) ;
 //============================================================

 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var x0 , y0 , renderWatch = nv . utils . renderWatch ( dispatch , duration ) ;
 //============================================================
 chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( scatter ) ; selection . each ( ( data ) { container = d3 . select ( this ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; nv . utils . initSVG ( container ) ;
 // Setup Scales
 x = scatter . xScale ( ) ; y = scatter . yScale ( ) ; x0 = x0 || x ; y0 = y0 || y ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-line" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-line" ) . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; var nvGroups = gEnter . append ( "g" ) . attr ( "class" , "nv-groups" ) ; var scatterWrap = gEnter . append ( "g" ) . attr ( "class" , "nv-scatterWrap" ) ; scatter . width ( availableWidth ) . height ( availableHeight ) ; scatterWrap . call ( scatter ) ; defsEnter . merge ( defsEnter ) . append ( "clipPath" ) . attr ( "id" , "nv-edge-clip-" + scatter . id ( ) ) . append ( "rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , ( availableHeight > 0 ) ? availableHeight : 0 ) ; gEnter . attr ( "clip-path" , clipEdge ? "url(#nv-edge-clip-" + scatter . id ( ) + ")" : "" ) ; scatterWrap . attr ( "clip-path" , clipEdge ? "url(#nv-edge-clip-" + scatter . id ( ) + ")" : "" ) ; var groups = nvGroups . selectAll ( ".nv-group" ) . data ( ( d ) { return d ; } , ( d ) { return d . key ; } ) ; var groupsEntries = groups . enter ( ) . append ( "g" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "stroke-width" , ( d ) { return d . strokeWidth || strokeWidth ; } ) . style ( "fill-opacity" , 1e-6 ) ; groups . exit ( ) . remove ( ) ; groupsEntries . attr ( "class" , ( d , i ) { return ( d . classed || "" ) + " nv-group nv-series-" + i ; } ) . classed ( "hover" , ( d ) { return d . hover ; } ) . style ( "fill" , ( d , i ) { return color ( d , i ) ; } ) . style ( "stroke" , ( d , i ) { return color ( d , i ) ; } ) ; groupsEntries . watchTransition ( renderWatch , "line: groups" ) . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , ( d ) { return d . fillOpacity || .5 ; } ) ; var areaPaths = groups . selectAll ( "path.nv-area" ) . data ( ( d ) { return isArea ( d ) ? [ d ] : [ ] ; } ) ; areaPaths . enter ( ) . append ( "path" ) . attr ( "class" , "nv-area" ) . attr ( "d" , ( d ) { return d3 . area ( ) . interpolate ( interpolate ) . defined ( defined ) . x ( ( d , i ) { return nv . utils . NaNtoZero ( x0 ( getX ( d , i ) ) ) ; } ) . y0 ( ( d , i ) { return nv . utils . NaNtoZero ( y0 ( getY ( d , i ) ) ) ; } ) . y1 ( ( d , i ) { return y0 ( y . domain ( ) [ 0 ] <= 0 ? y . domain ( ) [ 1 ] >= 0 ? 0 : y . domain ( ) [ 1 ] : y . domain ( ) [ 0 ] ) ; } ) . apply ( this , [ d . values ] ) ; } ) ; groups . exit ( ) . selectAll ( "path.nv-area" ) . remove ( ) ; areaPaths . watchTransition ( renderWatch , "line: areaPaths" ) . attr ( "d" , ( d ) { return d3 . area ( ) . interpolate ( interpolate ) . defined ( defined ) . x ( ( d , i ) { return nv . utils . NaNtoZero ( x ( getX ( d , i ) ) ) ; } ) . y0 ( ( d , i ) { return nv . utils . NaNtoZero ( y ( getY ( d , i ) ) ) ; } ) . y1 ( ( d , i ) { return y ( y . domain ( ) [ 0 ] <= 0 ? y . domain ( ) [ 1 ] >= 0 ? 0 : y . domain ( ) [ 1 ] : y . domain ( ) [ 0 ] ) ; } ) . apply ( this , [ d . values ] ) ; } ) ; var linePaths = groupsEntries . selectAll ( "path.nv-line" ) . data ( ( d ) { return [ d . values ] ; } ) ; linePaths . enter ( ) . append ( "path" ) . attr ( "class" , "nv-line" ) . attr ( "d" , d3 . line ( ) . curve ( curve ) . defined ( defined ) . x ( ( d , i ) { return nv . utils . NaNtoZero ( x0 ( getX ( d , i ) ) ) ; } ) . y ( ( d , i ) { return nv . utils . NaNtoZero ( y0 ( getY ( d , i ) ) ) ; } ) ) ; linePaths . watchTransition ( renderWatch , "line: linePaths" ) . attr ( "d" , d3 . line ( ) . curve ( curve ) . defined ( defined ) . x ( ( d , i ) { return nv . utils . NaNtoZero ( x ( getX ( d , i ) ) ) ; } ) . y ( ( d , i ) { return nv . utils . NaNtoZero ( y ( getY ( d , i ) ) ) ; } ) ) ;
 //store old scales for use in transitions on update
 x0 = x . copy ( ) ; y0 = y . copy ( ) ; } ) ; renderWatch . renderEnd ( "line immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . scatter = scatter ;
 // Pass through events
 scatter . dispatch . on ( "elementClick" , ( ) { dispatch . apply ( "elementClick" , this , arguments ) ; } ) ; scatter . dispatch . on ( "elementMouseover" , ( ) { dispatch . apply ( "elementMouseover" , this , arguments ) ; } ) ; scatter . dispatch . on ( "elementMouseout" , ( ) { dispatch . apply ( "elementMouseout" , this , arguments ) ; } ) ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , defined : { "get" : ( ) { return defined ; } , "set" : ( _ ) { defined = _ ; } } , interpolate : { "get" : ( ) { return interpolate ; } , "set" : ( _ ) { interpolate = _ ; } } , clipEdge : { "get" : ( ) { return clipEdge ; } , "set" : ( _ ) { clipEdge = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; scatter . duration ( duration ) ; } } , isArea : { "get" : ( ) { return isArea ; } , "set" : ( _ ) { isArea = d3 . functor ( _ ) ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; scatter . x ( _ ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; scatter . y ( _ ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; scatter . color ( color ) ; } } ) ; nv . utils . inheritOptions ( chart , scatter ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . lineChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var lines = nv . models . line ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , legend = nv . models . legend ( ) , interactiveLayer = nv . interactiveGuideline ( ) , tooltip = nv . models . tooltip ( ) , focus = nv . models . focus ( nv . models . line ( ) ) ; var margin = { "top" : 30 , "right" : 20 , "bottom" : 50 , "left" : 60 } , marginTop = null , color = nv . utils . defaultColor ( ) , width = null , height = null , showLegend = true , legendPosition = "top" , showXAxis = true , showYAxis = true , rightAlignYAxis = false , useInteractiveGuideline = false , x , y , focusEnable = false , state = nv . utils . state ( ) , defaultState = null , noData = null , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) , duration = 250 ;
 // set options on sub-objects for this chart
 xAxis . orient ( "bottom" ) . tickPadding ( 7 ) ; yAxis . orient ( rightAlignYAxis ? "right" : "left" ) ; lines . clipEdge ( true ) . duration ( 0 ) ; tooltip . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ; interactiveLayer . tooltip . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . active , undefined ) ) data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } ; } ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( lines ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) - ( focusEnable ? focus . height ( ) : 0 ) ; chart . update = ( ) { if ( identical ( duration , 0 ) ) { container . call ( chart ) ; } else { container . transition ( ) . duration ( duration ) . call ( chart ) ; } } ; chart . container = this ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 // DEPRECATED set state.disabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display noData message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 /* Update `main' graph on brush update. */
 focus . dispatch . on ( "onBrush" , ( extent ) { onBrush ( extent ) ; } ) ;
 // Setup Scales
 x = lines . xScale ( ) ; y = lines . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-lineChart" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-lineChart" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; var focusEnter = gEnter . append ( "g" ) . attr ( "class" , "nv-focus" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-background" ) . append ( "rect" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-linesWrap" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-interactive" ) ; var contextEnter = gEnter . append ( "g" ) . attr ( "class" , "nv-focusWrap" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { legend . width ( availableWidth ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( identical ( legendPosition , "bottom" ) ) { margin . bottom = xAxis . height ( ) + legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + ( availableHeight + xAxis . height ( ) ) + ")" ) ; } else if ( identical ( legendPosition , "top" ) ) { if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) - ( focusEnable ? focus . height ( ) : 0 ) ; } wrap . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) ; } } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 //Set up interactive layer
 if ( useInteractiveGuideline ) { interactiveLayer . width ( availableWidth ) . height ( availableHeight ) . margin ( left : margin . left , top : margin . top ) . svgContainer ( container ) . xScale ( x ) ; wrap . select ( ".nv-interactive" ) . call ( interactiveLayer ) ; } g . select ( ".nv-focus .nv-background rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; lines . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; var linesWrap = g . select ( ".nv-linesWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ;
 // Setup Main (Focus) Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; }
 //============================================================

 // Update Axes

 //============================================================
 updateXAxis ( ) { if ( showXAxis ) { g . select ( ".nv-focus .nv-x.nv-axis" ) . transition ( ) . duration ( duration ) . call ( xAxis ) ; } } updateYAxis ( ) { if ( showYAxis ) { g . select ( ".nv-focus .nv-y.nv-axis" ) . transition ( ) . duration ( duration ) . call ( yAxis ) ; } } g . select ( ".nv-focus .nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + availableHeight + ")" ) ;
 //============================================================

 // Update Focus

 //============================================================
 if ( ! focusEnable && identical ( focus . brush . extent ( ) , null ) ) { linesWrap . transition ( ) . call ( lines ) ; updateXAxis ( ) ; updateYAxis ( ) ; } else { focus . width ( availableWidth ) ; g . select ( ".nv-focusWrap" ) . style ( "display" , focusEnable ? "initial" : "none" ) . attr ( "transform" , "translate(0," + ( availableHeight + margin . bottom + focus . margin ( ) . top ) + ")" ) . call ( focus ) ; var extent = focus . brush . empty ( ) ? focus . xDomain ( ) : focus . brush . extent ( ) ; if ( ! identical ( extent , null ) ) { onBrush ( extent ) ; } }
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) state [ key ] = newState [ key ] ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; interactiveLayer . dispatch . on ( "elementMousemove" , ( e ) { lines . clearHighlights ( ) ; var singlePoint , pointIndex , pointXLocation , allData = [ ] ; data . filter ( ( series , i ) { series . seriesIndex = i ; return ! series . disabled && ! series . disableTooltip ; } ) . forEach ( ( series , i ) { var extent = ! identical ( focus . brush . extent ( ) , null ) ? ( focus . brush . empty ( ) ? focus . xScale ( ) . domain ( ) : focus . brush . extent ( ) ) : x . domain ( ) ; var currentValues = series . values . filter ( ( d , i ) {
 // Checks if the x point is between the extents, handling case where extent[0] is greater than extent[1]

 // (e.g. x domain is manually set to reverse the x-axis)
 if ( extent [ 0 ] <= extent [ 1 ] ) { return lines . x ( ) ( d , i ) >= extent [ 0 ] && lines . x ( ) ( d , i ) <= extent [ 1 ] ; } else { return lines . x ( ) ( d , i ) >= extent [ 1 ] && lines . x ( ) ( d , i ) <= extent [ 0 ] ; } } ) ; if ( currentValues . length > 0 ) { pointIndex = nv . interactiveBisect ( currentValues , e . pointXValue , lines . x ( ) ) ; var point = currentValues [ pointIndex ] ; var pointYValue = chart . y ( ) ( point , pointIndex ) ; if ( ! identical ( pointYValue , null ) ) { lines . highlightPoint ( i , series . values . indexOf ( point ) , true ) ; } if ( identical ( point , undefined ) ) return ; if ( identical ( singlePoint , undefined ) ) singlePoint = point ; if ( identical ( pointXLocation , undefined ) ) pointXLocation = chart . xScale ( ) ( chart . x ( ) ( point , pointIndex ) ) ; allData . push ( key : series . key , value : pointYValue , color : color ( series , series . seriesIndex ) , data : point ) ; } } ) ;
 //Highlight the tooltip entry based on which point the mouse is closest to.
 if ( allData . length > 2 ) { var yValue = chart . yScale ( ) . invert ( e . mouseY ) ; var domainExtent = Math . abs ( chart . yScale ( ) . domain ( ) [ 0 ] - chart . yScale ( ) . domain ( ) [ 1 ] ) ; var threshold = 0.03 * domainExtent ; var indexToHighlight = nv . nearestValueIndex ( allData . map ( ( d ) { return d . value ; } ) , yValue , threshold ) ; if ( ! identical ( indexToHighlight , null ) ) allData [ indexToHighlight ] . highlight = true ; } var defaultValueFormatter = ( d , i ) { return d == null ? "N/A" : yAxis . tickFormat ( ) ( d ) ; } ; if ( ! identical ( , "undefined" ) ) { interactiveLayer . tooltip . valueFormatter ( interactiveLayer . tooltip . valueFormatter ( ) || defaultValueFormatter ) . data ( value : chart . x ( ) ( singlePoint , pointIndex ) , index : pointIndex , series : allData ) ( ) ; interactiveLayer . renderGuideLine ( pointXLocation ) ; } } ) ; interactiveLayer . dispatch . on ( "elementClick" , ( e ) { var pointXLocation , allData = [ ] ; data . filter ( ( series , i ) { series . seriesIndex = i ; return ! series . disabled ; } ) . forEach ( ( series ) { var pointIndex = nv . interactiveBisect ( series . values , e . pointXValue , chart . x ( ) ) ; var point = series . values [ pointIndex ] ; if ( identical ( , "undefined" ) ) return ; if ( identical ( , "undefined" ) ) pointXLocation = chart . xScale ( ) ( chart . x ( ) ( point , pointIndex ) ) ; var yPos = chart . yScale ( ) ( chart . y ( ) ( point , pointIndex ) ) ; allData . push ( point : point , pointIndex : pointIndex , pos : [ pointXLocation , yPos ] , seriesIndex : series . seriesIndex , series : series ) ; } ) ; lines . dispatch . elementClick ( allData ) ; } ) ; interactiveLayer . dispatch . on ( "elementMouseout" , ( e ) { lines . clearHighlights ( ) ; } ) ; dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) && identical ( data . length , e . disabled . length ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } chart . update ( ) ; } ) ;
 //============================================================

 // Functions

 //------------------------------------------------------------

 // Taken from crossfilter (http://square.github.com/crossfilter/)
 resizePath ( d ) { var e = + ( d == "e" ) , x = e ? 1 : - 1 , y = availableHeight / 3 ; return "M" + ( 0.5 * x ) + "," + y + "A6,6 0 0 " + e + " " + ( 6.5 * x ) + "," + ( y + 6 ) + "V" + ( 2 * y - 6 ) + "A6,6 0 0 " + e + " " + ( 0.5 * x ) + "," + ( 2 * y ) + "Z" + "M" + ( 2.5 * x ) + "," + ( y + 8 ) + "V" + ( 2 * y - 8 ) + "M" + ( 4.5 * x ) + "," + ( y + 8 ) + "V" + ( 2 * y - 8 ) ; } onBrush ( extent ) {
 // Update Main (Focus)
 var focusLinesWrap = g . select ( ".nv-focus .nv-linesWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) . map ( ( d , i ) { return { "key" : d . key , "area" : d . area , "classed" : d . classed , "values" : d . values . filter ( ( d , i ) { return lines . x ( ) ( d , i ) >= extent [ 0 ] && lines . x ( ) ( d , i ) <= extent [ 1 ] ; } ) , "disableTooltip" : d . disableTooltip } ; } ) ) ; focusLinesWrap . transition ( ) . duration ( duration ) . call ( lines ) ;
 // Update Main (Focus) Axes
 updateXAxis ( ) ; updateYAxis ( ) ; } } ) ; renderWatch . renderEnd ( "lineChart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 lines . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { if ( ! evt . series . disableTooltip ) { tooltip . data ( evt ) . hidden ( false ) ; } } ) ; lines . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . lines = lines ; chart . legend = legend ; chart . focus = focus ; chart . xAxis = xAxis ; chart . x2Axis = focus . xAxis ; chart . yAxis = yAxis ; chart . y2Axis = focus . yAxis ; chart . interactiveLayer = interactiveLayer ; chart . tooltip = tooltip ; chart . state = state ; chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , legendPosition : { "get" : ( ) { return legendPosition ; } , "set" : ( _ ) { legendPosition = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , focusEnable : { "get" : ( ) { return focusEnable ; } , "set" : ( _ ) { focusEnable = _ ; } } , focusHeight : { "get" : ( ) { return focus . height ( ) ; } , "set" : ( _ ) { focus . height ( _ ) ; } } , focusShowAxisX : { "get" : ( ) { return focus . showXAxis ( ) ; } , "set" : ( _ ) { focus . showXAxis ( _ ) ; } } , focusShowAxisY : { "get" : ( ) { return focus . showYAxis ( ) ; } , "set" : ( _ ) { focus . showYAxis ( _ ) ; } } , brushExtent : { "get" : ( ) { return focus . brushExtent ( ) ; } , "set" : ( _ ) { focus . brushExtent ( _ ) ; } } , focusMargin : { "get" : ( ) { return focus . margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } focus . margin . right = ! identical ( _ . right , undefined ) ? _ . right : focus . margin . right ; focus . margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : focus . margin . bottom ; focus . margin . left = ! identical ( _ . left , undefined ) ? _ . left : focus . margin . left ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; lines . duration ( duration ) ; focus . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; lines . color ( color ) ; focus . color ( color ) ; } } , interpolate : { "get" : ( ) { return lines . interpolate ( ) ; } , "set" : ( _ ) { lines . interpolate ( _ ) ; focus . interpolate ( _ ) ; } } , xTickFormat : { "get" : ( ) { return xAxis . tickFormat ( ) ; } , "set" : ( _ ) { xAxis . tickFormat ( _ ) ; focus . xTickFormat ( _ ) ; } } , yTickFormat : { "get" : ( ) { return yAxis . tickFormat ( ) ; } , "set" : ( _ ) { yAxis . tickFormat ( _ ) ; focus . yTickFormat ( _ ) ; } } , x : { "get" : ( ) { return lines . x ( ) ; } , "set" : ( _ ) { lines . x ( _ ) ; focus . x ( _ ) ; } } , y : { "get" : ( ) { return lines . y ( ) ; } , "set" : ( _ ) { lines . y ( _ ) ; focus . y ( _ ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( rightAlignYAxis ? "right" : "left" ) ; } } , useInteractiveGuideline : { "get" : ( ) { return useInteractiveGuideline ; } , "set" : ( _ ) { useInteractiveGuideline = _ ; if ( useInteractiveGuideline ) { lines . interactive ( false ) ; lines . useVoronoi ( false ) ; } } } ) ; nv . utils . inheritOptions ( chart , lines ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . lineWithFocusChart = ( ) { return nv . models . lineChart ( ) . margin ( bottom : 30 ) . focusEnable ( true ) ; } ; nv . models . linePlusBarChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var lines = nv . models . line ( ) , lines2 = nv . models . line ( ) , bars = nv . models . historicalBar ( ) , bars2 = nv . models . historicalBar ( ) , xAxis = nv . models . axis ( ) , x2Axis = nv . models . axis ( ) , y1Axis = nv . models . axis ( ) , y2Axis = nv . models . axis ( ) , y3Axis = nv . models . axis ( ) , y4Axis = nv . models . axis ( ) , legend = nv . models . legend ( ) , brush = d3 . svg . brush ( ) , tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 30 , "bottom" : 30 , "left" : 60 } , marginTop = null , margin2 = { "top" : 0 , "right" : 30 , "bottom" : 20 , "left" : 60 } , width = null , height = null , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , color = nv . utils . defaultColor ( ) , showLegend = true , focusEnable = true , focusShowAxisY = false , focusShowAxisX = true , focusHeight = 50 , extent , brushExtent = null , x , x2 , y1 , y2 , y3 , y4 , noData = null , dispatch = d3 . dispatch ( "brush" , "stateChange" , "changeState" ) , transitionDuration = 0 , state = nv . utils . state ( ) , defaultState = null , legendLeftAxisHint = " (left axis)" , legendRightAxisHint = " (right axis)" , switchYAxisOrder = false ; lines . clipEdge ( true ) ; lines2 . interactive ( false ) ;
 // We don't want any points emitted for the focus chart's scatter graph.
 lines2 . pointActive ( ( d ) { return false ; } ) ; xAxis . orient ( "bottom" ) . tickPadding ( 5 ) ; y1Axis . orient ( "left" ) ; y2Axis . orient ( "right" ) ; x2Axis . orient ( "bottom" ) . tickPadding ( 5 ) ; y3Axis . orient ( "left" ) ; y4Axis . orient ( "right" ) ; tooltip . headerEnabled ( true ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var getBarsAxis = ( ) { return switchYAxisOrder ? { "main" : y2Axis , "focus" : y4Axis } : { "main" : y1Axis , "focus" : y3Axis } ; } ; var getLinesAxis = ( ) { return switchYAxisOrder ? { "main" : y1Axis , "focus" : y3Axis } : { "main" : y2Axis , "focus" : y4Axis } ; } ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . active , undefined ) ) data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } ; } ; var allDisabled = ( data ) { return data . every ( ( series ) { return series . disabled ; } ) ; } ; chart ( selection ) { selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight1 = nv . utils . availableHeight ( height , container , margin ) - ( focusEnable ? focusHeight : 0 ) , availableHeight2 = focusHeight - margin2 . top - margin2 . bottom ; chart . update = ( ) { container . transition ( ) . duration ( transitionDuration ) . call ( chart ) ; } ; chart . container = this ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 // DEPRECATED set state.disableddisabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 var dataBars = data . filter ( ( d ) { return ! d . disabled && d . bar ; } ) ; var dataLines = data . filter ( ( d ) { return ! d . bar ; } ) ; if ( dataBars . length && ! switchYAxisOrder ) { x = bars . xScale ( ) ; } else { x = lines . xScale ( ) ; } x2 = x2Axis . scale ( ) ;
 // select the scales and series based on the position of the yAxis
 y1 = switchYAxisOrder ? lines . yScale ( ) : bars . yScale ( ) ; y2 = switchYAxisOrder ? bars . yScale ( ) : lines . yScale ( ) ; y3 = switchYAxisOrder ? lines2 . yScale ( ) : bars2 . yScale ( ) ; y4 = switchYAxisOrder ? bars2 . yScale ( ) : lines2 . yScale ( ) ; var series1 = data . filter ( ( d ) { return ! d . disabled && ( switchYAxisOrder ? ! d . bar : d . bar ) ; } ) . map ( ( d ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d , i ) , "y" : getY ( d , i ) } ; } ) ; } ) ; var series2 = data . filter ( ( d ) { return ! d . disabled && ( switchYAxisOrder ? d . bar : ! d . bar ) ; } ) . map ( ( d ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d , i ) , "y" : getY ( d , i ) } ; } ) ; } ) ; x . range ( [ 0 , availableWidth ] ) ; x2 . domain ( d3 . extent ( d3 . merge ( series1 . concat ( series2 ) ) , ( d ) { return d . x ; } ) ) . range ( [ 0 , availableWidth ] ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-linePlusBar" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-linePlusBar" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ;
 // this is the main chart
 var focusEnter = gEnter . append ( "g" ) . attr ( "class" , "nv-focus" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-y1 nv-axis" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-y2 nv-axis" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-barsWrap" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-linesWrap" ) ;
 // context chart is where you can focus in
 var contextEnter = gEnter . append ( "g" ) . attr ( "class" , "nv-context" ) ; contextEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; contextEnter . append ( "g" ) . attr ( "class" , "nv-y1 nv-axis" ) ; contextEnter . append ( "g" ) . attr ( "class" , "nv-y2 nv-axis" ) ; contextEnter . append ( "g" ) . attr ( "class" , "nv-barsWrap" ) ; contextEnter . append ( "g" ) . attr ( "class" , "nv-linesWrap" ) ; contextEnter . append ( "g" ) . attr ( "class" , "nv-brushBackground" ) ; contextEnter . append ( "g" ) . attr ( "class" , "nv-x nv-brush" ) ;
 //============================================================

 // Legend

 //------------------------------------------------------------
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var legendWidth = legend . align ( ) ? availableWidth / 2 : availableWidth ; var legendXPosition = legend . align ( ) ? legendWidth : 0 ; legend . width ( legendWidth ) ; g . select ( ".nv-legendWrap" ) . datum ( data . map ( ( series ) { series . originalKey = identical ( series . originalKey , undefined ) ? series . key : series . originalKey ; if ( switchYAxisOrder ) { series . key = series . originalKey + ( series . bar ? legendRightAxisHint : legendLeftAxisHint ) ; } else { series . key = series . originalKey + ( series . bar ? legendLeftAxisHint : legendRightAxisHint ) ; } return series ; } ) ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ;
 // FIXME: shouldn't this be "- (focusEnabled ? focusHeight : 0)"?
 availableHeight1 = nv . utils . availableHeight ( height , container , margin ) - focusHeight ; } g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(" + legendXPosition + "," + ( - margin . top ) + ")" ) ; } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 //============================================================

 // Context chart (focus chart) components

 //------------------------------------------------------------

 // hide or show the focus context chart
 g . select ( ".nv-context" ) . style ( "display" , focusEnable ? "initial" : "none" ) ; bars2 . width ( availableWidth ) . height ( availableHeight2 ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . bar ; } ) ) ; lines2 . width ( availableWidth ) . height ( availableHeight2 ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled && ! data [ i ] . bar ; } ) ) ; var bars2Wrap = g . select ( ".nv-context .nv-barsWrap" ) . datum ( dataBars . length ? dataBars : [ { "values" : [ ] } ] ) ; var lines2Wrap = g . select ( ".nv-context .nv-linesWrap" ) . datum ( allDisabled ( dataLines ) ? [ { "values" : [ ] } ] : dataLines . filter ( ( dataLine ) { return ! dataLine . disabled ; } ) ) ; g . select ( ".nv-context" ) . attr ( "transform" , "translate(0," + ( availableHeight1 + margin . bottom + margin2 . top ) + ")" ) ; bars2Wrap . transition ( ) . call ( bars2 ) ; lines2Wrap . transition ( ) . call ( lines2 ) ;
 // context (focus chart) axis controls
 if ( focusShowAxisX ) { x2Axis . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight2 , 0 ) ; g . select ( ".nv-context .nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y3 . range ( ) [ 0 ] + ")" ) ; g . select ( ".nv-context .nv-x.nv-axis" ) . transition ( ) . call ( x2Axis ) ; } if ( focusShowAxisY ) { y3Axis . scale ( y3 ) . _ticks ( availableHeight2 / 36 ) . tickSize ( - availableWidth , 0 ) ; y4Axis . scale ( y4 ) . _ticks ( availableHeight2 / 36 ) . tickSize ( dataBars . length ? 0 : - availableWidth , 0 ) ; g . select ( ".nv-context .nv-y3.nv-axis" ) . style ( "opacity" , dataBars . length ? 1 : 0 ) . attr ( "transform" , "translate(0," + x2 . range ( ) [ 0 ] + ")" ) ; g . select ( ".nv-context .nv-y2.nv-axis" ) . style ( "opacity" , dataLines . length ? 1 : 0 ) . attr ( "transform" , "translate(" + x2 . range ( ) [ 1 ] + ",0)" ) ; g . select ( ".nv-context .nv-y1.nv-axis" ) . transition ( ) . call ( y3Axis ) ; g . select ( ".nv-context .nv-y2.nv-axis" ) . transition ( ) . call ( y4Axis ) ; }
 // Setup Brush
 brush . x ( x2 ) . on ( "brush" , onBrush ) ; if ( brushExtent ) brush . extent ( brushExtent ) ; var brushBG = g . select ( ".nv-brushBackground" ) . selectAll ( "g" ) . data ( [ brushExtent || brush . extent ( ) ] ) ; var brushBGenter = brushBG . enter ( ) . append ( "g" ) ; brushBGenter . append ( "rect" ) . attr ( "class" , "left" ) . attr ( "x" , 0 ) . attr ( "y" , 0 ) . attr ( "height" , availableHeight2 ) ; brushBGenter . append ( "rect" ) . attr ( "class" , "right" ) . attr ( "x" , 0 ) . attr ( "y" , 0 ) . attr ( "height" , availableHeight2 ) ; var gBrush = g . select ( ".nv-x.nv-brush" ) . call ( brush ) ; gBrush . selectAll ( "rect" ) . attr ( "height" , availableHeight2 ) ; gBrush . selectAll ( ".resize" ) . append ( "path" ) . attr ( "d" , resizePath ) ;
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) state [ key ] = newState [ key ] ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } chart . update ( ) ; } ) ;
 //============================================================

 // Functions

 //------------------------------------------------------------

 // Taken from crossfilter (http://square.github.com/crossfilter/)
 resizePath ( d ) { var e = + ( d == "e" ) , x = e ? 1 : - 1 , y = availableHeight2 / 3 ; return "M" + ( .5 * x ) + "," + y + "A6,6 0 0 " + e + " " + ( 6.5 * x ) + "," + ( y + 6 ) + "V" + ( 2 * y - 6 ) + "A6,6 0 0 " + e + " " + ( .5 * x ) + "," + ( 2 * y ) + "Z" + "M" + ( 2.5 * x ) + "," + ( y + 8 ) + "V" + ( 2 * y - 8 ) + "M" + ( 4.5 * x ) + "," + ( y + 8 ) + "V" + ( 2 * y - 8 ) ; } updateBrushBG ( ) { if ( ! brush . empty ( ) ) brush . extent ( brushExtent ) ; brushBG . data ( [ brush . empty ( ) ? x2 . domain ( ) : brushExtent ] ) . each ( ( d , i ) { var leftWidth = x2 ( d [ 0 ] ) - x2 . range ( ) [ 0 ] , rightWidth = x2 . range ( ) [ 1 ] - x2 ( d [ 1 ] ) ; d3 . select ( this ) . select ( ".left" ) . attr ( "width" , leftWidth < 0 ? 0 : leftWidth ) ; d3 . select ( this ) . select ( ".right" ) . attr ( "x" , x2 ( d [ 1 ] ) ) . attr ( "width" , rightWidth < 0 ? 0 : rightWidth ) ; } ) ; } onBrush ( ) { brushExtent = brush . empty ( ) ? null : brush . extent ( ) ; extent = brush . empty ( ) ? x2 . domain ( ) : brush . extent ( ) ; dispatch . brush ( extent : extent , brush : brush ) ; updateBrushBG ( ) ;
 // Prepare Main (Focus) Bars and Lines
 bars . width ( availableWidth ) . height ( availableHeight1 ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . bar ; } ) ) ; lines . width ( availableWidth ) . height ( availableHeight1 ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled && ! data [ i ] . bar ; } ) ) ; var focusBarsWrap = g . select ( ".nv-focus .nv-barsWrap" ) . datum ( ! dataBars . length ? [ { "values" : [ ] } ] : dataBars . map ( ( d , i ) { return { "key" : d . key , "values" : d . values . filter ( ( d , i ) { return bars . x ( ) ( d , i ) >= extent [ 0 ] && bars . x ( ) ( d , i ) <= extent [ 1 ] ; } ) } ; } ) ) ; var focusLinesWrap = g . select ( ".nv-focus .nv-linesWrap" ) . datum ( allDisabled ( dataLines ) ? [ { "values" : [ ] } ] : dataLines . filter ( ( dataLine ) { return ! dataLine . disabled ; } ) . map ( ( d , i ) { return { "area" : d . area , "fillOpacity" : d . fillOpacity , "strokeWidth" : d . strokeWidth , "key" : d . key , "values" : d . values . filter ( ( d , i ) { return lines . x ( ) ( d , i ) >= extent [ 0 ] && lines . x ( ) ( d , i ) <= extent [ 1 ] ; } ) } ; } ) ) ;
 // Update Main (Focus) X Axis
 if ( dataBars . length && ! switchYAxisOrder ) { x = bars . xScale ( ) ; } else { x = lines . xScale ( ) ; } xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight1 , 0 ) ; xAxis . domain ( [ Math . ceil ( extent [ 0 ] ) , Math . floor ( extent [ 1 ] ) ] ) ; g . select ( ".nv-x.nv-axis" ) . transition ( ) . duration ( transitionDuration ) . call ( xAxis ) ;
 // Update Main (Focus) Bars and Lines
 focusBarsWrap . transition ( ) . duration ( transitionDuration ) . call ( bars ) ; focusLinesWrap . transition ( ) . duration ( transitionDuration ) . call ( lines ) ;
 // Setup and Update Main (Focus) Y Axes
 g . select ( ".nv-focus .nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y1 . range ( ) [ 0 ] + ")" ) ; y1Axis . scale ( y1 ) . _ticks ( nv . utils . calcTicksY ( availableHeight1 / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; y2Axis . scale ( y2 ) . _ticks ( nv . utils . calcTicksY ( availableHeight1 / 36 , data ) ) ;
 // Show the y2 rules only if y1 has none
 if ( ! switchYAxisOrder ) { y2Axis . tickSize ( dataBars . length ? 0 : - availableWidth , 0 ) ; } else { y2Axis . tickSize ( dataLines . length ? 0 : - availableWidth , 0 ) ; }
 // Calculate opacity of the axis
 var barsOpacity = dataBars . length ? 1 : 0 ; var linesOpacity = dataLines . length && ! allDisabled ( dataLines ) ? 1 : 0 ; var y1Opacity = switchYAxisOrder ? linesOpacity : barsOpacity ; var y2Opacity = switchYAxisOrder ? barsOpacity : linesOpacity ; g . select ( ".nv-focus .nv-y1.nv-axis" ) . style ( "opacity" , y1Opacity ) ; g . select ( ".nv-focus .nv-y2.nv-axis" ) . style ( "opacity" , y2Opacity ) . attr ( "transform" , "translate(" + x . range ( ) [ 1 ] + ",0)" ) ; g . select ( ".nv-focus .nv-y1.nv-axis" ) . transition ( ) . duration ( transitionDuration ) . call ( y1Axis ) ; g . select ( ".nv-focus .nv-y2.nv-axis" ) . transition ( ) . duration ( transitionDuration ) . call ( y2Axis ) ; } onBrush ( ) ; } ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 lines . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { tooltip . duration ( 100 ) . valueFormatter ( ( d , i ) { return getLinesAxis ( ) . main . tickFormat ( ) ( d , i ) ; } ) . data ( evt ) . hidden ( false ) ; } ) ; lines . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; bars . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt . value = chart . x ( ) ( evt . data ) ; evt [ "series" ] = { "value" : chart . y ( ) ( evt . data ) , "color" : evt . color } ; tooltip . duration ( 0 ) . valueFormatter ( ( d , i ) { return getBarsAxis ( ) . main . tickFormat ( ) ( d , i ) ; } ) . data ( evt ) . hidden ( false ) ; } ) ; bars . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; bars . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . legend = legend ; chart . lines = lines ; chart . lines2 = lines2 ; chart . bars = bars ; chart . bars2 = bars2 ; chart . xAxis = xAxis ; chart . x2Axis = x2Axis ; chart . y1Axis = y1Axis ; chart . y2Axis = y2Axis ; chart . y3Axis = y3Axis ; chart . y4Axis = y4Axis ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , brushExtent : { "get" : ( ) { return brushExtent ; } , "set" : ( _ ) { brushExtent = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , focusEnable : { "get" : ( ) { return focusEnable ; } , "set" : ( _ ) { focusEnable = _ ; } } , focusHeight : { "get" : ( ) { return focusHeight ; } , "set" : ( _ ) { focusHeight = _ ; } } , focusShowAxisX : { "get" : ( ) { return focusShowAxisX ; } , "set" : ( _ ) { focusShowAxisX = _ ; } } , focusShowAxisY : { "get" : ( ) { return focusShowAxisY ; } , "set" : ( _ ) { focusShowAxisY = _ ; } } , legendLeftAxisHint : { "get" : ( ) { return legendLeftAxisHint ; } , "set" : ( _ ) { legendLeftAxisHint = _ ; } } , legendRightAxisHint : { "get" : ( ) { return legendRightAxisHint ; } , "set" : ( _ ) { legendRightAxisHint = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , focusMargin : { "get" : ( ) { return margin2 ; } , "set" : ( _ ) { margin2 . top = ! identical ( _ . top , undefined ) ? _ . top : margin2 . top ; margin2 . right = ! identical ( _ . right , undefined ) ? _ . right : margin2 . right ; margin2 . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin2 . bottom ; margin2 . left = ! identical ( _ . left , undefined ) ? _ . left : margin2 . left ; } } , duration : { "get" : ( ) { return transitionDuration ; } , "set" : ( _ ) { transitionDuration = _ ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; lines . x ( _ ) ; lines2 . x ( _ ) ; bars . x ( _ ) ; bars2 . x ( _ ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; lines . y ( _ ) ; lines2 . y ( _ ) ; bars . y ( _ ) ; bars2 . y ( _ ) ; } } , switchYAxisOrder : { "get" : ( ) { return switchYAxisOrder ; } , "set" : ( _ ) {
 // Switch the tick format for the yAxis
 if ( ! identical ( switchYAxisOrder , _ ) ) { var y1 = y1Axis ; y1Axis = y2Axis ; y2Axis = y1 ; var y3 = y3Axis ; y3Axis = y4Axis ; y4Axis = y3 ; } switchYAxisOrder = _ ; y1Axis . orient ( "left" ) ; y2Axis . orient ( "right" ) ; y3Axis . orient ( "left" ) ; y4Axis . orient ( "right" ) ; } } ) ; nv . utils . inheritOptions ( chart , lines ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . multiBar = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , x = d3 . scale . ordinal ( ) , y = d3 . scale . linear ( ) , id = Math . floor ( Math . random ( ) * 10000 ) , container = null , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , forceY = [ 0 ] , clipEdge = true , stacked = false , stackOffset = "zero" , color = nv . utils . defaultColor ( ) , hideable = false , barColor = null , disabled , duration = 500 , xDomain , yDomain , xRange , yRange , groupSpacing = 0.1 , fillOpacity = 0.75 , dispatch = d3 . dispatch ( "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var x0 , y0 , renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; var last_datalength = 0 ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var nonStackableCount = 0 ;
 // This function defines the requirements for render complete
 var endFn = ( d , i ) { if ( identical ( d . series , data . length - 1 ) && identical ( i , data [ 0 ] . values . length - 1 ) ) return true ; return false ; } ; if ( hideable && data . length ) hideable = [ { "values" : data [ 0 ] . values . map ( ( d ) { return { "x" : d . x , "y" : 0 , "series" : d . series , "size" : 0.01 } ; } ) } ] ; if ( stacked ) { var parsed = d3 . layout . stack ( ) . offset ( stackOffset ) . values ( ( d ) { return d . values ; } ) . y ( getY ) ( ! data . length && hideable ? hideable : data ) ; parsed . forEach ( ( series , i ) {
 // if series is non-stackable, use un-parsed data
 if ( series . nonStackable ) { data [ i ] . nonStackableSeries = nonStackableCount ++ ; parsed [ i ] = data [ i ] ; } else {
 // don't stack this seires on top of the nonStackable seriees
 if ( i > 0 && parsed [ i - 1 ] . nonStackable ) { parsed [ i ] . values . map ( ( d , j ) { d . y0 -= parsed [ i - 1 ] . values [ j ] . y ; d . y1 = d . y0 + d . y ; } ) ; } } } ) ; data = parsed ; }
 //add series index and key to each data point for reference
 data . forEach ( ( series , i ) { series . values . forEach ( ( point ) { point . series = i ; point . key = series . key ; } ) ; } ) ;
 // HACK for negative value stacking
 if ( stacked && data . length > 0 ) { data [ 0 ] . values . map ( ( d , i ) { var posBase = 0 , negBase = 0 ; data . map ( ( d , idx ) { if ( ! data [ idx ] . nonStackable ) { var f = d . values [ i ] ; f . size = Math . abs ( f . y ) ; if ( f . y < 0 ) { f . y1 = negBase ; negBase = negBase - f . size ; } else { f . y1 = f . size + posBase ; posBase = posBase + f . size ; } } } ) ; } ) ; }
 // Setup Scales

 // remap and flatten the data for use in calculating the scales' domains
 var seriesData = ( xDomain && yDomain ) ? [ ] : data . map ( ( d , idx ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d , i ) , "y" : getY ( d , i ) , "y0" : d . y0 , "y1" : d . y1 , "idx" : idx } ; } ) ; } ) ; x . domain ( xDomain || d3 . merge ( seriesData ) . map ( ( d ) { return d . x ; } ) ) . rangeBands ( xRange || [ 0 , availableWidth ] , groupSpacing ) ; y . domain ( yDomain || d3 . extent ( d3 . merge ( seriesData ) . map ( ( d ) { var domain = d . y ;
 // increase the domain range if this series is stackable
 if ( stacked && ! data [ d . idx ] . nonStackable ) { if ( d . y > 0 ) { domain = d . y1 ; } else { domain = d . y1 + d . y ; } } return domain ; } ) . concat ( forceY ) ) ) . range ( yRange || [ availableHeight , 0 ] ) ;
 // If scale's domain don't have a range, slightly adjust to make one... so a chart can show a single data point
 if ( identical ( x . domain ( ) [ 0 ] , x . domain ( ) [ 1 ] ) ) x . domain ( ) [ 0 ] ? x . domain ( [ x . domain ( ) [ 0 ] - x . domain ( ) [ 0 ] * 0.01 , x . domain ( ) [ 1 ] + x . domain ( ) [ 1 ] * 0.01 ] ) : x . domain ( [ - 1 , 1 ] ) ; if ( identical ( y . domain ( ) [ 0 ] , y . domain ( ) [ 1 ] ) ) y . domain ( ) [ 0 ] ? y . domain ( [ y . domain ( ) [ 0 ] + y . domain ( ) [ 0 ] * 0.01 , y . domain ( ) [ 1 ] - y . domain ( ) [ 1 ] * 0.01 ] ) : y . domain ( [ - 1 , 1 ] ) ; x0 = x0 || x ; y0 = y0 || y ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-multibar" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-multibar" ) ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-groups" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-edge-clip-" + id ) . append ( "rect" ) ; wrap . select ( "#nv-edge-clip-" + id + " rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; g . attr ( "clip-path" , clipEdge ? "url(#nv-edge-clip-" + id + ")" : "" ) ; var groups = wrap . select ( ".nv-groups" ) . selectAll ( ".nv-group" ) . data ( ( d ) { return d ; } , ( d , i ) { return i ; } ) ; groups . enter ( ) . append ( "g" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) ; var exitTransition = renderWatch . transition ( groups . exit ( ) . selectAll ( "rect.nv-bar" ) , "multibarExit" , Math . min ( 100 , duration ) ) . attr ( "y" , ( d , i , j ) { var yVal = y0 ( 0 ) || 0 ; if ( stacked ) { if ( data [ d . series ] && ! data [ d . series ] . nonStackable ) { yVal = y0 ( d . y0 ) ; } } return yVal ; } ) . attr ( "height" , 0 ) . remove ( ) ; if ( exitTransition . delay ) exitTransition . delay ( ( d , i ) { var delay = i * ( duration / ( last_datalength + 1 ) ) - i ; return delay ; } ) ; groups . attr ( "class" , ( d , i ) { return "nv-group nv-series-" + i ; } ) . classed ( "hover" , ( d ) { return d . hover ; } ) . style ( "fill" , ( d , i ) { return color ( d , i ) ; } ) . style ( "stroke" , ( d , i ) { return color ( d , i ) ; } ) ; groups . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , fillOpacity ) ; var bars = groups . selectAll ( "rect.nv-bar" ) . data ( ( d ) { return ( hideable && ! data . length ) ? hideable . values : d . values ; } ) ; bars . exit ( ) . remove ( ) ; var barsEnter = bars . enter ( ) . append ( "rect" ) . attr ( "class" , ( d , i ) { return getY ( d , i ) < 0 ? "nv-bar negative" : "nv-bar positive" ; } ) . attr ( "x" , ( d , i , j ) { return stacked && ! data [ j ] . nonStackable ? 0 : ( j * x . rangeBand ( ) / data . length ) ; } ) . attr ( "y" , ( d , i , j ) { return y0 ( stacked && ! data [ j ] . nonStackable ? d . y0 : 0 ) || 0 ; } ) . attr ( "height" , 0 ) . attr ( "width" , ( d , i , j ) { return x . rangeBand ( ) / ( stacked && ! data [ j ] . nonStackable ? 1 : data . length ) ; } ) . attr ( "transform" , ( d , i ) { return "translate(" + x ( getX ( d , i ) ) + ",0)" ; } ) ; bars . style ( "fill" , ( d , i , j ) { return color ( d , j , i ) ; } ) . style ( "stroke" , ( d , i , j ) { return color ( d , j , i ) ; } ) . on ( "mouseover" , ( d , i , j ) { d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( data : d , index : i , series : data [ j ] , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i , j ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( data : d , index : i , series : data [ j ] , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mousemove" , ( d , i , j ) { dispatch . elementMousemove ( data : d , index : i , series : data [ j ] , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "click" , ( d , i , j ) { var element = this ; dispatch . elementClick ( data : d , index : i , series : data [ j ] , color : d3 . select ( this ) . style ( "fill" ) , event : d3 . event , element : element ) ; d3 . event . stopPropagation ( ) ; } ) . on ( "dblclick" , ( d , i , j ) { dispatch . elementDblClick ( data : d , index : i , series : data [ j ] , color : d3 . select ( this ) . style ( "fill" ) ) ; d3 . event . stopPropagation ( ) ; } ) ; bars . attr ( "class" , ( d , i ) { return getY ( d , i ) < 0 ? "nv-bar negative" : "nv-bar positive" ; } ) . attr ( "transform" , ( d , i ) { return "translate(" + x ( getX ( d , i ) ) + ",0)" ; } ) ; if ( barColor ) { if ( ! disabled ) disabled = data . map ( ( ) { return true ; } ) ; bars . style ( "fill" , ( d , i , j ) { return d3 . rgb ( barColor ( d , i ) ) . darker ( disabled . map ( ( d , i ) { return i ; } ) . filter ( ( d , i ) { return ! disabled [ i ] ; } ) [ j ] ) . toString ( ) ; } ) . style ( "stroke" , ( d , i , j ) { return d3 . rgb ( barColor ( d , i ) ) . darker ( disabled . map ( ( d , i ) { return i ; } ) . filter ( ( d , i ) { return ! disabled [ i ] ; } ) [ j ] ) . toString ( ) ; } ) ; } var barSelection = bars . watchTransition ( renderWatch , "multibar" , Math . min ( 250 , duration ) ) . delay ( ( d , i ) { return i * duration / data [ 0 ] . values . length ; } ) ; if ( stacked ) { barSelection . attr ( "y" , ( d , i , j ) { var yVal = 0 ;
 // if stackable, stack it on top of the previous series
 if ( ! data [ j ] . nonStackable ) { yVal = y ( d . y1 ) ; } else { if ( getY ( d , i ) < 0 ) { yVal = y ( 0 ) ; } else { if ( y ( 0 ) - y ( getY ( d , i ) ) < - 1 ) { yVal = y ( 0 ) - 1 ; } else { yVal = y ( getY ( d , i ) ) || 0 ; } } } return yVal ; } ) . attr ( "height" , ( d , i , j ) { if ( ! data [ j ] . nonStackable ) { return Math . max ( Math . abs ( y ( d . y + d . y0 ) - y ( d . y0 ) ) , 0 ) ; } else { return Math . max ( Math . abs ( y ( getY ( d , i ) ) - y ( 0 ) ) , 0 ) || 0 ; } } ) . attr ( "x" , ( d , i , j ) { var width = 0 ; if ( data [ j ] . nonStackable ) { width = d . series * x . rangeBand ( ) / data . length ; if ( ! identical ( data . length , nonStackableCount ) ) { width = data [ j ] . nonStackableSeries * x . rangeBand ( ) / ( nonStackableCount * 2 ) ; } } return width ; } ) . attr ( "width" , ( d , i , j ) { if ( ! data [ j ] . nonStackable ) { return x . rangeBand ( ) ; } else {
 // if all series are nonStacable, take the full width
 var width = ( x . rangeBand ( ) / nonStackableCount ) ;
 // otherwise, nonStackable graph will be only taking the half-width

 // of the x rangeBand
 if ( ! identical ( data . length , nonStackableCount ) ) { width = x . rangeBand ( ) / ( nonStackableCount * 2 ) ; } return width ; } } ) ; } else { barSelection . attr ( "x" , ( d , i ) { return d . series * x . rangeBand ( ) / data . length ; } ) . attr ( "width" , x . rangeBand ( ) / data . length ) . attr ( "y" , ( d , i ) { return getY ( d , i ) < 0 ? y ( 0 ) : y ( 0 ) - y ( getY ( d , i ) ) < 1 ? y ( 0 ) - 1 : y ( getY ( d , i ) ) || 0 ; } ) . attr ( "height" , ( d , i ) { return Math . max ( Math . abs ( y ( getY ( d , i ) ) - y ( 0 ) ) , 1 ) || 0 ; } ) ; }
 //store old scales for use in transitions on update
 x0 = x . copy ( ) ; y0 = y . copy ( ) ;
 // keep track of the last data value length for transition calculations
 if ( data [ 0 ] && data [ 0 ] . values ) { last_datalength = data [ 0 ] . values . length ; } } ) ; renderWatch . renderEnd ( "multibar immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , forceY : { "get" : ( ) { return forceY ; } , "set" : ( _ ) { forceY = _ ; } } , stacked : { "get" : ( ) { return stacked ; } , "set" : ( _ ) { stacked = _ ; } } , stackOffset : { "get" : ( ) { return stackOffset ; } , "set" : ( _ ) { stackOffset = _ ; } } , clipEdge : { "get" : ( ) { return clipEdge ; } , "set" : ( _ ) { clipEdge = _ ; } } , disabled : { "get" : ( ) { return disabled ; } , "set" : ( _ ) { disabled = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , hideable : { "get" : ( ) { return hideable ; } , "set" : ( _ ) { hideable = _ ; } } , groupSpacing : { "get" : ( ) { return groupSpacing ; } , "set" : ( _ ) { groupSpacing = _ ; } } , fillOpacity : { "get" : ( ) { return fillOpacity ; } , "set" : ( _ ) { fillOpacity = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , barColor : { "get" : ( ) { return barColor ; } , "set" : ( _ ) { barColor = _ ? nv . utils . getColor ( _ ) : null ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . multiBarChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var multibar = nv . models . multiBar ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , interactiveLayer = nv . interactiveGuideline ( ) , legend = nv . models . legend ( ) , controls = nv . models . legend ( ) , tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 20 , "bottom" : 50 , "left" : 60 } , marginTop = null , width = null , height = null , color = nv . utils . defaultColor ( ) , showControls = true , controlLabels = { } , showLegend = true , legendPosition = null , showXAxis = true , showYAxis = true , rightAlignYAxis = false , reduceXTicks = true , staggerLabels = false , wrapLabels = false , rotateLabels = 0 , x , y , state = nv . utils . state ( ) , defaultState = null , noData = null , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) , controlWidth = ( ) { return showControls ? 180 : 0 ; } , duration = 250 , useInteractiveGuideline = false ; state . stacked = false ; multibar . stacked ( false ) ; xAxis . orient ( "bottom" ) . tickPadding ( 7 ) . showMaxMin ( false ) . tickFormat ( ( d ) { return d ; } ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) . tickFormat ( d3 . format ( ",.1f" ) ) ; tooltip . duration ( 0 ) . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ; interactiveLayer . tooltip . valueFormatter ( ( d , i ) { return d == null ? "N/A" : yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ; interactiveLayer . tooltip . valueFormatter ( ( d , i ) { return d == null ? "N/A" : yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ; interactiveLayer . tooltip . duration ( 0 ) . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ; controls . updateState ( false ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; var stacked = false ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) , "stacked" : stacked } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . stacked , undefined ) ) stacked = state . stacked ; if ( ! identical ( state . active , undefined ) ) data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } ; } ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( multibar ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { if ( identical ( duration , 0 ) ) container . call ( chart ) ; else container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 // DEPRECATED set state.disableddisabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display noData message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = multibar . xScale ( ) ; y = multibar . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-multiBarWithLegend" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-multiBarWithLegend" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-barsWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-controlsWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-interactive" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { if ( identical ( legendPosition , "bottom" ) ) { legend . width ( availableWidth - margin . right ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; margin . bottom = xAxis . height ( ) + legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + ( availableHeight + xAxis . height ( ) ) + ")" ) ; } else { legend . width ( availableWidth - controlWidth ( ) ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(" + controlWidth ( ) + "," + ( - margin . top ) + ")" ) ; } }
 // Controls
 if ( ! showControls ) { g . select ( ".nv-controlsWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var controlsData = [ { "key" : controlLabels . grouped || "Grouped" , "disabled" : multibar . stacked ( ) } , { "key" : controlLabels . stacked || "Stacked" , "disabled" : ! multibar . stacked ( ) } ] ; controls . width ( controlWidth ( ) ) . color ( [ "#444" , "#444" , "#444" ] ) ; g . select ( ".nv-controlsWrap" ) . datum ( controlsData ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) . call ( controls ) ; } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 // Main Chart Component(s)
 multibar . disabled ( data . map ( ( series ) { return series . disabled ; } ) ) . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; var barsWrap = g . select ( ".nv-barsWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ; barsWrap . call ( multibar ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) ; g . select ( ".nv-x.nv-axis" ) . call ( xAxis ) ; var xTicks = g . select ( ".nv-x.nv-axis > g" ) . selectAll ( "g" ) ; xTicks . selectAll ( "line, text" ) . style ( "opacity" , 1 ) ; if ( staggerLabels ) { var getTranslate = ( x , y ) { return "translate(" + x + "," + y + ")" ; } ; var staggerUp = 5 , staggerDown = 17 ;
 // Issue #140
 xTicks . selectAll ( "text" ) . attr ( "transform" , ( d , i , j ) { return getTranslate ( 0 , ( j % 2 == 0 ? staggerUp : staggerDown ) ) ; } ) ; var totalInBetweenTicks = d3 . selectAll ( ".nv-x.nv-axis .nv-wrap g g text" ) [ 0 ] . length ; g . selectAll ( ".nv-x.nv-axis .nv-axisMaxMin text" ) . attr ( "transform" , ( d , i ) { return getTranslate ( 0 , ( identical ( i , 0 ) || ! identical ( totalInBetweenTicks % 2 , 0 ) ) ? staggerDown : staggerUp ) ; } ) ; } if ( wrapLabels ) { g . selectAll ( ".tick text" ) . call ( nv . utils . wrapTicks , chart . xAxis . rangeBand ( ) ) ; } if ( reduceXTicks ) xTicks . filter ( ( d , i ) { return ! identical ( i % Math . ceil ( data [ 0 ] . values . length / ( availableWidth / 100 ) ) , 0 ) ; } ) . selectAll ( "text, line" ) . style ( "opacity" , 0 ) ; if ( rotateLabels ) xTicks . selectAll ( ".tick text" ) . attr ( "transform" , "rotate(" + rotateLabels + " 0,0)" ) . style ( "text-anchor" , rotateLabels > 0 ? "start" : "end" ) ; g . select ( ".nv-x.nv-axis" ) . selectAll ( "g.nv-axisMaxMin text" ) . style ( "opacity" , 1 ) ; } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-y.nv-axis" ) . call ( yAxis ) ; }
 //Set up interactive layer
 if ( useInteractiveGuideline ) { interactiveLayer . width ( availableWidth ) . height ( availableHeight ) . margin ( left : margin . left , top : margin . top ) . svgContainer ( container ) . xScale ( x ) ; wrap . select ( ".nv-interactive" ) . call ( interactiveLayer ) ; }
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) state [ key ] = newState [ key ] ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; controls . dispatch . on ( "legendClick" , ( d , i ) { if ( ! d . disabled ) return ; controlsData = controlsData . map ( ( s ) { s . disabled = true ; return s ; } ) ; d . disabled = false ; switch ( d . key ) { case "Grouped" : case controlLabels . grouped : multibar . stacked ( false ) ; break ; case "Stacked" : case controlLabels . stacked : multibar . stacked ( true ) ; break ; } state . stacked = multibar . stacked ( ) ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } if ( ! identical ( , "undefined" ) ) { multibar . stacked ( e . stacked ) ; state . stacked = e . stacked ; stacked = e . stacked ; } chart . update ( ) ; } ) ; if ( useInteractiveGuideline ) { interactiveLayer . dispatch . on ( "elementMousemove" , ( e ) { if ( e . pointXValue == undefined ) return ; var singlePoint , pointIndex , pointXLocation , xValue , allData = [ ] ; data . filter ( ( series , i ) { series . seriesIndex = i ; return ! series . disabled ; } ) . forEach ( ( series , i ) { pointIndex = x . domain ( ) . indexOf ( e . pointXValue ) ; var point = series . values [ pointIndex ] ; if ( identical ( point , undefined ) ) return ; xValue = point . x ; if ( identical ( singlePoint , undefined ) ) singlePoint = point ; if ( identical ( pointXLocation , undefined ) ) pointXLocation = e . mouseX ; allData . push ( key : series . key , value : chart . y ( ) ( point , pointIndex ) , color : color ( series , series . seriesIndex ) , data : series . values [ pointIndex ] ) ; } ) ; interactiveLayer . tooltip . data ( value : xValue , index : pointIndex , series : allData ) ( ) ; interactiveLayer . renderGuideLine ( pointXLocation ) ; } ) ; interactiveLayer . dispatch . on ( "elementMouseout" , ( e ) { interactiveLayer . tooltip . hidden ( true ) ; } ) ; } else { multibar . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt . value = chart . x ( ) ( evt . data ) ; evt [ "series" ] = { "key" : evt . data . key , "value" : chart . y ( ) ( evt . data ) , "color" : evt . color } ; tooltip . data ( evt ) . hidden ( false ) ; } ) ; multibar . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; multibar . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ; } } ) ; renderWatch . renderEnd ( "multibarchart immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . multibar = multibar ; chart . legend = legend ; chart . controls = controls ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . state = state ; chart . tooltip = tooltip ; chart . interactiveLayer = interactiveLayer ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , legendPosition : { "get" : ( ) { return legendPosition ; } , "set" : ( _ ) { legendPosition = _ ; } } , showControls : { "get" : ( ) { return showControls ; } , "set" : ( _ ) { showControls = _ ; } } , controlLabels : { "get" : ( ) { return controlLabels ; } , "set" : ( _ ) { controlLabels = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , reduceXTicks : { "get" : ( ) { return reduceXTicks ; } , "set" : ( _ ) { reduceXTicks = _ ; } } , rotateLabels : { "get" : ( ) { return rotateLabels ; } , "set" : ( _ ) { rotateLabels = _ ; } } , staggerLabels : { "get" : ( ) { return staggerLabels ; } , "set" : ( _ ) { staggerLabels = _ ; } } , wrapLabels : { "get" : ( ) { return wrapLabels ; } , "set" : ( _ ) { wrapLabels = ! ! _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; multibar . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; renderWatch . reset ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( rightAlignYAxis ? "right" : "left" ) ; } } , useInteractiveGuideline : { "get" : ( ) { return useInteractiveGuideline ; } , "set" : ( _ ) { useInteractiveGuideline = _ ; } } , barColor : { "get" : ( ) { return multibar . barColor ; } , "set" : ( _ ) { multibar . barColor ( _ ) ; legend . color ( ( d , i ) { return d3 . rgb ( "#ccc" ) . darker ( i * 1.5 ) . toString ( ) ; } ) ; } } ) ; nv . utils . inheritOptions ( chart , multibar ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . multiBarHorizontal = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , id = Math . floor ( Math . random ( ) * 10000 ) , container = null , x = d3 . scale . ordinal ( ) , y = d3 . scale . linear ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , getYerr = ( d ) { return d . yErr ; } , forceY = [ 0 ] , color = nv . utils . defaultColor ( ) , barColor = null , disabled , stacked = false , showValues = false , showBarLabels = false , valuePadding = 60 , groupSpacing = 0.1 , fillOpacity = 0.75 , valueFormat = d3 . format ( ",.2f" ) , delay = 1200 , xDomain , yDomain , xRange , yRange , duration = 250 , dispatch = d3 . dispatch ( "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var x0 , y0 ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; if ( stacked ) data = d3 . layout . stack ( ) . offset ( "zero" ) . values ( ( d ) { return d . values ; } ) . y ( getY ) ( data ) ;
 //add series index and key to each data point for reference
 data . forEach ( ( series , i ) { series . values . forEach ( ( point ) { point . series = i ; point . key = series . key ; } ) ; } ) ;
 // HACK for negative value stacking
 if ( stacked ) data [ 0 ] . values . map ( ( d , i ) { var posBase = 0 , negBase = 0 ; data . map ( ( d ) { var f = d . values [ i ] ; f . size = Math . abs ( f . y ) ; if ( f . y < 0 ) { f . y1 = negBase - f . size ; negBase = negBase - f . size ; } else { f . y1 = posBase ; posBase = posBase + f . size ; } } ) ; } ) ;
 // Setup Scales

 // remap and flatten the data for use in calculating the scales' domains
 var seriesData = ( xDomain && yDomain ) ? [ ] : data . map ( ( d ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d , i ) , "y" : getY ( d , i ) , "y0" : d . y0 , "y1" : d . y1 } ; } ) ; } ) ; x . domain ( xDomain || d3 . merge ( seriesData ) . map ( ( d ) { return d . x ; } ) ) . rangeBands ( xRange || [ 0 , availableHeight ] , groupSpacing ) ; y . domain ( yDomain || d3 . extent ( d3 . merge ( seriesData ) . map ( ( d ) { return stacked ? ( d . y > 0 ? d . y1 + d . y : d . y1 ) : d . y ; } ) . concat ( forceY ) ) ) ; if ( showValues && ! stacked ) y . range ( yRange || [ ( y . domain ( ) [ 0 ] < 0 ? valuePadding : 0 ) , availableWidth - ( y . domain ( ) [ 1 ] > 0 ? valuePadding : 0 ) ] ) ; else y . range ( yRange || [ 0 , availableWidth ] ) ; x0 = x0 || x ; y0 = y0 || d3 . scale . linear ( ) . domain ( y . domain ( ) ) . range ( [ y ( 0 ) , y ( 0 ) ] ) ;
 // Setup containers and skeleton of chart
 var wrap = d3 . select ( this ) . selectAll ( "g.nv-wrap.nv-multibarHorizontal" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-multibarHorizontal" ) ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-groups" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var groups = wrap . select ( ".nv-groups" ) . selectAll ( ".nv-group" ) . data ( ( d ) { return d ; } , ( d , i ) { return i ; } ) ; groups . enter ( ) . append ( "g" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) ; groups . exit ( ) . watchTransition ( renderWatch , "multibarhorizontal: exit groups" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) . remove ( ) ; groups . attr ( "class" , ( d , i ) { return "nv-group nv-series-" + i ; } ) . classed ( "hover" , ( d ) { return d . hover ; } ) . style ( "fill" , ( d , i ) { return color ( d , i ) ; } ) . style ( "stroke" , ( d , i ) { return color ( d , i ) ; } ) ; groups . watchTransition ( renderWatch , "multibarhorizontal: groups" ) . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , fillOpacity ) ; var bars = groups . selectAll ( "g.nv-bar" ) . data ( ( d ) { return d . values ; } ) ; bars . exit ( ) . remove ( ) ; var barsEnter = bars . enter ( ) . append ( "g" ) . attr ( "transform" , ( d , i , j ) { return "translate(" + y0 ( stacked ? d . y0 : 0 ) + "," + ( stacked ? 0 : ( j * x . rangeBand ( ) / data . length ) + x ( getX ( d , i ) ) ) + ")" ; } ) ; barsEnter . append ( "rect" ) . attr ( "width" , 0 ) . attr ( "height" , x . rangeBand ( ) / ( stacked ? 1 : data . length ) ) ; bars . on ( "mouseover" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . elementMouseover ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . elementMouseout ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mouseout" , ( d , i ) { dispatch . elementMouseout ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) . on ( "click" , ( d , i ) { var element = this ; dispatch . elementClick ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) , event : d3 . event , element : element ) ; d3 . event . stopPropagation ( ) ; } ) . on ( "dblclick" , ( d , i ) { dispatch . elementDblClick ( data : d , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; d3 . event . stopPropagation ( ) ; } ) ; if ( getYerr ( data [ 0 ] , 0 ) ) { barsEnter . append ( "polyline" ) ; bars . select ( "polyline" ) . attr ( "fill" , "none" ) . attr ( "points" , ( d , i ) { var xerr = getYerr ( d , i ) , mid = 0.8 * x . rangeBand ( ) / ( ( stacked ? 1 : data . length ) * 2 ) ; xerr = xerr . length ? xerr : [ - Math . abs ( xerr ) , Math . abs ( xerr ) ] ; xerr = xerr . map ( ( e ) { return y ( e + ( ( getY ( d , i ) < 0 ) ? 0 : getY ( d , i ) ) ) - y ( 0 ) ; } ) ; var a = [ [ xerr [ 0 ] , - mid ] , [ xerr [ 0 ] , mid ] , [ xerr [ 0 ] , 0 ] , [ xerr [ 1 ] , 0 ] , [ xerr [ 1 ] , - mid ] , [ xerr [ 1 ] , mid ] ] ; return a . map ( ( path ) { return path . join ( "," ) ; } ) . join ( " " ) ; } ) . attr ( "transform" , ( d , i ) { var mid = x . rangeBand ( ) / ( ( stacked ? 1 : data . length ) * 2 ) ; return "translate(0, " + mid + ")" ; } ) ; } barsEnter . append ( "text" ) ; if ( showValues && ! stacked ) { bars . select ( "text" ) . attr ( "text-anchor" , ( d , i ) { return getY ( d , i ) < 0 ? "end" : "start" ; } ) . attr ( "y" , x . rangeBand ( ) / ( data . length * 2 ) ) . attr ( "dy" , ".32em" ) . text ( ( d , i ) { var t = valueFormat ( getY ( d , i ) ) , yerr = getYerr ( d , i ) ; if ( identical ( yerr , undefined ) ) return t ; if ( ! yerr . length ) return t + "±" + valueFormat ( Math . abs ( yerr ) ) ; return t + "+" + valueFormat ( Math . abs ( yerr [ 1 ] ) ) + "-" + valueFormat ( Math . abs ( yerr [ 0 ] ) ) ; } ) ; bars . watchTransition ( renderWatch , "multibarhorizontal: bars" ) . select ( "text" ) . attr ( "x" , ( d , i ) { return getY ( d , i ) < 0 ? - 4 : y ( getY ( d , i ) ) - y ( 0 ) + 4 ; } ) ; } else { bars . selectAll ( "text" ) . text ( "" ) ; } if ( showBarLabels && ! stacked ) { barsEnter . append ( "text" ) . classed ( "nv-bar-label" , true ) ; bars . select ( "text.nv-bar-label" ) . attr ( "text-anchor" , ( d , i ) { return getY ( d , i ) < 0 ? "start" : "end" ; } ) . attr ( "y" , x . rangeBand ( ) / ( data . length * 2 ) ) . attr ( "dy" , ".32em" ) . text ( ( d , i ) { return getX ( d , i ) ; } ) ; bars . watchTransition ( renderWatch , "multibarhorizontal: bars" ) . select ( "text.nv-bar-label" ) . attr ( "x" , ( d , i ) { return getY ( d , i ) < 0 ? y ( 0 ) - y ( getY ( d , i ) ) + 4 : - 4 ; } ) ; } else { bars . selectAll ( "text.nv-bar-label" ) . text ( "" ) ; } bars . attr ( "class" , ( d , i ) { return getY ( d , i ) < 0 ? "nv-bar negative" : "nv-bar positive" ; } ) ; if ( barColor ) { if ( ! disabled ) disabled = data . map ( ( ) { return true ; } ) ; bars . style ( "fill" , ( d , i , j ) { return d3 . rgb ( barColor ( d , i ) ) . darker ( disabled . map ( ( d , i ) { return i ; } ) . filter ( ( d , i ) { return ! disabled [ i ] ; } ) [ j ] ) . toString ( ) ; } ) . style ( "stroke" , ( d , i , j ) { return d3 . rgb ( barColor ( d , i ) ) . darker ( disabled . map ( ( d , i ) { return i ; } ) . filter ( ( d , i ) { return ! disabled [ i ] ; } ) [ j ] ) . toString ( ) ; } ) ; } if ( stacked ) bars . watchTransition ( renderWatch , "multibarhorizontal: bars" ) . attr ( "transform" , ( d , i ) { return "translate(" + y ( d . y1 ) + "," + x ( getX ( d , i ) ) + ")" ; } ) . select ( "rect" ) . attr ( "width" , ( d , i ) { return Math . abs ( y ( getY ( d , i ) + d . y0 ) - y ( d . y0 ) ) || 0 ; } ) . attr ( "height" , x . rangeBand ( ) ) ; else bars . watchTransition ( renderWatch , "multibarhorizontal: bars" ) . attr ( "transform" , ( d , i ) {
 //TODO: stacked must be all positive or all negative, not both?
 return "translate(" + ( getY ( d , i ) < 0 ? y ( getY ( d , i ) ) : y ( 0 ) ) + "," + ( d . series * x . rangeBand ( ) / data . length + x ( getX ( d , i ) ) ) + ")" ; } ) . select ( "rect" ) . attr ( "height" , x . rangeBand ( ) / data . length ) . attr ( "width" , ( d , i ) { return Math . max ( Math . abs ( y ( getY ( d , i ) ) - y ( 0 ) ) , 1 ) || 0 ; } ) ;
 //store old scales for use in transitions on update
 x0 = x . copy ( ) ; y0 = y . copy ( ) ; } ) ; renderWatch . renderEnd ( "multibarHorizontal immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , yErr : { "get" : ( ) { return getYerr ; } , "set" : ( _ ) { getYerr = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , forceY : { "get" : ( ) { return forceY ; } , "set" : ( _ ) { forceY = _ ; } } , stacked : { "get" : ( ) { return stacked ; } , "set" : ( _ ) { stacked = _ ; } } , showValues : { "get" : ( ) { return showValues ; } , "set" : ( _ ) { showValues = _ ; } } , disabled : { "get" : ( ) { return disabled ; } , "set" : ( _ ) { disabled = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , valueFormat : { "get" : ( ) { return valueFormat ; } , "set" : ( _ ) { valueFormat = _ ; } } , valuePadding : { "get" : ( ) { return valuePadding ; } , "set" : ( _ ) { valuePadding = _ ; } } , groupSpacing : { "get" : ( ) { return groupSpacing ; } , "set" : ( _ ) { groupSpacing = _ ; } } , fillOpacity : { "get" : ( ) { return fillOpacity ; } , "set" : ( _ ) { fillOpacity = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , barColor : { "get" : ( ) { return barColor ; } , "set" : ( _ ) { barColor = _ ? nv . utils . getColor ( _ ) : null ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . multiBarHorizontalChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var multibar = nv . models . multiBarHorizontal ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , legend = nv . models . legend ( ) . height ( 30 ) , controls = nv . models . legend ( ) . height ( 30 ) , tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 20 , "bottom" : 50 , "left" : 60 } , marginTop = null , width = null , height = null , color = nv . utils . defaultColor ( ) , showControls = true , controlsPosition = "top" , controlLabels = { } , showLegend = true , legendPosition = "top" , showXAxis = true , showYAxis = true , stacked = false , x , y , state = nv . utils . state ( ) , defaultState = null , noData = null , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) , controlWidth = ( ) { return showControls ? 180 : 0 ; } , duration = 250 ; state . stacked = false ; multibar . stacked ( stacked ) ; xAxis . orient ( "left" ) . tickPadding ( 5 ) . showMaxMin ( false ) . tickFormat ( ( d ) { return d ; } ) ; yAxis . orient ( "bottom" ) . tickFormat ( d3 . format ( ",.1f" ) ) ; tooltip . duration ( 0 ) . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) ; controls . updateState ( false ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) , "stacked" : stacked } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . stacked , undefined ) ) stacked = state . stacked ; if ( ! identical ( state . active , undefined ) ) data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } ; } ; var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( multibar ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ; stacked = multibar . stacked ( ) ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 // DEPRECATED set state.disableddisabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = multibar . xScale ( ) ; y = multibar . yScale ( ) . clamp ( true ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-multiBarHorizontalChart" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-multiBarHorizontalChart" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) . append ( "g" ) . attr ( "class" , "nv-zeroLine" ) . append ( "line" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-barsWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-controlsWrap" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { legend . width ( availableWidth - controlWidth ( ) ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( identical ( legendPosition , "bottom" ) ) { margin . bottom = xAxis . height ( ) + legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(" + controlWidth ( ) + "," + ( availableHeight + xAxis . height ( ) ) + ")" ) ; } else if ( identical ( legendPosition , "top" ) ) { if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(" + controlWidth ( ) + "," + ( - margin . top ) + ")" ) ; } }
 // Controls
 if ( ! showControls ) { g . select ( ".nv-controlsWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var controlsData = [ { "key" : controlLabels . grouped || "Grouped" , "disabled" : multibar . stacked ( ) } , { "key" : controlLabels . stacked || "Stacked" , "disabled" : ! multibar . stacked ( ) } ] ; controls . width ( controlWidth ( ) ) . color ( [ "#444" , "#444" , "#444" ] ) ; if ( identical ( controlsPosition , "bottom" ) ) { margin . bottom = xAxis . height ( ) + legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; g . select ( ".nv-controlsWrap" ) . datum ( controlsData ) . attr ( "transform" , "translate(0," + ( availableHeight + xAxis . height ( ) ) + ")" ) . call ( controls ) ; } else if ( identical ( controlsPosition , "top" ) ) { g . select ( ".nv-controlsWrap" ) . datum ( controlsData ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) . call ( controls ) ; } } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // Main Chart Component(s)
 multibar . disabled ( data . map ( ( series ) { return series . disabled ; } ) ) . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; var barsWrap = g . select ( ".nv-barsWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ; barsWrap . transition ( ) . call ( multibar ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 24 , data ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-x.nv-axis" ) . call ( xAxis ) ; var xTicks = g . select ( ".nv-x.nv-axis" ) . selectAll ( "g" ) ; xTicks . selectAll ( "line, text" ) ; } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(0," + availableHeight + ")" ) ; g . select ( ".nv-y.nv-axis" ) . call ( yAxis ) ; }
 // Zero line
 g . select ( ".nv-zeroLine line" ) . attr ( "x1" , y ( 0 ) ) . attr ( "x2" , y ( 0 ) ) . attr ( "y1" , 0 ) . attr ( "y2" , - availableHeight ) ;
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) state [ key ] = newState [ key ] ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; controls . dispatch . on ( "legendClick" , ( d , i ) { if ( ! d . disabled ) return ; controlsData = controlsData . map ( ( s ) { s . disabled = true ; return s ; } ) ; d . disabled = false ; switch ( d . key ) { case "Grouped" : case controlLabels . grouped : multibar . stacked ( false ) ; break ; case "Stacked" : case controlLabels . stacked : multibar . stacked ( true ) ; break ; } state . stacked = multibar . stacked ( ) ; dispatch . stateChange ( state ) ; stacked = multibar . stacked ( ) ; chart . update ( ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } if ( ! identical ( , "undefined" ) ) { multibar . stacked ( e . stacked ) ; state . stacked = e . stacked ; stacked = e . stacked ; } chart . update ( ) ; } ) ; } ) ; renderWatch . renderEnd ( "multibar horizontal chart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 multibar . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt . value = chart . x ( ) ( evt . data ) ; evt [ "series" ] = { "key" : evt . data . key , "value" : chart . y ( ) ( evt . data ) , "color" : evt . color } ; tooltip . data ( evt ) . hidden ( false ) ; } ) ; multibar . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; multibar . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . multibar = multibar ; chart . legend = legend ; chart . controls = controls ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . state = state ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , legendPosition : { "get" : ( ) { return legendPosition ; } , "set" : ( _ ) { legendPosition = _ ; } } , controlsPosition : { "get" : ( ) { return controlsPosition ; } , "set" : ( _ ) { controlsPosition = _ ; } } , showControls : { "get" : ( ) { return showControls ; } , "set" : ( _ ) { showControls = _ ; } } , controlLabels : { "get" : ( ) { return controlLabels ; } , "set" : ( _ ) { controlLabels = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; multibar . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; } } , barColor : { "get" : ( ) { return multibar . barColor ; } , "set" : ( _ ) { multibar . barColor ( _ ) ; legend . color ( ( d , i ) { return d3 . rgb ( "#ccc" ) . darker ( i * 1.5 ) . toString ( ) ; } ) ; } } ) ; nv . utils . inheritOptions ( chart , multibar ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . multiChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 30 , "right" : 20 , "bottom" : 50 , "left" : 60 } , marginTop = null , color = nv . utils . defaultColor ( ) , width = null , height = null , showLegend = true , noData = null , yDomain1 , yDomain2 , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , interpolate = "linear" , useVoronoi = true , interactiveLayer = nv . interactiveGuideline ( ) , useInteractiveGuideline = false , legendRightAxisHint = " (right axis)" , duration = 250 ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var x = d3 . scale . linear ( ) , yScale1 = d3 . scale . linear ( ) , yScale2 = d3 . scale . linear ( ) , lines1 = nv . models . line ( ) . yScale ( yScale1 ) . duration ( duration ) , lines2 = nv . models . line ( ) . yScale ( yScale2 ) . duration ( duration ) , scatters1 = nv . models . scatter ( ) . yScale ( yScale1 ) . duration ( duration ) , scatters2 = nv . models . scatter ( ) . yScale ( yScale2 ) . duration ( duration ) , bars1 = nv . models . multiBar ( ) . stacked ( false ) . yScale ( yScale1 ) . duration ( duration ) , bars2 = nv . models . multiBar ( ) . stacked ( false ) . yScale ( yScale2 ) . duration ( duration ) , stack1 = nv . models . stackedArea ( ) . yScale ( yScale1 ) . duration ( duration ) , stack2 = nv . models . stackedArea ( ) . yScale ( yScale2 ) . duration ( duration ) , xAxis = nv . models . axis ( ) . scale ( x ) . orient ( "bottom" ) . tickPadding ( 5 ) . duration ( duration ) , yAxis1 = nv . models . axis ( ) . scale ( yScale1 ) . orient ( "left" ) . duration ( duration ) , yAxis2 = nv . models . axis ( ) . scale ( yScale2 ) . orient ( "right" ) . duration ( duration ) , legend = nv . models . legend ( ) . height ( 30 ) , tooltip = nv . models . tooltip ( ) , dispatch = d3 . dispatch ( ) ; var charts = [ lines1 , lines2 , scatters1 , scatters2 , bars1 , bars2 , stack1 , stack2 ] ; chart ( selection ) { selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; chart . update = ( ) { container . transition ( ) . call ( chart ) ; } ; chart . container = this ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; var dataLines1 = data . filter ( ( d ) { return d . type == "line" && d . yAxis == 1 ; } ) ; var dataLines2 = data . filter ( ( d ) { return d . type == "line" && d . yAxis == 2 ; } ) ; var dataScatters1 = data . filter ( ( d ) { return d . type == "scatter" && d . yAxis == 1 ; } ) ; var dataScatters2 = data . filter ( ( d ) { return d . type == "scatter" && d . yAxis == 2 ; } ) ; var dataBars1 = data . filter ( ( d ) { return d . type == "bar" && d . yAxis == 1 ; } ) ; var dataBars2 = data . filter ( ( d ) { return d . type == "bar" && d . yAxis == 2 ; } ) ; var dataStack1 = data . filter ( ( d ) { return d . type == "area" && d . yAxis == 1 ; } ) ; var dataStack2 = data . filter ( ( d ) { return d . type == "area" && d . yAxis == 2 ; } ) ;
 // Display noData message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; } var series1 = data . filter ( ( d ) { return ! d . disabled && d . yAxis == 1 ; } ) . map ( ( d ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d ) , "y" : getY ( d ) } ; } ) ; } ) ; var series2 = data . filter ( ( d ) { return ! d . disabled && d . yAxis == 2 ; } ) . map ( ( d ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d ) , "y" : getY ( d ) } ; } ) ; } ) ; x . domain ( d3 . extent ( d3 . merge ( series1 . concat ( series2 ) ) , ( d ) { return d . x ; } ) ) . range ( [ 0 , availableWidth ] ) ; var wrap = container . selectAll ( "g.wrap.multiChart" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "wrap nvd3 multiChart" ) . append ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y1 nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y2 nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "stack1Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "stack2Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "bars1Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "bars2Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "scatters1Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "scatters2Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "lines1Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "lines2Wrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "legendWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-interactive" ) ; var g = wrap . select ( "g" ) ; var color_array = data . map ( ( d , i ) { return data [ i ] . color || color ( d , i ) ; } ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var legendWidth = legend . align ( ) ? availableWidth / 2 : availableWidth ; var legendXPosition = legend . align ( ) ? legendWidth : 0 ; legend . width ( legendWidth ) ; legend . color ( color_array ) ; g . select ( ".legendWrap" ) . datum ( data . map ( ( series ) { series . originalKey = identical ( series . originalKey , undefined ) ? series . key : series . originalKey ; series . key = series . originalKey + ( series . yAxis == 1 ? "" : legendRightAxisHint ) ; return series ; } ) ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } g . select ( ".legendWrap" ) . attr ( "transform" , "translate(" + legendXPosition + "," + ( - margin . top ) + ")" ) ; } lines1 . width ( availableWidth ) . height ( availableHeight ) . interpolate ( interpolate ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 1 && data [ i ] . type == "line" ; } ) ) ; lines2 . width ( availableWidth ) . height ( availableHeight ) . interpolate ( interpolate ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 2 && data [ i ] . type == "line" ; } ) ) ; scatters1 . width ( availableWidth ) . height ( availableHeight ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 1 && data [ i ] . type == "scatter" ; } ) ) ; scatters2 . width ( availableWidth ) . height ( availableHeight ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 2 && data [ i ] . type == "scatter" ; } ) ) ; bars1 . width ( availableWidth ) . height ( availableHeight ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 1 && data [ i ] . type == "bar" ; } ) ) ; bars2 . width ( availableWidth ) . height ( availableHeight ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 2 && data [ i ] . type == "bar" ; } ) ) ; stack1 . width ( availableWidth ) . height ( availableHeight ) . interpolate ( interpolate ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 1 && data [ i ] . type == "area" ; } ) ) ; stack2 . width ( availableWidth ) . height ( availableHeight ) . interpolate ( interpolate ) . color ( color_array . filter ( ( d , i ) { return ! data [ i ] . disabled && data [ i ] . yAxis == 2 && data [ i ] . type == "area" ; } ) ) ; g . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var lines1Wrap = g . select ( ".lines1Wrap" ) . datum ( dataLines1 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var scatters1Wrap = g . select ( ".scatters1Wrap" ) . datum ( dataScatters1 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var bars1Wrap = g . select ( ".bars1Wrap" ) . datum ( dataBars1 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var stack1Wrap = g . select ( ".stack1Wrap" ) . datum ( dataStack1 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var lines2Wrap = g . select ( ".lines2Wrap" ) . datum ( dataLines2 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var scatters2Wrap = g . select ( ".scatters2Wrap" ) . datum ( dataScatters2 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var bars2Wrap = g . select ( ".bars2Wrap" ) . datum ( dataBars2 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var stack2Wrap = g . select ( ".stack2Wrap" ) . datum ( dataStack2 . filter ( ( d ) { return ! d . disabled ; } ) ) ; var extraValue1BarStacked = [ ] ; if ( bars1 . stacked ( ) && dataBars1 . length ) { var extraValue1BarStacked = dataBars1 . filter ( ( d ) { return ! d . disabled ; } ) . map ( ( a ) { return a . values ; } ) ; if ( extraValue1BarStacked . length > 0 ) extraValue1BarStacked = extraValue1BarStacked . reduce ( ( a , b ) { return a . map ( ( aVal , i ) { return { "x" : aVal . x , "y" : aVal . y + b [ i ] . y } ; } ) ; } ) ; } if ( dataBars1 . length ) { extraValue1BarStacked . push ( x : 0 , y : 0 ) ; } var extraValue2BarStacked = [ ] ; if ( bars2 . stacked ( ) && dataBars2 . length ) { var extraValue2BarStacked = dataBars2 . filter ( ( d ) { return ! d . disabled ; } ) . map ( ( a ) { return a . values ; } ) ; if ( extraValue2BarStacked . length > 0 ) extraValue2BarStacked = extraValue2BarStacked . reduce ( ( a , b ) { return a . map ( ( aVal , i ) { return { "x" : aVal . x , "y" : aVal . y + b [ i ] . y } ; } ) ; } ) ; } if ( dataBars2 . length ) { extraValue2BarStacked . push ( x : 0 , y : 0 ) ; } getStackedAreaYs ( series ) { return d3 . transpose ( series ) . map ( ( x ) { return x . map ( ( g ) { return g . y ; } ) ; } ) . map ( ( x ) { return d3 . sum ( x ) ; } ) ; } yScale1 . domain ( yDomain1 || d3 . extent ( d3 . merge ( series1 ) . concat ( extraValue1BarStacked ) , ( d ) { return d . y ; } ) ) . range ( [ 0 , availableHeight ] ) ; yScale2 . domain ( yDomain2 || d3 . extent ( d3 . merge ( series2 ) . concat ( extraValue2BarStacked ) , ( d ) { return d . y ; } ) ) . range ( [ 0 , availableHeight ] ) ; lines1 . yDomain ( yScale1 . domain ( ) ) ; scatters1 . yDomain ( yScale1 . domain ( ) ) ; if ( bars1 . stacked ( ) ) { var yStackScale1 = yScale1 . domain ( [ 0 , d3 . max ( getStackedAreaYs ( series1 ) ) ] ) . range ( [ 0 , availableHeight ] ) ; bars1 . yDomain ( yStackScale1 . domain ( ) ) ; } else { bars1 . yDomain ( yScale1 . domain ( ) ) ; } stack1 . yDomain ( yScale1 . domain ( ) ) ; lines2 . yDomain ( yScale2 . domain ( ) ) ; scatters2 . yDomain ( yScale2 . domain ( ) ) ; if ( bars2 . stacked ( ) ) { var yStackScale2 = yScale2 . domain ( [ 0 , d3 . max ( getStackedAreaYs ( series2 ) ) ] ) . range ( [ 0 , availableHeight ] ) ; bars2 . yDomain ( yStackScale2 . domain ( ) ) ; } else { bars2 . yDomain ( yScale2 . domain ( ) ) ; } stack2 . yDomain ( yScale2 . domain ( ) ) ; if ( dataStack1 . length ) { d3 . transition ( stack1Wrap ) . call ( stack1 ) ; } if ( dataStack2 . length ) { d3 . transition ( stack2Wrap ) . call ( stack2 ) ; } if ( dataBars1 . length ) { d3 . transition ( bars1Wrap ) . call ( bars1 ) ; } if ( dataBars2 . length ) { d3 . transition ( bars2Wrap ) . call ( bars2 ) ; } if ( dataLines1 . length ) { d3 . transition ( lines1Wrap ) . call ( lines1 ) ; } if ( dataLines2 . length ) { d3 . transition ( lines2Wrap ) . call ( lines2 ) ; } if ( dataScatters1 . length ) { d3 . transition ( scatters1Wrap ) . call ( scatters1 ) ; } if ( dataScatters2 . length ) { d3 . transition ( scatters2Wrap ) . call ( scatters2 ) ; } xAxis . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + availableHeight + ")" ) ; d3 . transition ( g . select ( ".nv-x.nv-axis" ) ) . call ( xAxis ) ; yAxis1 . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; d3 . transition ( g . select ( ".nv-y1.nv-axis" ) ) . call ( yAxis1 ) ; yAxis2 . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; d3 . transition ( g . select ( ".nv-y2.nv-axis" ) ) . call ( yAxis2 ) ; g . select ( ".nv-y1.nv-axis" ) . classed ( "nv-disabled" , series1 . length ? false : true ) . attr ( "transform" , "translate(" + x . range ( ) [ 0 ] + ",0)" ) ; g . select ( ".nv-y2.nv-axis" ) . classed ( "nv-disabled" , series2 . length ? false : true ) . attr ( "transform" , "translate(" + x . range ( ) [ 1 ] + ",0)" ) ; legend . dispatch . on ( "stateChange" , ( newState ) { chart . update ( ) ; } ) ; if ( useInteractiveGuideline ) { interactiveLayer . width ( availableWidth ) . height ( availableHeight ) . margin ( left : margin . left , top : margin . top ) . svgContainer ( container ) . xScale ( x ) ; wrap . select ( ".nv-interactive" ) . call ( interactiveLayer ) ; }
 //============================================================

 // Event Handling/Dispatching

 //------------------------------------------------------------
 mouseover_line ( evt ) { var yaxis = identical ( evt . series . yAxis , 2 ) ? yAxis2 : yAxis1 ; evt . value = evt . point . x ; evt . series = { "value" : evt . point . y , "color" : evt . point . color , "key" : evt . series . key } ; tooltip . duration ( 0 ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( ( d , i ) { return yaxis . tickFormat ( ) ( d , i ) ; } ) . data ( evt ) . hidden ( false ) ; } mouseover_scatter ( evt ) { var yaxis = identical ( evt . series . yAxis , 2 ) ? yAxis2 : yAxis1 ; evt . value = evt . point . x ; evt . series = { "value" : evt . point . y , "color" : evt . point . color , "key" : evt . series . key } ; tooltip . duration ( 100 ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( ( d , i ) { return yaxis . tickFormat ( ) ( d , i ) ; } ) . data ( evt ) . hidden ( false ) ; } mouseover_stack ( evt ) { var yaxis = identical ( evt . series . yAxis , 2 ) ? yAxis2 : yAxis1 ; evt . point [ "x" ] = stack1 . x ( ) ( evt . point ) ; evt . point [ "y" ] = stack1 . y ( ) ( evt . point ) ; tooltip . duration ( 0 ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( ( d , i ) { return yaxis . tickFormat ( ) ( d , i ) ; } ) . data ( evt ) . hidden ( false ) ; } mouseover_bar ( evt ) { var yaxis = identical ( evt . series . yAxis , 2 ) ? yAxis2 : yAxis1 ; evt . value = bars1 . x ( ) ( evt . data ) ; evt [ "series" ] = { "value" : bars1 . y ( ) ( evt . data ) , "color" : evt . color , "key" : evt . data . key } ; tooltip . duration ( 0 ) . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( ( d , i ) { return yaxis . tickFormat ( ) ( d , i ) ; } ) . data ( evt ) . hidden ( false ) ; } clearHighlights ( ) { for ( var i = 0 , il = charts . length ; i < il ; i ++ ) { var chart = charts [ i ] ; try { chart . clearHighlights ( ) ; } catch ( e , e_stack ) { } } } highlightPoint ( series , pointIndex , b , pointYValue ) { var chartMap = { "line" : { "yAxis1" : { "chart" : lines1 , "data" : dataLines1 } , "yAxis2" : { "chart" : lines2 , "data" : dataLines2 } } , "scatter" : { "yAxis1" : { "chart" : scatters1 , "data" : dataScatters1 } , "yAxis2" : { "chart" : scatters2 , "data" : dataScatters2 } } , "bar" : { "yAxis1" : { "chart" : bars1 , "data" : dataBars1 } , "yAxis2" : { "chart" : bars2 , "data" : dataBars2 } } , "area" : { "yAxis1" : { "chart" : stack1 , "data" : dataStack1 } , "yAxis2" : { "chart" : stack2 , "data" : dataStack2 } } } ; var relevantChart = chartMap [ series . type ] [ "yAxis" + series . yAxis ] . chart ; var relevantDatasets = chartMap [ series . type ] [ "yAxis" + series . yAxis ] . data ; var seriesIndex = relevantDatasets . reduce ( ( seriesIndex , dataSet , i ) { return identical ( dataSet . key , series . key ) ? i : seriesIndex ; } , 0 ) ; try { relevantChart . highlightPoint ( seriesIndex , pointIndex , b , pointYValue ) ; } catch ( e , e_stack ) { } } if ( useInteractiveGuideline ) { interactiveLayer . dispatch . on ( "elementMousemove" , ( e ) { clearHighlights ( ) ; var singlePoint , pointIndex , pointXLocation , allData = [ ] ; data . filter ( ( series , i ) { series . seriesIndex = i ; return ! series . disabled ; } ) . forEach ( ( series , i ) { var extent = x . domain ( ) ; var currentValues = series . values . filter ( ( d , i ) { return chart . x ( ) ( d , i ) >= extent [ 0 ] && chart . x ( ) ( d , i ) <= extent [ 1 ] ; } ) ; pointIndex = nv . interactiveBisect ( currentValues , e . pointXValue , chart . x ( ) ) ; var point = currentValues [ pointIndex ] ; var pointYValue = chart . y ( ) ( point , pointIndex ) ; if ( ! identical ( pointYValue , null ) && ! isNaN ( pointYValue ) && ! series . noHighlightSeries ) { highlightPoint ( series , pointIndex , true ) ; } if ( identical ( point , undefined ) ) return ; if ( identical ( singlePoint , undefined ) ) singlePoint = point ; if ( identical ( pointXLocation , undefined ) ) pointXLocation = x ( chart . x ( ) ( point , pointIndex ) ) ; allData . push ( key : series . key , value : pointYValue , color : color ( series , series . seriesIndex ) , data : point , yAxis : series . yAxis == 2 ? yAxis2 : yAxis1 ) ; } ) ; var defaultValueFormatter = ( d , i ) { var yAxis = allData [ i ] . yAxis ; return d == null ? "N/A" : yAxis . tickFormat ( ) ( d ) ; } ; interactiveLayer . tooltip . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( interactiveLayer . tooltip . valueFormatter ( ) || defaultValueFormatter ) . data ( value : chart . x ( ) ( singlePoint , pointIndex ) , index : pointIndex , series : allData ) ( ) ; interactiveLayer . renderGuideLine ( pointXLocation ) ; } ) ; interactiveLayer . dispatch . on ( "elementMouseout" , ( e ) { clearHighlights ( ) ; } ) ; } else { lines1 . dispatch . on ( "elementMouseover.tooltip" , mouseover_line ) ; lines2 . dispatch . on ( "elementMouseover.tooltip" , mouseover_line ) ; lines1 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; lines2 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; scatters1 . dispatch . on ( "elementMouseover.tooltip" , mouseover_scatter ) ; scatters2 . dispatch . on ( "elementMouseover.tooltip" , mouseover_scatter ) ; scatters1 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; scatters2 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; stack1 . dispatch . on ( "elementMouseover.tooltip" , mouseover_stack ) ; stack2 . dispatch . on ( "elementMouseover.tooltip" , mouseover_stack ) ; stack1 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; stack2 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; bars1 . dispatch . on ( "elementMouseover.tooltip" , mouseover_bar ) ; bars2 . dispatch . on ( "elementMouseover.tooltip" , mouseover_bar ) ; bars1 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; bars2 . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; bars1 . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ; bars2 . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ; } } ) ; return chart ; }
 //============================================================

 // Global getters and setters

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . legend = legend ; chart . lines1 = lines1 ; chart . lines2 = lines2 ; chart . scatters1 = scatters1 ; chart . scatters2 = scatters2 ; chart . bars1 = bars1 ; chart . bars2 = bars2 ; chart . stack1 = stack1 ; chart . stack2 = stack2 ; chart . xAxis = xAxis ; chart . yAxis1 = yAxis1 ; chart . yAxis2 = yAxis2 ; chart . tooltip = tooltip ; chart . interactiveLayer = interactiveLayer ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; xAxis . scale ( x ) ; } } , yDomain1 : { "get" : ( ) { return yDomain1 ; } , "set" : ( _ ) { yDomain1 = _ ; } } , yDomain2 : { "get" : ( ) { return yDomain2 ; } , "set" : ( _ ) { yDomain2 = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , interpolate : { "get" : ( ) { return interpolate ; } , "set" : ( _ ) { interpolate = _ ; } } , legendRightAxisHint : { "get" : ( ) { return legendRightAxisHint ; } , "set" : ( _ ) { legendRightAxisHint = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; lines1 . x ( _ ) ; lines2 . x ( _ ) ; scatters1 . x ( _ ) ; scatters2 . x ( _ ) ; bars1 . x ( _ ) ; bars2 . x ( _ ) ; stack1 . x ( _ ) ; stack2 . x ( _ ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; lines1 . y ( _ ) ; lines2 . y ( _ ) ; scatters1 . y ( _ ) ; scatters2 . y ( _ ) ; stack1 . y ( _ ) ; stack2 . y ( _ ) ; bars1 . y ( _ ) ; bars2 . y ( _ ) ; } } , useVoronoi : { "get" : ( ) { return useVoronoi ; } , "set" : ( _ ) { useVoronoi = _ ; lines1 . useVoronoi ( _ ) ; lines2 . useVoronoi ( _ ) ; stack1 . useVoronoi ( _ ) ; stack2 . useVoronoi ( _ ) ; } } , useInteractiveGuideline : { "get" : ( ) { return useInteractiveGuideline ; } , "set" : ( _ ) { useInteractiveGuideline = _ ; if ( useInteractiveGuideline ) { lines1 . interactive ( false ) ; lines1 . useVoronoi ( false ) ; lines2 . interactive ( false ) ; lines2 . useVoronoi ( false ) ; stack1 . interactive ( false ) ; stack1 . useVoronoi ( false ) ; stack2 . interactive ( false ) ; stack2 . useVoronoi ( false ) ; scatters1 . interactive ( false ) ; scatters2 . interactive ( false ) ; } } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; [ lines1 , lines2 , stack1 , stack2 , scatters1 , scatters2 , xAxis , yAxis1 , yAxis2 ] . forEach ( ( model ) { model . duration ( duration ) ; } ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . ohlcBar = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = null , height = null , id = Math . floor ( Math . random ( ) * 10000 ) , container = null , x = d3 . scale . linear ( ) , y = d3 . scale . linear ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , getOpen = ( d ) { return d . open ; } , getClose = ( d ) { return d . close ; } , getHigh = ( d ) { return d . high ; } , getLow = ( d ) { return d . low ; } , forceX = [ ] , forceY = [ ] , padData = false , clipEdge = true , color = nv . utils . defaultColor ( ) , interactive = false , xDomain , yDomain , xRange , yRange , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" , "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 chart ( selection ) { selection . each ( ( data ) { container = d3 . select ( this ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; nv . utils . initSVG ( container ) ;
 // ohlc bar width.
 var w = ( availableWidth / data [ 0 ] . values . length ) * .9 ;
 // Setup Scales
 x . domain ( xDomain || d3 . extent ( data [ 0 ] . values . map ( getX ) . concat ( forceX ) ) ) ; if ( padData ) x . range ( xRange || [ availableWidth * .5 / data [ 0 ] . values . length , availableWidth * ( data [ 0 ] . values . length - .5 ) / data [ 0 ] . values . length ] ) ; else x . range ( xRange || [ 5 + w / 2 , availableWidth - w / 2 - 5 ] ) ; y . domain ( yDomain || [ d3 . min ( data [ 0 ] . values . map ( getLow ) . concat ( forceY ) ) , d3 . max ( data [ 0 ] . values . map ( getHigh ) . concat ( forceY ) ) ] ) . range ( yRange || [ availableHeight , 0 ] ) ;
 // If scale's domain don't have a range, slightly adjust to make one... so a chart can show a single data point
 if ( identical ( x . domain ( ) [ 0 ] , x . domain ( ) [ 1 ] ) ) x . domain ( ) [ 0 ] ? x . domain ( [ x . domain ( ) [ 0 ] - x . domain ( ) [ 0 ] * 0.01 , x . domain ( ) [ 1 ] + x . domain ( ) [ 1 ] * 0.01 ] ) : x . domain ( [ - 1 , 1 ] ) ; if ( identical ( y . domain ( ) [ 0 ] , y . domain ( ) [ 1 ] ) ) y . domain ( ) [ 0 ] ? y . domain ( [ y . domain ( ) [ 0 ] + y . domain ( ) [ 0 ] * 0.01 , y . domain ( ) [ 1 ] - y . domain ( ) [ 1 ] * 0.01 ] ) : y . domain ( [ - 1 , 1 ] ) ;
 // Setup containers and skeleton of chart
 var wrap = d3 . select ( this ) . selectAll ( "g.nv-wrap.nv-ohlcBar" ) . data ( [ data [ 0 ] . values ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-ohlcBar" ) ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-ticks" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; container . on ( "click" , ( d , i ) { dispatch . chartClick ( data : d , index : i , pos : d3 . event , id : id ) ; } ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-chart-clip-path-" + id ) . append ( "rect" ) ; wrap . select ( "#nv-chart-clip-path-" + id + " rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; g . attr ( "clip-path" , clipEdge ? "url(#nv-chart-clip-path-" + id + ")" : "" ) ; var ticks = wrap . select ( ".nv-ticks" ) . selectAll ( ".nv-tick" ) . data ( ( d ) { return d ; } ) ; ticks . exit ( ) . remove ( ) ; ticks . enter ( ) . append ( "path" ) . attr ( "class" , ( d , i , j ) { return ( getOpen ( d , i ) > getClose ( d , i ) ? "nv-tick negative" : "nv-tick positive" ) + " nv-tick-" + j + "-" + i ; } ) . attr ( "d" , ( d , i ) { return "m0,0l0," + ( y ( getOpen ( d , i ) ) - y ( getHigh ( d , i ) ) ) + "l" + ( - w / 2 ) + ",0l" + ( w / 2 ) + ",0l0," + ( y ( getLow ( d , i ) ) - y ( getOpen ( d , i ) ) ) + "l0," + ( y ( getClose ( d , i ) ) - y ( getLow ( d , i ) ) ) + "l" + ( w / 2 ) + ",0l" + ( - w / 2 ) + ",0z" ; } ) . attr ( "transform" , ( d , i ) { return "translate(" + x ( getX ( d , i ) ) + "," + y ( getHigh ( d , i ) ) + ")" ; } ) . attr ( "fill" , ( d , i ) { return color [ 0 ] ; } ) . attr ( "stroke" , ( d , i ) { return color [ 0 ] ; } ) . attr ( "x" , 0 ) . attr ( "y" , ( d , i ) { return y ( Math . max ( 0 , getY ( d , i ) ) ) ; } ) . attr ( "height" , ( d , i ) { return Math . abs ( y ( getY ( d , i ) ) - y ( 0 ) ) ; } ) ;
 // the bar colors are controlled by CSS currently
 ticks . attr ( "class" , ( d , i , j ) { return ( getOpen ( d , i ) > getClose ( d , i ) ? "nv-tick negative" : "nv-tick positive" ) + " nv-tick-" + j + "-" + i ; } ) ; d3 . transition ( ticks ) . attr ( "transform" , ( d , i ) { return "translate(" + x ( getX ( d , i ) ) + "," + y ( getHigh ( d , i ) ) + ")" ; } ) . attr ( "d" , ( d , i ) { var w = ( availableWidth / data [ 0 ] . values . length ) * .9 ; return "m0,0l0," + ( y ( getOpen ( d , i ) ) - y ( getHigh ( d , i ) ) ) + "l" + ( - w / 2 ) + ",0l" + ( w / 2 ) + ",0l0," + ( y ( getLow ( d , i ) ) - y ( getOpen ( d , i ) ) ) + "l0," + ( y ( getClose ( d , i ) ) - y ( getLow ( d , i ) ) ) + "l" + ( w / 2 ) + ",0l" + ( - w / 2 ) + ",0z" ; } ) ; } ) ; return chart ; }
 //Create methods to allow outside functions to highlight a specific bar.
 chart . highlightPoint = ( pointIndex , isHoverOver ) { chart . clearHighlights ( ) ; container . select ( ".nv-ohlcBar .nv-tick-0-" + pointIndex ) . classed ( "hover" , isHoverOver ) ; } ; chart . clearHighlights = ( ) { container . select ( ".nv-ohlcBar .nv-tick.hover" ) . classed ( "hover" , false ) ; } ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , forceX : { "get" : ( ) { return forceX ; } , "set" : ( _ ) { forceX = _ ; } } , forceY : { "get" : ( ) { return forceY ; } , "set" : ( _ ) { forceY = _ ; } } , padData : { "get" : ( ) { return padData ; } , "set" : ( _ ) { padData = _ ; } } , clipEdge : { "get" : ( ) { return clipEdge ; } , "set" : ( _ ) { clipEdge = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , interactive : { "get" : ( ) { return interactive ; } , "set" : ( _ ) { interactive = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = _ ; } } , open : { "get" : ( ) { return getOpen ( ) ; } , "set" : ( _ ) { getOpen = _ ; } } , close : { "get" : ( ) { return getClose ( ) ; } , "set" : ( _ ) { getClose = _ ; } } , high : { "get" : ( ) { return getHigh ; } , "set" : ( _ ) { getHigh = _ ; } } , low : { "get" : ( ) { return getLow ; } , "set" : ( _ ) { getLow = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = _ . top != undefined ? _ . top : margin . top ; margin . right = _ . right != undefined ? _ . right : margin . right ; margin . bottom = _ . bottom != undefined ? _ . bottom : margin . bottom ; margin . left = _ . left != undefined ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ;
 // Code adapted from Jason Davies' "Parallel Coordinates"

 // http://bl.ocks.org/jasondavies/1341281
 nv . models . parallelCoordinates = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 30 , "right" : 0 , "bottom" : 10 , "left" : 0 } , width = null , height = null , availableWidth = null , availableHeight = null , x = d3 . scale . ordinal ( ) , y = { } , undefinedValuesLabel = "undefined values" , dimensionData = [ ] , enabledDimensions = [ ] , dimensionNames = [ ] , displayBrush = true , color = nv . utils . defaultColor ( ) , filters = [ ] , active = [ ] , dragging = [ ] , axisWithUndefinedValues = [ ] , lineTension = 1 , foreground , background , dimensions , line = d3 . svg . line ( ) , axis = d3 . svg . axis ( ) , dispatch = d3 . dispatch ( "brushstart" , "brush" , "brushEnd" , "dimensionsOrder" , "stateChange" , "elementClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" , "activeChanged" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; availableWidth = nv . utils . availableWidth ( width , container , margin ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; nv . utils . initSVG ( container ) ;
 //Convert old data to new format (name, values)
 if ( identical ( data [ 0 ] . values , undefined ) ) { var newData = [ ] ; data . forEach ( ( d ) { var val = { } ; var key = Object . keys ( d ) ; key . forEach ( ( k ) { if ( ! identical ( k , "name" ) ) val [ k ] = d [ k ] ; } ) ; newData . push ( key : d . name , values : val ) ; } ) ; data = newData ; } var dataValues = data . map ( ( d ) { return d . values ; } ) ; if ( identical ( active . length , 0 ) ) { active = data ; } ; dimensionNames = dimensionData . sort ( ( a , b ) { return a . currentPosition - b . currentPosition ; } ) . map ( ( d ) { return d . key ; } ) ; enabledDimensions = dimensionData . filter ( ( d ) { return ! d . disabled ; } ) ;
 // Setup Scales
 x . rangePoints ( [ 0 , availableWidth ] , 1 ) . domain ( enabledDimensions . map ( ( d ) { return d . key ; } ) ) ;
 //Set as true if all values on an axis are missing.

 // Extract the list of dimensions and create a scale for each.
 var oldDomainMaxValue = { } ; var displayMissingValuesline = false ; var currentTicks = [ ] ; dimensionNames . forEach ( ( d ) { var extent = d3 . extent ( dataValues , ( p ) { return + p [ d ] ; } ) ; var min = extent [ 0 ] ; var max = extent [ 1 ] ; var onlyUndefinedValues = false ;
 //If there is no values to display on an axis, set the extent to 0
 if ( isNaN ( min ) || isNaN ( max ) ) { onlyUndefinedValues = true ; min = 0 ; max = 0 ; }
 //Scale axis if there is only one value
 if ( identical ( min , max ) ) { min = min - 1 ; max = max + 1 ; } var f = filters . filter ( ( k ) { return k . dimension == d ; } ) ; if ( ! identical ( f . length , 0 ) ) {
 //If there is only NaN values, keep the existing domain.
 if ( onlyUndefinedValues ) { min = y [ d ] . domain ( ) [ 0 ] ; max = y [ d ] . domain ( ) [ 1 ] ; } else if ( ! f [ 0 ] . hasOnlyNaN && displayBrush ) { min = min > f [ 0 ] . extent [ 0 ] ? f [ 0 ] . extent [ 0 ] : min ; max = max < f [ 0 ] . extent [ 1 ] ? f [ 0 ] . extent [ 1 ] : max ; } else if ( f [ 0 ] . hasNaN ) { max = max < f [ 0 ] . extent [ 1 ] ? f [ 0 ] . extent [ 1 ] : max ; oldDomainMaxValue [ d ] = y [ d ] . domain ( ) [ 1 ] ; displayMissingValuesline = true ; } }
 //Use 90% of (availableHeight - 12) for the axis range, 12 reprensenting the space necessary to display "undefined values" text.

 //The remaining 10% are used to display the missingValue line.
 y [ d ] = d3 . scale . linear ( ) . domain ( [ min , max ] ) . range ( [ ( availableHeight - 12 ) * 0.9 , 0 ] ) ; axisWithUndefinedValues = [ ] ; y [ d ] . brush = d3 . svg . brush ( ) . y ( y [ d ] ) . on ( "brushstart" , brushstart ) . on ( "brush" , brush ) . on ( "brushend" , brushend ) ; } ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-parallelCoordinates" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-parallelCoordinates" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-parallelCoordinates background" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-parallelCoordinates foreground" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-parallelCoordinates missingValuesline" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; line . interpolate ( "cardinal" ) . tension ( lineTension ) ; axis . orient ( "left" ) ; var axisDrag = d3 . behavior . drag ( ) . on ( "dragstart" , dragStart ) . on ( "drag" , dragMove ) . on ( "dragend" , dragEnd ) ;
 //Add missing value line at the bottom of the chart
 var missingValuesline , missingValueslineText ; var step = x . range ( ) [ 1 ] - x . range ( ) [ 0 ] ; step = isNaN ( step ) ? x . range ( ) [ 0 ] : step ; if ( ! isNaN ( step ) ) { var lineData = [ 0 + step / 2 , availableHeight - 12 , availableWidth - step / 2 , availableHeight - 12 ] ; missingValuesline = wrap . select ( ".missingValuesline" ) . selectAll ( "line" ) . data ( [ lineData ] ) ; missingValuesline . enter ( ) . append ( "line" ) ; missingValuesline . exit ( ) . remove ( ) ; missingValuesline . attr ( "x1" , ( d ) { return d [ 0 ] ; } ) . attr ( "y1" , ( d ) { return d [ 1 ] ; } ) . attr ( "x2" , ( d ) { return d [ 2 ] ; } ) . attr ( "y2" , ( d ) { return d [ 3 ] ; } ) ;
 //Add the text "undefined values" under the missing value line
 missingValueslineText = wrap . select ( ".missingValuesline" ) . selectAll ( "text" ) . data ( [ undefinedValuesLabel ] ) ; missingValueslineText . append ( "text" ) . data ( [ undefinedValuesLabel ] ) ; missingValueslineText . enter ( ) . append ( "text" ) ; missingValueslineText . exit ( ) . remove ( ) ; missingValueslineText . attr ( "y" , availableHeight ) . attr ( "x" , availableWidth - 92 - step / 2 ) . text ( ( d ) { return d ; } ) ; }
 // Add grey background lines for context.
 background = wrap . select ( ".background" ) . selectAll ( "path" ) . data ( data ) ; background . enter ( ) . append ( "path" ) ; background . exit ( ) . remove ( ) ; background . attr ( "d" , path ) ;
 // Add blue foreground lines for focus.
 foreground = wrap . select ( ".foreground" ) . selectAll ( "path" ) . data ( data ) ; foreground . enter ( ) . append ( "path" ) ; foreground . exit ( ) . remove ( ) ; foreground . attr ( "d" , path ) . style ( "stroke-width" , ( d , i ) { if ( isNaN ( d . strokeWidth ) ) { d . strokeWidth = 1 ; } return d . strokeWidth ; } ) . attr ( "stroke" , ( d , i ) { return d . color || color ( d , i ) ; } ) ; foreground . on ( "mouseover" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , true ) . style ( "stroke-width" , d . strokeWidth + 2 + "px" ) . style ( "stroke-opacity" , 1 ) ; dispatch . elementMouseover ( label : d . name , color : d . color || color ( d , i ) , values : d . values , dimensions : enabledDimensions ) ; } ) ; foreground . on ( "mouseout" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) . style ( "stroke-width" , d . strokeWidth + "px" ) . style ( "stroke-opacity" , 0.7 ) ; dispatch . elementMouseout ( label : d . name , index : i ) ; } ) ; foreground . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( ) ; } ) ; foreground . on ( "click" , ( d ) { dispatch . elementClick ( id : d . id ) ; } ) ;
 // Add a group element for each dimension.
 dimensions = g . selectAll ( ".dimension" ) . data ( enabledDimensions ) ; var dimensionsEnter = dimensions . enter ( ) . append ( "g" ) . attr ( "class" , "nv-parallelCoordinates dimension" ) ; dimensions . attr ( "transform" , ( d ) { return "translate(" + x ( d . key ) + ",0)" ; } ) ; dimensionsEnter . append ( "g" ) . attr ( "class" , "nv-axis" ) ;
 // Add an axis and title.
 dimensionsEnter . append ( "text" ) . attr ( "class" , "nv-label" ) . style ( "cursor" , "move" ) . attr ( "dy" , "-1em" ) . attr ( "text-anchor" , "middle" ) . on ( "mouseover" , ( d , i ) { dispatch . elementMouseover ( label : d . tooltip || d . key , color : d . color ) ; } ) . on ( "mouseout" , ( d , i ) { dispatch . elementMouseout ( label : d . tooltip ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( ) ; } ) . call ( axisDrag ) ; dimensionsEnter . append ( "g" ) . attr ( "class" , "nv-brushBackground" ) ; dimensions . exit ( ) . remove ( ) ; dimensions . select ( ".nv-label" ) . text ( ( d ) { return d . key ; } ) ;
 // Add and store a brush for each axis.
 restoreBrush ( displayBrush ) ; var actives = dimensionNames . filter ( ( p ) { return ! y [ p ] . brush . empty ( ) ; } ) , extents = actives . map ( ( p ) { return y [ p ] . brush . extent ( ) ; } ) ; var formerActive = active . slice ( 0 ) ;
 //Restore active values
 active = [ ] ; foreground . style ( "display" , ( d ) { var isActive = actives . every ( ( p , i ) { if ( ( isNaN ( d . values [ p ] ) || isNaN ( parseFloat ( d . values [ p ] ) ) ) && extents [ i ] [ 0 ] == y [ p ] . brush . y ( ) . domain ( ) [ 0 ] ) { return true ; } return ( extents [ i ] [ 0 ] <= d . values [ p ] && d . values [ p ] <= extents [ i ] [ 1 ] ) && ! isNaN ( parseFloat ( d . values [ p ] ) ) ; } ) ; if ( isActive ) active . push ( d ) ; return ! isActive ? "none" : null ; } ) ; if ( filters . length > 0 || ! nv . utils . arrayEquals ( active , formerActive ) ) { dispatch . activeChanged ( active ) ; }
 // Returns the path for a given data point.
 path ( d ) { return line ( enabledDimensions . map ( ( p ) {
 //If value if missing, put the value on the missing value line
 if ( isNaN ( d . values [ p . key ] ) || isNaN ( parseFloat ( d . values [ p . key ] ) ) || displayMissingValuesline ) { var domain = y [ p . key ] . domain ( ) ; var range = y [ p . key ] . range ( ) ; var min = domain [ 0 ] - ( domain [ 1 ] - domain [ 0 ] ) / 9 ;
 //If it's not already the case, allow brush to select undefined values
 if ( axisWithUndefinedValues . indexOf ( p . key ) < 0 ) { var newscale = d3 . scale . linear ( ) . domain ( [ min , domain [ 1 ] ] ) . range ( [ availableHeight - 12 , range [ 1 ] ] ) ; y [ p . key ] . brush . y ( newscale ) ; axisWithUndefinedValues . push ( p . key ) ; } if ( isNaN ( d . values [ p . key ] ) || isNaN ( parseFloat ( d . values [ p . key ] ) ) ) { return [ x ( p . key ) , y [ p . key ] ( min ) ] ; } }
 //If parallelCoordinate contain missing values show the missing values line otherwise, hide it.
 if ( ! identical ( missingValuesline , undefined ) ) { if ( axisWithUndefinedValues . length > 0 || displayMissingValuesline ) { missingValuesline . style ( "display" , "inline" ) ; missingValueslineText . style ( "display" , "inline" ) ; } else { missingValuesline . style ( "display" , "none" ) ; missingValueslineText . style ( "display" , "none" ) ; } } return [ x ( p . key ) , y [ p . key ] ( d . values [ p . key ] ) ] ; } ) ) ; } restoreBrush ( visible ) { filters . forEach ( ( f ) {
 //If filter brushed NaN values, keep the brush on the bottom of the axis.
 var brushDomain = y [ f . dimension ] . brush . y ( ) . domain ( ) ; if ( f . hasOnlyNaN ) { f . extent [ 1 ] = ( y [ f . dimension ] . domain ( ) [ 1 ] - brushDomain [ 0 ] ) * ( f . extent [ 1 ] - f . extent [ 0 ] ) / ( oldDomainMaxValue [ f . dimension ] - f . extent [ 0 ] ) + brushDomain [ 0 ] ; } if ( f . hasNaN ) { f . extent [ 0 ] = brushDomain [ 0 ] ; } if ( visible ) y [ f . dimension ] . brush . extent ( f . extent ) ; } ) ; dimensions . select ( ".nv-brushBackground" ) . each ( ( d ) { d3 . select ( this ) . call ( y [ d . key ] . brush ) ; } ) . selectAll ( "rect" ) . attr ( "x" , - 8 ) . attr ( "width" , 16 ) ; updateTicks ( ) ; }
 // Handles a brush event, toggling the display of foreground lines.
 brushstart ( ) {
 //If brush aren't visible, show it before brushing again.
 if ( identical ( displayBrush , false ) ) { displayBrush = true ; restoreBrush ( true ) ; } }
 // Handles a brush event, toggling the display of foreground lines.
 brush ( ) { actives = dimensionNames . filter ( ( p ) { return ! y [ p ] . brush . empty ( ) ; } ) ; extents = actives . map ( ( p ) { return y [ p ] . brush . extent ( ) ; } ) ; filters = [ ] ; actives . forEach ( ( d , i ) { filters [ i ] = { "dimension" : d , "extent" : extents [ i ] , "hasNaN" : false , "hasOnlyNaN" : false } ; } ) ; active = [ ] ; foreground . style ( "display" , ( d ) { var isActive = actives . every ( ( p , i ) { if ( ( isNaN ( d . values [ p ] ) || isNaN ( parseFloat ( d . values [ p ] ) ) ) && extents [ i ] [ 0 ] == y [ p ] . brush . y ( ) . domain ( ) [ 0 ] ) return true ; return ( extents [ i ] [ 0 ] <= d . values [ p ] && d . values [ p ] <= extents [ i ] [ 1 ] ) && ! isNaN ( parseFloat ( d . values [ p ] ) ) ; } ) ; if ( isActive ) active . push ( d ) ; return isActive ? null : "none" ; } ) ; updateTicks ( ) ; dispatch . brush ( filters : filters , active : active ) ; } brushend ( ) { var hasActiveBrush = actives . length > 0 ? true : false ; filters . forEach ( ( f ) { if ( identical ( f . extent [ 0 ] , y [ f . dimension ] . brush . y ( ) . domain ( ) [ 0 ] ) && axisWithUndefinedValues . indexOf ( f . dimension ) >= 0 ) f . hasNaN = true ; if ( f . extent [ 1 ] < y [ f . dimension ] . domain ( ) [ 0 ] ) f . hasOnlyNaN = true ; } ) ; dispatch . brushEnd ( active , hasActiveBrush ) ; } updateTicks ( ) { dimensions . select ( ".nv-axis" ) . each ( ( d , i ) { var f = filters . filter ( ( k ) { return k . dimension == d . key ; } ) ; currentTicks [ d . key ] = y [ d . key ] . domain ( ) ;
 //If brush are available, display brush extent
 if ( f . length != 0 && displayBrush ) { currentTicks [ d . key ] = [ ] ; if ( f [ 0 ] . extent [ 1 ] > y [ d . key ] . domain ( ) [ 0 ] ) currentTicks [ d . key ] = [ f [ 0 ] . extent [ 1 ] ] ; if ( f [ 0 ] . extent [ 0 ] >= y [ d . key ] . domain ( ) [ 0 ] ) currentTicks [ d . key ] . push ( f [ 0 ] . extent [ 0 ] ) ; } d3 . select ( this ) . call ( axis . scale ( y [ d . key ] ) . tickFormat ( d . format ) . tickValues ( currentTicks [ d . key ] ) ) ; } ) ; } dragStart ( d ) { dragging [ d . key ] = this . parentNode . ___origin__ = x ( d . key ) ; background . attr ( "visibility" , "hidden" ) ; } dragMove ( d ) { dragging [ d . key ] = Math . min ( availableWidth , Math . max ( 0 , this . parentNode . ___origin__ += d3 . event . x ) ) ; foreground . attr ( "d" , path ) ; enabledDimensions . sort ( ( a , b ) { return dimensionPosition ( a . key ) - dimensionPosition ( b . key ) ; } ) ; enabledDimensions . forEach ( ( d , i ) { return d . currentPosition = i ; } ) ; x . domain ( enabledDimensions . map ( ( d ) { return d . key ; } ) ) ; dimensions . attr ( "transform" , ( d ) { return "translate(" + dimensionPosition ( d . key ) + ")" ; } ) ; } dragEnd ( d , i ) { ; ; d3 . select ( this . parentNode ) . attr ( "transform" , "translate(" + x ( d . key ) + ")" ) ; foreground . attr ( "d" , path ) ; background . attr ( "d" , path ) . attr ( "visibility" , null ) ; dispatch . dimensionsOrder ( enabledDimensions ) ; } dimensionPosition ( d ) { var v = dragging [ d ] ; return v == null ? x ( d ) : v ; } } ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , dimensionData : { "get" : ( ) { return dimensionData ; } , "set" : ( _ ) { dimensionData = _ ; } } , displayBrush : { "get" : ( ) { return displayBrush ; } , "set" : ( _ ) { displayBrush = _ ; } } , filters : { "get" : ( ) { return filters ; } , "set" : ( _ ) { filters = _ ; } } , active : { "get" : ( ) { return active ; } , "set" : ( _ ) { active = _ ; } } , lineTension : { "get" : ( ) { return lineTension ; } , "set" : ( _ ) { lineTension = _ ; } } , undefinedValuesLabel : { "get" : ( ) { return undefinedValuesLabel ; } , "set" : ( _ ) { undefinedValuesLabel = _ ; } } , dimensions : { "get" : ( ) { return dimensionData . map ( ( d ) { return d . key ; } ) ; } , "set" : ( _ ) {
 // deprecated after 1.8.1
 nv . deprecated ( "dimensions" , "use dimensionData instead" ) ; if ( identical ( dimensionData . length , 0 ) ) { _ . forEach ( ( k ) { dimensionData . push ( key : k ) ; } ) ; } else { _ . forEach ( ( k , i ) { dimensionData [ i ] . key = k ; } ) ; } } } , dimensionNames : { "get" : ( ) { return dimensionData . map ( ( d ) { return d . key ; } ) ; } , "set" : ( _ ) {
 // deprecated after 1.8.1
 nv . deprecated ( "dimensionNames" , "use dimensionData instead" ) ; dimensionNames = [ ] ; if ( identical ( dimensionData . length , 0 ) ) { _ . forEach ( ( k ) { dimensionData . push ( key : k ) ; } ) ; } else { _ . forEach ( ( k , i ) { dimensionData [ i ] . key = k ; } ) ; } } } , dimensionFormats : { "get" : ( ) { return dimensionData . map ( ( d ) { return d . format ; } ) ; } , "set" : ( _ ) {
 // deprecated after 1.8.1
 nv . deprecated ( "dimensionFormats" , "use dimensionData instead" ) ; if ( identical ( dimensionData . length , 0 ) ) { _ . forEach ( ( f ) { dimensionData . push ( format : f ) ; } ) ; } else { _ . forEach ( ( f , i ) { dimensionData [ i ] . format = f ; } ) ; } } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . parallelCoordinatesChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var parallelCoordinates = nv . models . parallelCoordinates ( ) ; var legend = nv . models . legend ( ) ; var tooltip = nv . models . tooltip ( ) ; var dimensionTooltip = nv . models . tooltip ( ) ; var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , marginTop = null , width = null , height = null , showLegend = true , color = nv . utils . defaultColor ( ) , state = nv . utils . state ( ) , dimensionData = [ ] , displayBrush = true , defaultState = null , noData = null , nanValue = "undefined" , dispatch = d3 . dispatch ( "dimensionsOrder" , "brushEnd" , "stateChange" , "changeState" , "renderEnd" ) , controlWidth = ( ) { return showControls ? 180 : 0 ; } ;
 //============================================================

 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . active , undefined ) ) { data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } } ; } ; tooltip . contentGenerator ( ( data ) { var str = "<table><thead><tr><td class=\"legend-color-guide\"><div style=\"background-color:" + data . color + "\"></div></td><td><strong>" + data . key + "</strong></td></tr></thead>" ; if ( ! identical ( data . series . length , 0 ) ) { str = str + "<tbody><tr><td height =\"10px\"></td></tr>" ; data . series . forEach ( ( d ) { str = str + "<tr><td class=\"legend-color-guide\"><div style=\"background-color:" + d . color + "\"></div></td><td class=\"key\">" + d . key + "</td><td class=\"value\">" + d . value + "</td></tr>" ; } ) ; str = str + "</tbody>" ; } str = str + "</table>" ; return str ; } ) ;
 //============================================================

 // Chart function

 //------------------------------------------------------------
 chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( parallelCoordinates ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var that = this ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { container . call ( chart ) ; } ; chart . container = this ; state . setter ( stateSetter ( dimensionData ) , chart . update ) . getter ( stateGetter ( dimensionData ) ) . update ( ) ;
 //set state.disabled
 state . disabled = dimensionData . map ( ( d ) { return ! ! d . disabled ; } ) ;
 //Keep dimensions position in memory
 dimensionData = dimensionData . map ( ( d ) { d . disabled = ! ! d . disabled ; return d ; } ) ; dimensionData . forEach ( ( d , i ) { d . originalPosition = isNaN ( d . originalPosition ) ? i : d . originalPosition ; d . currentPosition = isNaN ( d . currentPosition ) ? i : d . currentPosition ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 //------------------------------------------------------------

 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-parallelCoordinatesChart" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-parallelCoordinatesChart" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-parallelCoordinatesWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; g . select ( "rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , ( availableHeight > 0 ) ? availableHeight : 0 ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { legend . width ( availableWidth ) . color ( ( d ) { return "rgb(188,190,192)" ; } ) ; g . select ( ".nv-legendWrap" ) . datum ( dimensionData . sort ( ( a , b ) { return a . originalPosition - b . originalPosition ; } ) ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } wrap . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate( 0 ," + ( - margin . top ) + ")" ) ; } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // Main Chart Component(s)
 parallelCoordinates . width ( availableWidth ) . height ( availableHeight ) . dimensionData ( dimensionData ) . displayBrush ( displayBrush ) ; var parallelCoordinatesWrap = g . select ( ".nv-parallelCoordinatesWrap " ) . datum ( data ) ; parallelCoordinatesWrap . transition ( ) . call ( parallelCoordinates ) ;
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------

 //Display reset brush button
 parallelCoordinates . dispatch . on ( "brushEnd" , ( active , hasActiveBrush ) { if ( hasActiveBrush ) { displayBrush = true ; dispatch . brushEnd ( active ) ; } else { displayBrush = false ; } } ) ; legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) { state [ key ] = newState [ key ] ; } dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ;
 //Update dimensions order and display reset sorting button
 parallelCoordinates . dispatch . on ( "dimensionsOrder" , ( e ) { dimensionData . sort ( ( a , b ) { return a . currentPosition - b . currentPosition ; } ) ; var isSorted = false ; dimensionData . forEach ( ( d , i ) { d . currentPosition = i ; if ( ! identical ( d . currentPosition , d . originalPosition ) ) isSorted = true ; } ) ; dispatch . dimensionsOrder ( dimensionData , isSorted ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { dimensionData . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } chart . update ( ) ; } ) ; } ) ; renderWatch . renderEnd ( "parraleleCoordinateChart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 parallelCoordinates . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { var tp = { "key" : evt . label , "color" : evt . color , "series" : [ ] } ; if ( evt . values ) { Object . keys ( evt . values ) . forEach ( ( d ) { var dim = evt . dimensions . filter ( ( dd ) { return identical ( dd . key , d ) ; } ) [ 0 ] ; if ( dim ) { var v ; if ( isNaN ( evt . values [ d ] ) || isNaN ( parseFloat ( evt . values [ d ] ) ) ) { v = nanValue ; } else { v = dim . format ( evt . values [ d ] ) ; } tp . series . push ( idx : dim . currentPosition , key : d , value : v , color : dim . color ) ; } } ) ; tp . series . sort ( ( a , b ) { return a . idx - b . idx ; } ) ; } tooltip . data ( tp ) . hidden ( false ) ; } ) ; parallelCoordinates . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; parallelCoordinates . dispatch . on ( "elementMousemove.tooltip" , ( ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . parallelCoordinates = parallelCoordinates ; chart . legend = legend ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , dimensionData : { "get" : ( ) { return dimensionData ; } , "set" : ( _ ) { dimensionData = _ ; } } , displayBrush : { "get" : ( ) { return displayBrush ; } , "set" : ( _ ) { displayBrush = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , nanValue : { "get" : ( ) { return nanValue ; } , "set" : ( _ ) { nanValue = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; parallelCoordinates . color ( color ) ; } } ) ; nv . utils . inheritOptions ( chart , parallelCoordinates ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . pie = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 500 , height = 500 , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , id = Math . floor ( Math . random ( ) * 10000 ) , container = null , color = nv . utils . defaultColor ( ) , valueFormat = d3 . format ( ",.2f" ) , showLabels = true , labelsOutside = false , labelType = "key" , labelThreshold = .02 , hideOverlapLabels = false , donut = false , title = false , growOnHover = true , titleOffset = 0 , labelSunbeamLayout = false , startAngle = false , padAngle = false , endAngle = false , cornerRadius = 0 , donutRatio = 0.5 , duration = 250 , arcsRadius = [ ] , dispatch = d3 . dispatch ( "chartClick" , "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "elementMousemove" , "renderEnd" ) ; var arcs = [ ] ; var arcsOver = [ ] ;
 //============================================================

 // chart function

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom , radius = Math . min ( availableWidth , availableHeight ) / 2 , arcsRadiusOuter = [ ] , arcsRadiusInner = [ ] ; container = d3 . select ( this ) ; if ( identical ( arcsRadius . length , 0 ) ) { var outer = radius - radius / 10 ; var inner = donutRatio * radius ; for ( var i = 0 ; i < data [ 0 ] . length ; i ++ ) { arcsRadiusOuter . push ( outer ) ; arcsRadiusInner . push ( inner ) ; } } else { if ( growOnHover ) { arcsRadiusOuter = arcsRadius . map ( ( d ) { return ( d . outer - d . outer / 10 ) * radius ; } ) ; arcsRadiusInner = arcsRadius . map ( ( d ) { return ( d . inner - d . inner / 10 ) * radius ; } ) ; donutRatio = d3 . min ( arcsRadius . map ( ( d ) { return ( d . inner - d . inner / 10 ) ; } ) ) ; } else { arcsRadiusOuter = arcsRadius . map ( ( d ) { return d . outer * radius ; } ) ; arcsRadiusInner = arcsRadius . map ( ( d ) { return d . inner * radius ; } ) ; donutRatio = d3 . min ( arcsRadius . map ( ( d ) { return d . inner ; } ) ) ; } } nv . utils . initSVG ( container ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( ".nv-wrap.nv-pie" ) . data ( data ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-pie nv-chart-" + id ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; var g_pie = gEnter . append ( "g" ) . attr ( "class" , "nv-pie" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-pieLabels" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; g . select ( ".nv-pie" ) . attr ( "transform" , "translate(" + availableWidth / 2 + "," + availableHeight / 2 + ")" ) ; g . select ( ".nv-pieLabels" ) . attr ( "transform" , "translate(" + availableWidth / 2 + "," + availableHeight / 2 + ")" ) ;
 //
 container . on ( "click" , ( d , i ) { dispatch . chartClick ( data : d , index : i , pos : d3 . event , id : id ) ; } ) ; arcs = [ ] ; arcsOver = [ ] ; for ( var i = 0 ; i < data [ 0 ] . length ; i ++ ) { var arc = d3 . svg . arc ( ) . outerRadius ( arcsRadiusOuter [ i ] ) ; var arcOver = d3 . svg . arc ( ) . outerRadius ( arcsRadiusOuter [ i ] + 5 ) ; if ( ! identical ( startAngle , false ) ) { arc . startAngle ( startAngle ) ; arcOver . startAngle ( startAngle ) ; } if ( ! identical ( endAngle , false ) ) { arc . endAngle ( endAngle ) ; arcOver . endAngle ( endAngle ) ; } if ( donut ) { arc . innerRadius ( arcsRadiusInner [ i ] ) ; arcOver . innerRadius ( arcsRadiusInner [ i ] ) ; } if ( arc . cornerRadius && cornerRadius ) { arc . cornerRadius ( cornerRadius ) ; arcOver . cornerRadius ( cornerRadius ) ; } arcs . push ( arc ) ; arcsOver . push ( arcOver ) ; }
 // Setup the Pie chart and choose the data element
 var pie = d3 . layout . pie ( ) . sort ( null ) . value ( ( d ) { return d . disabled ? 0 : getY ( d ) ; } ) ;
 // padAngle added in d3 3.5
 if ( pie . padAngle && padAngle ) { pie . padAngle ( padAngle ) ; }
 // if title is specified and donut, put it in the middle
 if ( donut && title ) { g_pie . append ( "text" ) . attr ( "class" , "nv-pie-title" ) ; wrap . select ( ".nv-pie-title" ) . style ( "text-anchor" , "middle" ) . text ( ( d ) { return title ; } ) . style ( "font-size" , ( Math . min ( availableWidth , availableHeight ) ) * donutRatio * 2 / ( title . length + 2 ) + "px" ) . attr ( "dy" , "0.35em" ) . attr ( "transform" , ( d , i ) { return "translate(0, " + titleOffset + ")" ; } ) ; } var slices = wrap . select ( ".nv-pie" ) . selectAll ( ".nv-slice" ) . data ( pie ) ; var pieLabels = wrap . select ( ".nv-pieLabels" ) . selectAll ( ".nv-label" ) . data ( pie ) ; slices . exit ( ) . remove ( ) ; pieLabels . exit ( ) . remove ( ) ; var ae = slices . enter ( ) . append ( "g" ) ; ae . attr ( "class" , "nv-slice" ) ; ae . on ( "mouseover" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , true ) ; if ( growOnHover ) { d3 . select ( this ) . select ( "path" ) . transition ( ) . duration ( 70 ) . attr ( "d" , arcsOver [ i ] ) ; } dispatch . elementMouseover ( data : d . data , index : i , color : d3 . select ( this ) . style ( "fill" ) , percent : ( d . endAngle - d . startAngle ) / ( 2 * Math . PI ) ) ; } ) ; ae . on ( "mouseout" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) ; if ( growOnHover ) { d3 . select ( this ) . select ( "path" ) . transition ( ) . duration ( 50 ) . attr ( "d" , arcs [ i ] ) ; } dispatch . elementMouseout ( data : d . data , index : i ) ; } ) ; ae . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( data : d . data , index : i ) ; } ) ; ae . on ( "click" , ( d , i ) { var element = this ; dispatch . elementClick ( data : d . data , index : i , color : d3 . select ( this ) . style ( "fill" ) , event : d3 . event , element : element ) ; } ) ; ae . on ( "dblclick" , ( d , i ) { dispatch . elementDblClick ( data : d . data , index : i , color : d3 . select ( this ) . style ( "fill" ) ) ; } ) ; slices . attr ( "fill" , ( d , i ) { return color ( d . data , i ) ; } ) ; slices . attr ( "stroke" , ( d , i ) { return color ( d . data , i ) ; } ) ; var paths = ae . append ( "path" ) . each ( ( d ) { this . _current = d ; } ) ; slices . select ( "path" ) . transition ( ) . duration ( duration ) . attr ( "d" , ( d , i ) { return arcs [ i ] ( d ) ; } ) . attrTween ( "d" , arcTween ) ; if ( showLabels ) {
 // This does the normal label
 var labelsArc = [ ] ; for ( var i = 0 ; i < data [ 0 ] . length ; i ++ ) { labelsArc . push ( arcs [ i ] ) ; if ( labelsOutside ) { if ( donut ) { labelsArc [ i ] = d3 . svg . arc ( ) . outerRadius ( arcs [ i ] . outerRadius ( ) ) ; if ( ! identical ( startAngle , false ) ) labelsArc [ i ] . startAngle ( startAngle ) ; if ( ! identical ( endAngle , false ) ) labelsArc [ i ] . endAngle ( endAngle ) ; } } else if ( ! donut ) { labelsArc [ i ] . innerRadius ( 0 ) ; } } pieLabels . enter ( ) . append ( "g" ) . classed ( "nv-label" , true ) . each ( ( d , i ) { var group = d3 . select ( this ) ; group . attr ( "transform" , ( d , i ) { if ( labelSunbeamLayout ) { d . outerRadius = arcsRadiusOuter [ i ] + 10 ; d . innerRadius = arcsRadiusOuter [ i ] + 15 ; var rotateAngle = ( d . startAngle + d . endAngle ) / 2 * ( 180 / Math . PI ) ; if ( ( d . startAngle + d . endAngle ) / 2 < Math . PI ) { rotateAngle -= 90 ; } else { rotateAngle += 90 ; } return "translate(" + labelsArc [ i ] . centroid ( d ) + ") rotate(" + rotateAngle + ")" ; } else { d . outerRadius = radius + 10 ; d . innerRadius = radius + 15 ; return "translate(" + labelsArc [ i ] . centroid ( d ) + ")" ; } } ) ; group . append ( "rect" ) . style ( "stroke" , "#fff" ) . style ( "fill" , "#fff" ) . attr ( "rx" , 3 ) . attr ( "ry" , 3 ) ; group . append ( "text" ) . style ( "text-anchor" , labelSunbeamLayout ? ( ( d . startAngle + d . endAngle ) / 2 < Math . PI ? "start" : "end" ) : "middle" ) . style ( "fill" , "#000" ) ; } ) ; var labelLocationHash = { } ; var avgHeight = 14 ; var avgWidth = 140 ; var createHashKey = ( coordinates ) { return Math . floor ( coordinates [ 0 ] / avgWidth ) * avgWidth + "," + Math . floor ( coordinates [ 1 ] / avgHeight ) * avgHeight ; } ; var getSlicePercentage = ( d ) { return ( d . endAngle - d . startAngle ) / ( 2 * Math . PI ) ; } ; pieLabels . watchTransition ( renderWatch , "pie labels" ) . attr ( "transform" , ( d , i ) { if ( labelSunbeamLayout ) { d . outerRadius = arcsRadiusOuter [ i ] + 10 ; d . innerRadius = arcsRadiusOuter [ i ] + 15 ; var rotateAngle = ( d . startAngle + d . endAngle ) / 2 * ( 180 / Math . PI ) ; if ( ( d . startAngle + d . endAngle ) / 2 < Math . PI ) { rotateAngle -= 90 ; } else { rotateAngle += 90 ; } return "translate(" + labelsArc [ i ] . centroid ( d ) + ") rotate(" + rotateAngle + ")" ; } else { d . outerRadius = radius + 10 ; d . innerRadius = radius + 15 ;
 /*
                        Overlapping pie labels are not good. What this attempts to do is, prevent overlapping.
                        Each label location is hashed, and if a hash collision occurs, we assume an overlap.
                        Adjust the label's y-position to remove the overlap.
                        */
 var center = labelsArc [ i ] . centroid ( d ) ; var percent = getSlicePercentage ( d ) ; if ( d . value && percent >= labelThreshold ) { var hashKey = createHashKey ( center ) ; if ( labelLocationHash [ hashKey ] ) { center [ 1 ] -= avgHeight ; } labelLocationHash [ createHashKey ( center ) ] = true ; } return "translate(" + center + ")" ; } } ) ; pieLabels . select ( ".nv-label text" ) . style ( "text-anchor" , ( d , i ) {
 //center the text on it's origin or begin/end if orthogonal aligned
 return labelSunbeamLayout ? ( ( d . startAngle + d . endAngle ) / 2 < Math . PI ? "start" : "end" ) : "middle" ; } ) . text ( ( d , i ) { var percent = getSlicePercentage ( d ) ; var label = "" ; if ( ! d . value || percent < labelThreshold ) return "" ; if ( identical ( , "function" ) ) { label = labelType ( d , i , { "key" : getX ( d . data ) , "value" : getY ( d . data ) , "percent" : valueFormat ( percent ) } ) ; } else { switch ( labelType ) { case "key" : label = getX ( d . data ) ; break ; case "value" : label = valueFormat ( getY ( d . data ) ) ; break ; case "percent" : label = d3 . format ( "%" ) ( percent ) ; break ; } } return label ; } ) ; if ( hideOverlapLabels ) { pieLabels . each ( ( d , i ) { if ( ! this . getBBox ) return ; var bb = this . getBBox ( ) , center = labelsArc [ i ] . centroid ( d ) ; var topLeft = { "x" : center [ 0 ] + bb . x , "y" : center [ 1 ] + bb . y } ; var topRight = { "x" : topLeft . x + bb . width , "y" : topLeft . y } ; var bottomLeft = { "x" : topLeft . x , "y" : topLeft . y + bb . height } ; var bottomRight = { "x" : topLeft . x + bb . width , "y" : topLeft . y + bb . height } ; d . visible = nv . utils . pointIsInArc ( topLeft , d , arc ) && nv . utils . pointIsInArc ( topRight , d , arc ) && nv . utils . pointIsInArc ( bottomLeft , d , arc ) && nv . utils . pointIsInArc ( bottomRight , d , arc ) ; } ) . style ( "display" , ( d ) { return d . visible ? null : "none" ; } ) ; } }
 // Computes the angle of an arc, converting from radians to degrees.
 angle ( d ) { var a = ( d . startAngle + d . endAngle ) * 90 / Math . PI - 90 ; return a > 90 ? a - 180 : a ; } arcTween ( a , idx ) { a . endAngle = isNaN ( a . endAngle ) ? 0 : a . endAngle ; a . startAngle = isNaN ( a . startAngle ) ? 0 : a . startAngle ; if ( ! donut ) a . innerRadius = 0 ; var i = d3 . interpolate ( this . _current , a ) ; this . _current = i ( 0 ) ; return ( t ) { return arcs [ idx ] ( i ( t ) ) ; } ; } } ) ; renderWatch . renderEnd ( "pie immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , arcsRadius : { "get" : ( ) { return arcsRadius ; } , "set" : ( _ ) { arcsRadius = _ ; } } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLabels : { "get" : ( ) { return showLabels ; } , "set" : ( _ ) { showLabels = _ ; } } , title : { "get" : ( ) { return title ; } , "set" : ( _ ) { title = _ ; } } , titleOffset : { "get" : ( ) { return titleOffset ; } , "set" : ( _ ) { titleOffset = _ ; } } , labelThreshold : { "get" : ( ) { return labelThreshold ; } , "set" : ( _ ) { labelThreshold = _ ; } } , hideOverlapLabels : { "get" : ( ) { return hideOverlapLabels ; } , "set" : ( _ ) { hideOverlapLabels = _ ; } } , valueFormat : { "get" : ( ) { return valueFormat ; } , "set" : ( _ ) { valueFormat = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , endAngle : { "get" : ( ) { return endAngle ; } , "set" : ( _ ) { endAngle = _ ; } } , startAngle : { "get" : ( ) { return startAngle ; } , "set" : ( _ ) { startAngle = _ ; } } , padAngle : { "get" : ( ) { return padAngle ; } , "set" : ( _ ) { padAngle = _ ; } } , cornerRadius : { "get" : ( ) { return cornerRadius ; } , "set" : ( _ ) { cornerRadius = _ ; } } , donutRatio : { "get" : ( ) { return donutRatio ; } , "set" : ( _ ) { donutRatio = _ ; } } , labelsOutside : { "get" : ( ) { return labelsOutside ; } , "set" : ( _ ) { labelsOutside = _ ; } } , labelSunbeamLayout : { "get" : ( ) { return labelSunbeamLayout ; } , "set" : ( _ ) { labelSunbeamLayout = _ ; } } , donut : { "get" : ( ) { return donut ; } , "set" : ( _ ) { donut = _ ; } } , growOnHover : { "get" : ( ) { return growOnHover ; } , "set" : ( _ ) { growOnHover = _ ; } } , pieLabelsOutside : { "get" : ( ) { return labelsOutside ; } , "set" : ( _ ) { labelsOutside = _ ; nv . deprecated ( "pieLabelsOutside" , "use labelsOutside instead" ) ; } } , donutLabelsOutside : { "get" : ( ) { return labelsOutside ; } , "set" : ( _ ) { labelsOutside = _ ; nv . deprecated ( "donutLabelsOutside" , "use labelsOutside instead" ) ; } } , labelFormat : { "get" : ( ) { return valueFormat ; } , "set" : ( _ ) { valueFormat = _ ; nv . deprecated ( "labelFormat" , "use valueFormat instead" ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = != "undefined" ? _ . top : margin . top ; margin . right = != "undefined" ? _ . right : margin . right ; margin . bottom = != "undefined" ? _ . bottom : margin . bottom ; margin . left = != "undefined" ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = d3 . functor ( _ ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , labelType : { "get" : ( ) { return labelType ; } , "set" : ( _ ) { labelType = _ || "key" ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . pieChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var pie = nv . models . pie ( ) ; var legend = nv . models . legend ( ) ; var tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 20 , "bottom" : 20 , "left" : 20 } , marginTop = null , width = null , height = null , showTooltipPercent = false , showLegend = true , legendPosition = "top" , color = nv . utils . defaultColor ( ) , state = nv . utils . state ( ) , defaultState = null , noData = null , duration = 250 , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) ; tooltip . duration ( 0 ) . headerEnabled ( false ) . valueFormatter ( ( d , i ) { return pie . valueFormat ( ) ( d , i ) ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . active , undefined ) ) { data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } } ; } ;
 //============================================================

 // Chart function

 //------------------------------------------------------------
 chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( pie ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var that = this ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { container . transition ( ) . call ( chart ) ; } ; chart . container = this ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 //set state.disabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-pieChart" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-pieChart" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-pieWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { if ( identical ( legendPosition , "top" ) ) { legend . width ( availableWidth ) . key ( pie . x ( ) ) ; wrap . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } wrap . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) ; } else if ( identical ( legendPosition , "right" ) ) { var legendWidth = nv . models . legend ( ) . width ( ) ; if ( availableWidth / 2 < legendWidth ) { legendWidth = ( availableWidth / 2 ) ; } legend . height ( availableHeight ) . key ( pie . x ( ) ) ; legend . width ( legendWidth ) ; availableWidth -= legend . width ( ) ; wrap . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) . attr ( "transform" , "translate(" + ( availableWidth ) + ",0)" ) ; } else if ( identical ( legendPosition , "bottom" ) ) { legend . width ( availableWidth ) . key ( pie . x ( ) ) ; wrap . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; margin . bottom = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; wrap . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + availableHeight + ")" ) ; } } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // Main Chart Component(s)
 pie . width ( availableWidth ) . height ( availableHeight ) ; var pieWrap = g . select ( ".nv-pieWrap" ) . datum ( [ data ] ) ; d3 . transition ( pieWrap ) . call ( pie ) ;
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) { state [ key ] = newState [ key ] ; } dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } chart . update ( ) ; } ) ; } ) ; renderWatch . renderEnd ( "pieChart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 pie . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt [ "series" ] = { "key" : chart . x ( ) ( evt . data ) , "value" : chart . y ( ) ( evt . data ) , "color" : evt . color , "percent" : evt . percent } ; if ( ! showTooltipPercent ) { ; ; } tooltip . data ( evt ) . hidden ( false ) ; } ) ; pie . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; pie . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . legend = legend ; chart . dispatch = dispatch ; chart . pie = pie ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ;
 // use Object get/set functionality to map between vars and chart functions
 chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , showTooltipPercent : { "get" : ( ) { return showTooltipPercent ; } , "set" : ( _ ) { showTooltipPercent = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , legendPosition : { "get" : ( ) { return legendPosition ; } , "set" : ( _ ) { legendPosition = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = _ ; legend . color ( color ) ; pie . color ( color ) ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; pie . duration ( duration ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } ) ; nv . utils . inheritOptions ( chart , pie ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . sankey = ( ) { "use strict" ;
 // Sources:

 // - https://bost.ocks.org/mike/sankey/

 // - https://github.com/soxofaan/d3-plugin-captain-sankey

 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var sankey = { } , nodeWidth = 24 , nodePadding = 8 , size = [ 1 , 1 ] , nodes = [ ] , links = [ ] , sinksRight = true ; var layout = ( iterations ) { computeNodeLinks ( ) ; computeNodeValues ( ) ; computeNodeBreadths ( ) ; computeNodeDepths ( iterations ) ; } ; var relayout = ( ) { computeLinkDepths ( ) ; } ;
 // SVG path data generator, to be used as 'd' attribute on 'path' element selection.
 var link = ( ) { var curvature = .5 ; link ( d ) { var x0 = d . source . x + d . source . dx , x1 = d . target . x , xi = d3 . interpolateNumber ( x0 , x1 ) , x2 = xi ( curvature ) , x3 = xi ( 1 - curvature ) , y0 = d . source . y + d . sy + d . dy / 2 , y1 = d . target . y + d . ty + d . dy / 2 ; var linkPath = "M" + x0 + "," + y0 + "C" + x2 + "," + y0 + " " + x3 + "," + y1 + " " + x1 + "," + y1 ; return linkPath ; } link . curvature = ( _ ) { if ( ! arguments . length ) return curvature ; curvature = + _ ; return link ; } ; return link ; } ;
 // Y-position of the middle of a node.
 var center = ( node ) { return node . y + node . dy / 2 ; } ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------

 // Populate the sourceLinks and targetLinks for each node.

 // Also, if the source and target are not objects, assume they are indices.
 computeNodeLinks ( ) { nodes . forEach ( ( node ) {
 // Links that have this node as source.
 node . sourceLinks = [ ] ;
 // Links that have this node as target.
 node . targetLinks = [ ] ; } ) ; links . forEach ( ( link ) { var source = link . source , target = link . target ; if ( identical ( , "number" ) ) source = link . source = nodes [ link . source ] ; if ( identical ( , "number" ) ) target = link . target = nodes [ link . target ] ; source . sourceLinks . push ( link ) ; target . targetLinks . push ( link ) ; } ) ; }
 // Compute the value (size) of each node by summing the associated links.
 computeNodeValues ( ) { nodes . forEach ( ( node ) { node . value = Math . max ( d3 . sum ( node . sourceLinks , value ) , d3 . sum ( node . targetLinks , value ) ) ; } ) ; }
 // Iteratively assign the breadth (x-position) for each node.

 // Nodes are assigned the maximum breadth of incoming neighbors plus one;

 // nodes with no incoming links are assigned breadth zero, while

 // nodes with no outgoing links are assigned the maximum breadth.
 computeNodeBreadths ( ) {
 //
 var remainingNodes = nodes , nextNodes , x = 0 ;
 // Work from left to right.

 // Keep updating the breath (x-position) of nodes that are target of recently updated nodes.

 //
 while ( remainingNodes . length && x < nodes . length ) { nextNodes = [ ] ; remainingNodes . forEach ( ( node ) { node . x = x ; node . dx = nodeWidth ; node . sourceLinks . forEach ( ( link ) { if ( nextNodes . indexOf ( link . target ) < 0 ) { nextNodes . push ( link . target ) ; } } ) ; } ) ; remainingNodes = nextNodes ; ++ x ; }
 // Optionally move pure sinks always to the right.
 if ( sinksRight ) { moveSinksRight ( x ) ; } scaleNodeBreadths ( ( size [ 0 ] - nodeWidth ) / ( x - 1 ) ) ; } moveSourcesRight ( ) { nodes . forEach ( ( node ) { if ( ! node . targetLinks . length ) { node . x = d3 . min ( node . sourceLinks , ( d ) { return d . target . x ; } ) - 1 ; } } ) ; } moveSinksRight ( x ) { nodes . forEach ( ( node ) { if ( ! node . sourceLinks . length ) { node . x = x - 1 ; } } ) ; } scaleNodeBreadths ( kx ) { nodes . forEach ( ( node ) { node . x *= kx ; } ) ; }
 // Compute the depth (y-position) for each node.
 computeNodeDepths ( iterations ) {
 // Group nodes by breath.
 var nodesByBreadth = d3 . nest ( ) . key ( ( d ) { return d . x ; } ) . sortKeys ( d3 . ascending ) . entries ( nodes ) . map ( ( d ) { return d . values ; } ) ;
 //
 initializeNodeDepth ( ) ; resolveCollisions ( ) ; computeLinkDepths ( ) ; for ( var alpha = 1 ; iterations > 0 ; -- iterations ) { relaxRightToLeft ( alpha *= .99 ) ; resolveCollisions ( ) ; computeLinkDepths ( ) ; relaxLeftToRight ( alpha ) ; resolveCollisions ( ) ; computeLinkDepths ( ) ; } initializeNodeDepth ( ) {
 // Calculate vertical scaling factor.
 var ky = d3 . min ( nodesByBreadth , ( nodes ) { return ( size [ 1 ] - ( nodes . length - 1 ) * nodePadding ) / d3 . sum ( nodes , value ) ; } ) ; nodesByBreadth . forEach ( ( nodes ) { nodes . forEach ( ( node , i ) { node . y = i ; node . dy = node . value * ky ; } ) ; } ) ; links . forEach ( ( link ) { link . dy = link . value * ky ; } ) ; } relaxLeftToRight ( alpha ) { nodesByBreadth . forEach ( ( nodes , breadth ) { nodes . forEach ( ( node ) { if ( node . targetLinks . length ) {
 // Value-weighted average of the y-position of source node centers linked to this node.
 var y = d3 . sum ( node . targetLinks , weightedSource ) / d3 . sum ( node . targetLinks , value ) ; node . y += ( y - center ( node ) ) * alpha ; } } ) ; } ) ; weightedSource ( link ) { return ( link . source . y + link . sy + link . dy / 2 ) * link . value ; } } relaxRightToLeft ( alpha ) { nodesByBreadth . slice ( ) . reverse ( ) . forEach ( ( nodes ) { nodes . forEach ( ( node ) { if ( node . sourceLinks . length ) {
 // Value-weighted average of the y-positions of target nodes linked to this node.
 var y = d3 . sum ( node . sourceLinks , weightedTarget ) / d3 . sum ( node . sourceLinks , value ) ; node . y += ( y - center ( node ) ) * alpha ; } } ) ; } ) ; weightedTarget ( link ) { return ( link . target . y + link . ty + link . dy / 2 ) * link . value ; } } resolveCollisions ( ) { nodesByBreadth . forEach ( ( nodes ) { var node , dy , y0 = 0 , n = nodes . length , i ;
 // Push any overlapping nodes down.
 nodes . sort ( ascendingDepth ) ; for ( i = 0 ; i < n ; ++ i ) { node = nodes [ i ] ; dy = y0 - node . y ; if ( dy > 0 ) node . y += dy ; y0 = node . y + node . dy + nodePadding ; }
 // If the bottommost node goes outside the bounds, push it back up.
 dy = y0 - nodePadding - size [ 1 ] ; if ( dy > 0 ) { y0 = node . y -= dy ;
 // Push any overlapping nodes back up.
 for ( i = n - 2 ; i >= 0 ; -- i ) { node = nodes [ i ] ; dy = node . y + node . dy + nodePadding - y0 ; if ( dy > 0 ) node . y -= dy ; y0 = node . y ; } } } ) ; } ascendingDepth ( a , b ) { return a . y - b . y ; } }
 // Compute y-offset of the source endpoint (sy) and target endpoints (ty) of links,

 // relative to the source/target node's y-position.
 computeLinkDepths ( ) { nodes . forEach ( ( node ) { node . sourceLinks . sort ( ascendingTargetDepth ) ; node . targetLinks . sort ( ascendingSourceDepth ) ; } ) ; nodes . forEach ( ( node ) { var sy = 0 , ty = 0 ; node . sourceLinks . forEach ( ( link ) { link . sy = sy ; sy += link . dy ; } ) ; node . targetLinks . forEach ( ( link ) { link . ty = ty ; ty += link . dy ; } ) ; } ) ; ascendingSourceDepth ( a , b ) { return a . source . y - b . source . y ; } ascendingTargetDepth ( a , b ) { return a . target . y - b . target . y ; } }
 // Value property accessor.
 value ( x ) { return x . value ; } sankey . options = nv . utils . optionsFunc . bind ( sankey ) ; sankey . _options = Object . create ( { } , nodeWidth : { "get" : ( ) { return nodeWidth ; } , "set" : ( _ ) { nodeWidth = + _ ; } } , nodePadding : { "get" : ( ) { return nodePadding ; } , "set" : ( _ ) { nodePadding = _ ; } } , nodes : { "get" : ( ) { return nodes ; } , "set" : ( _ ) { nodes = _ ; } } , links : { "get" : ( ) { return links ; } , "set" : ( _ ) { links = _ ; } } , size : { "get" : ( ) { return size ; } , "set" : ( _ ) { size = _ ; } } , sinksRight : { "get" : ( ) { return sinksRight ; } , "set" : ( _ ) { sinksRight = _ ; } } , layout : { "get" : ( ) { layout ( 32 ) ; } , "set" : ( _ ) { layout ( _ ) ; } } , relayout : { "get" : ( ) { relayout ( ) ; } , "set" : ( _ ) { } } , center : { "get" : ( ) { return center ( ) ; } , "set" : ( _ ) { if ( identical ( , "function" ) ) { center = _ ; } } } , link : { "get" : ( ) { return link ( ) ; } , "set" : ( _ ) { if ( identical ( , "function" ) ) { link = _ ; } return link ( ) ; } } ) ; nv . utils . initOptions ( sankey ) ; return sankey ; } ; nv . models . sankeyChart = ( ) { "use strict" ;
 // Sources:

 // - https://bost.ocks.org/mike/sankey/

 // - https://github.com/soxofaan/d3-plugin-captain-sankey

 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 5 , "right" : 0 , "bottom" : 5 , "left" : 0 } , sankey = nv . models . sankey ( ) , width = 600 , height = 400 , nodeWidth = 36 , nodePadding = 40 , units = "units" , center = undefined ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var formatNumber = d3 . format ( ",.0f" ) ; var format = ( d ) { return formatNumber ( d ) + " " + units ; } ; var color = d3 . scale . category20 ( ) ; var linkTitle = ( d ) { return d . source . name + " → " + d . target . name + "\n" + format ( d . value ) ; } ; var nodeFillColor = ( d ) { return d . color = color ( d . name . replace ( new RegExp ( r' .*' ) , "" ) ) ; } ; var nodeStrokeColor = ( d ) { return d3 . rgb ( d . color ) . darker ( 2 ) ; } ; var nodeTitle = ( d ) { return d . name + "\n" + format ( d . value ) ; } ; var showError = ( element , message ) { element . append ( "text" ) . attr ( "x" , 0 ) . attr ( "y" , 0 ) . attr ( "class" , "nvd3-sankey-chart-error" ) . attr ( "text-anchor" , "middle" ) . text ( message ) ; } ; chart ( selection ) { selection . each ( ( data ) { var testData = { "nodes" : [ { "node" : 1 , "name" : "Test 1" } , { "node" : 2 , "name" : "Test 2" } , { "node" : 3 , "name" : "Test 3" } , { "node" : 4 , "name" : "Test 4" } , { "node" : 5 , "name" : "Test 5" } , { "node" : 6 , "name" : "Test 6" } ] , "links" : [ { "source" : 0 , "target" : 1 , "value" : 2295 } , { "source" : 0 , "target" : 5 , "value" : 1199 } , { "source" : 1 , "target" : 2 , "value" : 1119 } , { "source" : 1 , "target" : 5 , "value" : 1176 } , { "source" : 2 , "target" : 3 , "value" : 487 } , { "source" : 2 , "target" : 5 , "value" : 632 } , { "source" : 3 , "target" : 4 , "value" : 301 } , { "source" : 3 , "target" : 5 , "value" : 186 } ] } ;
 // Error handling
 var isDataValid = false ; var dataAvailable = false ;
 // check if data is valid
 if ( ( identical ( , "object" ) && data [ "nodes" ] . length ) >= 0 && ( identical ( , "object" ) && data [ "links" ] . length ) >= 0 ) { isDataValid = true ; }
 // check if data is available
 if ( data [ "nodes" ] && data [ "nodes" ] . length > 0 && data [ "links" ] && data [ "links" ] . length > 0 ) { dataAvailable = true ; }
 // show error
 if ( ! isDataValid ) { console . error ( "NVD3 Sankey chart error:" , "invalid data format for" , data ) ; console . info ( "Valid data format is: " , testData , JSON . stringify ( testData ) ) ; showError ( selection , "Error loading chart, data is invalid" ) ; return false ; }
 // TODO use nv.utils.noData
 if ( ! dataAvailable ) { showError ( selection , "No data available" ) ; return false ; }
 // No errors, continue

 // append the svg canvas to the page
 var svg = selection . append ( "svg" ) . attr ( "width" , width ) . attr ( "height" , height ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-sankeyChart" ) ;
 // Set the sankey diagram properties
 sankey . nodeWidth ( nodeWidth ) . nodePadding ( nodePadding ) . size ( [ width , height ] ) ; var path = sankey . link ( ) ; sankey . nodes ( data . nodes ) . links ( data . links ) . layout ( 32 ) . center ( center ) ;
 // add in the links
 var link = svg . append ( "g" ) . selectAll ( ".link" ) . data ( data . links ) . enter ( ) . append ( "path" ) . attr ( "class" , "link" ) . attr ( "d" , path ) . style ( "stroke-width" , ( d ) { return Math . max ( 1 , d . dy ) ; } ) . sort ( ( a , b ) { return b . dy - a . dy ; } ) ;
 // add the link titles
 link . append ( "title" ) . text ( linkTitle ) ;
 // add in the nodes
 var node = svg . append ( "g" ) . selectAll ( ".node" ) . data ( data . nodes ) . enter ( ) . append ( "g" ) . attr ( "class" , "node" ) . attr ( "transform" , ( d ) { return "translate(" + d . x + "," + d . y + ")" ; } ) . call ( d3 . behavior . drag ( ) . origin ( ( d ) { return d ; } ) . on ( "dragstart" , ( ) { this . parentNode . appendChild ( this ) ; } ) . on ( "drag" , dragmove ) ) ;
 // add the rectangles for the nodes
 node . append ( "rect" ) . attr ( "height" , ( d ) { return d . dy ; } ) . attr ( "width" , sankey . nodeWidth ( ) ) . style ( "fill" , nodeFillColor ) . style ( "stroke" , nodeStrokeColor ) . append ( "title" ) . text ( nodeTitle ) ;
 // add in the title for the nodes
 node . append ( "text" ) . attr ( "x" , - 6 ) . attr ( "y" , ( d ) { return d . dy / 2 ; } ) . attr ( "dy" , ".35em" ) . attr ( "text-anchor" , "end" ) . attr ( "transform" , null ) . text ( ( d ) { return d . name ; } ) . filter ( ( d ) { return d . x < width / 2 ; } ) . attr ( "x" , 6 + sankey . nodeWidth ( ) ) . attr ( "text-anchor" , "start" ) ;
 // the function for moving the nodes
 dragmove ( d ) { d3 . select ( this ) . attr ( "transform" , "translate(" + d . x + "," + ( d . y = Math . max ( 0 , Math . min ( height - d . dy , d3 . event . y ) ) ) + ")" ) ; sankey . relayout ( ) ; link . attr ( "d" , path ) ; } } ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , units : { "get" : ( ) { return units ; } , "set" : ( _ ) { units = _ ; } } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , format : { "get" : ( ) { return format ; } , "set" : ( _ ) { format = _ ; } } , linkTitle : { "get" : ( ) { return linkTitle ; } , "set" : ( _ ) { linkTitle = _ ; } } , nodeWidth : { "get" : ( ) { return nodeWidth ; } , "set" : ( _ ) { nodeWidth = _ ; } } , nodePadding : { "get" : ( ) { return nodePadding ; } , "set" : ( _ ) { nodePadding = _ ; } } , center : { "get" : ( ) { return center ; } , "set" : ( _ ) { center = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , nodeStyle : { "get" : ( ) { return { } ; } , "set" : ( _ ) { nodeFillColor = ! identical ( _ . fillColor , undefined ) ? _ . fillColor : nodeFillColor ; nodeStrokeColor = ! identical ( _ . strokeColor , undefined ) ? _ . strokeColor : nodeStrokeColor ; nodeTitle = ! identical ( _ . title , undefined ) ? _ . title : nodeTitle ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . scatter = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = null , height = null , color = nv . utils . defaultColor ( ) , pointBorderColor = null , id = Math . floor ( Math . random ( ) * 100000 ) , container = null , x = d3 . scaleLinear ( ) , y = d3 . scaleLinear ( ) , z = d3 . scaleLinear ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , getSize = ( d ) { return d . size || 1 ; } , getShape = ( d ) { return d . shape || "circle" ; } , forceX = [ ] , forceY = [ ] , forceSize = [ ] , interactive = true , pointActive = ( d ) { return ! d . notActive ; } , padData = false , padDataOuter = .1 , clipEdge = false , clipVoronoi = true , showVoronoi = false , clipRadius = ( ) { return 25 ; } , xDomain = null , yDomain = null , xRange = null , yRange = null , sizeDomain = null , sizeRange = null , singlePoint = false , dispatch = d3 . dispatch ( "elementClick" , "elementDblClick" , "elementMouseover" , "elementMouseout" , "renderEnd" ) , useVoronoi = true , duration = 250 , interactiveUpdateDelay = 300 , showLabels = false ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var x0 , y0 , z0 , xDom , yDom , width0 , height0 , timeoutID , needsUpdate = false , renderWatch = nv . utils . renderWatch ( dispatch , duration ) , _sizeRange_def = [ 16 , 256 ] , _cache = { } ;
 //============================================================

 // Diff and Cache Utilities

 //------------------------------------------------------------

 // getDiffs is used to filter unchanged points from the update

 // selection. It implicitly updates it's cache when called and

 // therefor the diff is based upon the previous invocation NOT

 // the previous update.

 //

 // getDiffs takes a point as its first argument followed by n

 // key getter pairs (d, [key, get... key, get]) this approach

 // was chosen for efficiency. (The filter will call it a LOT).

 //

 // It is important to call delCache on point exit to prevent a

 // memory leak. It is also needed to prevent invalid caches if

 // a new point uses the same series and point id key.

 //

 // Argument Performance Concerns:

 // - Object property lists for key getter pairs would be very

 // expensive (points * objects for the GC every update).

 // - ES6 function names for implicit keys would be nice but

 // they are not guaranteed to be unique.

 // - function.toString to obtain implicit keys is possible

 // but long object keys are not free (internal hash).

 // - Explicit key without objects are the most efficient.
 getCache ( d ) { var key , val ; key = d [ 0 ] . series + ":" + d [ 1 ] ; val = _cache [ key ] = _cache [ key ] || { } ; return val ; } delCache ( d ) { var key , val ; key = d [ 0 ] . series + ":" + d [ 1 ] ; ; } getDiffs ( d ) { var i , key , val , cache = getCache ( d ) , diffs = false ; for ( i = 1 ; i < arguments . length ; i += 2 ) { key = arguments [ i ] ; val = arguments [ i + 1 ] ( d [ 0 ] , d [ 1 ] ) ; if ( ! identical ( cache [ key ] , val ) || ! cache . hasOwnProperty ( key ) ) { cache [ key ] = val ; diffs = true ; } } return diffs ; } chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { container = d3 . select ( this ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; nv . utils . initSVG ( container ) ;
 //add series index to each data point for reference
 data . forEach ( ( series , i ) { series . values . forEach ( ( point ) { point . series = i ; } ) ; } ) ;
 // Setup Scales
 var logScale = ( identical ( , "function" ) ) ;
 // remap and flatten the data for use in calculating the scales' domains
 var seriesData = ( xDomain && yDomain && sizeDomain ) ? [ ] : d3 . merge ( data . map ( ( d ) { return d . values . map ( ( d , i ) { return { "x" : getX ( d , i ) , "y" : getY ( d , i ) , "size" : getSize ( d , i ) } ; } ) ; } ) ) ; x . domain ( xDomain || d3 . extent ( seriesData . map ( ( d ) { return d . x ; } ) . concat ( forceX ) ) ) ; if ( padData && data [ 0 ] ) x . range ( xRange || [ ( availableWidth * padDataOuter + availableWidth ) / ( 2 * data [ 0 ] . values . length ) , availableWidth - availableWidth * ( 1 + padDataOuter ) / ( 2 * data [ 0 ] . values . length ) ] ) ; else x . range ( xRange || [ 0 , availableWidth ] ) ; if ( logScale ) { var min = d3 . min ( seriesData . map ( ( d ) { if ( ! identical ( d . y , 0 ) ) return d . y ; } ) ) ; y . clamp ( true ) . domain ( yDomain || d3 . extent ( seriesData . map ( ( d ) { if ( ! identical ( d . y , 0 ) ) return d . y ; else return min * 0.1 ; } ) . concat ( forceY ) ) ) . range ( yRange || [ availableHeight , 0 ] ) ; } else { y . domain ( yDomain || d3 . extent ( seriesData . map ( ( d ) { return d . y ; } ) . concat ( forceY ) ) ) . range ( yRange || [ availableHeight , 0 ] ) ; } z . domain ( sizeDomain || d3 . extent ( seriesData . map ( ( d ) { return d . size ; } ) . concat ( forceSize ) ) ) . range ( sizeRange || _sizeRange_def ) ;
 // If scale's domain don't have a range, slightly adjust to make one... so a chart can show a single data point
 singlePoint = identical ( x . domain ( ) [ 0 ] , x . domain ( ) [ 1 ] ) || identical ( y . domain ( ) [ 0 ] , y . domain ( ) [ 1 ] ) ; if ( identical ( x . domain ( ) [ 0 ] , x . domain ( ) [ 1 ] ) ) x . domain ( ) [ 0 ] ? x . domain ( [ x . domain ( ) [ 0 ] - x . domain ( ) [ 0 ] * 0.01 , x . domain ( ) [ 1 ] + x . domain ( ) [ 1 ] * 0.01 ] ) : x . domain ( [ - 1 , 1 ] ) ; if ( identical ( y . domain ( ) [ 0 ] , y . domain ( ) [ 1 ] ) ) y . domain ( ) [ 0 ] ? y . domain ( [ y . domain ( ) [ 0 ] - y . domain ( ) [ 0 ] * 0.01 , y . domain ( ) [ 1 ] + y . domain ( ) [ 1 ] * 0.01 ] ) : y . domain ( [ - 1 , 1 ] ) ; if ( isNaN ( x . domain ( ) [ 0 ] ) ) { x . domain ( [ - 1 , 1 ] ) ; } if ( isNaN ( y . domain ( ) [ 0 ] ) ) { y . domain ( [ - 1 , 1 ] ) ; } x0 = x0 || x ; y0 = y0 || y ; z0 = z0 || z ; var scaleDiff = ! identical ( x ( 1 ) , x0 ( 1 ) ) || ! identical ( y ( 1 ) , y0 ( 1 ) ) || ! identical ( z ( 1 ) , z0 ( 1 ) ) ; width0 = width0 || width ; height0 = height0 || height ; var sizeDiff = ! identical ( width0 , width ) || ! identical ( height0 , height ) ;
 // Domain Diffs
 xDom = xDom || [ ] ; var domainDiff = ! identical ( xDom [ 0 ] , x . domain ( ) [ 0 ] ) || ! identical ( xDom [ 1 ] , x . domain ( ) [ 1 ] ) ; xDom = x . domain ( ) ; yDom = yDom || [ ] ; domainDiff = domainDiff || ! identical ( yDom [ 0 ] , y . domain ( ) [ 0 ] ) || ! identical ( yDom [ 1 ] , y . domain ( ) [ 1 ] ) ; yDom = y . domain ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-scatter" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-scatter nv-chart-" + id ) . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; wrap . classed ( "nv-single-point" , singlePoint ) ; var nvGroups = gEnter . append ( "g" ) . attr ( "class" , "nv-groups" ) ; var nvPointPaths = gEnter . append ( "g" ) . attr ( "class" , "nv-point-paths" ) ; var nvPointClips = wrapEnter . append ( "g" ) . attr ( "class" , "nv-point-clips" ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-edge-clip-" + id ) . append ( "rect" ) . attr ( "transform" , "translate( -10, -10)" ) . attr ( "width" , availableWidth + 20 ) . attr ( "height" , ( availableHeight > 0 ) ? availableHeight + 20 : 0 ) ; gEnter . attr ( "clip-path" , clipEdge ? "url(#nv-edge-clip-" + id + ")" : "" ) ; updateInteractiveLayer ( ) {
 // Always clear needs-update flag regardless of whether or not

 // we will actually do anything (avoids needless invocations).
 needsUpdate = false ; if ( ! interactive ) return false ; container . selectAll ( ".nv-point.hover" ) . classed ( "hover" , false ) ;
 // nuke all voronoi paths
 nvPointPaths . selectAll ( "path" ) . remove ( ) ;
 // inject series and point index for reference into voronoi
 if ( identical ( useVoronoi , true ) ) { var vertices = d3 . merge ( data . map ( ( group , groupIndex ) { return group . values . map ( ( point , pointIndex ) {
 // *Adding noise to make duplicates very unlikely

 // *Injecting series and point index for reference

 // *Adding a 'jitter' to the points, because there's an issue in d3.geom.voronoi.
 var pX = getX ( point , pointIndex ) ; var pY = getY ( point , pointIndex ) ; return [ nv . utils . NaNtoZero ( x ( pX ) ) + Math . random ( ) * 1e-4 , nv . utils . NaNtoZero ( y ( pY ) ) + Math . random ( ) * 1e-4 , groupIndex , pointIndex , point ] ; } ) . filter ( ( pointArray , pointIndex ) { return pointActive ( pointArray [ 4 ] , pointIndex ) ; } ) ; } ) ) ; if ( vertices . length == 0 ) return false ; if ( vertices . length < 3 ) {
 // Issue #283 - Adding 2 dummy points to the voronoi b/c voronoi requires min 3 points to work
 vertices . push ( [ x . range ( ) [ 0 ] - 20 , y . range ( ) [ 0 ] - 20 , null , null ] ) ; vertices . push ( [ x . range ( ) [ 1 ] + 20 , y . range ( ) [ 1 ] + 20 , null , null ] ) ; vertices . push ( [ x . range ( ) [ 0 ] - 20 , y . range ( ) [ 0 ] + 20 , null , null ] ) ; vertices . push ( [ x . range ( ) [ 1 ] + 20 , y . range ( ) [ 1 ] - 20 , null , null ] ) ; }
 // keep voronoi sections from going more than 10 outside of graph

 // to avoid overlap with other things like legend etc
 var bounds = [ [ - 10 , - 10 ] , [ - 10 , height + 10 ] , [ width + 10 , height + 10 ] , [ width + 10 , - 10 ] ] ;
 // delete duplicates from vertices - essential assumption for d3.geom.voronoi
 var epsilon = 1e-4 ; vertices = vertices . sort ( ( a , b ) { return ( ( a [ 0 ] - b [ 0 ] ) || ( a [ 1 ] - b [ 1 ] ) ) ; } ) ; for ( var i = 0 ; i < vertices . length - 1 ; ) { if ( ( Math . abs ( vertices [ i ] [ 0 ] - vertices [ i + 1 ] [ 0 ] ) < epsilon ) && ( Math . abs ( vertices [ i ] [ 1 ] - vertices [ i + 1 ] [ 1 ] ) < epsilon ) ) { vertices . splice ( i + 1 , 1 ) ; } else { i ++ ; } } var voronoi = d3 . voronoi ( ) . extent ( [ bounds [ 0 ] , bounds [ 2 ] ] ) . polygons ( vertices ) . map ( ( d , i ) { return { "data" : d , "series" : vertices [ i ] [ 2 ] , "point" : vertices [ i ] [ 3 ] } ; } ) ; var pointPaths = nvPointPaths . selectAll ( "path" ) . data ( voronoi ) ; var vPointPaths = pointPaths . enter ( ) . append ( "svg:path" ) . attr ( "d" , ( d ) { if ( ! d || ! d . data || identical ( d . data . length , 0 ) ) return "M 0 0" ; else return "M" + d . data . join ( "," ) + "Z" ; } ) . attr ( "id" , ( d , i ) { return "nv-path-" + i ; } ) . attr ( "clip-path" , ( d , i ) { return "url(#nv-clip-" + id + "-" + i + ")" ; } ) ;
 // good for debugging point hover issues
 if ( showVoronoi ) { vPointPaths . style ( "fill" , d3 . rgb ( 230 , 230 , 230 ) ) . style ( "fill-opacity" , 0.4 ) . style ( "stroke-opacity" , 1 ) . style ( "stroke" , d3 . rgb ( 200 , 200 , 200 ) ) ; } if ( clipVoronoi ) {
 // voronoi sections are already set to clip,

 // just create the circles with the IDs they expect
 nvPointClips . selectAll ( "*" ) . remove ( ) ; var pointClips = nvPointClips . selectAll ( "clipPath" ) . data ( vertices ) ; var vPointClips = pointClips . enter ( ) . append ( "svg:clipPath" ) . attr ( "id" , ( d , i ) { return "nv-clip-" + id + "-" + i ; } ) . append ( "svg:circle" ) . attr ( "cx" , ( d ) { return d [ 0 ] ; } ) . attr ( "cy" , ( d ) { return d [ 1 ] ; } ) . attr ( "r" , clipRadius ) ; } var mouseEventCallback = ( el , d , mDispatch ) { if ( needsUpdate ) return 0 ; var series = data [ d . series ] ; if ( identical ( series , undefined ) ) return ; var point = series . values [ d . point ] ; point [ "color" ] = color ( series , d . series ) ;
 // standardize attributes for tooltip.
 point [ "x" ] = getX ( point ) ; point [ "y" ] = getY ( point ) ;
 // can't just get box of event node since it's actually a voronoi polygon
 var box = container . node ( ) . getBoundingClientRect ( ) ; var scrollTop = window . pageYOffset || document . documentElement . scrollTop ; var scrollLeft = window . pageXOffset || document . documentElement . scrollLeft ; var pos = { "left" : x ( getX ( point , d . point ) ) + box . left + scrollLeft + margin . left + 10 , "top" : y ( getY ( point , d . point ) ) + box . top + scrollTop + margin . top + 10 } ; dispatch . call ( mDispatch , this , point : point , series : series , pos : pos , relativePos : [ x ( getX ( point , d . point ) ) + margin . left , y ( getY ( point , d . point ) ) + margin . top ] , seriesIndex : d . series , pointIndex : d . point , event : d3 . event , element : el ) ; } ; vPointPaths . on ( "click" , ( d ) { mouseEventCallback ( this , d , "elementClick" ) ; } ) . on ( "dblclick" , ( d ) { mouseEventCallback ( this , d , "elementDblClick" ) ; } ) . on ( "mouseover" , ( d ) { mouseEventCallback ( this , d , "elementMouseover" ) ; } ) . on ( "mouseout" , ( d , i ) { mouseEventCallback ( this , d , "elementMouseout" ) ; } ) ; } else {
 // add event handlers to points instead voronoi paths
 nvGroups . selectAll ( ".nv-group" ) . selectAll ( ".nv-point" ) . on ( "click" , ( d , i ) {
 //nv.log('test', d, i);
 if ( needsUpdate || ! data [ d [ 0 ] . series ] ) return 0 ; var series = data [ d [ 0 ] . series ] , point = series . values [ i ] ; var element = this ; dispatch . elementClick ( point : point , series : series , pos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , relativePos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , seriesIndex : d [ 0 ] . series , pointIndex : i , event : d3 . event , element : element ) ; } ) . on ( "dblclick" , ( d , i ) { if ( needsUpdate || ! data [ d [ 0 ] . series ] ) return 0 ; var series = data [ d [ 0 ] . series ] , point = series . values [ i ] ; dispatch . elementDblClick ( point : point , series : series , pos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , relativePos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , seriesIndex : d [ 0 ] . series , pointIndex : i ) ; } ) . on ( "mouseover" , ( d , i ) { if ( needsUpdate || ! data [ d [ 0 ] . series ] ) return 0 ; var series = data [ d [ 0 ] . series ] , point = series . values [ i ] ; dispatch . elementMouseover ( point : point , series : series , pos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , relativePos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , seriesIndex : d [ 0 ] . series , pointIndex : i , color : color ( d [ 0 ] , i ) ) ; } ) . on ( "mouseout" , ( d , i ) { if ( needsUpdate || ! data [ d [ 0 ] . series ] ) return 0 ; var series = data [ d [ 0 ] . series ] , point = series . values [ i ] ; dispatch . elementMouseout ( point : point , series : series , pos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , relativePos : [ x ( getX ( point , i ) ) + margin . left , y ( getY ( point , i ) ) + margin . top ] , seriesIndex : d [ 0 ] . series , pointIndex : i , color : color ( d [ 0 ] , i ) ) ; } ) ; } } needsUpdate = true ; var groups = nvGroups . selectAll ( ".nv-group" ) . data ( ( d ) { return d ; } , ( d ) { return d . key ; } ) ; var gGroups = groups . enter ( ) . append ( "g" ) . style ( "stroke-opacity" , 1e-6 ) . style ( "fill-opacity" , 1e-6 ) ; groups . exit ( ) . remove ( ) ; gGroups . attr ( "class" , ( d , i ) { return ( d . classed || "" ) + " nv-group nv-series-" + i ; } ) . classed ( "nv-noninteractive" , ! interactive ) . classed ( "hover" , ( d ) { return d . hover ; } ) ; gGroups . watchTransition ( renderWatch , "scatter: groups" ) . style ( "fill" , ( d , i ) { return color ( d , i ) ; } ) . style ( "stroke" , ( d , i ) { return d . pointBorderColor || pointBorderColor || color ( d , i ) ; } ) . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , .5 ) ;
 // create the points, maintaining their IDs from the original data set
 var points = gGroups . selectAll ( "path.nv-point" ) . data ( ( d ) { return d . values . map ( ( point , pointIndex ) { return [ point , pointIndex ] ; } ) . filter ( ( pointArray , pointIndex ) { return pointActive ( pointArray [ 0 ] , pointIndex ) ; } ) ; } ) ; points . enter ( ) . append ( "path" ) . attr ( "class" , ( d ) { return "nv-point nv-point-" + d [ 1 ] ; } ) . style ( "fill" , ( d ) { return d . color ; } ) . style ( "stroke" , ( d ) { return d . color ; } ) . attr ( "transform" , ( d ) { return "translate(" + nv . utils . NaNtoZero ( x0 ( getX ( d [ 0 ] , d [ 1 ] ) ) ) + "," + nv . utils . NaNtoZero ( y0 ( getY ( d [ 0 ] , d [ 1 ] ) ) ) + ")" ; } ) . attr ( "d" , nv . utils . symbol ( ) . type ( ( d ) { return getShape ( d [ 0 ] ) ; } ) . size ( ( d ) { return z ( getSize ( d [ 0 ] , d [ 1 ] ) ) ; } ) ) ; points . exit ( ) . each ( delCache ) . remove ( ) ; groups . exit ( ) . selectAll ( "path.nv-point" ) . watchTransition ( renderWatch , "scatter exit" ) . attr ( "transform" , ( d ) { return "translate(" + nv . utils . NaNtoZero ( x ( getX ( d [ 0 ] , d [ 1 ] ) ) ) + "," + nv . utils . NaNtoZero ( y ( getY ( d [ 0 ] , d [ 1 ] ) ) ) + ")" ; } ) . remove ( ) ;
 //============================================================

 // Point Update Optimisation Notes

 //------------------------------------------------------------

 // The following update selections are filtered with getDiffs

 // (defined at the top of this file) this brings a performance

 // benefit for charts with large data sets that accumulate a

 // subset of changes or additions over time.

 //

 // Uneccesary and expensive DOM calls are avoided by culling

 // unchanged points from the selection in exchange for the

 // cheaper overhead of caching and diffing each point first.

 //

 // Due to the way D3 and NVD3 work, other global changes need

 // to be considered in addition to local point properties.

 // This is a potential source of bugs (if any of the global

 // changes that possibly affect points are missed).

 // Update Point Positions [x, y]
 points . filter ( ( d ) {
 // getDiffs must always be called to update cache
 return getDiffs ( d , "x" , getX , "y" , getY ) || scaleDiff || sizeDiff || domainDiff ; } ) . watchTransition ( renderWatch , "scatter points" ) . attr ( "transform" , ( d ) { return "translate(" + nv . utils . NaNtoZero ( x ( getX ( d [ 0 ] , d [ 1 ] ) ) ) + "," + nv . utils . NaNtoZero ( y ( getY ( d [ 0 ] , d [ 1 ] ) ) ) + ")" ; } ) ;
 // Update Point Appearance [shape, size]
 points . filter ( ( d ) {
 // getDiffs must always be called to update cache
 return getDiffs ( d , "shape" , getShape , "size" , getSize ) || scaleDiff || sizeDiff || domainDiff ; } ) . watchTransition ( renderWatch , "scatter points" ) . attr ( "d" , nv . utils . symbol ( ) . type ( ( d ) { return getShape ( d [ 0 ] ) ; } ) . size ( ( d ) { return z ( getSize ( d [ 0 ] , d [ 1 ] ) ) ; } ) ) ;
 // add label a label to scatter chart
 if ( showLabels ) { var titles = groups . selectAll ( ".nv-label" ) . data ( ( d ) { return d . values . map ( ( point , pointIndex ) { return [ point , pointIndex ] ; } ) . filter ( ( pointArray , pointIndex ) { return pointActive ( pointArray [ 0 ] , pointIndex ) ; } ) ; } ) ; titles . enter ( ) . append ( "text" ) . style ( "fill" , ( d , i ) { return d . color ; } ) . style ( "stroke-opacity" , 0 ) . style ( "fill-opacity" , 1 ) . attr ( "transform" , ( d ) { var dx = nv . utils . NaNtoZero ( x0 ( getX ( d [ 0 ] , d [ 1 ] ) ) ) + Math . sqrt ( z ( getSize ( d [ 0 ] , d [ 1 ] ) ) / Math . PI ) + 2 ; return "translate(" + dx + "," + nv . utils . NaNtoZero ( y0 ( getY ( d [ 0 ] , d [ 1 ] ) ) ) + ")" ; } ) . text ( ( d , i ) { return d [ 0 ] . label ; } ) ; titles . exit ( ) . remove ( ) ; groups . exit ( ) . selectAll ( "path.nv-label" ) . watchTransition ( renderWatch , "scatter exit" ) . attr ( "transform" , ( d ) { var dx = nv . utils . NaNtoZero ( x ( getX ( d [ 0 ] , d [ 1 ] ) ) ) + Math . sqrt ( z ( getSize ( d [ 0 ] , d [ 1 ] ) ) / Math . PI ) + 2 ; return "translate(" + dx + "," + nv . utils . NaNtoZero ( y ( getY ( d [ 0 ] , d [ 1 ] ) ) ) + ")" ; } ) . remove ( ) ; titles . each ( ( d ) { d3 . select ( this ) . classed ( "nv-label" , true ) . classed ( "nv-label-" + d [ 1 ] , false ) . classed ( "hover" , false ) ; } ) ; titles . watchTransition ( renderWatch , "scatter labels" ) . text ( ( d , i ) { return d [ 0 ] . label ; } ) . attr ( "transform" , ( d ) { var dx = nv . utils . NaNtoZero ( x ( getX ( d [ 0 ] , d [ 1 ] ) ) ) + Math . sqrt ( z ( getSize ( d [ 0 ] , d [ 1 ] ) ) / Math . PI ) + 2 ; return "translate(" + dx + "," + nv . utils . NaNtoZero ( y ( getY ( d [ 0 ] , d [ 1 ] ) ) ) + ")" ; } ) ; }
 // Delay updating the invisible interactive layer for smoother animation
 if ( interactiveUpdateDelay ) { clearTimeout ( timeoutID ) ; timeoutID = setTimeout ( updateInteractiveLayer , interactiveUpdateDelay ) ; } else { updateInteractiveLayer ( ) ; }
 //store old scales for use in transitions on update
 x0 = x . copy ( ) ; y0 = y . copy ( ) ; z0 = z . copy ( ) ; width0 = width ; height0 = height ; } ) ; renderWatch . renderEnd ( "scatter immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ;
 // utility function calls provided by this chart
 chart . _calls = new ( ) { this . clearHighlights = ( ) { nv . dom . write ( ( ) { container . selectAll ( ".nv-point.hover" ) . classed ( "hover" , false ) ; } ) ; return null ; } ; this . highlightPoint = ( seriesIndex , pointIndex , isHoverOver ) { nv . dom . write ( ( ) { container . select ( ".nv-groups" ) . selectAll ( ".nv-series-" + seriesIndex ) . selectAll ( ".nv-point-" + pointIndex ) . classed ( "hover" , isHoverOver ) ; } ) ; } ; } ( ) ;
 // trigger calls from events too
 dispatch . on ( "elementMouseover.point" , ( d ) { if ( interactive ) chart . _calls . highlightPoint ( d . seriesIndex , d . pointIndex , true ) ; } ) ; dispatch . on ( "elementMouseout.point" , ( d ) { if ( interactive ) chart . _calls . highlightPoint ( d . seriesIndex , d . pointIndex , false ) ; } ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , pointScale : { "get" : ( ) { return z ; } , "set" : ( _ ) { z = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , pointDomain : { "get" : ( ) { return sizeDomain ; } , "set" : ( _ ) { sizeDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , pointRange : { "get" : ( ) { return sizeRange ; } , "set" : ( _ ) { sizeRange = _ ; } } , forceX : { "get" : ( ) { return forceX ; } , "set" : ( _ ) { forceX = _ ; } } , forceY : { "get" : ( ) { return forceY ; } , "set" : ( _ ) { forceY = _ ; } } , forcePoint : { "get" : ( ) { return forceSize ; } , "set" : ( _ ) { forceSize = _ ; } } , interactive : { "get" : ( ) { return interactive ; } , "set" : ( _ ) { interactive = _ ; } } , pointActive : { "get" : ( ) { return pointActive ; } , "set" : ( _ ) { pointActive = _ ; } } , padDataOuter : { "get" : ( ) { return padDataOuter ; } , "set" : ( _ ) { padDataOuter = _ ; } } , padData : { "get" : ( ) { return padData ; } , "set" : ( _ ) { padData = _ ; } } , clipEdge : { "get" : ( ) { return clipEdge ; } , "set" : ( _ ) { clipEdge = _ ; } } , clipVoronoi : { "get" : ( ) { return clipVoronoi ; } , "set" : ( _ ) { clipVoronoi = _ ; } } , clipRadius : { "get" : ( ) { return clipRadius ; } , "set" : ( _ ) { clipRadius = _ ; } } , showVoronoi : { "get" : ( ) { return showVoronoi ; } , "set" : ( _ ) { showVoronoi = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , interactiveUpdateDelay : { "get" : ( ) { return interactiveUpdateDelay ; } , "set" : ( _ ) { interactiveUpdateDelay = _ ; } } , showLabels : { "get" : ( ) { return showLabels ; } , "set" : ( _ ) { showLabels = _ ; } } , pointBorderColor : { "get" : ( ) { return pointBorderColor ; } , "set" : ( _ ) { pointBorderColor = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = d3 . functor ( _ ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = d3 . functor ( _ ) ; } } , pointSize : { "get" : ( ) { return getSize ; } , "set" : ( _ ) { getSize = d3 . functor ( _ ) ; } } , pointShape : { "get" : ( ) { return getShape ; } , "set" : ( _ ) { getShape = d3 . functor ( _ ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , useVoronoi : { "get" : ( ) { return useVoronoi ; } , "set" : ( _ ) { useVoronoi = _ ; if ( identical ( useVoronoi , false ) ) { clipVoronoi = false ; } } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . scatterChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var scatter = nv . models . scatter ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , legend = nv . models . legend ( ) , distX = nv . models . distribution ( ) , distY = nv . models . distribution ( ) , tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 20 , "bottom" : 50 , "left" : 75 } , marginTop = null , width = null , height = null , container = null , color = nv . utils . defaultColor ( ) , x = scatter . xScale ( ) , y = scatter . yScale ( ) , showDistX = false , showDistY = false , showLegend = true , showXAxis = true , showYAxis = true , rightAlignYAxis = false , state = nv . utils . state ( ) , defaultState = null , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) , noData = null , duration = 250 , showLabels = false ; scatter . xScale ( x ) . yScale ( y ) ; xAxis . orient ( "bottom" ) . tickPadding ( 10 ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) . tickPadding ( 10 ) ; distX . axis ( "x" ) ; distY . axis ( "y" ) ; tooltip . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var x0 , y0 , renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . active , undefined ) ) data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } ; } ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( scatter ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; if ( showDistX ) renderWatch . models ( distX ) ; if ( showDistY ) renderWatch . models ( distY ) ; selection . each ( ( data ) { var that = this ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { if ( identical ( duration , 0 ) ) container . call ( chart ) ; else container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 // DEPRECATED set state.disableddisabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display noData message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; renderWatch . renderEnd ( "scatter immediate" ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = scatter . xScale ( ) ; y = scatter . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-scatterChart" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-scatterChart nv-chart-" + scatter . id ( ) ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ;
 // background for pointer events
 gEnter . append ( "rect" ) . attr ( "class" , "nvd3 nv-background" ) . style ( "pointer-events" , "none" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-scatterWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-regressionLinesWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-distWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var legendWidth = availableWidth ; legend . width ( legendWidth ) ; wrap . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( ! marginTop && ! identical ( legend . height ( ) , margin . top ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; } wrap . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0" + "," + ( - margin . top ) + ")" ) ; } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // Main Chart Component(s)
 scatter . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { d . color = d . color || color ( d , i ) ; return d . color ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) . showLabels ( showLabels ) ; wrap . select ( ".nv-scatterWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) . call ( scatter ) ; wrap . select ( ".nv-regressionLinesWrap" ) . attr ( "clip-path" , "url(#nv-edge-clip-" + scatter . id ( ) + ")" ) ; var regWrap = wrap . select ( ".nv-regressionLinesWrap" ) . selectAll ( ".nv-regLines" ) . data ( ( d ) { return d ; } ) ; regWrap . enter ( ) . append ( "g" ) . attr ( "class" , "nv-regLines" ) ; var regLine = regWrap . selectAll ( ".nv-regLine" ) . data ( ( d ) { return [ d ] ; } ) ; regLine . enter ( ) . append ( "line" ) . attr ( "class" , "nv-regLine" ) . style ( "stroke-opacity" , 0 ) ;
 // don't add lines unless we have slope and intercept to use
 regLine . filter ( ( d ) { return d . intercept && d . slope ; } ) . watchTransition ( renderWatch , "scatterPlusLineChart: regline" ) . attr ( "x1" , x . range ( ) [ 0 ] ) . attr ( "x2" , x . range ( ) [ 1 ] ) . attr ( "y1" , ( d , i ) { return y ( x . domain ( ) [ 0 ] * d . slope + d . intercept ) ; } ) . attr ( "y2" , ( d , i ) { return y ( x . domain ( ) [ 1 ] * d . slope + d . intercept ) ; } ) . style ( "stroke" , ( d , i , j ) { return color ( d , j ) ; } ) . style ( "stroke-opacity" , ( d , i ) { return ( d . disabled || identical ( , "undefined" ) || identical ( , "undefined" ) ) ? 0 : 1 ; } ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; g . select ( ".nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) . call ( xAxis ) ; } if ( showYAxis ) { yAxis . scale ( y ) . _ticks ( nv . utils . calcTicksY ( availableHeight / 36 , data ) ) . tickSize ( - availableWidth , 0 ) ; g . select ( ".nv-y.nv-axis" ) . call ( yAxis ) ; }
 // Setup Distribution
 distX . getData ( scatter . x ( ) ) . scale ( x ) . width ( availableWidth ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; gEnter . select ( ".nv-distWrap" ) . append ( "g" ) . attr ( "class" , "nv-distributionX" ) ; g . select ( ".nv-distributionX" ) . attr ( "transform" , "translate(0," + y . range ( ) [ 0 ] + ")" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) . call ( distX ) . style ( "opacity" , ( ) { return showDistX ? "1" : "1e-6" ; } ) . watchTransition ( renderWatch , "scatterPlusLineChart" ) . style ( "opacity" , ( ) { return showDistX ? "1" : "1e-6" ; } ) ; distY . getData ( scatter . y ( ) ) . scale ( y ) . width ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; gEnter . select ( ".nv-distWrap" ) . append ( "g" ) . attr ( "class" , "nv-distributionY" ) ; g . select ( ".nv-distributionY" ) . attr ( "transform" , "translate(" + ( rightAlignYAxis ? availableWidth : - distY . size ( ) ) + ",0)" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) . call ( distY ) . style ( "opacity" , ( ) { return showDistY ? "1" : "1e-6" ; } ) . watchTransition ( renderWatch , "scatterPlusLineChart" ) . style ( "opacity" , ( ) { return showDistY ? "1" : "1e-6" ; } ) ;
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) state [ key ] = newState [ key ] ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } chart . update ( ) ; } ) ;
 // mouseover needs availableHeight so we just keep scatter mouse events inside the chart block
 scatter . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; container . select ( ".nv-chart-" + scatter . id ( ) + " .nv-series-" + evt . seriesIndex + " .nv-distx-" + evt . pointIndex ) . attr ( "y1" , 0 ) ; container . select ( ".nv-chart-" + scatter . id ( ) + " .nv-series-" + evt . seriesIndex + " .nv-disty-" + evt . pointIndex ) . attr ( "x2" , distY . size ( ) ) ; } ) ; scatter . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { container . select ( ".nv-series-" + evt . seriesIndex + " .nv-distx-" + evt . pointIndex ) . attr ( "y1" , evt . relativePos [ 1 ] - availableHeight ) ; container . select ( ".nv-series-" + evt . seriesIndex + " .nv-disty-" + evt . pointIndex ) . attr ( "x2" , evt . relativePos [ 0 ] + distX . size ( ) ) ; tooltip . data ( evt ) . hidden ( false ) ; } ) ;
 //store old scales for use in transitions on update
 x0 = x . copy ( ) ; y0 = y . copy ( ) ; } ) ; renderWatch . renderEnd ( "scatter with line immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . scatter = scatter ; chart . legend = legend ; chart . xAxis = xAxis ; chart . yAxis = yAxis ; chart . distX = distX ; chart . distY = distY ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , container : { "get" : ( ) { return container ; } , "set" : ( _ ) { container = _ ; } } , showDistX : { "get" : ( ) { return showDistX ; } , "set" : ( _ ) { showDistX = _ ; } } , showDistY : { "get" : ( ) { return showDistY ; } , "set" : ( _ ) { showDistY = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; } } , showLabels : { "get" : ( ) { return showLabels ; } , "set" : ( _ ) { showLabels = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( ( _ ) ? "right" : "left" ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; distX . color ( color ) ; distY . color ( color ) ; } } ) ; nv . utils . inheritOptions ( chart , scatter ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . sparkline = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 2 , "right" : 0 , "bottom" : 2 , "left" : 0 } , width = 400 , height = 32 , container = null , animate = true , x = d3 . scale . linear ( ) , y = d3 . scale . linear ( ) , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , color = nv . utils . getColor ( [ "#000" ] ) , xDomain , yDomain , xRange , yRange , showMinMaxPoints = true , showCurrentPoint = true , dispatch = d3 . dispatch ( "renderEnd" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup Scales
 x . domain ( xDomain || d3 . extent ( data , getX ) ) . range ( xRange || [ 0 , availableWidth ] ) ; y . domain ( yDomain || d3 . extent ( data , getY ) ) . range ( yRange || [ availableHeight , 0 ] ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-sparkline" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-sparkline" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; var paths = wrap . selectAll ( "path" ) . data ( ( d ) { return [ d ] ; } ) ; paths . enter ( ) . append ( "path" ) ; paths . exit ( ) . remove ( ) ; paths . style ( "stroke" , ( d , i ) { return d . color || color ( d , i ) ; } ) . attr ( "d" , d3 . svg . line ( ) . x ( ( d , i ) { return x ( getX ( d , i ) ) ; } ) . y ( ( d , i ) { return y ( getY ( d , i ) ) ; } ) ) ;
 // TODO: Add CURRENT data point (Need Min, Mac, Current / Most recent)
 var points = wrap . selectAll ( "circle.nv-point" ) . data ( ( data ) { var yValues = data . map ( ( d , i ) { return getY ( d , i ) ; } ) ; pointIndex ( index ) { if ( index != - 1 ) { var result = data [ index ] ; result . pointIndex = index ; return result ; } else { return null ; } } var maxPoint = pointIndex ( yValues . lastIndexOf ( y . domain ( ) [ 1 ] ) ) , minPoint = pointIndex ( yValues . indexOf ( y . domain ( ) [ 0 ] ) ) , currentPoint = pointIndex ( yValues . length - 1 ) ; return [ ( showMinMaxPoints ? minPoint : null ) , ( showMinMaxPoints ? maxPoint : null ) , ( showCurrentPoint ? currentPoint : null ) ] . filter ( ( d ) { return d != null ; } ) ; } ) ; points . enter ( ) . append ( "circle" ) ; points . exit ( ) . remove ( ) ; points . attr ( "cx" , ( d , i ) { return x ( getX ( d , d . pointIndex ) ) ; } ) . attr ( "cy" , ( d , i ) { return y ( getY ( d , d . pointIndex ) ) ; } ) . attr ( "r" , 2 ) . attr ( "class" , ( d , i ) { return getX ( d , d . pointIndex ) == x . domain ( ) [ 1 ] ? "nv-point nv-currentValue" : getY ( d , d . pointIndex ) == y . domain ( ) [ 0 ] ? "nv-point nv-minValue" : "nv-point nv-maxValue" ; } ) ; } ) ; renderWatch . renderEnd ( "sparkline immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , xDomain : { "get" : ( ) { return xDomain ; } , "set" : ( _ ) { xDomain = _ ; } } , yDomain : { "get" : ( ) { return yDomain ; } , "set" : ( _ ) { yDomain = _ ; } } , xRange : { "get" : ( ) { return xRange ; } , "set" : ( _ ) { xRange = _ ; } } , yRange : { "get" : ( ) { return yRange ; } , "set" : ( _ ) { yRange = _ ; } } , xScale : { "get" : ( ) { return x ; } , "set" : ( _ ) { x = _ ; } } , yScale : { "get" : ( ) { return y ; } , "set" : ( _ ) { y = _ ; } } , animate : { "get" : ( ) { return animate ; } , "set" : ( _ ) { animate = _ ; } } , showMinMaxPoints : { "get" : ( ) { return showMinMaxPoints ; } , "set" : ( _ ) { showMinMaxPoints = _ ; } } , showCurrentPoint : { "get" : ( ) { return showCurrentPoint ; } , "set" : ( _ ) { showCurrentPoint = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = d3 . functor ( _ ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = d3 . functor ( _ ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; chart . dispatch = dispatch ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . sparklinePlus = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var sparkline = nv . models . sparkline ( ) ; var margin = { "top" : 15 , "right" : 100 , "bottom" : 10 , "left" : 50 } , width = null , height = null , x , y , index = [ ] , paused = false , xTickFormat = d3 . format ( ",r" ) , yTickFormat = d3 . format ( ",.2f" ) , showLastValue = true , alignValue = true , rightAlignValue = false , noData = null , dispatch = d3 . dispatch ( "renderEnd" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( sparkline ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { container . call ( chart ) ; } ; chart . container = this ;
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; } var currentValue = sparkline . y ( ) ( data [ data . length - 1 ] , data . length - 1 ) ;
 // Setup Scales
 x = sparkline . xScale ( ) ; y = sparkline . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-sparklineplus" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-sparklineplus" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-sparklineWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-valueWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-hoverArea" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // Main Chart Component(s)
 var sparklineWrap = g . select ( ".nv-sparklineWrap" ) ; sparkline . width ( availableWidth ) . height ( availableHeight ) ; sparklineWrap . call ( sparkline ) ; if ( showLastValue ) { var valueWrap = g . select ( ".nv-valueWrap" ) ; var value = valueWrap . selectAll ( ".nv-currentValue" ) . data ( [ currentValue ] ) ; value . enter ( ) . append ( "text" ) . attr ( "class" , "nv-currentValue" ) . attr ( "dx" , rightAlignValue ? - 8 : 8 ) . attr ( "dy" , ".9em" ) . style ( "text-anchor" , rightAlignValue ? "end" : "start" ) ; value . attr ( "x" , availableWidth + ( rightAlignValue ? margin . right : 0 ) ) . attr ( "y" , alignValue ? ( d ) { return y ( d ) ; } : 0 ) . style ( "fill" , sparkline . color ( ) ( data [ data . length - 1 ] , data . length - 1 ) ) . text ( yTickFormat ( currentValue ) ) ; } gEnter . select ( ".nv-hoverArea" ) . append ( "rect" ) . on ( "mousemove" , sparklineHover ) . on ( "click" , ( ) { paused = ! paused ; } ) . on ( "mouseout" , ( ) { index = [ ] ; updateValueLine ( ) ; } ) ; g . select ( ".nv-hoverArea rect" ) . attr ( "transform" , ( d ) { return "translate(" + - margin . left + "," + - margin . top + ")" ; } ) . attr ( "width" , availableWidth + margin . left + margin . right ) . attr ( "height" , availableHeight + margin . top ) ;
 //index is currently global (within the chart), may or may not keep it that way
 updateValueLine ( ) { if ( paused ) return ; var hoverValue = g . selectAll ( ".nv-hoverValue" ) . data ( index ) ; var hoverEnter = hoverValue . enter ( ) . append ( "g" ) . attr ( "class" , "nv-hoverValue" ) . style ( "stroke-opacity" , 0 ) . style ( "fill-opacity" , 0 ) ; hoverValue . exit ( ) . transition ( ) . duration ( 250 ) . style ( "stroke-opacity" , 0 ) . style ( "fill-opacity" , 0 ) . remove ( ) ; hoverValue . attr ( "transform" , ( d ) { return "translate(" + x ( sparkline . x ( ) ( data [ d ] , d ) ) + ",0)" ; } ) . transition ( ) . duration ( 250 ) . style ( "stroke-opacity" , 1 ) . style ( "fill-opacity" , 1 ) ; if ( ! index . length ) return ; hoverEnter . append ( "line" ) . attr ( "x1" , 0 ) . attr ( "y1" , - margin . top ) . attr ( "x2" , 0 ) . attr ( "y2" , availableHeight ) ; hoverEnter . append ( "text" ) . attr ( "class" , "nv-xValue" ) . attr ( "x" , - 6 ) . attr ( "y" , - margin . top ) . attr ( "text-anchor" , "end" ) . attr ( "dy" , ".9em" ) ; g . select ( ".nv-hoverValue .nv-xValue" ) . text ( xTickFormat ( sparkline . x ( ) ( data [ index [ 0 ] ] , index [ 0 ] ) ) ) ; hoverEnter . append ( "text" ) . attr ( "class" , "nv-yValue" ) . attr ( "x" , 6 ) . attr ( "y" , - margin . top ) . attr ( "text-anchor" , "start" ) . attr ( "dy" , ".9em" ) ; g . select ( ".nv-hoverValue .nv-yValue" ) . text ( yTickFormat ( sparkline . y ( ) ( data [ index [ 0 ] ] , index [ 0 ] ) ) ) ; } sparklineHover ( ) { if ( paused ) return ; var pos = d3 . mouse ( this ) [ 0 ] - margin . left ; getClosestIndex ( data , x ) { var distance = Math . abs ( sparkline . x ( ) ( data [ 0 ] , 0 ) - x ) ; var closestIndex = 0 ; for ( var i = 0 ; i < data . length ; i ++ ) { if ( Math . abs ( sparkline . x ( ) ( data [ i ] , i ) - x ) < distance ) { distance = Math . abs ( sparkline . x ( ) ( data [ i ] , i ) - x ) ; closestIndex = i ; } } return closestIndex ; } index = [ getClosestIndex ( data , Math . round ( x . invert ( pos ) ) ) ] ; updateValueLine ( ) ; } } ) ; renderWatch . renderEnd ( "sparklinePlus immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . sparkline = sparkline ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , xTickFormat : { "get" : ( ) { return xTickFormat ; } , "set" : ( _ ) { xTickFormat = _ ; } } , yTickFormat : { "get" : ( ) { return yTickFormat ; } , "set" : ( _ ) { yTickFormat = _ ; } } , showLastValue : { "get" : ( ) { return showLastValue ; } , "set" : ( _ ) { showLastValue = _ ; } } , alignValue : { "get" : ( ) { return alignValue ; } , "set" : ( _ ) { alignValue = _ ; } } , rightAlignValue : { "get" : ( ) { return rightAlignValue ; } , "set" : ( _ ) { rightAlignValue = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } ) ; nv . utils . inheritOptions ( chart , sparkline ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . stackedArea = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 960 , height = 500 , color = nv . utils . defaultColor ( ) , id = Math . floor ( Math . random ( ) * 100000 ) , container = null , getX = ( d ) { return d . x ; } , getY = ( d ) { return d . y ; } , defined = ( d , i ) { return ! isNaN ( getY ( d , i ) ) && ! identical ( getY ( d , i ) , null ) ; } , style = "stack" , offset = "zero" , order = "default" , interpolate = "linear" , clipEdge = false , x , y , scatter = nv . models . scatter ( ) , duration = 250 , transformData = ( d , y0 , y ) { d . display = { "y" : y , "y0" : y0 } ; } , areaY1 = ( d ) { return y ( d . display . y + d . display . y0 ) ; } , dispatch = d3 . dispatch ( "areaClick" , "areaMouseover" , "areaMouseout" , "renderEnd" , "elementClick" , "elementMouseover" , "elementMouseout" ) ; scatter . pointSize ( 2.2 ) . pointDomain ( [ 2.2 , 2.2 ] ) ;
 /************************************
     * offset:
     *   'wiggle' (stream)
     *   'zero' (stacked)
     *   'expand' (normalize to 100%)
     *   'silhouette' (simple centered)
     *
     * order:
     *   'inside-out' (stream)
     *   'default' (input order)
     ************************************/
 var renderWatch = nv . utils . renderWatch ( dispatch , duration ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( scatter ) ; selection . each ( ( data ) { var availableWidth = width - margin . left - margin . right , availableHeight = height - margin . top - margin . bottom ; container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ;
 // Setup Scales
 x = scatter . xScale ( ) ; y = scatter . yScale ( ) ; var dataRaw = data ;
 // Injecting point index into each point because d3.layout.stack().out does not give index
 data . forEach ( ( aseries , i ) { aseries . seriesIndex = i ; aseries . values = aseries . values . map ( ( d , j ) { d . index = j ; d . seriesIndex = i ; return d ; } ) ; } ) ; var dataFiltered = data . filter ( ( series ) { return ! series . disabled ; } ) ; data = d3 . layout . stack ( ) . order ( order ) . offset ( offset ) . values ( ( d ) { return d . values ; } ) . x ( getX ) . y ( getY ) . out ( transformData ) ( dataFiltered ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-stackedarea" ) . data ( [ data ] ) ; var wrapEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-stackedarea" ) ; var defsEnter = wrapEnter . append ( "defs" ) ; var gEnter = wrapEnter . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-areaWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-scatterWrap" ) ; wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ;
 // If the user has not specified forceY, make sure 0 is included in the domain

 // Otherwise, use user-specified values for forceY
 if ( scatter . forceY ( ) . length == 0 ) { scatter . forceY ( ) . push ( 0 ) ; } scatter . width ( availableWidth ) . height ( availableHeight ) . x ( getX ) . y ( ( d ) { if ( ! identical ( d . display , undefined ) ) { return d . display . y + d . display . y0 ; } } ) . color ( data . map ( ( d , i ) { d . color = d . color || color ( d , d . seriesIndex ) ; return d . color ; } ) ) ; var scatterWrap = g . select ( ".nv-scatterWrap" ) . datum ( data ) ; scatterWrap . call ( scatter ) ; defsEnter . append ( "clipPath" ) . attr ( "id" , "nv-edge-clip-" + id ) . append ( "rect" ) ; wrap . select ( "#nv-edge-clip-" + id + " rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; g . attr ( "clip-path" , clipEdge ? "url(#nv-edge-clip-" + id + ")" : "" ) ; var area = d3 . svg . area ( ) . defined ( defined ) . x ( ( d , i ) { return x ( getX ( d , i ) ) ; } ) . y0 ( ( d ) { return y ( d . display . y0 ) ; } ) . y1 ( areaY1 ) . interpolate ( interpolate ) ; var zeroArea = d3 . svg . area ( ) . defined ( defined ) . x ( ( d , i ) { return x ( getX ( d , i ) ) ; } ) . y0 ( ( d ) { return y ( d . display . y0 ) ; } ) . y1 ( ( d ) { return y ( d . display . y0 ) ; } ) ; var path = g . select ( ".nv-areaWrap" ) . selectAll ( "path.nv-area" ) . data ( ( d ) { return d ; } ) ; path . enter ( ) . append ( "path" ) . attr ( "class" , ( d , i ) { return "nv-area nv-area-" + i ; } ) . attr ( "d" , ( d , i ) { return zeroArea ( d . values , d . seriesIndex ) ; } ) . on ( "mouseover" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , true ) ; dispatch . areaMouseover ( point : d , series : d . key , pos : [ d3 . event . pageX , d3 . event . pageY ] , seriesIndex : d . seriesIndex ) ; } ) . on ( "mouseout" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . areaMouseout ( point : d , series : d . key , pos : [ d3 . event . pageX , d3 . event . pageY ] , seriesIndex : d . seriesIndex ) ; } ) . on ( "click" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) ; dispatch . areaClick ( point : d , series : d . key , pos : [ d3 . event . pageX , d3 . event . pageY ] , seriesIndex : d . seriesIndex ) ; } ) ; path . exit ( ) . remove ( ) ; path . style ( "fill" , ( d , i ) { return d . color || color ( d , d . seriesIndex ) ; } ) . style ( "stroke" , ( d , i ) { return d . color || color ( d , d . seriesIndex ) ; } ) ; path . watchTransition ( renderWatch , "stackedArea path" ) . attr ( "d" , ( d , i ) { return area ( d . values , i ) ; } ) ;
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 scatter . dispatch . on ( "elementMouseover.area" , ( e ) { g . select ( ".nv-chart-" + id + " .nv-area-" + e . seriesIndex ) . classed ( "hover" , true ) ; } ) ; scatter . dispatch . on ( "elementMouseout.area" , ( e ) { g . select ( ".nv-chart-" + id + " .nv-area-" + e . seriesIndex ) . classed ( "hover" , false ) ; } ) ;
 //Special offset functions
 chart . d3_stackedOffset_stackPercent = ( stackData ) { var n = stackData . length , m = stackData [ 0 ] . length , i , j , o , y0 = [ ] ; for ( j = 0 ; j < m ; ++ j ) { for ( i = 0 , o = 0 ; i < dataRaw . length ; i ++ ) { o += getY ( dataRaw [ i ] . values [ j ] ) ; } if ( o ) for ( i = 0 ; i < n ; i ++ ) { stackData [ i ] [ j ] [ 1 ] /= o ; } else { for ( i = 0 ; i < n ; i ++ ) { stackData [ i ] [ j ] [ 1 ] = 0 ; } } } for ( j = 0 ; j < m ; ++ j ) y0 [ j ] = 0 ; return y0 ; } ; } ) ; renderWatch . renderEnd ( "stackedArea immediate" ) ; return chart ; }
 //============================================================

 // Global getters and setters

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . scatter = scatter ; scatter . dispatch . on ( "elementClick" , ( ) { dispatch . elementClick . apply ( this , arguments ) ; } ) ; scatter . dispatch . on ( "elementMouseover" , ( ) { dispatch . elementMouseover . apply ( this , arguments ) ; } ) ; scatter . dispatch . on ( "elementMouseout" , ( ) { dispatch . elementMouseout . apply ( this , arguments ) ; } ) ; chart . interpolate = ( _ ) { if ( ! arguments . length ) return interpolate ; interpolate = _ ; return chart ; } ; chart . duration = ( _ ) { if ( ! arguments . length ) return duration ; duration = _ ; renderWatch . reset ( duration ) ; scatter . duration ( duration ) ; return chart ; } ; chart . dispatch = dispatch ; chart . scatter = scatter ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , defined : { "get" : ( ) { return defined ; } , "set" : ( _ ) { defined = _ ; } } , clipEdge : { "get" : ( ) { return clipEdge ; } , "set" : ( _ ) { clipEdge = _ ; } } , offset : { "get" : ( ) { return offset ; } , "set" : ( _ ) { offset = _ ; } } , order : { "get" : ( ) { return order ; } , "set" : ( _ ) { order = _ ; } } , interpolate : { "get" : ( ) { return interpolate ; } , "set" : ( _ ) { interpolate = _ ; } } , x : { "get" : ( ) { return getX ; } , "set" : ( _ ) { getX = d3 . functor ( _ ) ; } } , y : { "get" : ( ) { return getY ; } , "set" : ( _ ) { getY = d3 . functor ( _ ) ; } } , areaY1 : { "get" : ( ) { return areaY1 ; } , "set" : ( _ ) { areaY1 = d3 . functor ( _ ) ; } } , transformData : { "get" : ( ) { return transformData ; } , "set" : ( _ ) { transformData = d3 . functor ( _ ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } , style : { "get" : ( ) { return style ; } , "set" : ( _ ) { style = _ ; switch ( style ) { case "stack" : chart . offset ( "zero" ) ; chart . order ( "default" ) ; break ; case "stream" : chart . offset ( "wiggle" ) ; chart . order ( "inside-out" ) ; break ; case "stream-center" : chart . offset ( "silhouette" ) ; chart . order ( "inside-out" ) ; break ; case "expand" : chart . offset ( "expand" ) ; chart . order ( "default" ) ; break ; case "stack_percent" : chart . offset ( chart . d3_stackedOffset_stackPercent ) ; chart . order ( "default" ) ; break ; } } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; scatter . duration ( duration ) ; } } ) ; nv . utils . inheritOptions ( chart , scatter ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . stackedAreaChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var stacked = nv . models . stackedArea ( ) , xAxis = nv . models . axis ( ) , yAxis = nv . models . axis ( ) , legend = nv . models . legend ( ) , controls = nv . models . legend ( ) , interactiveLayer = nv . interactiveGuideline ( ) , tooltip = nv . models . tooltip ( ) , focus = nv . models . focus ( nv . models . stackedArea ( ) ) ; var margin = { "top" : 10 , "right" : 25 , "bottom" : 50 , "left" : 60 } , marginTop = null , width = null , height = null , color = nv . utils . defaultColor ( ) , showControls = true , showLegend = true , legendPosition = "top" , showXAxis = true , showYAxis = true , rightAlignYAxis = false , focusEnable = false , useInteractiveGuideline = false , showTotalInTooltip = true , totalLabel = "TOTAL" , x , y , state = nv . utils . state ( ) , defaultState = null , noData = null , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) , controlWidth = 250 , controlOptions = [ "Stacked" , "Stream" , "Expanded" ] , controlLabels = { } , duration = 250 ; state . style = stacked . style ( ) ; xAxis . orient ( "bottom" ) . tickPadding ( 7 ) ; yAxis . orient ( ( rightAlignYAxis ) ? "right" : "left" ) ; tooltip . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( ( d , i ) { return yAxis . tickFormat ( ) ( d , i ) ; } ) ; interactiveLayer . tooltip . headerFormatter ( ( d , i ) { return xAxis . tickFormat ( ) ( d , i ) ; } ) . valueFormatter ( ( d , i ) { return d == null ? "N/A" : yAxis . tickFormat ( ) ( d , i ) ; } ) ; var oldYTickFormat = null , oldValueFormatter = null ; controls . updateState ( false ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; var style = stacked . style ( ) ; var stateGetter = ( data ) { return ( ) { return { "active" : data . map ( ( d ) { return ! d . disabled ; } ) , "style" : stacked . style ( ) } ; } ; } ; var stateSetter = ( data ) { return ( state ) { if ( ! identical ( state . style , undefined ) ) style = state . style ; if ( ! identical ( state . active , undefined ) ) data . forEach ( ( series , i ) { series . disabled = ! state . active [ i ] ; } ) ; } ; } ; var percentFormatter = d3 . format ( "%" ) ; chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( stacked ) ; if ( showXAxis ) renderWatch . models ( xAxis ) ; if ( showYAxis ) renderWatch . models ( yAxis ) ; selection . each ( ( data ) { var container = d3 . select ( this ) , that = this ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) , availableHeight = nv . utils . availableHeight ( height , container , margin ) - ( focusEnable ? focus . height ( ) : 0 ) ; chart . update = ( ) { container . transition ( ) . duration ( duration ) . call ( chart ) ; } ; chart . container = this ; state . setter ( stateSetter ( data ) , chart . update ) . getter ( stateGetter ( data ) ) . update ( ) ;
 // DEPRECATED set state.disabled
 state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; if ( ! defaultState ) { var key ; defaultState = { } ; for ( key in state ) { if ( state [ key ] is Array ) defaultState [ key ] = state [ key ] . slice ( 0 ) ; else defaultState [ key ] = state [ key ] ; } }
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length || ! data . filter ( ( d ) { return d . values . length ; } ) . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; }
 // Setup Scales
 x = stacked . xScale ( ) ; y = stacked . yScale ( ) ;
 // Setup containers and skeleton of chart
 var wrap = container . selectAll ( "g.nv-wrap.nv-stackedAreaChart" ) . data ( [ data ] ) ; var gEnter = wrap . enter ( ) . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-stackedAreaChart" ) . append ( "g" ) ; var g = wrap . select ( "g" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-legendWrap" ) ; gEnter . append ( "g" ) . attr ( "class" , "nv-controlsWrap" ) ; var focusEnter = gEnter . append ( "g" ) . attr ( "class" , "nv-focus" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-background" ) . append ( "rect" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-x nv-axis" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-y nv-axis" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-stackedWrap" ) ; focusEnter . append ( "g" ) . attr ( "class" , "nv-interactive" ) ;
 // g.select("rect").attr("width",availableWidth).attr("height",availableHeight);
 var contextEnter = gEnter . append ( "g" ) . attr ( "class" , "nv-focusWrap" ) ;
 // Legend
 if ( ! showLegend ) { g . select ( ".nv-legendWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var legendWidth = ( showControls && identical ( legendPosition , "top" ) ) ? availableWidth - controlWidth : availableWidth ; legend . width ( legendWidth ) ; g . select ( ".nv-legendWrap" ) . datum ( data ) . call ( legend ) ; if ( identical ( legendPosition , "bottom" ) ) { var xAxisHeight = xAxis . height ( ) ; margin . bottom = Math . max ( legend . height ( ) + xAxisHeight , margin . bottom ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) - ( focusEnable ? focus . height ( ) : 0 ) ; var legendTop = availableHeight + xAxisHeight ; g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(0," + legendTop + ")" ) ; } else if ( identical ( legendPosition , "top" ) ) { if ( ! marginTop && margin . top != legend . height ( ) ) { margin . top = legend . height ( ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) - ( focusEnable ? focus . height ( ) : 0 ) ; } g . select ( ".nv-legendWrap" ) . attr ( "transform" , "translate(" + ( availableWidth - legendWidth ) + "," + ( - margin . top ) + ")" ) ; } }
 // Controls
 if ( ! showControls ) { g . select ( ".nv-controlsWrap" ) . selectAll ( "*" ) . remove ( ) ; } else { var controlsData = [ { "key" : controlLabels . stacked || "Stacked" , "metaKey" : "Stacked" , "disabled" : stacked . style ( ) != "stack" , "style" : "stack" } , { "key" : controlLabels . stream || "Stream" , "metaKey" : "Stream" , "disabled" : stacked . style ( ) != "stream" , "style" : "stream" } , { "key" : controlLabels . stream_center || "Stream Center" , "metaKey" : "Stream_Center" , "disabled" : stacked . style ( ) != "stream_center" , "style" : "stream-center" } , { "key" : controlLabels . expanded || "Expanded" , "metaKey" : "Expanded" , "disabled" : stacked . style ( ) != "expand" , "style" : "expand" } , { "key" : controlLabels . stack_percent || "Stack %" , "metaKey" : "Stack_Percent" , "disabled" : stacked . style ( ) != "stack_percent" , "style" : "stack_percent" } ] ; controlWidth = ( controlOptions . length / 3 ) * 260 ; controlsData = controlsData . filter ( ( d ) { return ! identical ( controlOptions . indexOf ( d . metaKey ) , - 1 ) ; } ) ; controls . width ( controlWidth ) . color ( [ "#444" , "#444" , "#444" ] ) ; g . select ( ".nv-controlsWrap" ) . datum ( controlsData ) . call ( controls ) ; var requiredTop = Math . max ( controls . height ( ) , showLegend && ( identical ( legendPosition , "top" ) ) ? legend . height ( ) : 0 ) ; if ( margin . top != requiredTop ) { margin . top = requiredTop ; availableHeight = nv . utils . availableHeight ( height , container , margin ) - ( focusEnable ? focus . height ( ) : 0 ) ; } g . select ( ".nv-controlsWrap" ) . attr ( "transform" , "translate(0," + ( - margin . top ) + ")" ) ; } wrap . attr ( "transform" , "translate(" + margin . left + "," + margin . top + ")" ) ; if ( rightAlignYAxis ) { g . select ( ".nv-y.nv-axis" ) . attr ( "transform" , "translate(" + availableWidth + ",0)" ) ; }
 //Set up interactive layer
 if ( useInteractiveGuideline ) { interactiveLayer . width ( availableWidth ) . height ( availableHeight ) . margin ( left : margin . left , top : margin . top ) . svgContainer ( container ) . xScale ( x ) ; wrap . select ( ".nv-interactive" ) . call ( interactiveLayer ) ; } g . select ( ".nv-focus .nv-background rect" ) . attr ( "width" , availableWidth ) . attr ( "height" , availableHeight ) ; stacked . width ( availableWidth ) . height ( availableHeight ) . color ( data . map ( ( d , i ) { return d . color || color ( d , i ) ; } ) . filter ( ( d , i ) { return ! data [ i ] . disabled ; } ) ) ; var stackedWrap = g . select ( ".nv-focus .nv-stackedWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) ;
 // Setup Axes
 if ( showXAxis ) { xAxis . scale ( x ) . _ticks ( nv . utils . calcTicksX ( availableWidth / 100 , data ) ) . tickSize ( - availableHeight , 0 ) ; } if ( showYAxis ) { var ticks ; if ( identical ( stacked . offset ( ) , "wiggle" ) ) { ticks = 0 ; } else { ticks = nv . utils . calcTicksY ( availableHeight / 36 , data ) ; } yAxis . scale ( y ) . _ticks ( ticks ) . tickSize ( - availableWidth , 0 ) ; }
 //============================================================

 // Update Axes

 //============================================================
 updateXAxis ( ) { if ( showXAxis ) { g . select ( ".nv-focus .nv-x.nv-axis" ) . attr ( "transform" , "translate(0," + availableHeight + ")" ) . transition ( ) . duration ( duration ) . call ( xAxis ) ; } } updateYAxis ( ) { if ( showYAxis ) { if ( identical ( stacked . style ( ) , "expand" ) || identical ( stacked . style ( ) , "stack_percent" ) ) { var currentFormat = yAxis . tickFormat ( ) ; if ( ! oldYTickFormat || ! identical ( currentFormat , percentFormatter ) ) oldYTickFormat = currentFormat ;
 //Forces the yAxis to use percentage in 'expand' mode.
 yAxis . tickFormat ( percentFormatter ) ; } else { if ( oldYTickFormat ) { yAxis . tickFormat ( oldYTickFormat ) ; oldYTickFormat = null ; } } g . select ( ".nv-focus .nv-y.nv-axis" ) . transition ( ) . duration ( 0 ) . call ( yAxis ) ; } }
 //============================================================

 // Update Focus

 //============================================================
 if ( ! focusEnable ) { stackedWrap . transition ( ) . call ( stacked ) ; updateXAxis ( ) ; updateYAxis ( ) ; } else { focus . width ( availableWidth ) ; g . select ( ".nv-focusWrap" ) . attr ( "transform" , "translate(0," + ( availableHeight + margin . bottom + focus . margin ( ) . top ) + ")" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) ) . call ( focus ) ; var extent = focus . brush . empty ( ) ? focus . xDomain ( ) : focus . brush . extent ( ) ; if ( ! identical ( extent , null ) ) { onBrush ( extent ) ; } }
 //============================================================

 // Event Handling/Dispatching (in chart's scope)

 //------------------------------------------------------------
 stacked . dispatch . on ( "areaClick.toggle" , ( e ) { if ( identical ( data . filter ( ( d ) { return ! d . disabled ; } ) . length , 1 ) ) data . forEach ( ( d ) { d . disabled = false ; } ) ; else data . forEach ( ( d , i ) { d . disabled = ( i != e . seriesIndex ) ; } ) ; state . disabled = data . map ( ( d ) { return ! ! d . disabled ; } ) ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; legend . dispatch . on ( "stateChange" , ( newState ) { for ( var key in newState ) state [ key ] = newState [ key ] ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; controls . dispatch . on ( "legendClick" , ( d , i ) { if ( ! d . disabled ) return ; controlsData = controlsData . map ( ( s ) { s . disabled = true ; return s ; } ) ; d . disabled = false ; stacked . style ( d . style ) ; state . style = stacked . style ( ) ; dispatch . stateChange ( state ) ; chart . update ( ) ; } ) ; interactiveLayer . dispatch . on ( "elementMousemove" , ( e ) { stacked . clearHighlights ( ) ; var singlePoint , pointIndex , pointXLocation , allData = [ ] , valueSum = 0 , allNullValues = true , atleastOnePoint = false ; data . filter ( ( series , i ) { series . seriesIndex = i ; return ! series . disabled ; } ) . forEach ( ( series , i ) { pointIndex = nv . interactiveBisect ( series . values , e . pointXValue , chart . x ( ) ) ; var point = series . values [ pointIndex ] ; var pointYValue = chart . y ( ) ( point , pointIndex ) ; if ( pointYValue != null && pointYValue > 0 ) { stacked . highlightPoint ( i , pointIndex , true ) ; atleastOnePoint = true ; }
 // Draw at least one point if all values are zero.
 if ( identical ( i , ( data . length - 1 ) ) && ! atleastOnePoint ) { stacked . highlightPoint ( i , pointIndex , true ) ; } if ( identical ( , "undefined" ) ) return ; if ( identical ( , "undefined" ) ) singlePoint = point ; if ( identical ( , "undefined" ) ) pointXLocation = chart . xScale ( ) ( chart . x ( ) ( point , pointIndex ) ) ;
 //If we are in 'expand' mode, use the stacked percent value instead of raw value.
 var tooltipValue = ( stacked . style ( ) == "expand" ) ? point . display . y : chart . y ( ) ( point , pointIndex ) ; allData . push ( key : series . key , value : tooltipValue , color : color ( series , series . seriesIndex ) , point : point ) ; if ( showTotalInTooltip && stacked . style ( ) != "expand" && tooltipValue != null ) { valueSum += tooltipValue ; allNullValues = false ; } ; } ) ; allData . reverse ( ) ;
 //Highlight the tooltip entry based on which stack the mouse is closest to.
 if ( allData . length > 2 ) { var yValue = chart . yScale ( ) . invert ( e . mouseY ) ; var yDistMax = Infinity , indexToHighlight = null ; allData . forEach ( ( series , i ) {
 //To handle situation where the stacked area chart is negative, we need to use absolute values

 //when checking if the mouse Y value is within the stack area.
 yValue = Math . abs ( yValue ) ; var stackedY0 = Math . abs ( series . point . display . y0 ) ; var stackedY = Math . abs ( series . point . display . y ) ; if ( yValue >= stackedY0 && yValue <= ( stackedY + stackedY0 ) ) { indexToHighlight = i ; return ; } } ) ; if ( indexToHighlight != null ) allData [ indexToHighlight ] . highlight = true ; }
 //If we are not in 'expand' mode, add a 'Total' row to the tooltip.
 if ( showTotalInTooltip && stacked . style ( ) != "expand" && allData . length >= 2 && ! allNullValues ) { allData . push ( key : totalLabel , value : valueSum , total : true ) ; } var xValue = chart . x ( ) ( singlePoint , pointIndex ) ; var valueFormatter = interactiveLayer . tooltip . valueFormatter ( ) ;
 // Keeps track of the tooltip valueFormatter if the chart changes to expanded view
 if ( identical ( stacked . style ( ) , "expand" ) || identical ( stacked . style ( ) , "stack_percent" ) ) { if ( ! oldValueFormatter ) { oldValueFormatter = valueFormatter ; }
 //Forces the tooltip to use percentage in 'expand' mode.
 valueFormatter = d3 . format ( ".1%" ) ; } else { if ( oldValueFormatter ) { valueFormatter = oldValueFormatter ; oldValueFormatter = null ; } } interactiveLayer . tooltip . valueFormatter ( valueFormatter ) . data ( value : xValue , series : allData ) ( ) ; interactiveLayer . renderGuideLine ( pointXLocation ) ; } ) ; interactiveLayer . dispatch . on ( "elementMouseout" , ( e ) { stacked . clearHighlights ( ) ; } ) ;
 /* Update `main' graph on brush update. */
 focus . dispatch . on ( "onBrush" , ( extent ) { onBrush ( extent ) ; } ) ;
 // Update chart from a state object passed to event handler
 dispatch . on ( "changeState" , ( e ) { if ( ! identical ( , "undefined" ) && identical ( data . length , e . disabled . length ) ) { data . forEach ( ( series , i ) { series . disabled = e . disabled [ i ] ; } ) ; state . disabled = e . disabled ; } if ( ! identical ( , "undefined" ) ) { stacked . style ( e . style ) ; style = e . style ; } chart . update ( ) ; } ) ;
 //============================================================

 // Functions

 //------------------------------------------------------------
 onBrush ( extent ) {
 // Update Main (Focus)
 var stackedWrap = g . select ( ".nv-focus .nv-stackedWrap" ) . datum ( data . filter ( ( d ) { return ! d . disabled ; } ) . map ( ( d , i ) { return { "key" : d . key , "area" : d . area , "classed" : d . classed , "values" : d . values . filter ( ( d , i ) { return stacked . x ( ) ( d , i ) >= extent [ 0 ] && stacked . x ( ) ( d , i ) <= extent [ 1 ] ; } ) , "disableTooltip" : d . disableTooltip } ; } ) ) ; stackedWrap . transition ( ) . duration ( duration ) . call ( stacked ) ;
 // Update Main (Focus) Axes
 updateXAxis ( ) ; updateYAxis ( ) ; } } ) ; renderWatch . renderEnd ( "stacked Area chart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 stacked . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt . point [ "x" ] = stacked . x ( ) ( evt . point ) ; evt . point [ "y" ] = stacked . y ( ) ( evt . point ) ; tooltip . data ( evt ) . hidden ( false ) ; } ) ; stacked . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . stacked = stacked ; chart . legend = legend ; chart . controls = controls ; chart . xAxis = xAxis ; chart . x2Axis = focus . xAxis ; chart . yAxis = yAxis ; chart . y2Axis = focus . yAxis ; chart . interactiveLayer = interactiveLayer ; chart . tooltip = tooltip ; chart . focus = focus ; chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , showLegend : { "get" : ( ) { return showLegend ; } , "set" : ( _ ) { showLegend = _ ; } } , legendPosition : { "get" : ( ) { return legendPosition ; } , "set" : ( _ ) { legendPosition = _ ; } } , showXAxis : { "get" : ( ) { return showXAxis ; } , "set" : ( _ ) { showXAxis = _ ; } } , showYAxis : { "get" : ( ) { return showYAxis ; } , "set" : ( _ ) { showYAxis = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , showControls : { "get" : ( ) { return showControls ; } , "set" : ( _ ) { showControls = _ ; } } , controlLabels : { "get" : ( ) { return controlLabels ; } , "set" : ( _ ) { controlLabels = _ ; } } , controlOptions : { "get" : ( ) { return controlOptions ; } , "set" : ( _ ) { controlOptions = _ ; } } , showTotalInTooltip : { "get" : ( ) { return showTotalInTooltip ; } , "set" : ( _ ) { showTotalInTooltip = _ ; } } , totalLabel : { "get" : ( ) { return totalLabel ; } , "set" : ( _ ) { totalLabel = _ ; } } , focusEnable : { "get" : ( ) { return focusEnable ; } , "set" : ( _ ) { focusEnable = _ ; } } , focusHeight : { "get" : ( ) { return focus . height ( ) ; } , "set" : ( _ ) { focus . height ( _ ) ; } } , brushExtent : { "get" : ( ) { return focus . brushExtent ( ) ; } , "set" : ( _ ) { focus . brushExtent ( _ ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { if ( ! identical ( _ . top , undefined ) ) { margin . top = _ . top ; marginTop = _ . top ; } margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; } } , focusMargin : { "get" : ( ) { return focus . margin ; } , "set" : ( _ ) { focus . margin . top = ! identical ( _ . top , undefined ) ? _ . top : focus . margin . top ; focus . margin . right = ! identical ( _ . right , undefined ) ? _ . right : focus . margin . right ; focus . margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : focus . margin . bottom ; focus . margin . left = ! identical ( _ . left , undefined ) ? _ . left : focus . margin . left ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; stacked . duration ( duration ) ; xAxis . duration ( duration ) ; yAxis . duration ( duration ) ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; legend . color ( color ) ; stacked . color ( color ) ; focus . color ( color ) ; } } , x : { "get" : ( ) { return stacked . x ( ) ; } , "set" : ( _ ) { stacked . x ( _ ) ; focus . x ( _ ) ; } } , y : { "get" : ( ) { return stacked . y ( ) ; } , "set" : ( _ ) { stacked . y ( _ ) ; focus . y ( _ ) ; } } , rightAlignYAxis : { "get" : ( ) { return rightAlignYAxis ; } , "set" : ( _ ) { rightAlignYAxis = _ ; yAxis . orient ( rightAlignYAxis ? "right" : "left" ) ; } } , useInteractiveGuideline : { "get" : ( ) { return useInteractiveGuideline ; } , "set" : ( _ ) { useInteractiveGuideline = ! ! _ ; chart . interactive ( ! _ ) ; chart . useVoronoi ( ! _ ) ; stacked . scatter . interactive ( ! _ ) ; } } ) ; nv . utils . inheritOptions ( chart , stacked ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . stackedAreaWithFocusChart = ( ) { return nv . models . stackedAreaChart ( ) . margin ( bottom : 30 ) . focusEnable ( true ) ; } ;
 // based on http://bl.ocks.org/kerryrodden/477c1bfb081b783f80ad
 nv . models . sunburst = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var margin = { "top" : 0 , "right" : 0 , "bottom" : 0 , "left" : 0 } , width = 600 , height = 600 , mode = "count" , modes = { "count" : ( d ) { return 1 ; } , "value" : ( d ) { return d . value || d . size ; } , "size" : ( d ) { return d . value || d . size ; } } , id = Math . floor ( Math . random ( ) * 10000 ) , container = null , color = nv . utils . defaultColor ( ) , showLabels = false , labelFormat = ( d ) { if ( identical ( mode , "count" ) ) { return d . name + " #" + d . value ; } else { return d . name + " " + ( d . value || d . size ) ; } } , labelThreshold = 0.02 , sort = ( d1 , d2 ) { return d1 . name > d2 . name ; } , key = ( d , i ) { if ( ! identical ( d . parent , undefined ) ) { return d . name + "-" + d . parent . name + "-" + i ; } else { return d . name ; } } , groupColorByParent = true , duration = 500 , dispatch = d3 . dispatch ( "chartClick" , "elementClick" , "elementDblClick" , "elementMousemove" , "elementMouseover" , "elementMouseout" , "renderEnd" ) ;
 //============================================================

 // aux functions and setup

 //------------------------------------------------------------
 var x = d3 . scale . linear ( ) . range ( [ 0 , 2 * Math . PI ] ) ; var y = d3 . scale . sqrt ( ) ; var partition = d3 . layout . partition ( ) . sort ( sort ) ; var node , availableWidth , availableHeight , radius ; var prevPositions = { } ; var arc = d3 . svg . arc ( ) . startAngle ( ( d ) { return Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x ) ) ) ; } ) . endAngle ( ( d ) { return Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x + d . dx ) ) ) ; } ) . innerRadius ( ( d ) { return Math . max ( 0 , y ( d . y ) ) ; } ) . outerRadius ( ( d ) { return Math . max ( 0 , y ( d . y + d . dy ) ) ; } ) ; rotationToAvoidUpsideDown ( d ) { var centerAngle = computeCenterAngle ( d ) ; if ( centerAngle > 90 ) { return 180 ; } else { return 0 ; } } computeCenterAngle ( d ) { var startAngle = Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x ) ) ) ; var endAngle = Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x + d . dx ) ) ) ; var centerAngle = ( ( ( startAngle + endAngle ) / 2 ) * ( 180 / Math . PI ) ) - 90 ; return centerAngle ; } computeNodePercentage ( d ) { var startAngle = Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x ) ) ) ; var endAngle = Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x + d . dx ) ) ) ; return ( endAngle - startAngle ) / ( 2 * Math . PI ) ; } labelThresholdMatched ( d ) { var startAngle = Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x ) ) ) ; var endAngle = Math . max ( 0 , Math . min ( 2 * Math . PI , x ( d . x + d . dx ) ) ) ; var size = endAngle - startAngle ; return size > labelThreshold ; }
 // When zooming: interpolate the scales.
 arcTweenZoom ( e , i ) { var xd = d3 . interpolate ( x . domain ( ) , [ node . x , node . x + node . dx ] ) , yd = d3 . interpolate ( y . domain ( ) , [ node . y , 1 ] ) , yr = d3 . interpolate ( y . range ( ) , [ node . y ? 20 : 0 , radius ] ) ; if ( identical ( i , 0 ) ) { return ( ) { return arc ( e ) ; } ; } else { return ( t ) { x . domain ( xd ( t ) ) ; y . domain ( yd ( t ) ) . range ( yr ( t ) ) ; return arc ( e ) ; } ; } ; } arcTweenUpdate ( d ) { var ipo = d3 . interpolate ( { "x" : d . x0 , "dx" : d . dx0 , "y" : d . y0 , "dy" : d . dy0 } , d ) ; return ( t ) { var b = ipo ( t ) ; d . x0 = b . x ; d . dx0 = b . dx ; d . y0 = b . y ; d . dy0 = b . dy ; return arc ( b ) ; } ; } updatePrevPosition ( node ) { var k = key ( node ) ; if ( ! prevPositions [ k ] ) prevPositions [ k ] = { } ; var pP = prevPositions [ k ] ; pP . dx = node . dx ; pP . x = node . x ; pP . dy = node . dy ; pP . y = node . y ; } storeRetrievePrevPositions ( nodes ) { nodes . forEach ( ( n ) { var k = key ( n ) ; var pP = prevPositions [ k ] ;
 //console.log(k,n,pP);
 if ( pP ) { n . dx0 = pP . dx ; n . x0 = pP . x ; n . dy0 = pP . dy ; n . y0 = pP . y ; } else { n . dx0 = n . dx ; n . x0 = n . x ; n . dy0 = n . dy ; n . y0 = n . y ; } updatePrevPosition ( n ) ; } ) ; } zoomClick ( d ) { var labels = container . selectAll ( "text" ) ; var path = container . selectAll ( "path" ) ;
 // fade out all text elements
 labels . transition ( ) . attr ( "opacity" , 0 ) ;
 // to allow reference to the new center node
 node = d ; path . transition ( ) . duration ( duration ) . attrTween ( "d" , arcTweenZoom ) . each ( "end" , ( e ) {
 // partially taken from here: http://bl.ocks.org/metmajer/5480307

 // check if the animated element's data e lies within the visible angle span given in d
 if ( e . x >= d . x && e . x < ( d . x + d . dx ) ) { if ( e . depth >= d . depth ) {
 // get a selection of the associated text element
 var parentNode = d3 . select ( this . parentNode ) ; var arcText = parentNode . select ( "text" ) ;
 // fade in the text element and recalculate positions
 arcText . transition ( ) . duration ( duration ) . text ( ( e ) { return labelFormat ( e ) ; } ) . attr ( "opacity" , ( d ) { if ( labelThresholdMatched ( d ) ) { return 1 ; } else { return 0 ; } } ) . attr ( "transform" , ( ) { var width = this . getBBox ( ) . width ; if ( identical ( e . depth , 0 ) ) return "translate(" + ( width / 2 * - 1 ) + ",0)" ; else if ( identical ( e . depth , d . depth ) ) { return "translate(" + ( y ( e . y ) + 5 ) + ",0)" ; } else { var centerAngle = computeCenterAngle ( e ) ; var rotation = rotationToAvoidUpsideDown ( e ) ; if ( identical ( rotation , 0 ) ) { return "rotate(" + centerAngle + ")translate(" + ( y ( e . y ) + 5 ) + ",0)" ; } else { return "rotate(" + centerAngle + ")translate(" + ( y ( e . y ) + width + 5 ) + ",0)rotate(" + rotation + ")" ; } } } ) ; } } } ) ; }
 //============================================================

 // chart function

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; chart ( selection ) { renderWatch . reset ( ) ; selection . each ( ( data ) { container = d3 . select ( this ) ; availableWidth = nv . utils . availableWidth ( width , container , margin ) ; availableHeight = nv . utils . availableHeight ( height , container , margin ) ; radius = Math . min ( availableWidth , availableHeight ) / 2 ; y . range ( [ 0 , radius ] ) ;
 // Setup containers and skeleton of chart
 var wrap = container . select ( "g.nvd3.nv-wrap.nv-sunburst" ) ; if ( ! wrap [ 0 ] [ 0 ] ) { wrap = container . append ( "g" ) . attr ( "class" , "nvd3 nv-wrap nv-sunburst nv-chart-" + id ) . attr ( "transform" , "translate(" + ( ( availableWidth / 2 ) + margin . left + margin . right ) + "," + ( ( availableHeight / 2 ) + margin . top + margin . bottom ) + ")" ) ; } else { wrap . attr ( "transform" , "translate(" + ( ( availableWidth / 2 ) + margin . left + margin . right ) + "," + ( ( availableHeight / 2 ) + margin . top + margin . bottom ) + ")" ) ; } container . on ( "click" , ( d , i ) { dispatch . chartClick ( data : d , index : i , pos : d3 . event , id : id ) ; } ) ; partition . value ( modes [ mode ] || modes [ "count" ] ) ;
 //reverse the drawing order so that the labels of inner

 //arcs are drawn on top of the outer arcs.
 var nodes = partition . nodes ( data [ 0 ] ) . reverse ( ) ; storeRetrievePrevPositions ( nodes ) ; var cG = wrap . selectAll ( ".arc-container" ) . data ( nodes , key ) ;
 //handle new datapoints
 var cGE = cG . enter ( ) . append ( "g" ) . attr ( "class" , "arc-container" ) ; cGE . append ( "path" ) . attr ( "d" , arc ) . style ( "fill" , ( d ) { if ( d . color ) { return d . color ; } else if ( groupColorByParent ) { return color ( ( d . children ? d : d . parent ) . name ) ; } else { return color ( d . name ) ; } } ) . style ( "stroke" , "#FFF" ) . on ( "click" , ( d , i ) { zoomClick ( d ) ; dispatch . elementClick ( data : d , index : i ) ; } ) . on ( "mouseover" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , true ) . style ( "opacity" , 0.8 ) ; dispatch . elementMouseover ( data : d , color : d3 . select ( this ) . style ( "fill" ) , percent : computeNodePercentage ( d ) ) ; } ) . on ( "mouseout" , ( d , i ) { d3 . select ( this ) . classed ( "hover" , false ) . style ( "opacity" , 1 ) ; dispatch . elementMouseout ( data : d ) ; } ) . on ( "mousemove" , ( d , i ) { dispatch . elementMousemove ( data : d ) ; } ) ;
 ///Iterating via each and selecting based on the this

 ///makes it work ... a cG.selectAll('path') doesn't.

 ///Without iteration the data (in the element) didn't update.
 cG . each ( ( d ) { d3 . select ( this ) . select ( "path" ) . transition ( ) . duration ( duration ) . attrTween ( "d" , arcTweenUpdate ) ; } ) ; if ( showLabels ) {
 //remove labels first and add them back
 cG . selectAll ( "text" ) . remove ( ) ;
 //this way labels are on top of newly added arcs
 cG . append ( "text" ) . text ( ( e ) { return labelFormat ( e ) ; } ) . transition ( ) . duration ( duration ) . attr ( "opacity" , ( d ) { if ( labelThresholdMatched ( d ) ) { return 1 ; } else { return 0 ; } } ) . attr ( "transform" , ( d ) { var width = this . getBBox ( ) . width ; if ( identical ( d . depth , 0 ) ) { return "rotate(0)translate(" + ( width / 2 * - 1 ) + ",0)" ; } else { var centerAngle = computeCenterAngle ( d ) ; var rotation = rotationToAvoidUpsideDown ( d ) ; if ( identical ( rotation , 0 ) ) { return "rotate(" + centerAngle + ")translate(" + ( y ( d . y ) + 5 ) + ",0)" ; } else { return "rotate(" + centerAngle + ")translate(" + ( y ( d . y ) + width + 5 ) + ",0)rotate(" + rotation + ")" ; } } } ) ; }
 //zoom out to the center when the data is updated.
 zoomClick ( nodes [ nodes . length - 1 ] ) ;
 //remove unmatched elements ...
 cG . exit ( ) . transition ( ) . duration ( duration ) . attr ( "opacity" , 0 ) . each ( "end" , ( d ) { var k = key ( d ) ; prevPositions [ k ] = undefined ; } ) . remove ( ) ; } ) ; renderWatch . renderEnd ( "sunburst immediate" ) ; return chart ; }
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------
 chart . dispatch = dispatch ; chart . options = nv . utils . optionsFunc . bind ( chart ) ; chart . _options = Object . create ( { } , width : { "get" : ( ) { return width ; } , "set" : ( _ ) { width = _ ; } } , height : { "get" : ( ) { return height ; } , "set" : ( _ ) { height = _ ; } } , mode : { "get" : ( ) { return mode ; } , "set" : ( _ ) { mode = _ ; } } , id : { "get" : ( ) { return id ; } , "set" : ( _ ) { id = _ ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; } } , groupColorByParent : { "get" : ( ) { return groupColorByParent ; } , "set" : ( _ ) { groupColorByParent = ! ! _ ; } } , showLabels : { "get" : ( ) { return showLabels ; } , "set" : ( _ ) { showLabels = ! ! _ ; } } , labelFormat : { "get" : ( ) { return labelFormat ; } , "set" : ( _ ) { labelFormat = _ ; } } , labelThreshold : { "get" : ( ) { return labelThreshold ; } , "set" : ( _ ) { labelThreshold = _ ; } } , sort : { "get" : ( ) { return sort ; } , "set" : ( _ ) { sort = _ ; } } , key : { "get" : ( ) { return key ; } , "set" : ( _ ) { key = _ ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = _ . top != undefined ? _ . top : margin . top ; margin . right = _ . right != undefined ? _ . right : margin . right ; margin . bottom = _ . bottom != undefined ? _ . bottom : margin . bottom ; margin . left = _ . left != undefined ? _ . left : margin . left ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = nv . utils . getColor ( _ ) ; } } ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . models . sunburstChart = ( ) { "use strict" ;
 //============================================================

 // Public Variables with Default Settings

 //------------------------------------------------------------
 var sunburst = nv . models . sunburst ( ) ; var tooltip = nv . models . tooltip ( ) ; var margin = { "top" : 30 , "right" : 20 , "bottom" : 20 , "left" : 20 } , width = null , height = null , color = nv . utils . defaultColor ( ) , showTooltipPercent = false , id = Math . round ( Math . random ( ) * 100000 ) , defaultState = null , noData = null , duration = 250 , dispatch = d3 . dispatch ( "stateChange" , "changeState" , "renderEnd" ) ;
 //============================================================

 // Private Variables

 //------------------------------------------------------------
 var renderWatch = nv . utils . renderWatch ( dispatch ) ; tooltip . duration ( 0 ) . headerEnabled ( false ) . valueFormatter ( ( d ) { return d ; } ) ;
 //============================================================

 // Chart function

 //------------------------------------------------------------
 chart ( selection ) { renderWatch . reset ( ) ; renderWatch . models ( sunburst ) ; selection . each ( ( data ) { var container = d3 . select ( this ) ; nv . utils . initSVG ( container ) ; var availableWidth = nv . utils . availableWidth ( width , container , margin ) ; var availableHeight = nv . utils . availableHeight ( height , container , margin ) ; chart . update = ( ) { if ( identical ( duration , 0 ) ) { container . call ( chart ) ; } else { container . transition ( ) . duration ( duration ) . call ( chart ) ; } } ; chart . container = container ;
 // Display No Data message if there's nothing to show.
 if ( ! data || ! data . length ) { nv . utils . noData ( chart , container ) ; return chart ; } else { container . selectAll ( ".nv-noData" ) . remove ( ) ; } sunburst . width ( availableWidth ) . height ( availableHeight ) . margin ( margin ) ; container . call ( sunburst ) ; } ) ; renderWatch . renderEnd ( "sunburstChart immediate" ) ; return chart ; }
 //============================================================

 // Event Handling/Dispatching (out of chart's scope)

 //------------------------------------------------------------
 sunburst . dispatch . on ( "elementMouseover.tooltip" , ( evt ) { evt . series = { "key" : evt . data . name , "value" : ( evt . data . value || evt . data . size ) , "color" : evt . color , "percent" : evt . percent } ; if ( ! showTooltipPercent ) { ; ; } tooltip . data ( evt ) . hidden ( false ) ; } ) ; sunburst . dispatch . on ( "elementMouseout.tooltip" , ( evt ) { tooltip . hidden ( true ) ; } ) ; sunburst . dispatch . on ( "elementMousemove.tooltip" , ( evt ) { tooltip ( ) ; } ) ;
 //============================================================

 // Expose Public Variables

 //------------------------------------------------------------

 // expose chart's sub-components
 chart . dispatch = dispatch ; chart . sunburst = sunburst ; chart . tooltip = tooltip ; chart . options = nv . utils . optionsFunc . bind ( chart ) ;
 // use Object get/set functionality to map between vars and chart functions
 chart . _options = Object . create ( { } , noData : { "get" : ( ) { return noData ; } , "set" : ( _ ) { noData = _ ; } } , defaultState : { "get" : ( ) { return defaultState ; } , "set" : ( _ ) { defaultState = _ ; } } , showTooltipPercent : { "get" : ( ) { return showTooltipPercent ; } , "set" : ( _ ) { showTooltipPercent = _ ; } } , color : { "get" : ( ) { return color ; } , "set" : ( _ ) { color = _ ; sunburst . color ( color ) ; } } , duration : { "get" : ( ) { return duration ; } , "set" : ( _ ) { duration = _ ; renderWatch . reset ( duration ) ; sunburst . duration ( duration ) ; } } , margin : { "get" : ( ) { return margin ; } , "set" : ( _ ) { margin . top = ! identical ( _ . top , undefined ) ? _ . top : margin . top ; margin . right = ! identical ( _ . right , undefined ) ? _ . right : margin . right ; margin . bottom = ! identical ( _ . bottom , undefined ) ? _ . bottom : margin . bottom ; margin . left = ! identical ( _ . left , undefined ) ? _ . left : margin . left ; sunburst . margin ( margin ) ; } } ) ; nv . utils . inheritOptions ( chart , sunburst ) ; nv . utils . initOptions ( chart ) ; return chart ; } ; nv . version = "1.8.6-dev" ; } ) ( ) ;
 //# sourceMappingURL=nv.d3.js.map
