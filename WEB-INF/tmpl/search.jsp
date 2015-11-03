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
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			.barcode, { white-space: nowrap; }
			.quality { font-size: 80%; }
			.quality span { display: inline-block; padding: 0 5px; margin: 2px 0 0 0; white-space: nowrap; background-color: red; color: white; border-radius: 4px; }
			.quality span.good { background-color: green; }
			.tbl_container { padding: 0; margin: 0; width: 100%; border-collapse: collapse; }
			.tbl_container td, .tbl_container tr { padding: 0px !important; margin: 0px !important; }

			#inventory_container { display: none; }
			#map { width: 100%; height: 450px; }
			#advanced_cell { width: 265px; display: none; padding: 4px 8px; vertical-align: top; }
			#advanced_cell label { display: block; padding: 0px; }
			#advanced_cell select { padding: 0px; margin: 0px 0px 10px 0px; max-width: 235px; }
			#advanced_cell span { font-size: 14px; }
			#advanced_container { height: 450px; overflow-y: auto; overflow-x: hidden; padding: 0px 8px; margin: 0px; }

			label { font-size: 14px; font-weight: bold; }
			.navbar { white-space: nowrap; }
			.datagrid thead td { padding: 4px !important; }
			th { white-space: nowrap; font-size: 85%; }

			@media print {
				* { font-family: 'Georgia, serif'; font-size: 14px; }
				html, body, table, .container { margin: 0px; }
				.nowrap { white-space: nowrap; }
				.noprint, .navbar { display: none; }
				table { border-collapse: collapse; page-break-inside: auto; }
				tr { page-break-inside: avoid; page-break-after: auto; }
				tr:nth-child(odd) { background-color: #eee; }
				th { vertical-align: bottom; text-align: left; }
				td { vertical-align: top; }
				td, th { padding: 0px 4px; }
				a { color: black; text-decoration: none; }
			}
		</style>
	</head>
	<body>
		<div class="navbar">
			<div class="navbar-head">
				<a href="${pageContext.request.contextPath}/">Geologic Materials Center</a>
			</div>

			<div class="navbar-form">
				<input type="text" id="q" name="q" tabindex="1">
				<button class="btn btn-primary" id="search">
					<span class="glyphicon glyphicon-search"></span> Search
				</button>
				<button class="btn btn-info" id="help">
					<span class="glyphicon glyphicon-question-sign"></span>
				</button>
				<button class="btn btn-info" id="advanced">
					<span class="glyphicon glyphicon-list"></span> Advanced
				</button>
			</div>
		</div>

		<div class="container noprint">
			<table class="tbl_container">
				<tr>
					<td>
						<div id="map"></div>
					</td>
					<td id="advanced_cell">
						<div id="advanced_container">
							<label for="mining_district_id">Mining District</label>
							<select size="5" multiple="multiple" name="mining_district_id" id="mining_district_id"></select>

							<label for="keyword_id">Keyword</label>
							<select size="5" multiple="multiple" name="keyword_id" id="keyword_id"></select>

							<label for="quadrangle_id">Quadrangle</label>
							<select size="5" multiple="multiple" name="quadrangle_id" id="quadrangle_id"></select>

							<label for="prospect_id">Prospect</label>
							<select size="5" multiple="multiple" name="prospect_id" id="prospect_id"></select>

							<label for="collection_id">Collection</label>
							<select size="5" multiple="multiple" name="collection_id" id="collection_id"></select>

							<label for="top">Interval</label>
							<span>Top</span> <input type="text" size="5" name="top" id="top" />
							<span>Bottom</span> <input type="text" size="5" name="bottom" id="bottom" />
						</div>
					</td>
				</tr>
			</table>
		</div>

		<div id="inventory_container" class="container">
			<table class="datagrid datagrid-info"> 
				<thead>
					<tr class="noprint">
						<td colspan="13" style="text-align: right">
							<input type="hidden" name="start" id="start" value="0" />

							Displaying <span id="page_start"></span>
							- <span id="page_end"></span> of
							<span id="page_found"></span>

							<span class="spacer">|</span>

							<a id="pdf" href="#pdf">PDF</a> /
							<a id="csv" href="#csv">CSV</a>
						
							<span class="spacer">|</span>

							<ul class="pagination" id="page_control"></ul>
						</td>
					</tr>
					<tr class="noprint">
						<td colspan="13" style="text-align: right">
							<label for="sort">Sort by</label>
							<c:forEach begin="0" end="1">
							<select name="sort">
								<option value="0">Best Match</option>
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
								<option value="0">Asc</option>
								<option value="1">Desc</option>
							</select>
							</c:forEach>

							<span class="spacer">|</span>

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

						</td>
					</tr>
					<tr>
						<th class="noprint">ID</th>
						<th>Related</th>
						<th>Sample</th>
						<th>Box /<br/>Set</th>
						<th>Core No /</br>Diameter</th>
						<th class="al-r">Top /<br>Bottom</th>
						<th>Keywords</th>
						<th>Collection</th>
						<th>Barcode</th>
						<th>Location /<br>Quality</th>
					</tr>
				</thead>
				<tbody id="inventory_body"></tbody>
			</table>
		</div>

		<div class="container" style="text-align: right; margin-top: 20px;">
			<b>Other Tools:</b>
			[<a href="container_log.html">Move Log</a>]
			[<a href="quality_report.html">Quality Assurance</a>]
			[<a href="audit_report.html">Audit</a>]
			<c:if test="${not empty pageContext.request.userPrincipal}">
				<c:if test="${pageContext.request.isUserInRole('admin')}">
				[<a href="import.html">Data Importer</a>]
				</c:if>
			</c:if>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
		<script type="text/javascript" src="https://maps.google.com/maps/api/js?v=3.7&sensor=false"></script>
		<script src="${pageContext.request.contextPath}/ol/2.13.1/OpenLayers.js"></script>
		<script src="${pageContext.request.contextPath}/js/util${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
		<script src="${pageContext.request.contextPath}/js/search${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
	</body>
</html>
