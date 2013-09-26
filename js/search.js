var SearchTool = {
	lastsearch: '',

	// Error event: Should be overridden.
	onerror: function(brief, detail)
	{

	},

	// Builds search results. Should be overridden.
	buildResults: function(json)
	{

	},

	// Builds parameter used for search. Should be overridden.
	buildParameters: function()
	{
		return false;
	},

	buildPages: function(start, max, found, size, length)
	{
		var current_page = 1 + Math.floor((start + 1) / max);
		var total_pages = Math.ceil(size / max);

		var pages = this.calculatePages(current_page, total_pages);

		document.getElementById('page_start').innerHTML = String(start + 1);
		document.getElementById('page_end').innerHTML = String(start + length);
		document.getElementById('page_found').innerHTML = found;

		var ul = document.getElementById('page_control');
		while(ul.hasChildNodes()){ ul.removeChild(ul.firstChild); }

		var li = document.createElement('li');
		if(current_page > 1){
			var a = document.createElement('a');
			a.href = '#';
			a.innerHTML = '&laquo;';
			a.onclick = function(){
				SearchTool.page(-1);
				return false;
			};
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
					return function(){
						SearchTool.page(page);
						return false;
					};
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
			a.onclick = function(){
				SearchTool.page(0);
				return false;
			};
			li.appendChild(a);
		} else {
			li.className = 'disabled';
			var span = document.createElement('span');
			span.innerHTML = '&raquo;';
			li.appendChild(span);
		}
		ul.appendChild(li);
	},

	getMax: function()
	{
		var e = document.getElementById('max');
		return Number(e.options[e.selectedIndex].value);
	},

	getSort: function()
	{
		var e = document.getElementById('sort');
		return Number(e.options[e.selectedIndex].value);
	},

	getStart: function()
	{
		return Number(document.getElementById('start').value);
	},

	setStart: function(n)
	{
		document.getElementById('start').value = n;
	},

	page: function(n)
	{
		var start = this.getStart();
		var max = this.getMax();

		if(n == 0){ start = start + max; }
		else if(n == -1){ start = start - max; }
		else { start = (max * n) - max; }

		this.setStart(start);
		this.execute();
	},

	execute: function()
	{
		var params = {};
		if(this.buildParameters(params)){
			var max = this.getMax();
			if(max !== 25){ params['max'] = max; }

			var sort = this.getSort();
			if(sort !== 0){ params['sort'] = sort; }
			
			var currsearch = this.encodeParameters(params);
			if(currsearch !== this.lastsearch){ this.setStart(0); }

			this.lastsearch = currsearch;

			var start = this.getStart();
			if(start !== 0){ params['start'] = start; }

			currsearch = this.encodeParameters(params);
			window.location.hash = currsearch;

			var request = new XMLHttpRequest();
			request.onreadystatechange = function(){
				SearchTool.stateChange(this, params);
			};
			request.open('POST', this.url, true);
			request.setRequestHeader(
				'Content-type', 'application/x-www-form-urlencoded'
			);
			request.send(currsearch);
		}
	},

	stateChange: function(request, params)
	{
		if(request.readyState === 4){
			if(request.status !== 200){
				this.onerror('Fetch error', request.statusText);
			} else {
				var json = JSON.parse(request.responseText);
				if(!('start' in params)){ params['start'] = 0; }
				if(!('max' in params)){ params['max'] = 25; }

				this.buildPages(
					params['start'], params['max'], json['found'],
					json['size'], json['list'].length
				);
				this.buildResults(json);
			}
		}
	},

	// Returns an array containing a list of pages to be shown
	// given a specific current page and total number of pages
	calculatePages: function(current_page, total_pages)
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
	},

  // Encodes an object into a URI form (e.g. "search=monkey&limit=10")
  // Use this function instead of $.param, as $.param uses
  // old stype + as space encoding for URLs.
  encodeParameters: function(o, l)
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
  },

  // Adds a value to an object as a property. If the key of that value
  // already exists, it converts it to an array and adds the new
  // property to it.
  addProperty: function(o, k, v)
  {
    if(k in o){
      if(typeof o[k] === 'object'){ o[k].push(v); }
      else {
        var t = [];
        t.push(o[k]);
        t.push(v);
        o[k] = t;
      }
    } else { o[k] = v; }
  }
};

var AlertTool = {
	clear: function()
	{
		var panel = document.getElementById('alert_panel');
		if(panel != null){ panel.parentNode.removeChild(panel); }
	},

	create: function(t, d, type)
	{
		this.clear();

		var panel_head = document.createElement('div');
		panel_head.className = 'panel-head';
		panel_head.appendChild(document.createTextNode(t));

		var panel_body = document.createElement('div');
		panel_body.className = 'panel-body';
		panel_body.appendChild(document.createTextNode(d));

		var panel = document.createElement('div');
		panel.id = 'alert_panel';
		panel.className = 'panel panel-' + type + ' space-top';
		panel.appendChild(panel_head);
		panel.appendChild(panel_body);

		var body = document.getElementsByTagName('body')[0];
		body.appendChild(panel);
	},

	warning: function(t, d){ this.create(t, d, 'warning'); },
	error: function(t, d){ this.create(t, d, 'danger'); }
};

$(function(){
	SearchTool.url = 'search.json';
	SearchTool.onerror = function(d){
		document.getElementById('inventory_table').style.display = 'none';
		AlertTool.error('Search Error', d);
	};

	SearchTool.buildParameters = function(o){
		var q = document.getElementById('q').value.trim();
		if(q.length === 0){
			AlertTool.warning('Empty Search', 'Search cannot be empty.');
			return false;
		}
		
		o['q'] = q;
		return true;
	};

	SearchTool.buildResults = function(json){
		if(json['list'].length == 0){
			document.getElementById('inventory_table').style.display = 'none';
			AlertTool.warning(
				'Inventory Results',	
				'No results have been found for your query. ' +
				'Please narrow the search parameters and try again.'
			);
		} else {
			AlertTool.clear();

			var body = document.getElementById('inventory_body');
			while(body.hasChildNodes()){ body.removeChild(body.firstChild); }

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

				if(obj['keywords'].length > 0){
					td.appendChild(document.createElement('br'));
				}

				for(var j in obj['keywords']){
					var keyword = obj['keywords'][j];
					td.appendChild(document.createTextNode(
						(j > 0 ? ', ' : '') +
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
				td.appendChild(document.createTextNode(
					obj['containerPath']
				));
				tr.appendChild(td);

				body.appendChild(tr);
			}
			document.getElementById('inventory_table').style.display = 'table';
		}
	};

	$('#search').click(function(){
		SearchTool.execute();
		return false;
	});

	$('#sort, #max').change(function(){ SearchTool.execute(); });

	$('#q').keypress(function(e){
		if(e.keyCode === 13){ $('#search').click(); }
	});
});
