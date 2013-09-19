function load(id)
{
	$.ajax({
		url: '../borehole.json', dataType: 'json', data: { 'id': id },
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

			if(json['prospect'] !== null){
				var dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Prospect Name:'));
				dl.appendChild(dt);

				var dd = document.createElement('dd');
				var a = document.createElement('a');
				a.href = '../prospect/' + json['prospect']['ID'];
				a.appendChild(document.createTextNode(json['prospect']['name']));
				dd.appendChild(a);
				dl.appendChild(dd);

				if(json['prospect']['altNames'] !== null){
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

				if(json['prospect']['ARDF'] !== null){
					dt = document.createElement('dt');
					dt.appendChild(document.createTextNode(
						'ARDF:'
					));
					dl.appendChild(dt);

					dd = document.createElement('dd');
					dd.appendChild(document.createTextNode(
						json['prospect']['ARDF'])
					);
					dl.appendChild(dd);
				}
			}

			var dt = document.createElement('dt');
			dt.appendChild(document.createTextNode('Borehole Name:'));
			dl.appendChild(dt);

			var dd = document.createElement('dd');
			dd.appendChild(document.createTextNode(json['name']));
			dl.appendChild(dd);

			if(json['altNames'] !== null){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Alt. Borehole Names:'));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(json['altNames']));
				dl.appendChild(dd);
			}

			dt = document.createElement('dt');
			dt.appendChild(document.createTextNode('Onshore:'));
			dl.appendChild(dt);

			dd = document.createElement('dd');
			dd.appendChild(document.createTextNode(
				json['onshore'] ? 'Yes' : 'No'
			));
			dl.appendChild(dd);

			if(json['elevation'] !== null){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Elevation:'));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(json['elevation']));
				if(json['elevationUnit']){
					dd.appendChild(document.createTextNode(
						' ' + json['elevationUnit']['abbr']
					));
				}
				dl.appendChild(dd);
			}

			if(json['measuredDepth'] !== null){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Measured Depth:'));
				dl.appendChild(dt);

				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(json['measuredDepth']));
				if(json['measuredDepthUnit']){
					dd.appendChild(document.createTextNode(
						' ' + json['measuredDepthUnit']['abbr']
					));
				}
				dl.appendChild(dd);
			}

			if(json['completion'] !== null){
				dt = document.createElement('dt');
				dt.appendChild(document.createTextNode('Completed:'));
				dl.appendChild(dt);
			
				dd = document.createElement('dd');
				dd.appendChild(document.createTextNode(json['completion']));
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
						var borehole_id = json['ID'];

						return function(){
							$(this).parents('ul').find('li').removeClass('active');
							$(this).parent('li').addClass('active');

							inventory_show(encodeParameters({
								'keyword_id': keyword_ids, 
								'borehole_id': borehole_id
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
					var borehole_id = json['ID'];

					return function(){
						$(this).parents('ul').find('li').removeClass('active');
						$(this).parent('li').addClass('active');

						inventory_show(encodeParameters({
							'borehole_id': borehole_id
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
