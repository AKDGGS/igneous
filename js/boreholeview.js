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
							console.log(keyword_ids);
							console.log(borehole_id);
						}
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
