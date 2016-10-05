var map, features, aoi;
var searchok = true;

var SEARCH_FIELDS = [
	'q', 'keyword', 'collection_id', 'prospect_id',
	'mining_district_id', 'quadrangle_id', 'top',
	'bottom'
];
var CONTROL_FIELDS = ['start', 'max', 'sort', 'dir'];


function encodeParameters()
{
	var params = encodeFields(SEARCH_FIELDS);

	// Encode the AOI, if it exists
	if(aoi.getLayers().length > 0){
		if(params.length > 0) params += '&';
		var geojson = JSON.stringify(
			aoi.getLayers()[0].toGeoJSON().geometry
		);

		// Prune geojson to 4 significant digits
		geojson = geojson.replace(/\d+\.\d+/g, function(match){
			return Number(match).toFixed(4);
		});

		params += 'aoi=' + encodeURIComponent(geojson);
	}

	// Only encode the control fields if there's
	// actual search parameters in there
	if(params.length > 0){
		params += '&' + encodeFields(CONTROL_FIELDS);
	}

	return params;
}


function encodeFields(fields)
{
	var params = '';
	for(var i = 0; i < fields.length; i++){
		var name = fields[i];
		var els = document.getElementsByName(fields[i]);
		for(var j = 0; j < els.length; j++){
			var el = els[j];
			switch(el.tagName){
				case 'INPUT':
					if(el.value.trim().length > 0){
						if(params.length > 0) params += '&';
						params += name + '=' + encodeURIComponent(
							el.value.trim()
						);
					}
				break;

				case 'SELECT':
					for(var k = 0; k < el.options.length; k++){
						var opt = el.options[k];
						if(opt.selected){
							if(params.length > 0) params += '&';
							params += name + '=' +
								encodeURIComponent(opt.value);
						}	
					}
				break;
			}
		}
	}
	return params;
}


function decodeParameters(params)
{
	var advanced = false;
	if(params.length < 1) return advanced;

	var cnt = {};

	var kvs = params.split('&');
	for(var i = 0; i < kvs.length; i++){
		var idx = kvs[i].indexOf('=');
		var k = kvs[i].substring(0, idx);
		var v = decodeURIComponent(kvs[i].substring(idx + 1));

		// Should the advanced field be expanded?
		if(v.length > 0 && k !== 'q'){
			for(var j = 0; j < SEARCH_FIELDS.length; j++){
				if(k === SEARCH_FIELDS[j]) advanced = true;
			}
		}

		if(k === 'aoi'){
			aoi.addData(JSON.parse(v));
			continue;
		}

		var els = document.getElementsByName(k);

		// If there's more than one element, keep
		// a count so we can set each.
		if(els.length == 0) continue;
		else if(els.length == 1 || !(k in cnt)) cnt[k] = 0;
		else cnt[k]++;

		var el = els[cnt[k]];

		switch(el.tagName){
			case 'INPUT':
				el.value = v;
			break;
		
			case 'SELECT':
				for(var j = 0; j < el.options.length; j++){
					if(el.options[j].value === v){
						el.options[j].selected = true;
						break;
					}
				}
			break;
		}
	}

	return advanced;
}


