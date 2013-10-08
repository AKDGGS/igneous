var search, map;


function reset()
{
	$('#max').val(25);
	$('#start, #sort, #dir').val(0);
	$('#q').val('').blur();
}


function clearmap()
{
	var layer = map.getLayersByName('Result Layer')[0];
	layer.destroyFeatures();
	return layer;
}


function restore()
{
	if(window.location.hash.length > 1){
		reset();

		var hash = window.location.hash.substr(1).split('&');
		for(var i in hash){
			var st = hash[i].indexOf('=') + 1;
			if(st === hash[i].length){ st = -1; }

			var key = decodeURIComponent(st >= 0 ? hash[i].substr(0, st-1) : hash[i]);
			var val = decodeURIComponent(st >= 0 ? hash[i].substr(st) : '');

			if(val.length > 0){
				switch(key){
					default: $('#'+key).val(val);
				}
			}
		}

		return true;
	}
}


$(function(){
	var wkt_parser = new OpenLayers.Format.WKT();

	map = new OpenLayers.Map({
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
				renderers: ['Canvas', 'VML'],
				rendererOptions: { zIndexing: true },
				isBaseLayer: false
			})
		],
		controls: [
			new OpenLayers.Control.PanZoom(),
			new OpenLayers.Control.LayerSwitcher({
				'ascending' : true, 'title': 'Click to toggle layers'
			}),
			new OpenLayers.Control.MousePosition({
				numDigits: 3, emptyString: 'Unknown',
				displayProjection: new OpenLayers.Projection('EPSG:4326')
			}),
			new OpenLayers.Control.ScaleLine({ geodetic: true }),
			new OpenLayers.Control.Navigation(),
			new OpenLayers.Control.Attribution({separator: ''}),
		]
	});

	search = new Search({
		url: 'search.json',

		onhashchange: function(){
			if(restore()){ this.execute(false); }
		},

		onerror: function(t, d){
			clearmap();
			document.getElementById('inventory_container').style.display = 'none';

			AlertTool.error(t, d);
		},

		onparam: function(o){
			var q = document.getElementById('q').value;

			if(q.length === 0){
				clearmap();
				document.getElementById('inventory_container').style.display = 'none';

				AlertTool.warning('Empty Search', 'Search cannot be empty.');
				return false;
			}
			
			o['q'] = q;
			return true;
		},

		onparse: function(json){
			if(json['list'].length == 0){
				clearmap();
				document.getElementById('inventory_container').style.display = 'none';

				AlertTool.warning(
					'Inventory Results',	
					'No results have been found for your query. ' +
					'Please narrow the search parameters and try again.'
				);
			} else {
				AlertTool.clear();

				var layer = clearmap();
				var body = document.getElementById('inventory_body');
				while(body.hasChildNodes()){ body.removeChild(body.firstChild); }

				var features = [];
				for(var i in json['list']){
					var obj = json['list'][i];

					if(obj['WKT'] !== null){
						features.push( wkt_parser.read(obj['WKT']));
					}

					var tr = document.createElement('tr');

					var td = document.createElement('td');
					var a = document.createElement('a');
					a.href = 'detail/' + obj['ID'];
					a.appendChild(document.createTextNode(obj['ID']));
					td.appendChild(a);
					tr.appendChild(td);

					// Begin related
					td = document.createElement('td');

					// Boreholes
					for(var j in obj['boreholes']){
						var borehole = obj['boreholes'][j];

						var div = document.createElement('div');
						if(borehole['prospect'] !== null){
							div.appendChild(document.createTextNode(
								'Prospect: '
							));
							var prospect = borehole['prospect'];

							a = document.createElement('a');
							a.href = 'prospect/' + prospect['ID'];
							a.appendChild(document.createTextNode(
								prospect['name']
							));
							if(prospect['altNames'] !== null){
								a.appendChild(document.createTextNode(
									' (' + prospect['altNames'] + ')'
								));
							}
							div.appendChild(a);

							div.appendChild(document.createElement('br'));
						}

						div.appendChild(document.createTextNode('Borehole: '));
						a = document.createElement('a');
						a.href = 'borehole/' + borehole['ID'];
						a.appendChild(document.createTextNode(borehole['name']));
						div.appendChild(a);

						td.appendChild(div);
					}

					// Wells
					for(var j in obj['wells']){
						var well = obj['wells'][j];

						var div = document.createElement('div');
						div.appendChild(document.createTextNode('Well: '));
						a = document.createElement('a');
						a.href = 'well/' + well['ID'];
						a.appendChild(document.createTextNode(well['name']));
						if(well['wellNumber'] !== null){
							a.appendChild(document.createTextNode(
								' - ' + well['wellNumber']
							));
						}
						div.appendChild(a);

						if(well['APINumber'] !== null){
							var div2 = document.createElement('div');
							div2.appendChild(document.createTextNode('API: '));
							div2.appendChild(document.createTextNode(well['APINumber']));
							div.appendChild(div2);
						}

						td.appendChild(div);
					}

					// Outcrops
					for(var j in obj['outcrops']){
						var outcrop = obj['outcrops'][j];

						var div = document.createElement('div');
						div.appendChild(document.createTextNode('Outcrop: '));
						a = document.createElement('a');
						a.href = 'outcrop/' + outcrop['ID'];
						a.appendChild(document.createTextNode(outcrop['name']));
						if(outcrop['outcropNumber'] !== null){
							a.appendChild(document.createTextNode(
								' - ' + outcrop['outcropNumber']
							));
						}
						div.appendChild(a);

						td.appendChild(div);
					}

					tr.appendChild(td);
					// End Related

					td = document.createElement('td');
					if(obj['sampleNumber'] !== null){
						td.appendChild(document.createTextNode(
							obj['sampleNumber']
						));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					if(obj['core'] !== null){
						td.appendChild(document.createTextNode(obj['core']));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					if(obj['box'] !== null){
						td.appendChild(document.createTextNode(obj['box']));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					if(obj['set'] !== null){
						td.appendChild(document.createTextNode(obj['set']));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					td.className = 'al-r';
					if(obj['intervalTop'] !== null){
						td.appendChild(document.createTextNode(obj['intervalTop']));
						if(obj['intervalUnit'] !== null){
							td.appendChild(document.createTextNode(
								' ' + obj['intervalUnit']['abbr']
							));
						}
					}

					if(obj['intervalBottom'] !== null){
						td.appendChild(document.createElement('br'));
					}

					if(obj['intervalBottom'] !== null){
						td.appendChild(document.createTextNode(
							obj['intervalBottom']
						));
						if(obj['intervalUnit'] !== null){
							td.appendChild(document.createTextNode(
								' ' + obj['intervalUnit']['abbr']
							));
						}
					}
					tr.appendChild(td);

					td = document.createElement('td');
					if(obj['coreDiameter'] !== null){
						if(obj['coreDiameter']['name'] !== null){
							td.appendChild(document.createTextNode(
								obj['coreDiameter']['name']
							));
						} else {
							td.appendChild(document.createTextNode(
								obj['coreDiameter']['diameter']
							));
							if(obj['coreDiameter']['unit'] !== null){
								td.appendChild(document.createTextNode(
									 ' ' +obj['coreDiameter']['unit']['abbr']
								));
							}
						}
					}
					tr.appendChild(td);

					td = document.createElement('td');
					for(var j in obj['keywords']){
						var keyword = obj['keywords'][j];
						td.appendChild(document.createTextNode(
							(j > 0 ? ', ' : '') +
							keyword['name']
						));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					if(obj['collection'] !== null){
						td.appendChild(document.createTextNode(
							obj['collection']['name']
						));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					td.className = 'barcode';
					if(obj['barcode'] !== null){
						var img = document.createElement('img');
						img.height = 20;
						img.src = 'barcode?c=' + obj['barcode'];
						td.appendChild(img);

						var div = document.createElement('div');
						div.appendChild(document.createTextNode(obj['barcode']));
						td.appendChild(div);
					}
					tr.appendChild(td);

					td = document.createElement('td');
					td.appendChild(document.createTextNode(
						obj['containerPath']
					));
					tr.appendChild(td);

					body.appendChild(tr);
				}

				if(features.length > 0){ layer.addFeatures(features); }

				document.getElementById('inventory_container').style.display = 'block';
			}
		} // End onparse
	});

	$('#search').click(function(){
		search.execute();
		return false;
	});

	$('#sort, #max, #dir').change(function(){ search.execute(); });

	$('#q').keypress(function(e){
		if(e.keyCode === 13){ $('#search').click(); }
	});

	if(restore()){ search.execute(false); }
	search.setuponhashchange();
});


$(window).load(function(){
	map.render('map');
	map.updateSize();
});
