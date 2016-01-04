<%@
	page trimDirectiveWhitespaces="true"
%><%@
	taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><%@
	taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"
%><%@
	taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Division of Geological &amp; Geophysical Surveys Geologic Materials Center</title>
		<meta charset="utf-8">
		<meta http-equiv="x-ua-compatible" content="IE=edge" >
		<link rel="stylesheet" href="css/apptmpl.min.css">
		<link rel="stylesheet" href="leaflet/leaflet.css" />
		<link rel="stylesheet" href="leaflet/leaflet.draw.css" />
		<link rel="stylesheet" href="leaflet/leaflet.mouseposition.css" />
		<link rel="stylesheet" href="leaflet/leaflet.searchcontrol.css" />
		<link rel="stylesheet" href="css/search.css" />
		<style>
			.apptmpl-container { min-width: 800px !important; }
			.apptmpl-content { font-family: 'Georgia, serif'; }
			.apptmpl-content a { color: #428bca; text-decoration: none; }
			.apptmpl-content a:hover, a:focus { color: #2a6496; text-decoration: underline; }
			#map { height: 450px; }
		</style>
		<script src="leaflet/leaflet.js"></script>
		<script src="leaflet/leaflet.draw.js"></script>
		<script src="leaflet/leaflet.mouseposition.js"></script>
		<script src="leaflet/leaflet.searchcontrol.js"></script>
		<script src="js/mustache-2.2.0.min.js"></script>
		<script src="js/utility.js"></script>
		<script>
			var map, features, aoi;
			var searchok = true;

			var SEARCH_FIELDS = [
				'q', 'keyword_id', 'collection_id', 'prospect_id',
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


			function search(clean)
			{
				// Only run a search if a search
				// isn't already running
				if(!searchok) return;
				searchok = false;

				// If a search is dirty, restart
				// at page 0
				if(clean !== true) document.getElementById('start').value = 0;

				var params = encodeParameters();
				window.location.hash = params;

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
							search(true);
						}
					};
				}

				features = mirroredLayer(null, function(f){
					return {
						color: f.properties.color,
						opacity: 1,
						weight: 2,
						radius: 6,
						fill: true,
						'z-index': 8
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
					'z-index': 9
				});

				var baselayers = {
					'Open Street Maps': new L.TileLayer(
						'//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
						{ minZoom: 3, maxZoom: 19, zIndex: 1 }
					),
					'MapQuest Open Aerial': new L.TileLayer(
						'http://otile{s}.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.png',
						{ minZoom: 3, maxZoom: 11, subdomains: '1234', zIndex: 2  }
					),
					'MapQuest Open OSM': new L.TileLayer(
						'http://otile{s}.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.png',
						{ minZoom: 3, maxZoom: 17, subdomains: '1234', zIndex: 3 }
					),
					'GINA Satellite': new L.TileLayer(
						'http://tiles.gina.alaska.edu/tilesrv/bdl/tile/{x}/{y}/{z}',
						{ minZoom: 3, mazZoom: 15, zIndex: 4 }
					),
					'GINA Topographic': new L.TileLayer(
						'http://tiles.gina.alaska.edu/tilesrv/drg/tile/{x}/{y}/{z}',
						{ minZoom: 3, maxZoom: 12, zINdex: 5 }
					),
					'Stamen Watercolor': new L.TileLayer(
						'http://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.png',
						{ minZoom: 3, maxZoom: 16, subdomains: 'abcd', zIndex: 6 }
					)
				};

				var overlays = {
					'Quadrangles': new L.TileLayer(
						'http://tiles.gina.alaska.edu/tilesrv/quad_google/tile/{x}/{y}/{z}',
						{ minZoom: 3, maxZoom: 16, zIndex: 7 }
					)
				};

				map = L.map('map', {
					attributionControl: false,
					zoomControl: false,
					worldCopyJump: true,
					layers: [ baselayers['Open Street Maps'] ]
				});

				map.addLayer(features);
				map.addLayer(aoi);

				// Add zoom control
				map.addControl(L.control.zoom({ position: 'topleft' }));
				// Add mouse position control
				map.addControl(L.control.mousePosition({
					emptyString: 'Unknown', numDigits: 3
				}));
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
							search(true);
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

				document.getElementById('q').focus();
			}
		</script>
	</head>
	<body onload="init()">
		<div class="apptmpl-container">
			<div class="apptmpl-goldbar">
				<a class="apptmpl-goldbar-left" href="http://alaska.gov"></a>
				<span class="apptmpl-goldbar-right"></span>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<a href="container_log.html">Move Log</a>
				<a href="quality_report.html">Quality Assurance</a>
				<a href="audit_report.html">Audit</a>
				<c:if test="${pageContext.request.isUserInRole('admin')}">
				<a href="import.html">Data Importer</a>
				</c:if>
				</c:if>
				<a href="help">Search Help</a>
			</div>

			<div class="apptmpl-banner">
				<a class="apptmpl-banner-logo" href="http://dggs.alaska.gov"></a>
				<div class="apptmpl-banner-title">Geologic Materials Center Inventory</div>
				<div class="apptmpl-banner-desc">Alaska Division of Geological &amp; Geophysical Surveys</div>
			</div>

			<div class="apptmpl-breadcrumb">
				<a href="http://alaska.gov">State of Alaska</a> &gt;
				<a href="http://dnr.alaska.gov">Natural Resources</a> &gt;
				<a href="http://dggs.alaska.gov">Geological &amp; Geophysical Surveys</a> &gt;
				<a href="http://dggs.alaska.gov/gmc">Geologic Materials Center</a>
			</div>

			<div class="apptmpl-content">
				<div id="map"></div>
				<div id="controls">
					<input type="hidden" name="start" id="start" value="0" />
					<div>
						<label for="max">Showing</label>
						<select name="max" id="max">
							<option value="10">10</option>
							<option value="25" selected="selected">25</option>
							<option value="50">50</option>
							<option value="100">100</option>
							<option value="250">250</option>
							<option value="500">500</option>
							<option value="1000">1000</option>
						</select>

						<span class="spacer">|</span>

						<button id="btn-prev">Previous</button>
						Displaying <span id="pages"></span>
						<button id="btn-next">Next</button>
					</div>

					<div>
						<a id="pdf" href="#">PDF</a> / <a id="csv" href="#">CSV</a>

						<span class="spacer">|</span>

						<label for="sort">Sort by</label>
						<c:forEach begin="0" end="1">
						<select name="sort">
							<option value="0" selected="selected">Best Match</option>
							<option value="9">Barcode</option>
							<option value="10">Borehole</option>
							<option value="11">Box</option>
							<option value="1">Collection</option>
							<option value="2">Core Number</option>
							<option value="14">Keywords</option>
							<option value="3">Location</option>
							<option value="12">Prospect</option>
							<option value="13">Sample</option>
							<option value="4">Set Number</option>
							<option value="5">Top</option>
							<option value="6">Bottom</option>
							<option value="7">Well Name</option>
							<option value="8">Well Number</option>
						</select>
						<select name="dir">
							<option value="0" selected="selected">Asc</option>
							<option value="1">Desc</option>
						</select>
						</c:forEach>
					</div>
				</div>
				<div id="list"></div>
			</div>
		</div>
		<script id="tmpl-popup" type="x-tmpl-mustache">
			<div>
				<a href="inventory/{{ID}}">{{ID}}</a>
				{{#containerPath}} - {{containerPath}}{{/containerPath}}<br>
				{{#intervalTop}}{{intervalTop}} {{intervalUnit.abbr}}{{/intervalTop}}
				{{#intervalBottom}}{{#intervalTop}} - {{/intervalTop}}{{intervalBottom}} {{intervalUnit.abbr}}{{/intervalBottom}}
			</div>
			{{#boreholes}}
			<div>
				{{#prospect}}
				Prospect: <a href="prospect/{{ID}}">{{name}}</a><br>
				{{/prospect}}
				Borehole: <a href="borehole/{{ID}}">{{name}}</a>
			</div>
			{{/boreholes}}
			{{#wells}}
			<div>
				Well: <a href="well/{{ID}}">{{name}}{{#wellNumber}} - {{wellNumber}}{{/wellNumber}}</a>
				{{#APINumber}}<div>API: {{APINumber}}</div>{{/APINumber}}
			</div>
			{{/wells}}
			{{#outcrops}}
			<div>
				Outcrop: <a href="outcrop/{{ID}}">{{name}}{{#number}} - {{number}}{{/number}}</a>
			</div>
			{{/outcrops}}
			<ul class="kw">{{#keywords}}<li>{{name}}</li>{{/keywords}}</ul>
		</script>
		<script id="tmpl-table" type="x-tmpl-mustache">
			<table class="results">
				<thead>
					<tr>
						<th>ID</th>
						<th>Related</th>
						<th>Sample</th>
						<th>Box /<br>Set</th>
						<th>Core No /<br>Diameter</th>
						<th>Top /<br>Bottom</th>
						<th>Keywords</th>
						<th>Collection</th>
						<th>Barcode</th>
						<Th>Location /<br>Quality</th>
					</tr>
				</thead>
				<tbody>
					{{#list}}
					<tr class="{{#boreholes.0}}borehole {{/boreholes.0}}{{#wells.0}}well {{/wells.0}}{{#outcrops.0}}outcrop {{/outcrops.0}}{{#shotlines.0}}shotline {{/shotlines.0}}">
						<td><a href="inventory/{{ID}}">{{ID}}</a></td>
						<td>
							{{#boreholes}}
							<div>
								{{#prospect}}
								Prospect: <a href="prospect/{{ID}}">{{name}}</a><br>
								{{/prospect}}
								Borehole: <a href="borehole/{{ID}}">{{name}}</a>
							</div>
							{{/boreholes}}
							{{#wells}}
							<div>
								Well: <a href="well/{{ID}}">{{name}}{{#wellNumber}} - {{wellNumber}}{{/wellNumber}}</a>
								{{#APINumber}}<div>API: {{APINumber}}</div>{{/APINumber}}
							</div>
							{{/wells}}
							{{#outcrops}}
							<div>
								Outcrop: <a href="outcrop/{{ID}}">{{name}}{{#number}} - {{number}}{{/number}}</a>
							</div>
							{{/outcrops}}
						</td>
						<td>{{sampleNumber}}</td>
						<td>
							{{boxNumber}}
							{{#setNumber}}<br>{{setNumber}}{{/setNumber}}
						</td>
						<td>
							{{coreNumber}}
							{{#coreDiameter}}<br>{{name}}{{^name}}{{diameter}} {{unit.abbr}}{{/name}}{{/coreDiameter}}
						</td>
						<td>
							{{#intervalTop}}{{intervalTop}} {{intervalUnit.abbr}}{{/intervalTop}}
							{{#intervalBottom}}<br>{{intervalBottom}} {{intervalUnit.abbr}}{{/intervalBottom}}
						</td>
						<td>
							<ul class="kw">{{#keywords}}<li>{{name}}</li>{{/keywords}}</ul>
						</td>
						<td>{{collection.name}}</td>
						<td class="barcode">
							{{barcode}}{{^barcode}}{{altBarcode}}{{/barcode}}
						</td>
						<td class="quality">
							{{containerPath}}
							{{#qualities}}<div>{{#issues}}<span>{{.}}</span>{{/issues}}</div>{{/qualities}}
						</td>
					</tr>
					{{/list}}
				</tbody>
			</table>
		</script>
		<script id="tmpl-advanced" type="x-tmpl-mustache">
			<div>
				<label for="keyword_id">Keywords</label>
				<select id="keyword_id" name="keyword_id" size="5" multiple="multiple" onchange="search()">
				{{#keyword}}
					<option value="{{ID}}">{{name}}</option>
				{{/keyword}}
				</select>
			</div>
			<div>
				<label for="top">Interval</label>
				Top: <input type="text" name="top" id="top" size="5">
				Bottom: <input type="text" name="bottom" id="bottom" size="5">
			</div>
			<div>
				<label for="collection_id">Collection</label>
				<select id="collection_id" name="collection_id" size="5" multiple="multiple" onchange="search()">
				{{#collection}}
					<option value="{{ID}}">{{name}}</option>
				{{/collection}}
				</select>
			</div>
			<div>
				<label for="prospect_id">Prospect</label>
				<select id="prospect_id" name="prospect_id" size="5" multiple="multiple" onchange="search()">
				{{#prospect}}
					<option value="{{ID}}">{{name}}</option>
				{{/prospect}}
				</select>
			</div>
			<div>
				<label for="quadrangle_id">Quadrangle</label>
				<select id="quadrangle_id" name="quadrangle_id" size="5" multiple="multiple">
				{{#quadrangle}}
					<option data-geojson="{{geoJSON}}" value="{{ID}}">{{name}}</option>
				{{/quadrangle}}
				</select>
			</div>
			<div>
				<label for="mining_district_id">Mining District</label>
				<select id="mining_district_id" name="mining_district_id" size="5" multiple="multiple">
				{{#mining_district}}
					<option data-geojson="{{geoJSON}}" value="{{ID}}">{{name}}</option>
				{{/mining_district}}
				</select>
			</div>
		</script>
	</body>
</html>
