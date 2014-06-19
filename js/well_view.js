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
		url: '../well.json',

		onerror: function(t, d){
			$('#overview_container').hide();
			AlertTool.error(t, d);
		},

		onparse: function(json){
			var well = json['well'];

			if('wkts' in json){
				var wkt_parser = new OpenLayers.Format.WKT();
				var features = [];
				for(var i in json['wkts']){
					var entry = json['wkts'][i];

					var feature = new OpenLayers.Feature.Vector(
						OpenLayers.Geometry.fromWKT(entry['wkt']),
						{ 'id': entry['well_id'], 'name': entry['name'] }
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
			dt.appendChild(document.createTextNode('Well Name:'));
			dl.appendChild(dt);

			var dd = document.createElement('dd');
			dd.appendChild(document.createTextNode(well['name']));
			dl.appendChild(dd);

			if('altNames' in well){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Alt. Well Names:'));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(
					well['altNames'])
				);
				dl.appendChild(dd);
			}

			if('quadrangles' in json && json['quadrangles'].length > 0){
				var quadrangles = json['quadrangles'];
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

			if('keywords' in json && json['keywords'].length > 0){
				var keywords = json['keywords'];
				var keywords_el = document.getElementById('keywords');

				var ul = document.createElement('ul');
				ul.className = 'nav nav-pills';

				for(var i in keywords){
					var set = keywords[i];

					var span = document.createElement('span');
					span.className = 'badge';
					span.appendChild(document.createTextNode(set['count']));

					var a = document.createElement('a');
					a.href = '#';
					a.setAttribute('data-keyword-id', set['ids']);
					a.onclick = function(){
						var li = $(this).parent('li');

						if(li.hasClass('active')){ li.removeClass('active'); }
						else { li.addClass('active'); }

						var keyword_ids = $('#keyword_controls li.active a').map(function(){
							return this.getAttribute('data-keyword-id').split(',');
						}).get();

						if(keyword_ids.length == 0){
							delete search['keyword_id'];
							AlertTool.clear();
							$('#inventory_container').hide();
						} else {
							search['keyword_id'] = keyword_ids;
							search.execute();
						}

						return false;
					};
					a.appendChild(document.createTextNode(set['keywords']));
					a.appendChild(span);

					var li = document.createElement('li');
					li.appendChild(a);

					keywords_el.appendChild(li);
				}
				$('#keyword_controls').show();
			}
		}
	}); // End detail

	search = new Search({
		url: '../search.json',

		updatehash: false,

		onerror: function(t, d){
			$('#inventory_container').hide();
			AlertTool.error(t, d);
		},

		onparam: function(o){
			o['well_id'] = id;
			if('keyword_id' in this){ o['keyword_id'] = this['keyword_id']; }
			return true;
		},

		onparse: function(json){
			if(!('list' in json) || json['list'].length == 0){
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

					// Box
					td = document.createElement('td');
					if('box' in obj){
						td.appendChild(document.createTextNode(obj['box']));
					}
					tr.appendChild(td);

					// Top / Bottom
					td = document.createElement('td');
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
					if('collection' in obj){
						td.appendChild(document.createTextNode(
							obj['collection']['name']
						));
					}
					tr.appendChild(td);

					// Barcode
					td = document.createElement('td');
					td.className = 'barcode';
					var barcode = null;
					if('barcode' in obj){ barcode = obj['barcode']; }
					else if('altBarcode' in obj){ barcode = obj['altBarcode'] }
					if(barcode !== null){
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
					if('containerPath' in obj){
						td.appendChild(document.createTextNode(
							obj['containerPath']
						));
					}
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
