var detail, search;


$(function(){
  $('#sort, #max, #dir').change(function(){ search.execute(); });

	$('#search').click(function(){
		window.location.href = '../search#q=' + $('#q').val();
	});

	$('#q').keypress(function(e){
		if(e.keyCode === 13){ $('#search').click(); }
	});

	map = initMap();

	detail = new Detail({
		url: '../borehole.json',

		onerror: function(t, d){
			$('#overview_container').hide();
			AlertTool.error(t, d);
		},

		onparse: function(json){
			var borehole = json['borehole'];

			if(json['wkts'] != null){
				var wkt_parser = new OpenLayers.Format.WKT();
				var features = [];
				for(var i in json['wkts']){
					var entry = json['wkts'][i];

					var feature = new OpenLayers.Feature.Vector(
						OpenLayers.Geometry.fromWKT(entry['wkt']),
						{ 'id': entry['borehole_id'], 'name': entry['name'] }
					);
					features.push(feature);
				}

				if(features.length > 0){
				  var layer = map.getLayersByName('Result Layer')[0];
					layer.addFeatures(features);
				}
			}

			var dl = document.getElementById('overview');
			while(dl.hasChildNodes()){ dl.removeChild(dl.firstChild); }

			var dt = document.createElement('dt');
			dt.appendChild(document.createTextNode('Borehole Name:'));
			dl.appendChild(dt);

			var dd = document.createElement('dd');
			dd.appendChild(document.createTextNode(borehole['name']));
			dl.appendChild(dd);

			if(borehole['altNames'] !== null){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Alt. Borehole Names:'));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(
					borehole['altNames'])
				);
				dl.appendChild(dd);
			}

			var quadrangles = json['quadrangles'];
			if(quadrangles !== null && quadrangles.length > 0){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Quadrangles:'));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				for(var i in quadrangles){
					var quad = quadrangles[i];
					if(i > 0){ dd.appendChild(document.createTextNode(', ')); }

					var a = document.createElement('a');
					a.href = '../search#quadrangle_id=' + quad['ID'];
					a.appendChild(document.createTextNode(quad['name']));
					dd.appendChild(a);
				}
				dl.appendChild(dd);
			}

			var miningdistricts = json['miningdistricts'];
			if(miningdistricts !== null && miningdistricts.length > 0){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Mining Districts:'));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				for(var i in miningdistricts){
					var md = miningdistricts[i];
					if(i > 0){ dd.appendChild(document.createTextNode(', ')); }

					var a = document.createElement('a');
					a.href = '../search#mining_district_id=' + md['ID'];
					a.appendChild(document.createTextNode(md['name']));
					dd.appendChild(a);
				}
				dl.appendChild(dd);
			}

			var summary = json['summary'];
			if(summary !== null && summary.length > 0){
				var keywords = document.getElementById('keywords');

				var ul = document.createElement('ul');
				ul.className = 'nav nav-pills';

				for(var i in summary){
					var set = summary[i];

					var span = document.createElement('span');
					span.className = 'badge';
					span.appendChild(document.createTextNode(set['count']));

					var a = document.createElement('a');
					a.href = '#';
					a.onclick = function(){
						var keyword_id = set['keyword_id'];
						var borehole_id = borehole['ID'];

						return function(){
							$('#keyword_controls').find('li').removeClass('active');
							$(this).parent('li').addClass('active');

							search['keyword_id'] = keyword_id;
							search.execute();
							return false;
						};
					}();
					a.appendChild(document.createTextNode(set['keyword']));
					a.appendChild(span);

					var li = document.createElement('li');
					li.appendChild(a);

					keywords.appendChild(li);
				}

				var a = document.createElement('a');
				a.href = '#';
				a.onclick = function(){
					var borehole_id = borehole['ID'];

					return function(){
						$('#keyword_controls').find('li').removeClass('active');
						$(this).parent('li').addClass('active');

						delete search['keyword_id'];
						search.execute();
						return false;
					};
				}();
				a.appendChild(document.createTextNode('All'));

				var li = document.createElement('li');
				li.appendChild(a);

				keywords.appendChild(li);
				$('#keyword_controls').show();
			}
		}
	}); // End detail

	popup = new Popup({
		map: map,
		onupdate: function(content, feature){
			var attr = feature.attributes;

			content.appendChild(document.createTextNode('Borehole: '));
			var a = document.createElement('a');
			a.href = '../borehole/' + attr['borehole_id'];
			a.appendChild(document.createTextNode(attr['name']));
			content.appendChild(a);
		}
	});
	popup.attach();

	search = new Search({
		url: '../search.json',

		updatehash: false,

		onerror: function(t, d){
			$('#inventory_container').hide();
			AlertTool.error(t, d);
		},

		onparam: function(o){
			o['borehole_id'] = id;
			if('keyword_id' in this){ o['keyword_id'] = this['keyword_id']; }
			return true;
		},

		onparse: function(json){
			if(json['list'].length == 0){
				$('#inventory_container').hide();
				AlertTool.warning('Inventory Results', 'No results have been found');
			} else {
				AlertTool.clear();

				var body = document.getElementById('inventory_body');
				while(body.hasChildNodes()){ body.removeChild(body.firstChild); }

				var features = [];
				for(var i in json['list']){
					var obj = json['list'][i];

					var tr = document.createElement('tr');

					var td = document.createElement('td');
					var a = document.createElement('a');
					a.href = 'detail/' + obj['ID'];
					a.appendChild(document.createTextNode(obj['ID']));
					td.appendChild(a);
					tr.appendChild(td);

					// Boreholes
					td = document.createElement('td');
					for(var j in obj['boreholes']){
						var borehole = obj['boreholes'][j];

						var div = document.createElement('div');
						a = document.createElement('a');
						a.href = 'borehole/' + borehole['ID'];
						a.appendChild(document.createTextNode(borehole['name']));
						div.appendChild(a);

						td.appendChild(div);
					}
					tr.appendChild(td);

					// Box
					td = document.createElement('td');
					if(obj['box'] !== null){
						td.appendChild(document.createTextNode(obj['box']));
					}
					tr.appendChild(td);

					// Top / Bottom
					td = document.createElement('td');
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

					// Keywords
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

					// Barcode
					td = document.createElement('td');
					td.className = 'barcode';
					if(obj['barcode'] !== null || obj['altBarcode'] !== null){
						var barcode = obj['barcode'] !== null ? obj['barcode'] : obj['altBarcode'];
						var img = document.createElement('img');
						img.height = 20;
						img.src = '../barcode?c=' + barcode;
						td.appendChild(img);

						var div = document.createElement('div');
						div.appendChild(document.createTextNode(barcode));
						td.appendChild(div);
					}
					tr.appendChild(td);

					// Location
					td = document.createElement('td');
					td.appendChild(document.createTextNode(
						obj['containerPath']
					));
					tr.appendChild(td);

					body.appendChild(tr);
				}

				$('#inventory_container').show();
			}
		} // End onparse
	}); // End search
});


$(window).load(function(){
	map.render('map');
	map.updateSize();

	detail.fetch(id);
});
