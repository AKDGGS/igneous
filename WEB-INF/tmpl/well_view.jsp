<%@
	page trimDirectiveWhitespaces="true"
%><%@
	taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><%@
	taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"
%><%@
	taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Division of Geological &amp; Geophysical Surveys Geologic Materials Center</title>
		<meta charset="utf-8">
		<meta http-equiv="x-ua-compatible" content="IE=edge" >
		<link rel="stylesheet" href="../css/apptmpl.min.css">
		<link rel="stylesheet" href="../leaflet/leaflet.css">
		<link rel="stylesheet" href="../leaflet/leaflet.mouseposition.css">
		<link rel="stylesheet" href="../css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" media="screen">
		<style>
			.barcode { min-width: 205px; }
			.barcode div { margin-left: 5px; font-size: 11px; font-weight: bold; }
			#inventory_container { display: none; }
			#keyword_container a { margin: 2px 0px 0px 2px; }
			#keyword_container .active { box-shadow: none !important; background-color: transparent !important; }
			#keywords li { display: block; }

			.half-left { width: 50%; }
			.half-right { width: 50%; float: right; margin: 0px 0px 0px auto; }

			#map { width: 100%; height: 300px; display: none; background-color: black; margin: 0; }
			#lonlat { display: none; }

			dd a { white-space: nowrap; }
			dl { display: table; margin: 8px 4px; }
			dt, dd { display: table-cell; }
			dt { width: 160px; }
			dd { margin: 0px; }

			pre { margin: 0px; }
			.notehd { color: #777; }
			#tab-notes > div:not(:first-child) { margin-top: 30px; }

			#filelist { display: flex; flex-wrap: wrap; }
			#filelist a { display: inline-block; margin: 4px; 8px; flex-basis: 75px; text-align: center; font-size: 12px; }
			#filelist a img { border: none; }

			.nav-tabs > li > a { padding: 8px 16px; }
		</style>
	</head>
	<body onload="init()">
		<div class="apptmpl-container">
			<div class="apptmpl-goldbar">
				<a class="apptmpl-goldbar-left" href="http://alaska.gov"></a>
				<span class="apptmpl-goldbar-right"></span>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<a href="../container_log.html">Move Log</a>
				<a href="../quality_report.html">Quality Assurance</a>
				<a href="../audit_report.html">Audit</a>
				<c:if test="${pageContext.request.isUserInRole('admin')}">
				<a href="../import.html">Data Importer</a>
				</c:if>
				<a href="../logout/">Logout</a>
				</c:if>
				<c:if test="${empty pageContext.request.userPrincipal}">
				<a href="https://${pageContext.request.serverName}${pageContext.request.contextPath}/login/">Login</a>
				</c:if>
				<a href="../help">Search Help</a>
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
				<a href="../search">Inventory</a>
			</div>

			<div class="apptmpl-content">
				<div class="half-right">
					<div id="map"></div>
				</div>
				
				<input type="hidden" name="geojson" id="geojson" value="${fn:escapeXml(geojson)}">
				
				<div class="half-left">
					<dl>
						<dt>Name</dt>
						<dd>${well.name}</dd>
					</dl>
					<c:if test="${!empty well.altNames}">
					<dl>
						<dt>Alternative Name(s)</dt>
						<dd>${well.altNames}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.wellNumber}">
					<dl>
						<dt>Well Number</dt>
						<dd>${well.wellNumber}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.APINumber}">
					<dl>
						<dt>API Number</dt>
						<dd><a href="../search#q=api:${fn:escapeXml(well.APINumber)}">${well.APINumber}</a></dd>
					</dl>
					</c:if>
					<dl>
						<dt>Onshore</dt>
						<dd><span title="${well.onshore ? 'true' : 'false'}" class="glyphicon glyphicon-${well.onshore ? 'ok' : 'remove'}"></span></dd>
					</dl>
					<dl>
						<dt>Federal</dt>
						<dd><span title="${well.federal ? 'true' : 'false'}" class="glyphicon glyphicon-${well.federal ? 'ok' : 'remove'}"></span></dd>
					</dl>
					<c:if test="${!empty well.spudDate}">
					<dl>
						<dt>Spud Date</dt>
						<dd><fmt:formatDate pattern="M/d/yyyy" value="${well.spudDate}"/></dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.completionDate}">
					<dl>
						<dt>Completion Date</dt>
						<dd><fmt:formatDate pattern="M/d/yyyy" value="${well.completionDate}"/></dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.measuredDepth}">
					<dl>
						<dt>Measured Depth</dt>
						<dd><fmt:formatNumber value="${well.measuredDepth}" /> <c:if test="${!empty well.unit}"> ${well.unit.abbr}</c:if></dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.verticalDepth}">
					<dl>
						<dt>Vertical Depth</dt>
						<dd><fmt:formatNumber value="${well.verticalDepth}" /> <c:if test="${!empty well.unit}"> ${well.unit.abbr}</c:if></dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.elevation}">
					<dl>
						<dt>Elevation</dt>
						<dd><fmt:formatNumber value="${well.elevation}" /> <c:if test="${!empty well.unit}"> ${well.unit.abbr}</c:if></dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.elevationKB}">
					<dl>
						<dt>Kelly Bushing Elevation</dt>
						<dd><fmt:formatNumber value="${well.elevationKB}" /> <c:if test="${!empty well.unit}"> ${well.unit.abbr}</c:if></dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.permitStatus}">
					<dl>
						<dt>Permit Status</dt>
						<dd>${well.permitStatus}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.completionStatus}">
					<dl>
						<dt>Completion Status</dt>
						<dd>${well.completionStatus}</dd>
					</dl>
					</c:if>
					<dl id="lonlat">
						<dt>Lon/Lat</dt>
						<dd></dt>
					</dl>
					<c:if test="${!empty quadrangles}">
					<dl>
						<dt>Quadrangle</dt>
						<dd><c:forEach items="${quadrangles}" var="quadrangle" varStatus="stat">${stat.count gt 1 ? ", " : ""}<a href="../search#quadrangle_id=${quadrangle.ID}">${quadrangle.name}</a></c:forEach>
						</dd>
					</dl>
					</c:if>
				</div>

				<div style="clear:both"></div>

				<c:set var="inventory_count" value="0" />
				<c:forEach items="${keywords}" var="keyword">
					<c:set var="inventory_count" value="${inventory_count + keyword.count}" />
				</c:forEach>

				<ul id="tabs" class="nav nav-tabs" style="width: 100%; margin-top: 15px">
					<li class="active"><a href="#inventory">Inventory <span class="badge">${inventory_count}</span></a></li>
					<li><a href="#operators">Operators <span class="badge">${fn:length(well.operators)}</span></a></li>
					<li><a href="#urls">URLs <span class="badge">${fn:length(well.URLs)}</span></a></li>
					<li><a href="#files">Files <span class="badge">${fn:length(well.files)}</span></a></li>
					<c:if test="${not empty pageContext.request.userPrincipal}">
					<li><a href="#notes">Notes <span class="badge">${fn:length(well.notes)}</span></a></li>
					</c:if>
				</ul>

				<div id="tab-operators" class="hidden">
					<c:forEach items="${well.operators}" var="operator">
						<div class="container">
						<dl>
							<dt>${operator.current ? 'Current' : 'Previous'} Operator</dt>
							<dd>${operator.name} <c:if test="${!empty operator.abbr}">(${operator.abbr})</c:if></dd>
						</dl>
						<dl>
							<dt>Operator Type</dt>
							<dd>${operator.type.name}</dd>
						</dl>
					</div>
					</c:forEach>
				</div>

				<div id="tab-inventory">
					<div class="container" id="keyword_container">
						<c:if test="${!empty keywords}">
						<c:set var="link" value="well:\"${well.name}\"" />
						<c:if test="${!empty well.wellNumber}">
						<c:set var="link" value="${link} wellnumber:\"${well.wellNumber}\"" />
						</c:if>
						<div>
							<span class="label label-info">By Keywords</span>
							<ul class="nav nav-pills" id="keywords">
							<c:forEach items="${keywords}" var="keyword">
							<c:set var="kws" value="&keyword_id=${fn:join(fn:split(keyword.ids, ','), '&keyword_id=')}" />
							<li><a href="../search#q=${fn:escapeXml(link)}${kws}">${keyword.keywords} <span class="badge">${keyword.count}</span></a></li>
							</c:forEach>
							</ul>
						</div>
						</c:if>
					</div>
				</div>

				<div id="tab-urls" class="hidden">
					<c:forEach items="${well.URLs}" var="url" varStatus="stat">
					<div class="container">
						<dl>
							<dt>URL Description</dt>
							<dd>${url.description}</dd>
						</dl>
						<c:if test="${!empty url.type}">
						<dl>
							<dt>URL Type</dt>
							<dd>${url.type.name}</dd>
						</dl>
						</c:if>
						<dl>
							<dt>URL</dt>
							<dd><a href="${url.URL}">${url.URL}</a></dd>
						</dl>
					</div>
					</c:forEach>
				</div>

				<div id="tab-files" class="hidden">
					<div id="filelist">
					<c:forEach items="${well.files}" var="file">
						<a href="../file/${file.ID}" title="${empty file.description ? file.filename : file.description} (${file.sizeString})">
							<img src="../img/icons/${file.simpleType}.png"><br>${file.filename}
						</a>
					</c:forEach>
					</div>

					<c:if test="${pageContext.request.isUserInRole('edit')}">
					<br>

					<form action="../upload" method="POST" enctype="multipart/form-data">
						<input type="hidden" name="well_id" value="${well.ID}">
						<fieldset id="uploadcontainer">
							<legend>Upload File(s)</legend>

							<table>
								<tr>
									<td>Description:</td>
									<td style="text-align: right">
										<input type="text" name="description" size="35">
									</td>
								</tr>
								<tr>
									<td>
										Select files:
									</td>
									<td style="text-align: right">
										<input type="file" id="fileselect" name="files" multiple="multiple">
										<input type="submit" id="filesubmit" value="Upload">
									</td>
								</tr>
							</table>
						</fieldset>
					</form>
					</c:if>
				</div>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<div id="tab-notes" class="hidden">
					<c:forEach items="${well.notes}" var="note" varStatus="stat">
					<div class="container">
						<div class="notehd"><fmt:formatDate pattern="M/d/yyyy" value="${note.date}"/>, ${note.type.name} (${note.username}, ${note.isPublic ? 'public' : 'private'})</div>
						<pre>${fn:escapeXml(note.note)}</pre>
					</div>
					</c:forEach>
				</div>
				</c:if>
			</div>
		</div>
		<script src="../leaflet/leaflet.js"></script>
		<script src="../js/utility.js"></script>
		<script src="../leaflet/leaflet.mouseposition.js"></script>
		<script>
			function init()
			{
				initTabs();
				
				var geojson = null;
				var gj_el = document.getElementById('geojson');
				if(gj_el != null && gj_el.value.length > 0){
					geojson = JSON.parse(gj_el.value);

					if(geojson['type'] === 'Point'){
						var ll = document.getElementById('lonlat');
						if(ll !== null){
							ll.style.display = 'table';
							var dd = ll.getElementsByTagName('dd');
							if(dd.length > 0){
								dd[0].innerHTML = geojson['coordinates'][0] +
									', ' + geojson['coordinates'][1];
							}
						}
					}
					initSimpleMap(geojson, '#2e70ff');
				}
			}
		</script>
	</body>
</html>
