$(function(){
	$('#search').click(function(){
		var q = $('#q').val();

		if(q.length > 0){
			$.ajax({
				url: 'inventory', dataType: 'json', data: { 'q': q },
				error: function(xhr){
					$('#error_body').text(xhr.responseText);
					$('#error_modal').modal({ show: true });
				},
				success: function(json){
					if(json.length == 0){
						$('#inventory_header').text(
							'No results have been found for your query. ' +
							'Please narrow the search parameters and try again.'
						);
						$('#inventory_header').show();
						$('#inventory_table').hide();
					} else {
						var body = document.getElementById('inventory_body');
						while(body.hasChildNodes()){
							body.removeChild(body.firstChild);
						}

						for(var i in json){
							var branch = json[i]['branch']['name'];

							var tr = document.createElement('tr');

							var td = document.createElement('td');
							var a = document.createElement('a');
							a.href = 'detail/' + json[i]['ID'];
							a.appendChild(document.createTextNode(
								json[i]['ID']
							));
							td.appendChild(a);
							tr.appendChild(td);

							// Begin related
							td = document.createElement('td');
							for(var j in json[i]['boreholes']){
								var borehole = json[i]['boreholes'][j];

								var div = document.createElement('div');
								if(borehole['prospect'] !== null){
									div.appendChild(document.createTextNode(
										'Prospect: '
									));
									var prospect = borehole['prospect'];

									a = document.createElement('a');
									a.href = '#';
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

								div.appendChild(document.createTextNode(
									'Borehole: '
								));
								a = document.createElement('a');
								a.href = 'borehole/' + borehole['ID'];
								a.appendChild(document.createTextNode(
									borehole['name']
								));
								div.appendChild(a);

								td.appendChild(div);
							}
							tr.appendChild(td);
							td = document.createElement('td');
							if(json[i]['sampleNumber'] !== null){
								td.appendChild(document.createTextNode(
									json[i]['sampleNumber']
								));
							}
							tr.appendChild(td);
							// End Related

							td = document.createElement('td');
							if(json[i]['core'] !== null){
								td.appendChild(document.createTextNode(
									json[i]['core']
								));
							}
							tr.appendChild(td);

							td = document.createElement('td');
							if(json[i]['box'] !== null){
								td.appendChild(document.createTextNode(
									json[i]['box']
								));
							}
							tr.appendChild(td);

							td = document.createElement('td');
							if(json[i]['set'] !== null){
								td.appendChild(document.createTextNode(
									json[i]['set']
								));
							}
							tr.appendChild(td);

							td = document.createElement('td');
							if(json[i]['intervalTop'] !== null){
								td.appendChild(document.createTextNode(
									json[i]['intervalTop']
								));
								if(json[i]['intervalUnit'] !== null){
									td.appendChild(document.createTextNode(
										json[i]['intervalUnit']['abbr']
									));
								}
							}
							tr.appendChild(td);

							td = document.createElement('td');
							if(json[i]['intervalBottom'] !== null){
								td.appendChild(document.createTextNode(
									json[i]['intervalBottom']
								));
								if(json[i]['intervalUnit'] !== null){
									td.appendChild(document.createTextNode(
										json[i]['intervalUnit']['abbr']
									));
								}
							}
							tr.appendChild(td);

							td = document.createElement('td');
							if(json[i]['coreDiameter'] !== null){
								if(branch === 'energy' && json[i]['coreDiameter']['name'] !== null){
									td.appendChild(document.createTextNode(
										json[i]['coreDiameter']['name']
									));
								} else {
									td.appendChild(document.createTextNode(
										json[i]['coreDiameter']['diameter']
									));
									if(json[i]['coreDiameter']['unit'] !== null){
										td.appendChild(document.createTextNode(
											json[i]['coreDiameter']['unit']['abbr']
										));
									}
								}
							}
							tr.appendChild(td);

							td = document.createElement('td');
							td.appendChild(document.createTextNode(branch));
							tr.appendChild(td);

							td = document.createElement('td');
							if(json[i]['collection'] !== null){
								td.appendChild(document.createTextNode(
									json[i]['collection']['name']
								));
							}
							tr.appendChild(td);

							td = document.createElement('td');
							for(var j in json[i]['keywords']){
								var keyword = json[i]['keywords'][j];
								td.appendChild(document.createTextNode(
									(j > 0 ? ', ' : '') +
									keyword['name']
								));
							}
							tr.appendChild(td);



							td = document.createElement('td');
							td.appendChild(document.createTextNode(
								json[i]['containerPath']
							));
							tr.appendChild(td);

							body.appendChild(tr);
						}

						$('#inventory_table').show();
						$('#inventory_header').hide();
					}

					$('#inventory_panel').show();
				}
			});
		}
		return false;
	});
});
