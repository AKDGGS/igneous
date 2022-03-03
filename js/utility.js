// Takes an object containing a list of JSON requests
// and makes them, loading all the data into the object
// provided, and then finally calling the complete function
// of the object when finished
function queueRequests(obj)
{
	// Reset object run
	obj.finished = 0;
	obj.data = {};

	for(var i = 0; i < obj.requests.length; i++){
		queueRequest(obj.requests[i], obj);
	}
}

// See queueReqeusts()
function queueRequest(url, obj)
{
	var xhr = (window.ActiveXObject ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest());
	xhr.onreadystatechange = function(){
		if(xhr.readyState === 4){
			if(xhr.status === 200){
				var n = url.slice(0, -5);
				obj.data[n] = JSON.parse(xhr.responseText);
			}

			obj.finished++;
			if(obj.finished === obj.requests.length){
				obj.complete();
			}
		}
	};
	xhr.open('GET', url, true);
	xhr.send();
}


// Takes an arbitrary JSON object
// and renders it into a table, returning
// the table element
function JSONToElement(obj){
	var type = Object.prototype.toString.call(obj);

	switch(type){
		case '[object Boolean]':
			return document.createTextNode(obj.toString());

		case '[object String]':
			return document.createTextNode(obj);

		case '[object Number]':
			return document.createTextNode(obj.toString());

		case '[object Null]':
			return document.createTextNode('(null)');

		case '[object Object]':
			var tbl = document.createElement('table');
			var count = 0;
			for(var i in obj){
				var tr = document.createElement('tr');

				var th = document.createElement('th');
				th.appendChild(document.createTextNode(i));
				tr.appendChild(th);

				var td = document.createElement('td');
				td.appendChild(JSONToElement(obj[i]));
				tr.appendChild(td);

				tbl.appendChild(tr);
				count++;
			}
			if(count > 0) return tbl;
			else return document.createTextNode('(Empty Object)');

		case '[object Array]':
			if(obj.length < 1) return document.createTextNode('(Empty List)');

			var tbl = document.createElement('table');
			for(var i = obj.length; i--;){
				var tr = document.createElement('tr');

				var th = document.createElement('th');
				th.appendChild(document.createTextNode(i));
				tr.appendChild(th);

				var td = document.createElement('td');
				td.appendChild(JSONToElement(obj[i]));
				tr.appendChild(td);

				tbl.appendChild(tr);
			}
			return tbl;

		default:
			return document.createTextNode('Unknown - ' + type);
	}
}


// Initialize a set of simple javascript-based
function initTabs(){
	var tabs = document.getElementById('tabs');
	if(tabs !== null){
		var els = tabs.getElementsByTagName('a');
		for(var i = 0; i < els.length; i++){
			els[i].onclick = showTab;
		}
	}
}


// See initTabs()
function showTab(evt)
{
	var tabs = document.getElementById('tabs');
	if(tabs !== null){
		var els = tabs.getElementsByTagName('li');
		for(var i = 0; i < els.length; i++){
			// Ensure no list item has an active
			// class attached to it.
			var li = els[i];
			li.className = '';

			// The anchor should be the first child.
			// Find the element associated with this
			// anchor and hide it.
			var a = els[i].childNodes[0];
			var name = a.href.substring(a.href.indexOf('#') + 1);
			var tab = document.getElementById('tab-' + name);
			if(tab !== null) tab.style.display = 'none';
		}

		// Flag the one that was clicked as active
		// and show its content
		this.parentNode.className = 'active';
		var name = this.href.substring(this.href.indexOf('#') + 1);
		var tab = document.getElementById('tab-' + name);
		if(tab !== null) tab.style.display = 'block';
	}

	var e = evt === undefined ? window.event : evt;	
	if('preventDefault' in e) e.preventDefault();
	return false;
}


