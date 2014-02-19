var Search = function(o)
{
	this.lastsearch = '';
	this.ignorehashchange = false;
	this.updatehash = true;

	for(var i in o){ this[i] = o[i]; }
};

Search.prototype = {
	// These functions should be overridden, inside the object
	onhashchange: function(){ },
	onerror: function(title, description){ },
	onparam: function(obj){ return false; },
	onparse: function(json){ },

	hashwrapper: function()
	{
		if(this.ignorehashchange){
			this.ignorehashchange = false; return;
		}

		this.onhashchange();
	},
	
	setuponhashchange: function()
	{
		if('onhashchange' in window){
			var self = this;
			window.onhashchange = function(){ self.hashwrapper(); }
		}
	},

	getMax: function()
	{
		var e = document.getElementById('max');
		return Number(e.options[e.selectedIndex].value);
	},

	getSort: function(){
		var e = document.getElementById('sort');
		return Number(e.options[e.selectedIndex].value);
	},

	getDir: function(){
		var e = document.getElementById('dir');
		return Number(e.options[e.selectedIndex].value);
	},

	getStart: function(){
		return Number(document.getElementById('start').value);
	},

	setStart: function(n){
		document.getElementById('start').value = n;
	},

	setDisplayStart: function(h){
		document.getElementById('page_start').innerHTML = String(h);
	},

	setDisplayEnd: function(h)
	{
		document.getElementById('page_end').innerHTML = String(h);
	},

	setDisplayFound: function(h)
	{
		document.getElementById('page_found').innerHTML = String(h);
	},

	getPageControl: function(){
		return document.getElementById('page_control');
	},

	buildPageControl: function(start, max, found, size, length)
	{
		var self = this;
		var current_page = 1 + Math.floor((start + 1) / max);
		var total_pages = Math.ceil(size / max);

		var pages = this.calculatePages(current_page, total_pages);

		this.setDisplayStart(start + 1);
		this.setDisplayEnd(start + length);
		this.setDisplayFound(found);

		var ul = document.getElementById('page_control');
		while(ul.hasChildNodes()){ ul.removeChild(ul.firstChild); }

		var li = document.createElement('li');
		if(current_page > 1){
			var a = document.createElement('a');
			a.href = '#';
			a.innerHTML = '&laquo;';
			a.onclick = function(){
				self.page(-1);
				return false;
			};
			li.appendChild(a);
		} else {
			li.className = 'disabled';
			var span = document.createElement('span');
			span.innerHTML = '&laquo;';
			li.appendChild(span);
		}
		ul.appendChild(li);

		for(var i in pages){
			var li = document.createElement('li');
			if(pages[i] == 0){
				li.className = 'disabled';
				var span = document.createElement('span');
				span.appendChild(document.createTextNode('..'));
				li.appendChild(span);
			} else if(pages[i] == current_page){
				li.className = 'active';
				var span = document.createElement('span');
				span.appendChild(document.createTextNode(current_page));
				li.appendChild(span);
			} else {
				var a = document.createElement('a');
				a.href = '#';
				a.appendChild(document.createTextNode(pages[i]));
				a.onclick = function(){
					var page = pages[i];

					return function(){
						self.page(page);
						return false;
					};
				}();
				li.appendChild(a);
			}
			ul.appendChild(li);
		}

		li = document.createElement('li');
		if(current_page < total_pages){
			var a = document.createElement('a');
			a.href = '#';
			a.innerHTML = '&raquo;';
			a.onclick = function(){
				self.page(0);
				return false;
			};
			li.appendChild(a);
		} else {
			li.className = 'disabled';
			var span = document.createElement('span');
			span.innerHTML = '&raquo;';
			li.appendChild(span);
		}
		ul.appendChild(li);
	},

	page: function(n)
	{
		var start = this.getStart();
		var max = this.getMax();

		if(n == 0){ start = start + max; }
		else if(n == -1){ start = start - max; }
		else { start = (max * n) - max; }

		this.setStart(start);
		this.execute();
	},

	execute: function(updatehash)
	{
		if(typeof(updatehash) === 'undefined'){ updatehash = this.updatehash; }

		var self = this;
		var params = {};
		if(this.onparam(params)){
			var max = this.getMax();
			if(max !== 25){ params['max'] = max; }

			var sort = this.getSort();
			if(sort !== 0){ params['sort'] = sort; }

			var dir = this.getDir();
			if(dir !== 0){ params['dir'] = dir; }
			
			var currsearch = this.encodeParameters(params);
			if(this.lastsearch.length > 0 && currsearch !== this.lastsearch){
				this.setStart(0);
			}

			this.lastsearch = currsearch;

			var start = this.getStart();
			if(start !== 0){ params['start'] = start; }

			currsearch = this.encodeParameters(params);

			if(updatehash){
				this.ignorehashchange = true;
				window.location.hash = currsearch;
			}

			var request = new XMLHttpRequest();
			request.onreadystatechange = function(){
				self.statechange(this, params);
			};
			request.open('POST', this.url, true);
			request.setRequestHeader(
				'Content-type', 'application/x-www-form-urlencoded'
			);
			request.send(currsearch);
		}
	},

	statechange: function(request, params)
	{
		if(request.readyState === 4){
			if(request.status !== 200){
				this.onerror(
					'Fetch error',
					request.statusText + ': ' + request.responseText
				);
			} else {
				var json = JSON.parse(request.responseText);
				if(!('start' in params)){ params['start'] = 0; }
				if(!('max' in params)){ params['max'] = 25; }

				var length = 0;
				if('list' in json){ length = json['list'].length; }

				this.buildPageControl(
					params['start'], params['max'], json['found'],
					json['size'], length
				);
				this.onparse(json);
			}
		}
	},

	// Returns an array containing a list of pages to be shown
	// given a specific current page and total number of pages
	calculatePages: function(current_page, total_pages)
	{
		var pages = [];

		var s = Math.max((current_page - 1), 1);
		var e = Math.min((current_page + 1), total_pages);

		if((e-s) < 3){
			if(s == 1){ e = Math.min(3, total_pages); }
			else if(e == total_pages){ s = Math.max((total_pages - 2), 1); }
		}

		for(var i = s; i <= e; i++){ pages.push(i); }

		if(pages[0] != 1){
			if(pages[0] == 2){  }
			else if(pages[0] == 3){ pages.unshift(2); }
			else { pages.unshift(0); }

			pages.unshift(1);
		}

		if(pages.length > 2 && pages[pages.length-1] < total_pages){
			if(pages[pages.length-1] == (total_pages-1)){ pages.push(total_pages); }
			else { pages.push(0); }
		}

		return pages;
	},

  // Encodes an object into a URI form (e.g. "search=monkey&limit=10")
  // Use this function instead of $.param, as $.param uses
  // old stype + as space encoding for URLs.
  encodeParameters: function(o, l)
  {
    var r = '';
    if(o == null){ return r; }
    for(var k in o){
      if(typeof o[k] === 'object'){
        var t = this.encodeParameters(o[k], k);
        if(t.length > 0){
          if(r.length > 0){ r += '&'; }
          r += t;
        }
      } else {
        var t = encodeURIComponent(o[k]);
        if(t.length > 0){
          if(r.length > 0){ r += '&'; }
          r += encodeURIComponent(typeof l !== 'undefined' ? l : k) +
            '=' + t;
        }
      }
    }
    return r;
  },

  // Adds a value to an object as a property. If the key of that value
  // already exists, it converts it to an array and adds the new
  // property to it.
  addProperty: function(o, k, v)
  {
    if(k in o){
      if(typeof o[k] === 'object'){ o[k].push(v); }
      else {
        var t = [];
        t.push(o[k]);
        t.push(v);
        o[k] = t;
      }
    } else { o[k] = v; }
  }
};


