// Takes an object containing a list of JSON requests
// and makes them, loading all the data into the object
// provided, and then finally calling the complete function
// of the object when finished
function queueRequests(obj)
{
	// Reset object run
	obj.finished = 0;
	obj.data = {};

	for(var i = 0; i < obj.requests.length; i++){
		queueRequest(obj.requests[i], obj);
	}
}

// See queueReqeusts()
function queueRequest(url, obj)
{
	var xhr = (window.ActiveXObject ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest());
	xhr.onreadystatechange = function(){
		if(xhr.readyState === 4){
			if(xhr.status === 200){
				var n = url.slice(0, -5);
				obj.data[n] = JSON.parse(xhr.responseText);
			}

			obj.finished++;
			if(obj.finished === obj.requests.length){
				obj.complete();
			}
		}
	};
	xhr.open('GET', url, true);
	xhr.send();
}


// Takes an arbitrary JSON object
// and renders it into a table, returning
// the table element
function JSONToElement(obj){
	var type = Object.prototype.toString.call(obj);

	switch(type){
		case '[object Boolean]':
			return document.createTextNode(obj.toString());

		case '[object String]':
			return document.createTextNode(obj);

		case '[object Number]':
			return document.createTextNode(obj.toString());

		case '[object Null]':
			return document.createTextNode('(null)');

		case '[object Object]':
			var tbl = document.createElement('table');
			var count = 0;
			for(var i in obj){
				var tr = document.createElement('tr');

				var th = document.createElement('th');
				th.appendChild(document.createTextNode(i));
				tr.appendChild(th);

				var td = document.createElement('td');
				td.appendChild(JSONToElement(obj[i]));
				tr.appendChild(td);

				tbl.appendChild(tr);
				count++;
			}
			if(count > 0) return tbl;
			else return document.createTextNode('(Empty Object)');

		case '[object Array]':
			if(obj.length < 1) return document.createTextNode('(Empty List)');

			var tbl = document.createElement('table');
			for(var i = obj.length; i--;){
				var tr = document.createElement('tr');

				var th = document.createElement('th');
				th.appendChild(document.createTextNode(i));
				tr.appendChild(th);

				var td = document.createElement('td');
				td.appendChild(JSONToElement(obj[i]));
				tr.appendChild(td);

				tbl.appendChild(tr);
			}
			return tbl;

		default:
			return document.createTextNode('Unknown - ' + type);
	}
}