function search(clean, noupdate)
{
	// Only run a search if a search
	// isn't already running
	if(!searchok) return;
	searchok = false;

	// If a search is dirty, restart
	// at page 0
	if(clean !== true) document.getElementById('start').value = 0;

	var params = encodeParameters();
	if(noupdate !== true) window.location.hash = params;

	// If there's nothing to search by, don't 
	// search, and hide all the search stuff
	if(params.length == 0){
		features.clearLayers();

		document.getElementById('controls').style.display = 'none';
		document.getElementById('list').innerHTML =  '';
		searchok = true;
		return;
	}
	
	var xhr = (window.ActiveXObject ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest());
	xhr.onreadystatechange = function() {
		if(xhr.readyState === 4){
			searchok = true;

			// Clear out all the features
			features.clearLayers();

			// Setup the PDF/CSV links
			var pdf = document.getElementById('pdf');
			if(pdf) pdf.href = 'search.pdf?' + params;
			var csv = document.getElementById('csv');
			if(csv) csv.href = 'search.csv?' + params;

			// If the search json returns an error
			if(xhr.status !== 200){
				document.getElementById('controls').style.display = 'none';
				document.getElementById('list').innerHTML = 
					'<div class="error">Error: ' + xhr.responseText + '</div>';
				return;

			} else {
				var obj = JSON.parse(xhr.responseText);

				// If there's no results, hide the controls and show
				// a warning.
				if(!('list' in obj)){
					document.getElementById('controls').style.display = 'none';
					document.getElementById('list').innerHTML = 
						'<div class="warning">No results found.</div>';
					return;
				}

				var start = Number(document.getElementById('start').value);

				// Disable previous button, if necessary
				document.getElementById('btn-prev').disabled =
					(start === 0 ? true : false);

				// Disable next button if necessary
				document.getElementById('btn-next').disabled = 
					((start + obj['list'].length) >= obj['found'] ? true : false);

				// Update display on number of items/current items displayed
				document.getElementById('pages').innerHTML = 
					(start + 1) + ' - ' + (obj['list'].length + start) + 
					' of ' + obj['found'];

				// Iterate over the geoJSON in the results
				// and populate the map
				for(var i = 0; i < obj['list'].length; i++){
					var o = obj['list'][i];
					if('geoJSON' in o){
						// Clone the geojson object, allowing
						// the original reference to be freed
						var geojson = {
							type: 'Feature', 
							properties: {
								popup: Mustache.render(
									document.getElementById('tmpl-popup').innerHTML,
									o
								),
								color: '#9f00ff'
							},
							geometry: JSON.parse(JSON.stringify(o['geoJSON']))
						};
						if('boreholes' in o){
							geojson.properties.color = '#76ff7a';
						} else if('wells' in o){
							geojson.properties.color = '#2e70ff';
						} else if('outcrops' in o){
							geojson.properties.color = '#fdff00';
						} else if('shotlines' in o){
							geojson.properties.color = '#ed2939';
						}

						features.addData(geojson);
					}
				}
				features.bringToBack();

				// Show the controls and update the results table
				document.getElementById('controls').style.display = 'block';
				document.getElementById('list').innerHTML = Mustache.render(
					document.getElementById('tmpl-table').innerHTML,
					obj
				);
			}
		}
	}
	xhr.open('POST', 'search.json', true);
	xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
	xhr.send(params);
}


function handlegeojson(ele)
{
	var el = ele === undefined ? this : ele;
	if('layer' in el){
		el.layer.clearLayers();
		for(var i = 0; i < el.options.length; i++){
			var opt = el.options[i];
			if(opt.selected){
				var attr = opt.getAttribute("data-geojson");
				if(attr != null && attr.length > 0){
					var json = JSON.parse(attr);
					el.layer.addData(json);
				}
			}
		}
	}
}