var Detail = function(o){
	for(var i in o){ this[i] = o[i]; }
};

Detail.prototype = {
	onerror: function(title, description){ },
	onparse: function(json){ },

	fetch: function(id)
	{
		var self = this;

		var request = new XMLHttpRequest();
		request.onreadystatechange = function(){
			self.statechange(this, id);
		};
		request.open('POST', this.url, true);
		request.setRequestHeader(
			'Content-type', 'application/x-www-form-urlencoded'
		);
		request.send('id=' + id);
	},

	statechange: function(request, id)
	{
		if(request.readyState === 4){
			if(request.status !== 200){
				this.onerror(
					'Fetch error',
					request.statusText + ': ' + request.responseText
				);
			} else {
				var json = JSON.parse(request.responseText);
				this.onparse(json);
			}
		}
	}
};


var AlertTool = {
	clear: function()
	{
		var panel = document.getElementById('alert_panel');
		if(panel != null){ panel.parentNode.removeChild(panel); }
	},

	create: function(t, d, type)
	{
		this.clear();

		var panel_head = document.createElement('div');
		panel_head.className = 'panel-head';
		panel_head.appendChild(document.createTextNode(t));

		var panel_body = document.createElement('div');
		panel_body.className = 'panel-body';
		panel_body.appendChild(document.createTextNode(d));

		var panel = document.createElement('div');
		panel.id = 'alert_panel';
		panel.className = 'panel panel-' + type;
		panel.appendChild(panel_head);
		panel.appendChild(panel_body);

		var body = document.getElementsByTagName('body')[0];
		body.appendChild(panel);
	},

	warning: function(t, d){ this.create(t, d, 'warning'); },
	error: function(t, d){ this.create(t, d, 'danger'); }
};