// Returns a hacked up layer that's designed
// to work around the fact that Leaflet doesn't
// properly display features if you move beyond
// the anti-meridian (dateline) - when adding
// features to this layer, a second, mirrored
// feature will be added automatically.
// This makes it so that the feature shows up
// when the view crosses the dateline.
function mirroredLayer(data, style){
	var layer = L.geoJson(null, {
		pointToLayer: function (f, ll) {
			return L.circleMarker(ll);
		},
		coordsToLatLngInvert: function(c){
			var ll = new L.LatLng(c[1], c[0], c[2]);
			if(ll.lng >= 0) ll.lng -= 360;
			else ll.lng += 360;

			return ll;
		},
		style: style
	});
	layer.on('layeradd', function(e){
		if('coordsToLatLng' in e.target.options){
			delete e.target.options.coordsToLatLng;
		} else {
			e.target.options.coordsToLatLng =
				e.target.options.coordsToLatLngInvert;

			// If the layer has an identifable feature, use that
			// otherwise, just break it down to geoJSON
			if('feature' in e.layer) {
				e.target.addData(e.layer.feature);
			} else {
				e.target.addData(e.layer.toGeoJSON());
			}
		}
	});

	if(data != null) layer.addData(data);
	return layer;
}


// This function is used on several view pages to initialize
// a small map containing a single feature
function initSimpleMap(geojson, featureColor)
{
	if(typeof featureColor === 'undefined'){
		featureColor = '#9f00ff';
	}

	var features = mirroredLayer(geojson, {
		color: featureColor,
		opacity: 1,
		weight: 2,
		radius: 6,
		fill: true,
		'z-index': 8
	});

	var baselayers = {
		'Open Street Maps': new L.TileLayer(
			'//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
			{ minZoom: 3, maxZoom: 19, zIndex: 2 }
		),
		'OpenTopoMap': new L.TileLayer(
			'http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
			{ minZoom: 3, maxZoom: 17, zIndex: 3 }
		),
		'ESRI Imagery': new L.TileLayer(
			'//server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
			{ minZoom: 3, maxZoom: 19, zIndex: 4 }
		),
		'ESRI Topographic': new L.TileLayer(
			'//server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
			{ minZoom: 3, maxZoom: 19, zIndex: 5 }
		),
		'ESRI Shaded Relief': new L.TileLayer(
			'//server.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}',
			{ minZoom: 3, maxZoom: 13, zIndex: 6 }
		),
		'ESRI DeLorme': new L.TileLayer(
			'//server.arcgisonline.com/ArcGIS/rest/services/Specialty/DeLorme_World_Base_Map/MapServer/tile/{z}/{y}/{x}',
			{ minZoom: 3, maxZoom: 11, zIndex: 7 }
		),
		'ESRI National Geographic': new L.TileLayer(
			'//server.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/{z}/{y}/{x}',
			{ minZoom: 3, maxZoom: 16, zIndex: 8 }
		),
		'Stamen Watercolor': new L.TileLayer(
			'http://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.png',
			{ minZoom: 3, maxZoom: 16, subdomains: 'abcd', zIndex: 11 }
		)
	};


	var overlays = {
		'PLSS (BLM)': new L.tileLayer.wms(
			'http://maps.dggs.alaska.gov/arcgis/services/apps/plss/MapServer/WMSServer',
			{
				layers: '1,2,3',
				transparent: true,
				format: 'image/png',
				minZoom: 3, maxZoom: 16, zIndex: 12
			}
		),
		'Quadrangles': new L.tileLayer.wms(
			'http://maps.dggs.alaska.gov/arcgis/services/apps/Quad_Boundaries/MapServer/WMSServer',
			{
				layers: '1,2,3',
				transparent: true,
				format: 'image/png',
				minZoom: 3, maxZoom: 16, zIndex: 12
			}
		)
	};

	var map_el = document.getElementById('map');
	if(map_el != null) map_el.style.display = 'block';

	var map = L.map('map', {
		attributionControl: false,
		zoomControl: false,
		worldCopyJump: true,
		layers: [
			baselayers['Open Street Maps'],
			features
		]
	});

	// Add zoom control
	map.addControl(L.control.zoom({ position: 'topleft' }));
	// Add mouse position control
	map.addControl(L.control.mousePosition({
		emptyString: 'Unknown', numDigits: 3
	}));
	// Add layer control
	map.addControl(L.control.layers(
		baselayers, overlays, {
			position: 'bottomright', autoZIndex: false
		}
	));

	// Start in Fairbanks
	map.setView([64.843611, -147.723056], 3);

	return map;
}