function init()
{
	// Disable bfcache (firefox compatibility)
	if('onunload' in window){
		window.onunload = function(){};
	}

	// IE8 fix -- support trim()
	if(typeof String.prototype.trim !== 'function') {
		String.prototype.trim = function() {
			return this.replace(/^\s+|\s+$/g, ''); 
		}
	}

	// If this browser supports hash updates, and
	// we're not currently searching, go ahead
	// and search based on the new hash
	if('onhashchange' in window){
		window.onhashchange = function(){
			if(searchok && window.location.hash.length > 1){
				var show = decodeParameters(
					window.location.hash.substring(1)
				);
				if(show){
					var adv = document.getElementById('advancedcontrols');
					if(adv != null) adv.style.display = 'block';
				}

				var md_el = document.getElementById('mining_district_id');
				if(md_el !== null) handlegeojson(md_el);

				var q_el = document.getElementById('quadrangle_id');
				if(q_el !== null) handlegeojson(q_el);
				search(true, true);
			}
		};
	}

	features = mirroredLayer(null, function(f){
		return {
			color: f.properties.color,
			opacity: 1,
			weight: 2,
			radius: 6,
			fill: false,
			'z-index': 20
		};
	});
	// Bind the generated popup
	features.options.onEachFeature = function(f, l){
		l.bindPopup(f.properties.popup);
	};

	aoi = mirroredLayer(null, {
		color: '#f00',
		opacity: 1,
		weight: 2,
		radius: 6,
		fill: false,
		clickable: false,
		'z-index': 20
	});

	var baselayers = {
		'Open Street Maps Monochrome': L.tileLayer(
			'http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png',
			{ minZoom: 3, maxZoom: 18, zIndex: 1 }
		),
		'Open Street Maps': new L.TileLayer(
			'//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
			{ minZoom: 3, maxZoom: 19, zIndex: 2 }
		),
		'OpenTopoMap': new L.TileLayer(
			'http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
			{ minZoom: 3, maxZoom: 17, zIndex: 3  }
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
		'GINA Satellite': new L.TileLayer(
			'http://tiles.gina.alaska.edu/tilesrv/bdl/tile/{x}/{y}/{z}',
			{ minZoom: 3, mazZoom: 15, zIndex: 9 }
		),
		'GINA Topographic': new L.TileLayer(
			'http://tiles.gina.alaska.edu/tilesrv/drg/tile/{x}/{y}/{z}',
			{ minZoom: 3, maxZoom: 12, zIndex: 10 }
		),
		'Stamen Watercolor': new L.TileLayer(
			'http://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.png',
			{ minZoom: 3, maxZoom: 16, subdomains: 'abcd', zIndex: 11 }
		)
	};

	var overlays = {
		'PLSS (BLM)': new L.tileLayer.wms(
			'http://www.geocommunicator.gov/arcgis/services/PLSS/MapServer/WMSServer',
			{
				'layers': '1,2,3,4,5,6,7,8,9,10,11,12,13',
				transparent: true,
				format: 'image/png',
				minZoom: 3, maxZoom: 16, zIndex: 12
			}
		),
		'Quadrangles': new L.TileLayer(
			'http://tiles.gina.alaska.edu/tilesrv/quad_google/tile/{x}/{y}/{z}',
			{ minZoom: 3, maxZoom: 16, zIndex: 13 }
		)
	};

	map = L.map('map', {
		attributionControl: false,
		zoomControl: false,
		worldCopyJump: true,
		layers: [ baselayers['Open Street Maps Monochrome'] ]
	});

	map.addLayer(features);
	map.addLayer(aoi);

	// Add zoom control
	map.addControl(L.control.zoom({ position: 'topleft' }));

	// Add mouse position control
	map.addControl(L.control.mousePosition({
		emptyString: 'Unknown', numDigits: 4
	}));

	// Add scale bar
	map.addControl(L.control.scale({ position: 'bottomleft' }));

	// Add layer control
	map.addControl(L.control.layers(
		baselayers, overlays, {
			position: 'bottomleft', autoZIndex: false
		}
	));

	// Modify the button text
	L.drawLocal.draw.toolbar.buttons.rectangle = 'Draw an area of interest';
	L.drawLocal.draw.handlers.rectangle.tooltip.start = 'Click and draw to draw an area of interest';

	// Initialize drawing control
	map.addControl(
		new L.Control.Draw({
			position: 'topleft',
			draw: {
				polygon: false, polyline: false,
				marker: false, circle: false,
				rectangle: {
					metric: true,
					shapeOptions: {
						color: '#f00',
						opacity: 1,
						weight: 2,
						radius: 6,
						fill: false,
						clickable: false
					}
				}
			},
			edit: {
				featureGroup: aoi,
				edit: false,
				remove: false
			}
		})
	);

	// When drawing starts, empty out the
	// old drawing
	map.on('draw:drawstart', function(e){
		aoi.clearLayers();
	});

	// When you draw, add it to the aoi
	// and the anti-aoi
	map.on('draw:created', function(e){
		aoi.addLayer(e.layer);
	});
	
	// Search when drawing ends
	map.on('draw:drawstop', function(e){
		search();
	});

	// Add search control
	var searchctl = L.control.searchControl({
		position: 'topright',
		menubutton: true,
		// Search on submit
		onSubmit: function(evt){
			search(false);

			var e = evt === undefined ? window.event : evt;	
			if('preventDefault' in e) e.preventDefault();
			return false;
		},
		// If the menu button is clicked, show and hide
		// the advanced controls
		onMenuButton: function(){
			var adv = document.getElementById('advancedcontrols');
			if(adv != null){
				if(adv.style.display === 'block'){
					adv.style.display = 'none';
				} else {
					adv.style.display = 'block';
				}
			}
		}
	});
	map.addControl(searchctl);

	// Add the advanced controls
	var advanced = L.DomUtil.create(
		'div', 'search-advanced-container',
		searchctl.getContainer()
	);
	advanced.id = 'advancedcontrols';

	queueRequests({
		requests: [
			'mining_district.json', 'keyword.json',
			'collection.json', 'prospect.json',
			'quadrangle.json'
		],
		complete: function(){
			advanced.innerHTML = Mustache.render(
				document.getElementById('tmpl-advanced').innerHTML,
				this.data
			);

			// Top/Bottom key submit
			var top = document.getElementById('top');
			var bottom = document.getElementById('bottom');
			top.onkeydown = bottom.onkeydown = function(evt){
				var e = evt === undefined ? window.event : evt;	
				if(e.keyCode === 13){
					search();
					if('preventDefault' in e) e.preventDefault();
					return false;
				}
			};

			// Setup the preview for mining district
			var md_el = document.getElementById('mining_district_id');
			md_el.layer = mirroredLayer(null, {
				color: '#f00',
				opacity: 1,
				weight: 2,
				radius: 6,
				fill: false,
				clickable: false
			});
			map.addLayer(md_el.layer);
			md_el.onchange = function(){
				handlegeojson(this);
				search();
			}

			// Setup the preview for quadrangles
			var q_el = document.getElementById('quadrangle_id');
			q_el.layer = mirroredLayer(null, {
				color: '#f00',
				opacity: 1,
				weight: 2,
				radius: 6,
				fill: false,
				clickable: false
			});
			map.addLayer(q_el.layer);
			q_el.onchange = function(){
				handlegeojson(this);
				search();
			}

			// After all the resources have loaded, do the hashed
			// search, if there is one.
			if(window.location.hash.length > 1){
				var show = decodeParameters(
					window.location.hash.substring(1)
				);
				if(show){
					var adv = document.getElementById('advancedcontrols');
					if(adv != null) adv.style.display = 'block';
				}

				handlegeojson(md_el);
				handlegeojson(q_el);
				search(true, true);
			}
		}
	});

	// Start in Fairbanks
	map.setView([64.843611, -147.723056], 3);

	document.getElementById('max').onchange = search;

	document.getElementById('btn-next').onclick = function(){
		var st = document.getElementById('start');
		var mx = document.getElementById('max');
		st.value = Number(st.value) +
			Number(mx.options[mx.selectedIndex].value);
		search(true);
	};

	document.getElementById('btn-prev').onclick = function(){
		var st = document.getElementById('start');
		var mx = document.getElementById('max');
		st.value = Math.max(0, (Number(st.value) -
			Number(mx.options[mx.selectedIndex].value)));
		search(true);
	};

	var sorts = document.getElementsByName('sort');
	for(var i=0; i < sorts.length; i++){
		sorts[i].onchange = search;
	}

	var dirs = document.getElementsByName('dir');
	for(var i=0; i < dirs.length; i++){
		dirs[i].onchange = search;
	}

	document.getElementById('btn-reset').onclick = function(){
		window.location.hash = '';
		window.location.reload(false);
	}

	document.getElementById('q').focus();
}