var Popup = function(o){
	this.layer = null;
	this.map = null;
	this.popup = null;
	this.features = [];
	this.record = 0;

	for(var i in o){ this[i] = o[i]; }

	if(this.map !== null && this.layer === null){
		var layers = this.map.getLayersByClass('OpenLayers.Layer.Vector');
		if(layers.length > 0){ this.layer = layers[0]; }
	}
};

Popup.prototype = {
	onupdate: function(content, feature){ },

	attach: function()
	{
		var controls = this.map.getControlsByClass('OpenLayers.Control.Navigation');
		if(controls.length > 0){
			var self = this;
			controls[0].handlers.click.callbacks.click = function(evt){
				self.open(evt.xy);
			};
		}
	},

	getFeaturesAtXY: function(xy, tolerance)
	{
		// Generate two pairs of longitude and latitudes, one straight
		// from the click location, the other that adds in the tolerance
		var ll = this.map.getLonLatFromPixel(xy);
		var lx = this.map.getLonLatFromPixel(xy.add(tolerance, tolerance));

		// Figure out the actual tolerance by comparing the two
		// sets of lon/lats.
		var lon = Math.round(Math.abs(lx.lon - ll.lon));
		var lat = Math.round(Math.abs(lx.lat - ll.lat));

		// Generate a square around the click location using the
		// tolerance as it's bounds. This is where we look for
		// intersecting features
		var point = new OpenLayers.Geometry.Point(ll.lon, ll.lat);
		var poly = OpenLayers.Geometry.Polygon.createRegularPolygon(
			point, (lat/2), 4, 90
		);

		// Search for matching features. This search uses two schemes,
		// the first, which runs first, creates a bounding box for
		// all of the geometries inside each feature and compares it
		// to our point within a certain tolerance. This scheme is fast.
		// The second is a precise comparison of each geoemtry
		// inside each feature. This is slow.
		// If both line up, add to the feature list
		var features = [];
		for(var i in this.layer.features){
			if(this.layer.features[i].renderIntent !== 'aoi' &&
			   this.layer.features[i].renderIntent !== 'preview' &&
				 this.layer.features[i].geometry.atPoint(ll, lon, lat) &&
				 this.layer.features[i].geometry.intersects(poly)){

				features.push(this.layer.features[i]);
			}
		}

		return features;
	},

	open: function(xy)
	{
		if(this.layer !== null){
			this.features = this.getFeaturesAtXY(xy, 20);

			if(this.features.length > 0){
				var self = this;

				this.record = 0;
				this.close();

				this.popup = new OpenLayers.Popup.FramedCloud(
					'Detail', this.map.getLonLatFromPixel(xy),
					new OpenLayers.Size(270, 145),
					null, null, true, null
				);

				this.popup.autoSize = false;
				this.popup.panMapIfOutOfView  = true;

				this.button_prev = document.createElement('button');
				var span = document.createElement('span');
				span.className = 'glyphicon glyphicon-arrow-left';
				this.button_prev.appendChild(span);
				this.button_prev.appendChild(document.createTextNode(' Previous'));
				this.button_prev.onclick = function(){
					if(self.record > 0){
						self.record--; self.update();
					}
				};
				this.popup.contentDiv.appendChild(this.button_prev);

				span = document.createElement('span');
				span.className = 'spacer';
				span.appendChild(document.createTextNode('|'));
				this.popup.contentDiv.appendChild(span);

				this.el_status = document.createElement('span');
				this.el_status.className = 'text-small';
				this.popup.contentDiv.appendChild(this.el_status);

				span = document.createElement('span');
				span.className = 'spacer';
				span.appendChild(document.createTextNode('|'));
				this.popup.contentDiv.appendChild(span);

				this.button_next = document.createElement('button');
				this.button_next.appendChild(document.createTextNode('Next '));
				var span = document.createElement('span');
				span.className = 'glyphicon glyphicon-arrow-right';
				this.button_next.appendChild(span);
				this.button_next.onclick = function(){
					if(self.record < (self.features.length - 1)){
						self.record++; self.update();
					}
				};
				this.popup.contentDiv.appendChild(this.button_next);

				this.el_content = document.createElement('div');
				this.el_content.className = 'container text-smaller';
				this.popup.contentDiv.appendChild(this.el_content);

				this.update();
				this.map.addPopup(this.popup, true);
			}
		}
	},

	update: function()
	{
		this.button_prev.className = 'btn btn-primary btn-small';
		if(this.record === 0){ this.button_prev.className += ' disabled'; }

		this.button_next.className = 'btn btn-primary btn-small';
		if(this.record === (this.features.length - 1)){
			this.button_next.className += ' disabled';
		}

		if(this.el_status.hasChildNodes()){
			this.el_status.removeChild(this.el_status.firstChild);
		}
		this.el_status.appendChild(document.createTextNode(
			'Record ' + (this.record + 1) + ' of ' + this.features.length
		));

		while(this.el_content.hasChildNodes()){
			this.el_content.removeChild(this.el_content.firstChild);
		}

		this.onupdate(this.el_content, this.features[this.record]);
	},

	close: function()
	{
		for(var i in this.map.popups){
			this.map.removePopup(this.map.popups[i]);
		}
	}
};


