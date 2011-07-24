// some icons to play with

var red_icon = new GIcon(); 
red_icon.image = 'http://labs.google.com/ridefinder/images/mm_20_red.png';
red_icon.shadow = 'http://labs.google.com/ridefinder/images/mm_20_shadow.png';
red_icon.iconSize = new GSize(12, 20);
red_icon.shadowSize = new GSize(22, 20);
red_icon.iconAnchor = new GPoint(6, 20);
red_icon.infoWindowAnchor = new GPoint(5, 1);

var vessel_icon = new Image();
vessel_icon.src = "http://www.openwebgraphics.com/resources/data/1762/16x16_1uparrow.png";
//vessel_icon.src = "http://icons.iconarchive.com/icons/mad-science/arcade-saturdays/32/Ship-icon.png";

var invisible_icon = new GIcon(G_DEFAULT_ICON, "http://www.google.com/intl/en_ALL/mapfiles/markerTransparent.png");
invisible_icon.shadowSize = new GSize(5,5);

var vessels = {};           // vessel data keyed on mmsi, holds array of data
var map;

function initialize() {
    if (GBrowserIsCompatible()) {
    	map = new GMap2(document.getElementById("bkgrndMap"));
    	map.setCenter(new GLatLng(37.82,-122.38), 13);
        map.setMapType(G_SATELLITE_MAP);
    	map.setUIToDefault();
   	}
    start_ais_connection();
}

/*----------------------------- handling ais data --------------------------*/

// open a websocket connection, handle incoming infomration about the vessel
function start_ais_connection() {
    var socket = io.connect('http://127.0.0.1:58080/');
    socket.on('ais', on_vessel_ais_data);
}

// handle ais data coming through
function on_vessel_ais_data(data) {
    if (vessels[data.mmsi]==null) {  // never heard from this vessel before
        vessels[data.mmsi]= {
            ais: [data], 
            marker: create_marker(data),
            elabel: create_elabel(data)
        };
    }
    else { // update track for this vessel, updating both marker & label
        var vessel = vessels[data.mmsi];
        vessel.marker.setPoint(new GLatLng(data.y, data.x));
        vessel.elabel.setPoint(new GLatLng(data.y, data.x));
        update_elabel_rotation(data);
        vessel.ais = data;
    }
}

/*--------------------------- vessel info display ---------------------------*/

function vesselTR(hdr, value) {
    return "<tr><th>" + hdr + "</th><td>" + value + "</td></tr>";
}

function vesselTABLE(ais) {
    desc = "<table cellpadding='5'>"
    desc += vesselTR('MMSI',ais.mmsi)
    desc += vesselTR('SOG', Math.round(ais.sog)); 
    desc += vesselTR('COG', Math.round(ais.cog)); 
    if (ais.true_heading <= 360) {
        desc += vesselTR('HDG', Math.round(ais.true_heading)); 
    }
    desc += "</table>"
    return desc;
}

/*----------------------------- marker rotation -----------------------------*/

// create and return a marker (actually, an invisible one, since we're using elables)
function create_marker(ais) {
    var marker = new GMarker(new GLatLng(ais.y, ais.x), invisible_icon);
	GEvent.addListener(marker, 'click', function() {
		marker.openInfoWindowHtml(vesselTABLE(ais));
	});
    map.addOverlay(marker);
    return marker;
}

// create and return an elabel (http://econym.org.uk/gmap/elabel.htm)
function create_elabel(ais) {
    var elabel = new ELabel(
        new GLatLng(ais.y, ais.x), 
        '<canvas id="vc'+ais.mmsi+'" width="32" height="32"><\/canvas>',
        null, new GSize(-16, 16)
    );     
    map.addOverlay(elabel); 
    update_elabel_rotation(ais);
    return elabel;
}

// given an ais info object, set the rotation of this marker.  We can't 
// assume we can accesess vessels as this marker may be new
function update_elabel_rotation(ais)
{
    var angleDegrees = ais.cog;
    var canvas = document.getElementById("vc"+ais.mmsi).getContext('2d');
    var angleRadians = (angleDegrees / 180) * Math.PI;
    var cosa = Math.cos(angleRadians);
    var sina = Math.sin(angleRadians);

    canvas.clearRect(0, 0, 32, 32);
    canvas.save();
    canvas.rotate(angleRadians);
    canvas.translate(16 * sina + 16 * cosa, 16 * cosa - 16 * sina);
    canvas.drawImage(vessel_icon, -16, -16);
    canvas.restore();    
}
  