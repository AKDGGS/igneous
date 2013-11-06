var search, map, popup;


function reset()
{
	$('#max').val(25);
	$('#start, #sort, #dir').val(0);
	$('#q').val('').blur();
}


function clearmap()
{
	popup.close();

	var layer = map.getLayersByName('Result Layer')[0];
	var queue = [];
	for(var i in layer.features){
		if(layer.features[i].id !== 'AOI_Vector'){
			queue.push(layer.features[i]);
		}
	}
	layer.destroyFeatures(queue);
	layer.refresh();
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
					case 'wkt':
						var layer = map.getLayersByName('Result Layer')[0];

						var feature = new OpenLayers.Feature.Vector(
							OpenLayers.Geometry.fromWKT(val)
						);
						feature.id = 'AOI_Vector';
						feature.renderIntent = 'aoi';
						layer.addFeatures([feature]);
					break;

					default: $('#'+key).val(val);
				}
			}
		}

		return true;
	}
}


$(function(){
	map = initMap();

	var result_layer = map.getLayersByName('Result Layer')[0];

  var control_panel = new OpenLayers.Control.Panel();
	control_panel.addControls([
		new OpenLayers.Control.DrawFeature(
			result_layer, OpenLayers.Handler.RegularPolygon, {
				id: 'draw_control',
				title: 'Area of Interest Search: Click and drag the mouse to define your area of interest.',
				type: OpenLayers.Control.TYPE_TOGGLE,
				handlerOptions: { irregular: true },
				eventListeners: {
					activate: function(e){
						// Turn off select control if active
						for(var i in e.object.map.popups){
							e.object.map.removePopup(e.object.map.popups[i]);
						}

						var el = e.object.layer.getFeatureById('AOI_Vector');
						if(el !== null){ e.object.layer.destroyFeatures(el); }
					},
					featureadded: function(e){
						e.object.deactivate();

						e.feature.id = 'AOI_Vector';
						e.feature.renderIntent = 'aoi';
						e.feature.layer.drawFeature(e.feature);

						search.execute(true);
          }
        }
      }
    )
	]);

	map.addControl(control_panel);

	popup = new Popup({ map: map,
		onupdate: function(content, feature){
			var attr = feature.attributes;

			var a = document.createElement('a');
			a.href = 'detail/' + attr['ID'];
			a.appendChild(document.createTextNode(attr['ID']));
			content.appendChild(a);

			content.appendChild(document.createTextNode(' - '));

			content.appendChild(document.createTextNode(attr['containerPath']));

			if(attr['intervalTop'] !== null || attr['intervalBottom'] !== null){
				var div = document.createElement('div');
				if(attr['intervalTop'] !== null){
					div.appendChild(document.createTextNode(attr['intervalTop']));
					if(attr['intervalUnit'] !== null){
						div.appendChild(document.createTextNode(
							' ' + attr['intervalUnit']['abbr']
						));
					}
				}

				if(attr['intervalBottom'] !== null){
					div.appendChild(document.createTextNode(' - '));
				}

				if(attr['intervalBottom'] !== null){
					div.appendChild(document.createTextNode(
						attr['intervalBottom']
					));
					if(attr['intervalUnit'] !== null){
						div.appendChild(document.createTextNode(
							' ' + attr['intervalUnit']['abbr']
						));
					}
				}
				content.appendChild(div);
			}

			// Begin related
			// Boreholes
			for(var i in attr['boreholes']){
				var borehole = attr['boreholes'][i];

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

				content.appendChild(div);
			}

			// Wells
			for(var i in attr['wells']){
				var well = attr['wells'][i];

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

				content.appendChild(div);
			}

			// Outcrops
			for(var i in attr['outcrops']){
				var outcrop = attr['outcrops'][i];

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

				content.appendChild(div);
			}
			// End Related


			var div = document.createElement('div');
			for(var i in attr['keywords']){
				var keyword = attr['keywords'][i];
				div.appendChild(document.createTextNode(
					(i > 0 ? ', ' : '') + keyword['name']
				));
			}
			content.appendChild(div);
		}
	});
	popup.attach();

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
			var searchok = false;

			var q = document.getElementById('q').value;
			if(q.length !== 0){ o['q'] = q; searchok = false; }

			var layer = map.getLayersByName('Result Layer')[0];
			var aoi = layer.getFeatureById('AOI_Vector');
			if(aoi !== null){
				var wkt = new OpenLayers.Format.WKT();
				o['wkt'] = wkt.write(aoi).replace(/\.\d+/g, '');
				searchok = true;
			}

			if(!searchok){
				clearmap();
				document.getElementById('inventory_container').style.display = 'none';

				AlertTool.warning('Empty Search', 'Search cannot be empty.');
				return false;
			}
			
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
						features.push(new OpenLayers.Feature.Vector(
							OpenLayers.Geometry.fromWKT(obj['WKT']),
							obj
						));
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
							(j > 0 ? ' > ' : '') +
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
					if(obj['barcode'] !== null || obj['altBarcode'] !== null){
						var barcode = obj['barcode'] !== null ? obj['barcode'] : obj['altBarcode'];
						var img = document.createElement('img');
						img.height = 20;
						img.src = 'barcode?c=' + barcode;
						td.appendChild(img);

						var div = document.createElement('div');
						div.appendChild(document.createTextNode(barcode));
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
