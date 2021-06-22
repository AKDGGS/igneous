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
		<link rel="stylesheet" href="css/apptmpl.min.css">
		<link rel="stylesheet" href="leaflet/leaflet.css" />
		<style>
			.apptmpl-container { min-width: 800px !important; }
			.apptmpl-content { font-family: 'Georgia, serif'; }
			#list a, #controls a { color: #428bca; text-decoration: none; }
			#list a:hover, #list a:focus, #controls a:hover, #controls a:focus { color: #2a6496; text-decoration: underline; }
			#map { height: 450px; }
			#advancedcontrols div { margin: 8px 0; }
			.popupCustom, .leaflet-popup-content-wrapper, .leaflet-popup-scrolled{
				border: none;
			}
			.circle-with-txt{
				position: relative;
				color: white;
				font-size: 12px;
				font-weight:bold;
				width: 40px;
				height: 40px;		
			}
			.txt{
				margin: 0;
				position: absolute;
				top:50%;
				left: 50%;
				-ms-transform: translate(-50%, -50%);
				transform: translate(-50%, -50%);
				font-size: 16px
				}
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
				<a href="import.html">Data Importer</a>
				<a href="logout/">Logout</a>
				</c:if>
				<c:if test="${empty pageContext.request.userPrincipal}">
				<a href="login/">Login</a>
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
				<a href="search">Wells</a>
			</div>

			<div class="apptmpl-content">
				<div id="map"></div>
			</div>

			<script id="tmpl-well-popup" type="x-tmpl-mustache">
				<div>
					{{#well.name}}<div><b>Name:</b> <a href = "{{nameURL}}"> {{well.name}}{{#well.ID}} - {{well.ID}}{{/well.ID}}</a></div>{{/well.name}}
					{{#well.APINumber}}<div><b>API Number:</b> {{well.APINumber}}</div>{{/well.APINumber}}
					{{#well.wellNumber}}<div><b>Well Number:</b> {{well.wellNumber}}</div>{{/well.wellNumber}}
					{{#well.measuredDepth}}<div><b>Measured Depth:</b> {{well.measuredDepth}} {{#well.unit.abbr}}{{well.unit.abbr}}{{/well.unit.abbr}}</div>{{/well.measuredDepth}}
					{{#well.verticalDepth}}<div><b>Verical Depth:</b> {{well.verticalDepth}} {{#well.unit.abbr}}{{well.unit.abbr}}{{/well.unit.abbr}}</div>{{/well.verticalDepth}}
					{{#well.elevation}}<div><b>Elevation:</b> {{well.elevation}} {{#well.unit.abbr}}{{well.unit.abbr}}{{/well.unit.abbr}}</div>{{/well.elevation}}
					{{#well.onshore}}<div><b>Onshore:</b> {{well.onshore}}</div>{{/well.onshore}}
					{{#well.federal}}<div><b>Federal:</b> {{well.federal}}</div>{{/well.federal}}
					{{#well.permitStatus}}<div><b>Permit Status:</b> {{well.permitStatus}}</div>{{/well.permitStatus}}
					{{#well.permitNumber}}<div><b>Permit Number:</b> {{well.permitNumber}}</div>{{/well.permitNumber}}
					{{#well.completionStatus}}<div><b>Completion Status:</b> {{well.completionStatus}}</div>{{/well.completionStatus}}
					{{#well.completionDate}}<div><b>Compeletion Date:</b> {{well.completionDate}}</div>{{/well.completionDate}}
					{{#well.spudDate}}<div><b>Spud Date:</b> {{well.spudDate}}</div>{{/well.spudDate}}
					<div><br/><b>Keywords:</b></div>
					{{#keywords}}<div style="padding-left: 10px"><a href = "{{keyword_url}}"> {{keywords}} </a> {{count}} </div>{{/keywords}}
				</div>
			</script>

			<script src="leaflet/leaflet.js"></script>
			<script src="js/mustache-2.2.0.min.js"></script>
			<script src="js/wells.js"></script>
		</div>
	</body>
</html>
