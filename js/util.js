var Search = function(o)
{
	this.lastsearch = '';
	this.ignorehashchange = false;

	for(var i in o){ this[i] = o[i]; }
};

Search.prototype = {
	// These functions should be overridden, inside the object
	onhashchange: function(){ },
	onerror: function(){ },
	onparam: function(){ return false; },
	onparse: function(){ },

	hashwrapper: function()
	{
		if(this.ignorehashchange){
			this.ignorehashchange = false; return;
		}

		this.onhashchange();
	},
	
	setuponhashchange: function()
	{
		if('onhashchange' in window){
			var self = this;
			window.onhashchange = function(){ self.hashwrapper(); }
		}
	},

	getMax: function()
	{
		var e = document.getElementById('max');
		return Number(e.options[e.selectedIndex].value);
	},

	getSort: function(){
		var e = document.getElementById('sort');
		return Number(e.options[e.selectedIndex].value);
	},

	getStart: function(){
		return Number(document.getElementById('start').value);
	},

	setStart: function(n){
		document.getElementById('start').value = n;
	},

	setDisplayStart: function(h){
		document.getElementById('page_start').innerHTML = String(h);
	},

	setDisplayEnd: function(h)
	{
		document.getElementById('page_end').innerHTML = String(h);
	},

	setDisplayFound: function(h)
	{
		document.getElementById('page_found').innerHTML = String(h);
	},

	getPageControl: function(){
		return document.getElementById('page_control');
	},

	buildPageControl: function(start, max, found, size, length)
	{
		var self = this;
		var current_page = 1 + Math.floor((start + 1) / max);
		var total_pages = Math.ceil(size / max);

		var pages = this.calculatePages(current_page, total_pages);

		this.setDisplayStart(start + 1);
		this.setDisplayEnd(start + length);
		this.setDisplayFound(found);

		var ul = document.getElementById('page_control');
		while(ul.hasChildNodes()){ ul.removeChild(ul.firstChild); }

		var li = document.createElement('li');
		if(current_page > 1){
			var a = document.createElement('a');
			a.href = '#';
			a.innerHTML = '&laquo;';
			a.onclick = function(){
				self.page(-1);
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
						self.page(page);
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
				self.page(0);
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

	execute: function(updatehash)
	{
		updatehash = typeof updatehash !== 'undefined' ? updatehash : true;

		var self = this;
		var params = {};
		if(this.onparam(params)){
			var max = this.getMax();
			if(max !== 25){ params['max'] = max; }

			var sort = this.getSort();
			if(sort !== 0){ params['sort'] = sort; }
			
			var currsearch = this.encodeParameters(params);
			if(this.lastsearch.length > 0 && currsearch !== this.lastsearch){
				this.setStart(0);
			}

			this.lastsearch = currsearch;

			var start = this.getStart();
			if(start !== 0){ params['start'] = start; }

			currsearch = this.encodeParameters(params);

			if(updatehash){
				this.ignorehashchange = true;
				window.location.hash = currsearch;
			}

			var request = new XMLHttpRequest();
			request.onreadystatechange = function(){
				self.statechange(this, params);
			};
			request.open('POST', this.url, true);
			request.setRequestHeader(
				'Content-type', 'application/x-www-form-urlencoded'
			);
			request.send(currsearch);
		}
	},

	statechange: function(request, params)
	{
		if(request.readyState === 4){
			if(request.status !== 200){
				this.onerror(
					'Fetch error',
					request.statusText + ': ' + request.responseText
				);
			} else {
				var json = JSON.parse(request.responseText);
				if(!('start' in params)){ params['start'] = 0; }
				if(!('max' in params)){ params['max'] = 25; }

				this.buildPageControl(
					params['start'], params['max'], json['found'],
					json['size'], json['list'].length
				);
				this.onparse(json);
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
		panel.className = 'panel panel-' + type;
		panel.appendChild(panel_head);
		panel.appendChild(panel_body);

		var body = document.getElementsByTagName('body')[0];
		body.appendChild(panel);
	},

	warning: function(t, d){ this.create(t, d, 'warning'); },
	error: function(t, d){ this.create(t, d, 'danger'); }
};