function initMap()
{
	return new OpenLayers.Map({
		maxExtent: new OpenLayers.Bounds(
			-20037508,-20037508,20037508,20037508
		),
		numZoomLevels: 18,
		maxResolution: 156543.0339,
		units: 'm',
		projection: new OpenLayers.Projection('EPSG:3857'),
		center: [-16446500, 9562680],
		zoom: 3,
		transitionEffect: null,
		zoomMethod: null,
		layers: [
			new OpenLayers.Layer.Google(
				'Google Terrain',
				{ type: google.maps.MapTypeId.TERRAIN, numZoomLevels: 15 }
			),
			new OpenLayers.Layer.Google(
				'Google Satellite',
				{ type: google.maps.MapTypeId.SATELLITE, numZoomLevels: 22 }
			),
			new OpenLayers.Layer.XYZ('GINA Satellite',
				'http://tiles.gina.alaska.edu/tilesrv/bdl/tile/${x}/${y}/${z}', {
					isBaseLayer: true, sphericalMercator: true,
					wrapDateLine: true
				}
			),
			new OpenLayers.Layer.XYZ('GINA Topographic',
				'http://tiles.gina.alaska.edu/tilesrv/drg/tile/${x}/${y}/${z}', {
					isBaseLayer: true, sphericalMercator: true,
					wrapDateLine: true
				}
			),
			new OpenLayers.Layer.XYZ('GINA Shaded Relief',
				'http://tiles.gina.alaska.edu/tilesrv/shaded_relief_ned/tile/${x}/${y}/${z}', {
					isBaseLayer: true, sphericalMercator: true,
					wrapDateLine: true
				}
			),
			new OpenLayers.Layer.OSM("Street Map"),
			new OpenLayers.Layer.XYZ('Street Map',
				'http://tiles.gina.alaska.edu/tilesrv/osm-google-ol_google/tile/${x}/${y}/${z}', {
					isBaseLayer: false, visibility: false,
					sphericalMercator: true, wrapDateLine: true, opacity: 0.5,
					attribution: '(c) <a href="http://www.openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
				}
			),
			new OpenLayers.Layer.XYZ('Hydrography',
				'http://tiles.gina.alaska.edu/tilesrv/hydro_google/tile/${x}/${y}/${z}', {
					isBaseLayer: false, sphericalMercator: true,
					visibility: false, wrapDateLine: true
				}
			),
			new OpenLayers.Layer.XYZ('Township and Range',
				'http://tiles.gina.alaska.edu/tilesrv/pls_google/tile/${x}/${y}/${z}', {
					isBaseLayer: false, sphericalMercator: true,
					visibility: false, wrapDateLine: true
				}
			),
			new OpenLayers.Layer.XYZ('Land Ownership (Generalized)',
				'http://tiles.gina.alaska.edu/tilesrv/glo_google/tile/${x}/${y}/${z}', {
					isBaseLayer: false, visibility: false, opacity: 0.5,
					sphericalMercator: true, wrapDateLine: true,
					attribution: '<img src="http://wms.proto.gina.alaska.edu/wms/glo?LAYER=glo72011_D1&styles=&service=WMS&request=GetLegendGraphic&VERSION=1.1.1&FORMAT=image/png">'
				}
			),
			new OpenLayers.Layer.XYZ('Quadrangles',
				'http://tiles.gina.alaska.edu/tilesrv/quad_google/tile/${x}/${y}/${z}', {
					isBaseLayer: false, visibility: false,
					sphericalMercator: true, wrapDateLine: true
				}
			),
			new OpenLayers.Layer.Vector('Result Layer', {
				isBaseLayer: false,
				styleMap: new OpenLayers.StyleMap({
					'default': new OpenLayers.Style({
						fillColor: "#2E70FF",
						fillOpacity: 0.08,
						strokeColor: "#2E70FF",
						strokeWidth: 2,
						strokeOpacity: 0.8,
						pointRadius: 6,
						cursor: 'pointer',
						graphicZIndex: 100
					}),
					'aoi': new OpenLayers.Style({
						fillColor: "#FF0000",
						fillOpacity: 0,
						strokeColor: "#FF0000",
						strokeWidth: 2,
						strokeOpacity: 1,
						cursor: 'auto',
						graphicZIndex: 5000
					}),
					'preview': new OpenLayers.Style({
						fillColor: "#FF0000",
						fillOpacity: 0,
						strokeColor: "#FF0000",
						strokeWidth: 2,
						strokeOpacity: 1,
						cursor: 'auto',
						graphicZIndex: 5000
					})
				})
			})
		],
		controls: [
			new OpenLayers.Control.PanZoom(),
			new OpenLayers.Control.Attribution({separator: ''}),
			new OpenLayers.Control.LayerSwitcher({
				'ascending' : true, 'title': 'Click to toggle layers'
			}),
			new OpenLayers.Control.MousePosition({
				numDigits: 3, emptyString: 'Unknown',
				displayProjection: new OpenLayers.Projection('EPSG:4326')
			}),
			new OpenLayers.Control.ScaleLine({ geodetic: true }),
			new OpenLayers.Control.Navigation()
		]
	});
}


function destroyFeaturesByIntent(layer, intent)
{
	var queue = [];
	for(var i in layer.features){
		if(layer.features[i].renderIntent === intent){
			queue.push(layer.features[i]);
		}
	}

	if(queue.length > 0){
		layer.destroyFeatures(queue);
	}
}
