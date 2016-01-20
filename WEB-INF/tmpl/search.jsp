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
		<link rel="stylesheet" href="leaflet/leaflet.draw.css" />
		<link rel="stylesheet" href="leaflet/leaflet.mouseposition.css" />
		<link rel="stylesheet" href="leaflet/leaflet.searchcontrol.css" />
		<link rel="stylesheet" href="css/search.css" />
		<style>
			.apptmpl-container { min-width: 800px !important; }
			.apptmpl-content { font-family: 'Georgia, serif'; }
			.apptmpl-content a { color: #428bca; text-decoration: none; }
			.apptmpl-content a:hover, a:focus { color: #2a6496; text-decoration: underline; }
			#map { height: 450px; }
			#advancedcontrols div { margin: 8px 0; }
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
				<a href="logout/">Logout</a>
				</c:if>
				<c:if test="${empty pageContext.request.userPrincipal}">
				<a href="https://${pageContext.request.serverName}${pageContext.request.contextPath}/login/">Login</a>
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
				<div id="map"></div>
				<div id="controls">
					<input type="hidden" name="start" id="start" value="0" />
					<div>
						<label for="max">Showing</label>
						<select name="max" id="max">
							<option value="10">10</option>
							<option value="25" selected="selected">25</option>
							<option value="50">50</option>
							<option value="100">100</option>
							<option value="250">250</option>
							<option value="500">500</option>
							<option value="1000">1000</option>
						</select>

						<span class="spacer">|</span>

						<button id="btn-prev">Previous</button>
						Displaying <span id="pages"></span>
						<button id="btn-next">Next</button>
					</div>

					<div>
						<a id="pdf" href="#">PDF</a> / <a id="csv" href="#">CSV</a>

						<span class="spacer">|</span>

						<label for="sort">Sort by</label>
						<c:forEach begin="0" end="1">
						<select name="sort">
							<option value="0" selected="selected">Best Match</option>
							<option value="9">Barcode</option>
							<option value="10">Borehole</option>
							<option value="11">Box</option>
							<option value="1">Collection</option>
							<option value="2">Core Number</option>
							<option value="14">Keywords</option>
							<option value="3">Location</option>
							<option value="12">Prospect</option>
							<option value="13">Sample</option>
							<option value="4">Set Number</option>
							<option value="5">Top</option>
							<option value="6">Bottom</option>
							<option value="7">Well Name</option>
							<option value="8">Well Number</option>
						</select>
						<select name="dir">
							<option value="0" selected="selected">Asc</option>
							<option value="1">Desc</option>
						</select>
						</c:forEach>
					</div>
				</div>
				<div id="list"></div>
			</div>
		</div>
		<script id="tmpl-popup" type="x-tmpl-mustache">
			<div>
				<a href="inventory/{{ID}}">{{ID}}</a>
				{{#containerPath}} - {{containerPath}}{{/containerPath}}<br>
				{{#intervalTop}}{{intervalTop}} {{intervalUnit.abbr}}{{/intervalTop}}
				{{#intervalBottom}}{{#intervalTop}} - {{/intervalTop}}{{intervalBottom}} {{intervalUnit.abbr}}{{/intervalBottom}}
			</div>
			{{#boreholes}}
			<div>
				{{#prospect}}
				<div>Prospect: <a href="prospect/{{ID}}">{{name}}</a></div>
				{{/prospect}}
				Borehole: <a href="borehole/{{ID}}">{{name}}</a>
			</div>
			{{/boreholes}}
			{{#wells}}
			<div>
				Well: <a href="well/{{ID}}">{{name}}{{#wellNumber}} - {{wellNumber}}{{/wellNumber}}</a>
				{{#APINumber}}<div>API: {{APINumber}}</div>{{/APINumber}}
			</div>
			{{/wells}}
			{{#outcrops}}
			<div>
				Outcrop: <a href="outcrop/{{ID}}">{{name}}{{#number}} - {{number}}{{/number}}</a>
			</div>
			{{/outcrops}}
			{{#shotlines}}
			<div>
				Shotline: <a href="shotline/{{ID}}">{{name}}</a>
				{{#shotlineMax}}<div>Shotpoints: {{shotlineMin}} - {{shotlineMax}}</div>{{/shotlineMax}}
				{{#project}}<div>Project: {{name}}</div>{{/project}}
			</div>
			{{/shotlines}}
			<ul class="kw">{{#keywords}}<li>{{name}}</li>{{/keywords}}</ul>
		</script>
		<script id="tmpl-table" type="x-tmpl-mustache">
			<table class="results">
				<thead>
					<tr>
						<th>ID</th>
						<th>Related</th>
						<th>Sample /<br>Slide</th>
						<th>Box /<br>Set</th>
						<th>Core No /<br>Diameter</th>
						<th>Top /<br>Bottom</th>
						<th>Keywords</th>
						<th>Collection</th>
						<c:if test="${not empty pageContext.request.userPrincipal}">
						<th>Barcode</th>
						<Th>Location /<br>Quality</th>
						</c:if>
					</tr>
				</thead>
				<tbody>
					{{#list}}
					<tr class="{{#boreholes.0}}borehole {{/boreholes.0}}{{#wells.0}}well {{/wells.0}}{{#outcrops.0}}outcrop {{/outcrops.0}}{{#shotlines.0}}shotline {{/shotlines.0}}">
						<td><a href="inventory/{{ID}}">{{ID}}</a></td>
						<td>
							{{#boreholes}}
							<div>
								{{#prospect}}
								<div>Prospect: <a href="prospect/{{ID}}">{{name}}</a></div>
								{{/prospect}}
								Borehole: <a href="borehole/{{ID}}">{{name}}</a>
							</div>
							{{/boreholes}}
							{{#wells}}
							<div>
								Well: <a href="well/{{ID}}">{{name}}{{#wellNumber}} - {{wellNumber}}{{/wellNumber}}</a>
								{{#APINumber}}<div>API: {{APINumber}}</div>{{/APINumber}}
							</div>
							{{/wells}}
							{{#outcrops}}
							<div>
								Outcrop: <a href="outcrop/{{ID}}">{{name}}{{#number}} - {{number}}{{/number}}</a>
							</div>
							{{/outcrops}}
							{{#shotlines}}
							<div>
								Shotline: <a href="shotline/{{ID}}">{{name}}</a>
								{{#shotlineMax}}<div>Shotpoints: {{shotlineMin}} - {{shotlineMax}}</div>{{/shotlineMax}}
								{{#project}}<div>Project: {{name}}</div>{{/project}}
							</div>
							{{/shotlines}}
						</td>
						<td>
							{{sampleNumber}}
							{{#slideNumber}}<br>{{slideNumber}}{{/slideNumber}}
						</td>
						<td>
							{{boxNumber}}
							{{#setNumber}}<br>{{setNumber}}{{/setNumber}}
						</td>
						<td>
							{{coreNumber}}
							{{#coreDiameter}}<br>{{name}}{{^name}}{{diameter}} {{unit.abbr}}{{/name}}{{/coreDiameter}}
						</td>
						<td>
							{{#intervalTop}}{{intervalTop}} {{intervalUnit.abbr}}{{/intervalTop}}
							{{#intervalBottom}}<br>{{intervalBottom}} {{intervalUnit.abbr}}{{/intervalBottom}}
						</td>
						<td>
							<ul class="kw">{{#keywords}}<li>{{alias}}{{^alias}}{{name}}{{/alias}}</li>{{/keywords}}</ul>
						</td>
						<td>{{collection.name}}</td>
						<c:if test="${not empty pageContext.request.userPrincipal}">
						<td class="barcode">
							{{barcode}}{{^barcode}}{{altBarcode}}{{/barcode}}
						</td>
						<td class="quality">
							{{containerPath}}
							{{#qualities}}<div>{{#issues}}<span>{{.}}</span>{{/issues}}</div>{{/qualities}}
						</td>
						</c:if>
					</tr>
					{{/list}}
				</tbody>
			</table>
		</script>
		<script id="tmpl-advanced" type="x-tmpl-mustache">
			<div>
				<label for="prospect_id">Prospect</label>
				<select id="prospect_id" name="prospect_id" size="5" multiple="multiple" onchange="search()">
				{{#prospect}}
					<option value="{{ID}}">{{name}}</option>
				{{/prospect}}
				</select>
			</div>
			<div>
				<label for="top">Interval</label>
				Top: <input type="text" name="top" id="top" size="5">
				Bottom: <input type="text" name="bottom" id="bottom" size="5">
			</div>
			<div>
				<label for="keyword_id">Keywords</label>
				<select id="keyword_id" name="keyword_id" size="5" multiple="multiple" onchange="search()">
				{{#keyword}}
					<option value="{{ID}}">{{name}}{{#alias}} ({{alias}}){{/alias}}</option>
				{{/keyword}}
				</select>
			</div>
			<div>
				<label for="collection_id">Collection</label>
				<select id="collection_id" name="collection_id" size="5" multiple="multiple" onchange="search()">
				{{#collection}}
					<option value="{{ID}}">{{name}}</option>
				{{/collection}}
				</select>
			</div>
			<div>
				<label for="quadrangle_id">Quadrangle</label>
				<select id="quadrangle_id" name="quadrangle_id" size="5" multiple="multiple">
				{{#quadrangle}}
					<option data-geojson="{{geoJSON}}" value="{{ID}}">{{name}}</option>
				{{/quadrangle}}
				</select>
			</div>
			<div>
				<label for="mining_district_id">Mining District</label>
				<select id="mining_district_id" name="mining_district_id" size="5" multiple="multiple">
				{{#mining_district}}
					<option data-geojson="{{geoJSON}}" value="{{ID}}">{{name}}</option>
				{{/mining_district}}
				</select>
			</div>
		</script>
		<script src="leaflet/leaflet.js"></script>
		<script src="leaflet/leaflet.draw.js"></script>
		<script src="leaflet/leaflet.mouseposition.js"></script>
		<script src="leaflet/leaflet.searchcontrol.js"></script>
		<script src="js/mustache-2.2.0.min.js"></script>
		<script src="js/utility.js"></script>
		<script src="js/search.js"></script>
	</body>
</html>
