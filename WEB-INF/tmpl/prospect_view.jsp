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
		<link rel="stylesheet" href="../css/view.css" media="screen">
		<style>
			#keyword_container a { margin: 2px 0px 0px 2px; }
			#keyword_container .active { box-shadow: none !important; background-color: transparent !important; }
			#keywords li { display: block; }

			.half-left { width: 50%; }
			.half-right { width: 50%; float: right; margin: 0px 0px 0px auto; }

			#map { width: 100%; height: 300px; display: none; background-color: black; margin: 0px; }

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
				<a href="../import.html">Data Importer</a>
				<a href="../logout/">Logout</a>
				</c:if>
				<c:if test="${empty pageContext.request.userPrincipal}">
				<a href="../login/">Login</a>
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
						<dd><a href="../search#prospect_id=${prospect.ID}">${prospect.name}</a></dd>
					</dl>
					<c:if test="${!empty prospect.altNames}">
					<dl>
						<dt>Alternative Name(s)</dt>
						<dd>${prospect.altNames}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty prospect.ARDF}">
					<dl>
						<dt>ARDF Number</dt>
						<dd><a href="http://mrdata.usgs.gov/ardf/show-ardf.php?ardf_num=${prospect.ARDF}">${prospect.ARDF}</a></dd>
					</dl>
					</c:if>
					<c:if test="${!empty boreholes}">
					<dl>
						<dt>Boreholes</dt>
						<dd><c:forEach items="${boreholes}" var="borehole" varStatus="stat">${stat.count gt 1 ? ", " : ""}<a href="../borehole/${borehole.ID}">${borehole.name}</a></c:forEach></dd>
					</dl>
					</c:if>
					<c:if test="${!empty quadrangles}">
					<dl>
						<dt>Quadrangle</dt>
						<dd>
						<c:forEach items="${quadrangles}" var="quadrangle" varStatus="stat">
							${stat.count gt 1 ? ", " : ""} <a href="../search#quadrangle_id=${quadrangle.ID}">${quadrangle.name}</a>
						</c:forEach>
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
				</div>

				<div style="clear:both"></div>

				<c:set var="inventory_count" value="0" />
				<c:forEach items="${keywords}" var="keyword">
					<c:set var="inventory_count" value="${inventory_count + keyword.count}" />
				</c:forEach>

				<ul id="tabs" class="nav nav-tabs" style="width: 100%; margin-top: 15px">
					<li class="active"><a href="#inventory">Inventory <span class="badge">${inventory_count}</span></a></li>
					<li><a href="#files">Files <span class="badge">${fn:length(prospect.files)}</span></a></li>
				</ul>

				<div id="tab-inventory">
					<div class="container" id="keyword_container">
						<c:if test="${!empty keywords}">
						<c:set var="link" value="prospect:\"${prospect.name}\"" />
						<div>
							<span class="label label-info">Keywords</span>
							<ul class="nav nav-pills" id="keywords">
							<c:forEach items="${keywords}" var="keyword">
							<c:set var="kws" value="&keyword=${fn:join(fn:split(keyword.keywords, ','), '&keyword=')}" />
							<li><a href="../search#q=${fn:escapeXml(link)}${kws}">${fn:join(fn:split(keyword.keywords, ','), ' > ')} <span class="badge">${keyword.count}</span></a></li>
							</c:forEach>
							</ul>
						</div>
						</c:if>
					</div>
				</div>

				<div id="tab-files" class="hidden">
					<div id="filelist">
					<c:forEach items="${prospect.files}" var="file">
						<a href="../file/${file.ID}" title="${empty file.description ? file.filename : file.description} (${file.sizeString})">
							<img src="../img/icons/${file.simpleType}.png"><br>${file.filename}
						</a>
					</c:forEach>
					</div>

					<c:if test="${not empty pageContext.request.userPrincipal}">
					<br>

					<form action="../upload" method="POST" enctype="multipart/form-data">
						<input type="hidden" name="prospect_id" value="${prospect.ID}">
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

			</div>
		</div>
		<script src="../leaflet/leaflet.js"></script>
		<script src="../leaflet/leaflet.mouseposition.js"></script>
		<script src="../js/utility.js"></script>
		<script>
			function init()
			{
				initTabs();
				
				var geojson = null;
				var gj_el = document.getElementById('geojson');
				if(gj_el != null && gj_el.value.length > 0){
					geojson = JSON.parse(gj_el.value);
					initSimpleMap(geojson, '#76ff7a');
				}
			}
		</script>
	</body>
</html>
