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
		if(layer.features[i].renderIntent === 'default'){
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
						var feature = new OpenLayers.Feature.Vector(
							OpenLayers.Geometry.fromWKT(val)
						);
						feature.id = 'AOI_Vector';
						feature.renderIntent = 'aoi';
						var layer = map.getLayersByName('Result Layer')[0];
						layer.addFeatures([feature]);
					break;

					case 'mining_district_id':
						$('#advanced').addClass('active');
						$('#advanced_cell').show();

						var opt = $('#mining_district_id').find(
							'option[value="' + val +'"]'
						).attr('selected', 'selected').get(0);
						if('wkt' in opt){
							var feature = new OpenLayers.Feature.Vector(
								OpenLayers.Geometry.fromWKT(opt['wkt'])
							);
							feature.renderIntent = 'preview';
							var layer = map.getLayersByName('Result Layer')[0];
							layer.addFeatures([feature]);
						}
					break;

					default: $('#'+key).val(val);
				}
			}
		}

		map.updateSize();
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

			if('containerPath' in attr){
				content.appendChild(document.createTextNode(' - '));
				content.appendChild(document.createTextNode(attr['containerPath']));
			}

			if('intervalTop' in attr || 'intervalBottom' in attr){
				var div = document.createElement('div');
				if('intervalTop' in attr){
					div.appendChild(document.createTextNode(attr['intervalTop']));
					if('intervalUnit' in attr){
						div.appendChild(document.createTextNode(
							' ' + attr['intervalUnit']['abbr']
						));
					}
				}

				if('intervalBottom' in attr){
					div.appendChild(document.createTextNode(' - '));
				}

				if('intervalBottom' in attr){
					div.appendChild(document.createTextNode(
						attr['intervalBottom']
					));
					if('intervalUnit' in attr){
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
				if('prospect' in borehole){
					div.appendChild(document.createTextNode(
						'Prospect: '
					));
					var prospect = borehole['prospect'];

					a = document.createElement('a');
					a.href = 'prospect/' + prospect['ID'];
					a.appendChild(document.createTextNode(
						prospect['name']
					));
					if('altNames' in prospect){
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
				if('wellNumber' in well){
					a.appendChild(document.createTextNode(
						' - ' + well['wellNumber']
					));
				}
				div.appendChild(a);

				if('APINumber' in well){
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
				if('number' in outcrop){
					a.appendChild(document.createTextNode(
						' - ' + outcrop['number']
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
			$('#search').removeClass('disabled').contents().last().replaceWith(' Search');

			AlertTool.error(t, d);
		},

		onparam: function(o){
			var searchok = false;

			var q = document.getElementById('q').value;
			if(q.length !== 0){ o['q'] = q; searchok = true; }

			var layer = map.getLayersByName('Result Layer')[0];
			var aoi = layer.getFeatureById('AOI_Vector');
			if(aoi !== null){
				var wkt = new OpenLayers.Format.WKT();
				o['wkt'] = wkt.write(aoi).replace(/\.\d+/g, '');
				searchok = true;
			}

			$('#mining_district_id').find(':selected').each(function(i,v){
				Search.prototype.addProperty(o, 'mining_district_id', $(v).val());
				searchok = true;
			});

			if(!searchok){
				clearmap();
				document.getElementById('inventory_container').style.display = 'none';

				AlertTool.warning('Empty Search', 'Search cannot be empty.');
				return false;
			}

			$('#search').addClass('disabled')
				.contents().last().replaceWith(' Searching ...');

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

					if('WKT' in obj){
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
						if('prospect' in borehole){
							div.appendChild(document.createTextNode(
								'Prospect: '
							));
							var prospect = borehole['prospect'];

							a = document.createElement('a');
							a.href = 'prospect/' + prospect['ID'];
							a.appendChild(document.createTextNode(
								prospect['name']
							));
							if('altNames' in prospect){
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
						if('wellNumber' in well){
							a.appendChild(document.createTextNode(
								' - ' + well['wellNumber']
							));
						}
						div.appendChild(a);

						if('APINumber' in well){
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
						if('number' in outcrop){
							a.appendChild(document.createTextNode(
								' - ' + outcrop['number']
							));
						}
						div.appendChild(a);

						td.appendChild(div);
					}

					// Shotlines/Shotpoints
					if('shotpoints' in obj){
						var shotlines = {};
						for(var j in obj['shotpoints']){
							var shotpoint = obj['shotpoints'][j];
							if('shotline' in shotpoint){
								shotlines[shotpoint['shotline']['ID']] = shotpoint['shotline'];
							}
						}

						if('project' in obj){
							var div = document.createElement('div');
							var project = obj['project'];
							div.appendChild(document.createTextNode(
								'Project: ' + project['name']
							));

							if('year' in project){
								div.appendChild(document.createTextNode(
									', ' + project['year']
								));
							}
							td.appendChild(div);
						}

						for(var j in shotlines){
							var shotline = shotlines[j];

							var div = document.createElement('div');
							div.appendChild(document.createTextNode('Shotline: '));
							a = document.createElement('a');
							a.href = 'shotline/' + shotline['ID'];
							a.appendChild(document.createTextNode(shotline['name']));
							div.appendChild(a);

							if('year' in shotline){
								div.appendChild(document.createTextNode(
									', ' + shotline['year']
								));
							}

							td.appendChild(div);
						}
					}

					tr.appendChild(td);
					// End Related

					td = document.createElement('td');
					if('sampleNumber' in obj){
						td.appendChild(document.createTextNode(
							obj['sampleNumber']
						));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					if('box' in obj){
						td.appendChild(document.createTextNode(obj['box']));
					}
					if('set' in obj){
						td.appendChild(document.createElement('br'));	
						td.appendChild(document.createTextNode(obj['set']));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					if('core' in obj){
						td.appendChild(document.createTextNode(obj['core']));
					}
					if('coreDiameter' in obj){
						td.appendChild(document.createElement('br'));	
						if('name' in obj['coreDiameter']){
							td.appendChild(document.createTextNode(
								obj['coreDiameter']['name']
							));
						} else {
							td.appendChild(document.createTextNode(
								obj['coreDiameter']['diameter']
							));
							if('unit' in obj['coreDiameter']){
								td.appendChild(document.createTextNode(
									 ' ' +obj['coreDiameter']['unit']['abbr']
								));
							}
						}
					}
					tr.appendChild(td);

					td = document.createElement('td');
					td.className = 'al-r nowrap';
					if('intervalTop' in obj){
						td.appendChild(document.createTextNode(obj['intervalTop']));
						if('intervalUnit' in obj){
							td.appendChild(document.createTextNode(
								' ' + obj['intervalUnit']['abbr']
							));
						}
					}

					if('intervalBottom' in obj){
						td.appendChild(document.createElement('br'));
						td.appendChild(document.createTextNode(
							obj['intervalBottom']
						));
						if('intervalUnit' in obj){
							td.appendChild(document.createTextNode(
								' ' + obj['intervalUnit']['abbr']
							));
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
					if('collection' in obj){
						td.appendChild(document.createTextNode(
							obj['collection']['name']
						));
					}
					tr.appendChild(td);

					td = document.createElement('td');
					td.className = 'barcode';

					var barcode = null;
					if('barcode' in obj){ barcode = obj['barcode']; }
					else if('altBarcode' in obj){ barcode = obj['altBarcode'] }
					if(barcode !== null){
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
					if('containerPath' in obj){
						td.appendChild(document.createTextNode(
							obj['containerPath']
						));
					}
					tr.appendChild(td);

					body.appendChild(tr);
				}

				if(features.length > 0){ layer.addFeatures(features); }

				document.getElementById('inventory_container').style.display = 'block';
			}

			$('#search').removeClass('disabled').contents().last().replaceWith(' Search');
		} // End onparse
	});

	$('#advanced').click(function(){
		var shown = $(this).hasClass('active');
		if(shown){
			$('#advanced_cell').hide();
			$(this).removeClass('active');
		} else {
			$('#advanced_cell').show();
			$(this).addClass('active');
		}

		$(this).blur();
		return false;
	});

	$('#search').click(function(){
		search.execute();
		
		$(this).blur();
		return false;
	});

	$('#sort, #max, #dir').change(function(){ search.execute(); });

	$('#q').keypress(function(e){
		if(e.keyCode === 13){ $('#search').click(); }
	});

	var mining_district_loaded = $.Deferred();
	$('#mining_district_id').change(function(){
		var layer = map.getLayersByName('Result Layer')[0];
		destroyFeaturesByIntent(layer, 'preview');

		$(this).find(':selected').each(function(i, v){
			if('wkt' in v){
				var feature = new OpenLayers.Feature.Vector(
					OpenLayers.Geometry.fromWKT(v['wkt'])
				);
				feature.renderIntent = 'preview';
				layer.addFeatures([feature]);
			}
		});
		search.execute();
	});

	$.ajax({
		url: 'mining_district.json', dataType: 'json',
		error: function(xhr){
			mining_district_loaded.resolve();
			// Silently ignore failure
		},
		success: function(json){
			var md_el = document.getElementById('mining_district_id');
			for(var i in json){
				var option = document.createElement('option');
				option.value = json[i]['ID'];
				option.wkt = json[i]['WKT'];
				option.appendChild(document.createTextNode(json[i]['name']));
				md_el.appendChild(option);
			}
			mining_district_loaded.resolve();
		}
	});

	// Wait for outside resources to finish loading, then restore
	// the search state
	$.when( mining_district_loaded ).done(function(){
		if(restore()){ search.execute(false); }
		search.setuponhashchange();
	});
});


$(window).load(function(){
	map.render('map');
	map.updateSize();
});
