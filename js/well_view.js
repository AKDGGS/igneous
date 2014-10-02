var search;


$(function(){
  $('#sort, #max, #dir').change(function(){ search.execute(); });

	$('#search').click(function(){
		window.location.href = '../search#q=' + $('#q').val();
	});

	$('#q').keypress(function(e){
		if(e.keyCode === 13){ $('#search').click(); }
	});

	$('#keywords a').click(function(){
		var li = $(this).parent('li');

		if(li.hasClass('active')){ li.removeClass('active'); }
		else { li.addClass('active'); }

		var keyword_ids = $('#keywords li.active a').map(function(){
			return this.getAttribute('data-keyword-id');
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
	});

	map = initMap();

	var wkt = $('#wkt').val();
	if(wkt.length > 0){
		var wkt_parser = new OpenLayers.Format.WKT();

		var layer = map.getLayersByName('Result Layer')[0];
		layer.addFeatures([
			new OpenLayers.Feature.Vector(
				OpenLayers.Geometry.fromWKT(wkt)
			)
		]);
	}

	search = new Search({
		url: '../search.json',

		updatehash: false,

		onerror: function(t, d){
			$('#inventory_container').hide();
			AlertTool.error(t, d);
		},

		onparam: function(o){
			o['well_id'] = $('#well_id').val();
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
					a.href = '../inventory/' + obj['ID'];
					a.appendChild(document.createTextNode(obj['ID']));
					td.appendChild(a);
					tr.appendChild(td);

					// Box
					td = document.createElement('td');
					if('boxNumber' in obj){
						td.appendChild(document.createTextNode(obj['boxNumber']));
					}
					if('setNumber' in obj){
						td.appendChild(document.createElement('br'));
						td.appendChild(document.createTextNode(obj['setNumber']));
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
});
