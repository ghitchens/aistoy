// Binds a function to the jQuery document ready event utilising the jQuery .class selector.
// The following code illustrates how the JavaScript can dynamically
// pick up the number of charts laid out in the HTML and then make them
// draggable (jQuery UI interaction).  The draggable scatterplots are
// nested bottom right. This is because their divs are positioned
// absolute in order to easily display them over the background map.
// The .bkgrndMapChartCanvas class needed an absolute location and each
// chart would be directly above and therefore obscure the other charts if
// their positions were not offset from one another.
$(document).ready(function(){
	scatterplots = $('.bkgrndMapChartCanvas');
	nestOffset = "";
});

// The creation of custom icons and the initialize function
// is based upon code found in 'Using PHP/MySQL with Google Maps'
// http://code.google.com/apis/maps/articles/phpsqlajax.html
var blue_icon = new GIcon(); 
blue_icon.image = 'http://labs.google.com/ridefinder/images/mm_20_blue.png';
blue_icon.shadow = 'http://labs.google.com/ridefinder/images/mm_20_shadow.png';
blue_icon.iconSize = new GSize(12, 20);
blue_icon.shadowSize = new GSize(22, 20);
blue_icon.iconAnchor = new GPoint(6, 20);
blue_icon.infoWindowAnchor = new GPoint(5, 1);

var yellow_icon = new GIcon(); 
yellow_icon.image = 'http://labs.google.com/ridefinder/images/mm_20_yellow.png';
yellow_icon.shadow = 'http://labs.google.com/ridefinder/images/mm_20_shadow.png';
yellow_icon.iconSize = new GSize(12, 20);
yellow_icon.shadowSize = new GSize(22, 20);
yellow_icon.iconAnchor = new GPoint(6, 20);
yellow_icon.infoWindowAnchor = new GPoint(5, 1);

var red_icon = new GIcon(); 
red_icon.image = 'http://labs.google.com/ridefinder/images/mm_20_red.png';
red_icon.shadow = 'http://labs.google.com/ridefinder/images/mm_20_shadow.png';
red_icon.iconSize = new GSize(12, 20);
red_icon.shadowSize = new GSize(22, 20);
red_icon.iconAnchor = new GPoint(6, 20);
red_icon.infoWindowAnchor = new GPoint(5, 1);


var markers = [];  
var next_mark_id = 0;
var map;

function initialize() {
	if (GBrowserIsCompatible()) {
		map = new GMap2(document.getElementById("bkgrndMap"));
		map.setCenter(new GLatLng(37.85,-122.38), 11);
        map.setMapType(G_SATELLITE_MAP);
		map.setUIToDefault();
 	}
   start_ais_connection();
}

function start_ais_connection() {
    var socket = io.connect('http://127.0.0.1:58080/');
    socket.on('ais', function (data) {
      var marker = createVesselMarker(data);
      map.addOverlay(marker);
      console.log(JSON.stringify(data));
    });
}

function createVesselMarker(data) { 
    var mmsi = data['mmsi'];
    var sog = data['sog'];
    var point = new GLatLng(data['y'],data['x']);
    var type = 'pub';
    
    var icon = (sog > 1.5 ? yellow_icon : red_icon);
	var marker = new GMarker(point, icon);
	var html = "MMSI: "+ mmsi + " SOG: " + sog;
	

	markers.push(marker);
	var i = next_mark_id;
	next_mark_id = next_mark_id + 1 ;
	markers[i].markId = i;
	markers[i].groupSelect = false;
	GEvent.addListener(marker, 'dblclick', function() {
		marker.openInfoWindowHtml(html);
	});
	
	// Switch icon on marker mouseover and mouseout
	GEvent.addListener(marker, "mouseover", function() {
		selectPoint(marker.markId);
	});

	GEvent.addListener(marker, "mouseout", function() {
		deselectPoint(marker.markId);
	});

	// The click event is used for multiple marker selection
	// by switching the groupSelect flag.
	GEvent.addListener(marker, "click", function() {
		if (marker.groupSelect == false) {
			marker.groupSelect = true;
			selectPoint(marker.markId);
		}
		else {
			marker.groupSelect = false;
			deselectPoint(marker.markId);
		}
	});

	return marker;
}


// The selectPoint and deselectPoint functions alter the
// appearance of the scatterplot points simultaneous with
// the alteration of the appearance of markers according
// to the mouseover, mouseout, and click events.
// The points and markers have the same corresponding colours.
// Each marker has its own id.  In the first scatterplot these ids
// correspond to the ids of the markers, but in the second
// scatterplot their ids correspond to the (number of markers + i).
// In the third scatterplot they correspond to ((2 * number of markers) + i),
// and so on.  This is because a single column array holds all the points.
function selectPoint(id) {
	if (markers[id].groupSelect == false) {
		for (var i = 0; i < scatterplots.length; i++) {
			myPoints[id + (markers.length * i)].attr({
				"fill": "#FFFF00",
				"r": 7
			});
		};
		markers[id].setImage(yellow_icon.image);
	}
	else
	{
		for (var i = 0; i < scatterplots.length; i++) {
			myPoints[id + (markers.length * i)].attr({
				"fill": "#FF0000",
				"r": 7
			});
		};
		markers[id].setImage(red_icon.image);
	}
}	

function deselectPoint(id) {
	if (markers[id].groupSelect == false) {
		for (var i = 0; i < scatterplots.length; i++) {
			myPoints[id + (markers.length * i)].attr({
				"fill": "#0000FF",
				"r": 5
			});
		};
		markers[id].setImage(blue_icon.image);
	}
}

            