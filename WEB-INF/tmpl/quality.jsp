<%@
	page trimDirectiveWhitespaces="true"
%><%@
	taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Division of Geological &amp; Geophysical Surveys Geologic Materials Center</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,initial-scale=0.75,user-scalable=no">
		<link rel="stylesheet" href="css/apptmpl-fullscreen.css">
		<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
		<style>
			.ok { background-color: green; color: white; }
			.warning { background-color: yellow; }
			.critical { background-color: red; color: white; }
			.nowrap, #dest { white-space: nowrap; }
			#detail img { margin: 30px; }
			table { width: 100%; }
			td { vertical-align: top; }
			th { text-align: left; }
		</style>
	</head>
	<body>
		<div class="soa-apptmpl-header">
			<div class="soa-apptmpl-header-top">
				<a class="soa-apptmpl-logo" title="The Great State of Alaska" href="https://alaska.gov"></a>
				<a class="soa-apptmpl-logo-dggs" title="The Division of Geological &amp; Geophysical Surveys" href="https://dggs.alaska.gov"></a>
			 	<div class="soa-apptmpl-header-nav">
					<c:if test="${not empty pageContext.request.userPrincipal}">
					<a href="container_log.html">Move Log</a>
					<a href="quality_report.html">Quality Assurance</a>
					<a href="audit_report.html">Audit</a>
					<a href="import.html">Data Importer</a>
					<a href="logout/">Logout</a>
					</c:if>
					<c:if test="${empty pageContext.request.userPrincipal}">
					<a href="login/">Login</a>
					</c:if>
					<a href="help"> Help/Contact</a>
				</div>
			</div>
 			<div class="soa-apptmpl-header-breadcrumb">
				<a href="https://alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">State of Alaska</span>
					<span class="soa-apptmpl-breadcrumb-sm">Alaska</span>
				</a>
				|
				<a href="http://dnr.alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">Natural Resources</span>
					<span class="soa-apptmpl-breadcrumb-sm">DNR</span>
				</a>
				|
					<a href="https://dggs.alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">Geological &amp; Geophysical Surveys</span>
			 		<span class="soa-apptmpl-breadcrumb-sm">DGGS</span>
				</a>
				|
				<a href="https://dggs.alaska.gov/gmc/">
					<span class="soa-apptmpl-breadcrumb-lg">Geologic Materials Center</span>
					<span class="soa-apptmpl-breadcrumb-sm">GMC</span>
				</a>
				|
					<a href="search">
					<span class="soa-apptmpl-breadcrumb-lg">Inventory</span>
					<span class="soa-apptmpl-breadcrumb-sm">Inventory</span>
				</a>
			</div>
		</div>
		<div class="apptmpl-content">
			<table>
				<tbody>
					<tr>
						<td id="dest"></td>
						<td id="detail"></td>
					</tr>
				</tbody>
			</table>
		</div>

		<script src="js/mustache-2.2.0.min.js"></script>
		<script id="tmpl-detail" type="x-tmpl-mustache">
			<table>
				<thead>
					<tr>
						<th>ID</th>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					{{#.}}
					<tr>
						<td class="nowrap">{{id}}</td>
						<td>{{desc}}</td>
					</tr>
					{{/.}}
				</tbody>
			</table>
		</script>
		<script>
			function updateReportCount(id, el, type)
			{
				var xhr = (window.ActiveXObject ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest());
				xhr.onreadystatechange = function(){
					if(xhr.readyState === 4 && xhr.status === 200){
						while(el.lastChild) el.removeChild(el.lastChild);
						var json = JSON.parse(xhr.responseText);

						if(json[0] === 0){
							el.className = 'ok';
							el.innerHTML = 'PASSED';
						} else {
							el.className = type.toLowerCase();
							el.innerHTML = type.toUpperCase();

							el.parentNode.appendChild(document.createTextNode(' ('));
							var a = document.createElement('a');
							a.href = '#' + id;
							a.innerHTML = json[0];
							a.onclick = updateDetail;
							el.parentNode.appendChild(a);
							el.parentNode.appendChild(document.createTextNode(')'));
						}
					}
				};
				xhr.open('GET', 'quality_report.json?r=' + id + 'Count', true);
				xhr.send();
			}


			function updateDetail(evt)
			{
				var id = this.href.substring(this.href.indexOf('#') + 1);

				var detail = document.getElementById('detail');
				while(detail.lastChild) detail.removeChild(detail.lastChild);
				var img = document.createElement('img');
				img.src = 'img/big_loading.gif';
				detail.appendChild(img);

				var xhr = (window.ActiveXObject ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest());
				xhr.onreadystatechange = function(){
					if(xhr.readyState === 4 && xhr.status === 200){
						detail.innerHTML = Mustache.render(
							document.getElementById('tmpl-detail').innerHTML,
							JSON.parse(xhr.responseText)
						);
					}
				};
				xhr.open('GET', 'quality_report.json?r=' + id, true);
				xhr.send();

				var e = evt === undefined ? window.event : evt;
				if('preventDefault' in e) e.preventDefault();
				return false;
			}

			var dest = document.getElementById('dest');
			if(dest !== null){
				// Query the list of reports available
				var xhr = (window.ActiveXObject ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest());
				xhr.onreadystatechange = function(){
					if(xhr.readyState === 4 && xhr.status === 200){
						var json = JSON.parse(xhr.responseText);
						for(var i in json){
							var div = document.createElement('div');
							div.className = 'result';
							div.appendChild(document.createTextNode(
								json[i]['desc'] + ' : '
							));

							var span = document.createElement('span');
							span.id = i;
							span.appendChild(document.createTextNode(
								'Running ..'
							));
							div.appendChild(span);
							dest.appendChild(div);

							updateReportCount(i, span, json[i]['type']);
						}
					}
				};
				xhr.open('GET', 'quality_report.json', true);
				xhr.send();
			}
		</script>
	</body>
</html>
