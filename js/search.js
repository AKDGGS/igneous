// Returns an array containing a list of pages to be shown
// given a specific current page and total number of pages
function calculatePages(current_page, total_pages)
{
	var pages = [];

	var s = Math.max((current_page - 1), 1);
	var e = Math.min((current_page + 1), total_pages);

	if((e-s) < 3){
		if(s == 1){ e = Math.min(3, total_pages); }
		else if(e == total_pages){ s = Math.max((total_pages - 2), 1); }
	}

	for(var i = s; i <= e; i++){ pages.push(i); }

	if(pages[0] != 1){
		if(pages[0] == 2){  }
		else if(pages[0] == 3){ pages.unshift(2); }
		else { pages.unshift(0); }

		pages.unshift(1);
	}

	if(pages.length > 2 && pages[pages.length-1] < total_pages){
		if(pages[pages.length-1] == (total_pages-1)){ pages.push(total_pages); }
		else { pages.push(0); }
	}

	return pages;
}


function search_page(n)
{
	var start_el = document.getElementById('start');
	var start = Number(start_el.value);

	var max_el = document.getElementById('max');
	var max = Number(max_el.options[max_el.selectedIndex].value);

	if(n == 0){ start = start + max; }
	else if(n == -1){ start = start - max; }
	else { start = (max * n) - max; }

	start_el.value = start;
	search_fetch(start, max);
}


function search_fetch(start, max)
{
	var q = $('#q').val();

	if(q.length > 0){
		$.ajax({
			url: 'search.json', dataType: 'json',
			data: { 'q': q, 'start': start, 'max': max },
			error: function(xhr){
				alert(xhr.responseText);
			},
			success: function(json){ search_parse(json, start, max); }
		});
	}
}


function search_parse(json, start, max)
{
	if(json['list'].length == 0){
		$('#inventory_table').hide();
		alert(
			'No results have been found for your query. ' +
			'Please narrow the search parameters and try again.'
		);
	} else {
		var body = document.getElementById('inventory_body');
		while(body.hasChildNodes()){ body.removeChild(body.firstChild); }

		// Begin page math
		var current_page = 1 + Math.floor((start + 1) / max);
		var total_pages = Math.ceil(json.size / max);

		var pages = calculatePages(current_page, total_pages);

		var display = document.getElementById('page_display');

		document.getElementById('page_start').innerHTML = String(start + 1);
		document.getElementById('page_end').innerHTML = String(start + json['list'].length);
		document.getElementById('page_found').innerHTML = json.found;

		var ul = document.getElementById('page_control');
		while(ul.hasChildNodes()){ ul.removeChild(ul.firstChild); }

		var li = document.createElement('li');
		if(current_page > 1){
			var a = document.createElement('a');
			a.href = '#';
			a.innerHTML = '&laquo;';
			a.onclick = function(){ search_page(-1); };
			li.appendChild(a);
		} else {
			li.className = 'disabled';
			var span = document.createElement('span');
			span.innerHTML = '&laquo;';
			li.appendChild(span);
		}
		ul.appendChild(li);

		for(var i in pages){
			var li = document.createElement('li');
			if(pages[i] == 0){
				li.className = 'disabled';
				var span = document.createElement('span');
				span.appendChild(document.createTextNode('..'));
				li.appendChild(span);
			} else if(pages[i] == current_page){
				li.className = 'active';
				var span = document.createElement('span');
				span.appendChild(document.createTextNode(current_page));
				li.appendChild(span);
			} else {
				var a = document.createElement('a');
				a.href = '#';
				a.appendChild(document.createTextNode(pages[i]));
				a.onclick = function(){
					var page = pages[i];
					return function(){ search_page(page); };
				}();
				li.appendChild(a);
			}
			ul.appendChild(li);
		}

		li = document.createElement('li');
		if(current_page < total_pages){
			var a = document.createElement('a');
			a.href = '#';
			a.innerHTML = '&raquo;';
			a.onclick = function(){ search_page(0); };
			li.appendChild(a);
		} else {
			li.className = 'disabled';
			var span = document.createElement('span');
			span.innerHTML = '&raquo;';
			li.appendChild(span);
		}
		ul.appendChild(li);
		// End page math

		for(var i in json['list']){
			var obj = json['list'][i];
			var branch = obj['branch']['name'];

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
			if(obj['coreDiameter'] !== null){
				if(branch === 'energy' && obj['coreDiameter']['name'] !== null){
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
			td.appendChild(document.createTextNode(branch));
			tr.appendChild(td);

			td = document.createElement('td');
			if(obj['collection'] !== null){
				td.appendChild(document.createTextNode(
					obj['collection']['name']
				));
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
			td.appendChild(document.createTextNode(
				obj['containerPath']
			));
			tr.appendChild(td);

			body.appendChild(tr);
		}
		$('#inventory_table').show();
	}
}


$(function(){
	$('#search').click(function(){
		var start = Number(document.getElementById('start').value);

		var max_el = document.getElementById('max');
		var max = Number(max_el.options[max_el.selectedIndex].value);

		search_fetch(start, max);
		return false;
	});

	$('#q').keypress(function(e){
		if(e.keyCode === 13){ $('#search').click(); }
	});

	document.getElementById('max').onchange = function(){ search_page(1); };
});
