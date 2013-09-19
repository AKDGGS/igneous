function load(id)
{
	$.ajax({
		url: '../prospect.json', dataType: 'json', data: { 'id': id },
		error: function(xhr){
			$('#error_body').text(xhr.responseText);
			$('#error_modal').modal({ show: true });
		},
		success: function(json){
			var overview = document.getElementById('overview');

			while(overview.hasChildNodes()){
				overview.removeChild(overview.firstChild);
			}

			var dl = document.createElement('dl');
			dl.className = 'dl-horizontal';

			var dt = document.createElement('dt');
			dt.appendChild(document.createTextNode('Prospect Name:'));
			dl.appendChild(dt);

			var dd = document.createElement('dd');
			dd.appendChild(document.createTextNode(json['name']));
			dl.appendChild(dd);

			if(json['altNames'] !== null){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode(
					'Alt. Prospect Names:'
				));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(
					json['prospect']['altNames'])
				);
				dl.appendChild(dd);
			}

			if(json['ARDF'] !== null){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode(
					'ARDF:'
				));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(
					json['ARDF']
				));
				dl.appendChild(dd);
			}
			overview.appendChild(dl);

			if(json['inventorySummary'] !== null && json['inventorySummary'].length > 0){
				var ul = document.createElement('ul');
				ul.className = 'nav nav-pills';

				var total = 0;

				for(var i in json['inventorySummary']){
					var set = json['inventorySummary'][i];
					total += set['count'];

					var span = document.createElement('span');
					span.className = 'badge pull-right';
					span.appendChild(document.createTextNode(set['count']));

					var a = document.createElement('a');
					a.href = '#';
					a.onclick = function(){
						var keyword_ids = set['ids'].split(',');
						var prospect_id = json['ID'];

						return function(){
							$(this).parents('ul').find('li').removeClass('active');
							$(this).parent('li').addClass('active');

							inventory_show(encodeParameters({
								'keyword_id': keyword_ids, 
								'prospect_id': prospect_id
							}));

							return false;
						};
					}();
					a.appendChild(document.createTextNode(set['keywords']));
					a.appendChild(span);

					var li = document.createElement('li');
					li.appendChild(a);

					ul.appendChild(li);
				}

				var span = document.createElement('span');
				span.className = 'badge pull-right';
				span.appendChild(document.createTextNode(total));

				var a = document.createElement('a');
				a.href = '#';
				a.onclick = function(){
					var prospect_id = json['ID'];

					return function(){
						$(this).parents('ul').find('li').removeClass('active');
						$(this).parent('li').addClass('active');

						inventory_show(encodeParameters({
							'prospect_id': prospect_id
						}));

						return false;
					};
				}();
				a.appendChild(document.createTextNode('All'));
				a.appendChild(span);

				var li = document.createElement('li');
				li.appendChild(a);

				ul.appendChild(li);

				var summary = document.getElementById('summary');
				summary.appendChild(ul);
			}
		}
	});
}


function inventory_show(params)
{
	$.ajax({
		url: '../inventory.json', dataType: 'json', data: params,
		error: function(xhr){
			$('#error_body').text(xhr.responseText);
			$('#error_modal').modal({ show: true });
			$('#inventory').hide();
		},
		success: function(json){
			var body = document.getElementById('inventory_body');
			while(body.hasChildNodes()){ body.removeChild(body.firstChild); }

			for(var i in json){
				var obj = json[i];
				var tr = document.createElement('tr');

				var td = document.createElement('td');
				var a = document.createElement('a');
				a.href = '../inventory/' + obj['ID'];
				a.appendChild(document.createTextNode(obj['ID']));
				td.appendChild(a);
				tr.appendChild(td);

				td = document.createElement('td');
				if(obj['intervalTop'] !== null){
					td.appendChild(document.createTextNode(obj['intervalTop']));
					if(obj['intervalUnit'] !== null){
						td.appendChild(document.createTextNode(
							' ' + obj['intervalUnit']['abbr']
						));
					}
				}
				tr.appendChild(td);

				td = document.createElement('td');
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
				if(obj['box'] !== null){
					td.appendChild(document.createTextNode(obj['box']));
				}
				tr.appendChild(td);

				td = document.createElement('td');
				if(obj['barcode'] !== null){
					td.appendChild(document.createTextNode(obj['barcode']));
				}
				tr.appendChild(td);

				td = document.createElement('td');
				td.appendChild(document.createTextNode(
					obj['containerPath']
				));
				tr.appendChild(td);

				body.appendChild(tr);
			}
			$('#inventory').show();
		}
	});
}


// Encodes an object into a URI form (e.g. "search=monkey&limit=10")
// Use this function instead of $.param, as $.param uses
// old stype + as space encoding for URLs.
function encodeParameters(o, l)
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
}
