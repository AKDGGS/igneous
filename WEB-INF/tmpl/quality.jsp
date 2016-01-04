<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Division of Geological &amp; Geophysical Surveys Geologic Materials Center</title>
		<meta charset="utf-8">
		<meta http-equiv="x-ua-compatible" content="IE=edge" >
		<link rel="stylesheet" href="css/apptmpl.min.css">
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
	<body onload="init()">
		<div class="apptmpl-container">
			<div class="apptmpl-goldbar">
				<a class="apptmpl-goldbar-left" href="http://alaska.gov"></a>
				<span class="apptmpl-goldbar-right"></span>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<a href="container_log.html">Move Log</a>
				<a href="quality_report.html">Quality Assurance</a>
				<a href="audit_report.html">Audit</a>
				<c:if test="${pageContext.request.isUserInRole('admin')}">
				<a href="import.html">Data Importer</a>
				</c:if>
				</c:if>
				<a href="help">Search Help</a>
			</div>

			<div class="apptmpl-banner">
				<a class="apptmpl-banner-logo" href="http://dggs.alaska.gov"></a>
				<div class="apptmpl-banner-title">Geologic Materials Center Inventory</div>
				<div class="apptmpl-banner-desc">Alaska Division of Geological &amp; Geophysical Surveys</div>
			</div>

			<div class="apptmpl-breadcrumb">
				<a href="http://alaska.gov">State of Alaska</a> &gt;
				<a href="http://dnr.alaska.gov">Natural Resources</a> &gt;
				<a href="http://dggs.alaska.gov">Geological &amp; Geophysical Surveys</a> &gt;
				<a href="http://dggs.alaska.gov/gmc">Geologic Materials Center</a> &gt;
				<a href="search">Inventory</a>
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
		</div>
		<script src="js/mustache-2.2.0.min.js"></script>
		<script>
			function init()
			{
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
			}

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
		</script>
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
	</body>
</html>
