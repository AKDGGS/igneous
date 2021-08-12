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

			.notehd { color: #777; }
			#tab-notes > div:not(:first-child) { margin-top: 30px; }
		</style>
	</head>
	<body>
		<div class="soa-apptmpl-header">
			<div class="soa-apptmpl-header-top">
				<a class="soa-apptmpl-logo" title="The Great State of Alaska" href="http://alaska.gov"></a>
				<a class="soa-apptmpl-logo-dggs" title="The Division of Geological &amp; Geophysical Surveys" href="http://dggs.alaska.gov"></a>
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
				<a href="http://alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">State of Alaska</span>
					<span class="soa-apptmpl-breadcrumb-sm">Alaska</span>
				</a>
				|
				<a href="http://dnr.alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">Natural Resources</span>
					<span class="soa-apptmpl-breadcrumb-sm">DNR</span>
				</a>
				|
				<a href="http://dggs.alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">Geological &amp; Geophysical Surveys</span>
					<span class="soa-apptmpl-breadcrumb-sm">DGGS</span>
				</a>
				|
				<a href="http://dggs.alaska.gov/gmc/">
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
				<dl>
					<dt>Shotline Name</dt>
					<dd>${shotline.name}</dd>
				</dl>
				<c:if test="${!empty shotline.altNames}">
				<dl>
					<dt>Alternative Shotline Name(s)</dt>
					<dd>${shotline.altNames}</dd>
				</dl>
				</c:if>
				<c:if test="${!empty shotline.year}">
				<dl>
					<dt>Year</dt>
					<dd>${shotline.year}</dd>
				</dl>
				</c:if>
				<c:if test="${!empty shotline.remark}">
				<dl>
					<dt>Remarks</dt>
					<dd>${shotline.remark}</dd>
				</dl>
				</c:if>
				<c:if test="${!empty shotline.shotpoints}">
					<c:set var="sp_min" value="" />
					<c:set var="sp_max" value="" />
					<c:forEach items="${shotline.shotpoints}" var="shotpoint">
						<c:if test="${!empty shotpoint.number}">
							<c:if test="${empty sp_max || shotpoint.number > sp_max}">
								<c:set var="sp_max" value="${shotpoint.number}" />
							</c:if>
							<c:if test="${empty sp_min || shotpoint.number < sp_min}">
								<c:set var="sp_min" value="${shotpoint.number}" />
							</c:if>
						</c:if>
					</c:forEach>
				</c:if>
				<c:if test="${!empty sp_min && !empty sp_max}">
				<dl>
					<dt>Shotpoints</dt>
					<dd><fmt:formatNumber value="${sp_min}" /> - <fmt:formatNumber value="${sp_max}" /></dd>
				</dl>
				</c:if>
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
				<li><a href="#urls">URLs <span class="badge">${fn:length(shotline.URLs)}</span></a></li>
				<c:if test="${not empty pageContext.request.userPrincipal}">
				<li><a href="#notes">Notes <span class="badge">${fn:length(shotline.notes)}</span></a></li>
				</c:if>
			</ul>

			<div id="tab-inventory">
				<div class="container" id="keyword_container">
					<c:if test="${!empty keywords}">
					<c:set var="link" value="shotline:\"${shotline.name}\"" />
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
				<c:forEach items="${shotline.URLs}" var="url" varStatus="stat">
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

			<c:if test="${not empty pageContext.request.userPrincipal}">
			<div id="tab-notes" class="hidden">
				<c:forEach items="${shotline.notes}" var="note" varStatus="stat">
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
				initSimpleMap(geojson, '#ed2939');
			}
		</script>
	</body>
</html>
