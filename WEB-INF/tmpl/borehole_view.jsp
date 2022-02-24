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
		<meta name="viewport" content="width=device-width,initial-scale=0.75,user-scalable=no">
		<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
		<link rel="stylesheet" href="../css/apptmpl-fullscreen.css">
		<link rel="stylesheet" href="../leaflet/leaflet.css">
		<link rel="stylesheet" href="../leaflet/leaflet.mouseposition.css">
		<link rel="stylesheet" href="../css/view.css" media="screen">
		<style>
			#keyword_container a { margin: 2px 0px 0px 2px; }
			#keyword_container .active { box-shadow: none !important; background-color: transparent !important; }
			#keywords li { display: block; }

			.half-left { width: 50%; }
			.half-right { width: 50%; float: right; margin: 0px 0px 0px auto; }

			#map { width: 100%; height: 300px; display: none; background-color: black; margin: 0px; }
			#lonlat { display: none; }

			.notehd { color: #777; }
			#tab-notes > div:not(:first-child) { margin-top: 30px; }
		</style>
	</head>
	<body>
		<div class="soa-apptmpl-header">
			<div class="soa-apptmpl-header-top">
				<a class="soa-apptmpl-logo" title="The Great State of Alaska" href="https://alaska.gov"></a>
				<a class="soa-apptmpl-logo-dggs" title="The Division of Geological &amp; Geophysical Surveys" href="https://dggs.alaska.gov"></a>
				<div class="soa-apptmpl-header-nav">
					<c:if test="${not empty pageContext.request.userPrincipal}">
					<a href="../container_log.html">Move Log</a>
					<a href="../quality_report.html">Quality Assurance</a>
					<a href="../audit_report.html">Audit</a>
					<a href="../import.html">Data Importer</a>
					<a href="../logout/">Logout</a>
					</c:if>
					<c:if test="${empty pageContext.request.userPrincipal}">
					<a href="../login/">Login</a>
					</c:if>
					<a href="../help">Help/Contact</a>
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
				<a href="../search">
					<span class="soa-apptmpl-breadcrumb-lg">Inventory</span>
					<span class="soa-apptmpl-breadcrumb-sm">Inventory</span>
				</a>
			</div>
		</div>
		<div class="apptmpl-content">
			<div class="half-right">
				<div id="map"></div>
			</div>

			<input type="hidden" name="geojson" id="geojson" value="${fn:escapeXml(geojson)}">

			<div class="half-left">
				<c:if test="${!empty borehole.prospect}">
				<dl>
					<dt>Prospect Name</dt>
					<dd><a href="../prospect/${borehole.prospect.ID}">${borehole.prospect.name}</a></dd>
				</dl>
				<c:if test="${!empty borehole.prospect.altNames}">
				<dl>
					<dt>Alternative Prospect Name(s)</dt>
					<dd>${borehole.prospect.altNames}</dd>
				</dl>
				</c:if>
				<c:if test="${!empty borehole.prospect.ARDF}">
				<dl>
					<dt>ARDF Number</dt>
					<dd><a href="http://mrdata.usgs.gov/ardf/show-ardf.php?ardf_num=${borehole.prospect.ARDF}">${borehole.prospect.ARDF}</a></dd>
				</dl>
				</c:if>
				</c:if>
				<dl>
					<dt>Borehole Name</dt>
					<dd>${borehole.name}</dd>
				</dl>
				<c:if test="${!empty borehole.altNames}">
				<dl>
					<dt>Alternative Borehole Name(s)</dt>
					<dd>${borehole.altNames}</dd>
				</dl>
				</c:if>
				<c:if test="${!empty borehole.completionDate}">
				<dl>
					<dt>Completion Date</dt>
					<dd><fmt:formatDate pattern="M/d/yyyy" value="${borehole.completionDate}"/></dd>
				</dl>
				</c:if>
				<c:if test="${!empty borehole.measuredDepth}">
				<dl>
					<dt>Measured Depth</dt>
					<dd><fmt:formatNumber value="${borehole.measuredDepth}" /> <c:if test="${!empty borehole.measuredDepthUnit}">&nbsp;${borehole.measuredDepthUnit}</c:if></dd>
				</dl>
				</c:if>
				<c:if test="${!empty borehole.elevation}">
				<dl>
					<dt>Elevation</dt>
					<dd><fmt:formatNumber value="${borehole.elevation}" /> <c:if test="${!empty borehole.elevationUnit}">&nbsp;${borehole.elevationUnit}</c:if></dd>
				</dl>
				</c:if>
				<dl id="lonlat">
					<dt>Lon/Lat</dt>
					<dd></dd>
				</dl>
				<c:if test="${!empty quadrangles}">
				<dl>
					<dt>Quadrangle</dt>
					<dd><c:forEach items="${quadrangles}" var="quadrangle" varStatus="stat">${stat.count gt 1 ? ", " : ""}<a href="../search#quadrangle_id=${quadrangle.ID}">${quadrangle.name}</a></c:forEach>
					</dd>
				</dl>
				</c:if>
				<c:if test="${!empty miningdistricts}">
				<dl>
					<dt>Mining District</dt>
					<dd><c:forEach items="${miningdistricts}" var="miningdistrict" varStatus="stat">${stat.count gt 1 ? ", " : ""}<a href="../search#mining_district_id=${miningdistrict.ID}">${miningdistrict.name}</a></c:forEach>
					</dd>
				</dl>
				</c:if>
				<dl>
					<dt>Onshore</dt>
					<dd>${borehole.onshore ? 'Yes' : 'No'}</dd>
				</dl>
			</div>

			<div style="clear:both"></div>

			<c:set var="inventory_count" value="0" />
			<c:forEach items="${keywords}" var="keyword">
				<c:set var="inventory_count" value="${inventory_count + keyword.count}" />
			</c:forEach>

			<ul id="tabs" class="nav nav-tabs" style="width: 100%; margin-top: 15px">
				<li class="active"><a href="#inventory">Inventory <span class="badge">${inventory_count}</span></a></li>
				<li><a href="#organizations">Organizations <span class="badge">${fn:length(borehole.organizations)}</span></a></li>
				<li><a href="#urls">URLs <span class="badge">${fn:length(borehole.URLs)}</span></a></li>
				<li><a href="#files">Files <span class="badge">${fn:length(borehole.files)}</span></a></li>
				<c:if test="${not empty pageContext.request.userPrincipal}">
				<li><a href="#notes">Notes <span class="badge">${fn:length(borehole.notes)}</span></a></li>
				</c:if>
			</ul>

			<div id="tab-organizations" class="hidden">
				<c:forEach items="${borehole.organizations}" var="organization">
					<div class="container">
					<dl>
						<dt>Organization</dt>
						<dd>${organization.name} <c:if test="${!empty organization.abbr}">(${organization.abbr})</c:if></dd>
					</dl>
					<dl>
						<dt>Organization Type</dt>
						<dd>${organization.type.name}</dd>
					</dl>
				</div>
				</c:forEach>
			</div>

			<div id="tab-inventory">
				<div class="container" id="keyword_container">
					<c:if test="${!empty keywords}">
					<c:set var="link" value="borehole:\"${borehole.name}\"" />
					<c:if test="${!empty borehole.prospect}">
					<c:set var="link" value="${link} prospect:\"${borehole.prospect.name}\"" />
					</c:if>
					<div>
						<span class="label label-info">Keywords</span>
						<ul class="nav nav-pills" id="keywords">
						<c:forEach items="${keywords}" var="keyword">
						<c:set var="kws" value="&amp;keyword=${fn:join(fn:split(keyword.keywords, ','), '&amp;keyword=')}" />
						<li><a href="../search#q=${fn:escapeXml(link)}${kws}">${fn:join(fn:split(keyword.keywords, ','), ' > ')} <span class="badge">${keyword.count}</span></a></li>
						</c:forEach>
						</ul>
					</div>
					</c:if>
				</div>
			</div>

			<div id="tab-urls" class="hidden">
				<c:forEach items="${borehole.URLs}" var="url" varStatus="stat">
				<div class="container">
					<dl>
						<dt>URL Description</dt>
						<dd>${url.description}</dd>
					</dl>
					<c:if test="${!empty url.type}">
					<dl>
						<dt>URL Type</dt>
						<dd>${url.URLType}</dd>
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
				<c:forEach items="${borehole.files}" var="file">
					<a href="../file/${file.ID}" title="${empty file.description ? file.filename : file.description} (${file.sizeString})">
						<img src="../img/icons/${file.simpleType}.png"><br>${file.filename}
					</a>
				</c:forEach>
				</div>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<br>

				<form action="../upload" method="POST" enctype="multipart/form-data">
					<input type="hidden" name="borehole_id" value="${borehole.ID}">
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
				<c:forEach items="${borehole.notes}" var="note" varStatus="stat">
				<div class="container">
					<div class="notehd"><fmt:formatDate pattern="M/d/yyyy" value="${note.date}"/>, ${note.type.name} (${note.username}, ${note.isPublic ? 'public' : 'private'})</div>
					<pre>${fn:escapeXml(note.note)}</pre>
				</div>
				</c:forEach>
			</div>
			</c:if>
		</div>
		<script src="../leaflet/leaflet.js"></script>
		<script src="../leaflet/leaflet.mouseposition.js"></script>
		<script src="../js/utility.js"></script>
		<script>
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
				initSimpleMap(geojson, '#76ff7a');
			}
		</script>
	</body>
</html>
