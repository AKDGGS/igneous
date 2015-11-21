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
		<link href="../css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			.barcode { min-width: 205px; }
			.barcode div { margin-left: 5px; font-size: 11px; font-weight: bold; }
			#inventory_container { display: none; }
			#keyword_container a { margin: 2px 0px 0px 2px; }
			#keyword_container .active { box-shadow: none !important; background-color: transparent !important; }

			.half-left { width: 50%; }
			.half-right { width: 50%; float: right; margin: 0px 0px 0px auto; }

			#map { width: 100%; height: 300px; background-color: black; margin: 0px; }

			dd a { white-space: nowrap; }
			dl { display: table; margin: 8px 4px; }
			dt, dd { display: table-cell; }
			dt { width: 160px; }
			dd { margin: 0px; }

			pre { margin: 0px; }
			.notehd { color: #777; }
			#tab-notes > div:not(:first-child) { margin-top: 30px; }
		</style>
	</head>
	<body>
		<div class="navbar">
			<div class="navbar-head">
				<a href="../search">Geologic Materials Center</a>
			</div>

			<div class="navbar-form">
				<input type="text" id="q" name="q" tabindex="1">
				<button class="btn btn-primary" id="search">
					<span class="glyphicon glyphicon-search"></span> Search
				</button>
			</div>
		</div>

		<div class="container" id="overview_container">
			<div class="half-right">
				<div id="map"></div>
			</div>

			<div class="half-left">
				<c:if test="${!empty borehole.prospect}">
				<dl>
					<dt>Prospect Name</dt>
					<dd><a href="../search#prospect_id=${borehole.prospect.ID}">${borehole.prospect.name}</a></dd>
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
					<dd><fmt:formatNumber value="${borehole.measuredDepth}" /> <c:if test="${!empty borehole.measuredDepthUnit}">&nbsp;${borehole.measuredDepthUnit.abbr}</c:if></dd>
				</dl>
				</c:if>
				<c:if test="${!empty borehole.elevation}">
				<dl>
					<dt>Elevation</dt>
					<dd><fmt:formatNumber value="${borehole.elevation}" /> <c:if test="${!empty borehole.elevationUnit}">&nbsp;${borehole.elevationUnit.abbr}</c:if></dd>
				</dl>
				</c:if>
				<c:if test="${!empty quadrangles}">
				<dl>
					<dt>Quadrangle</dt>
					<dd><c:forEach items="${quadrangles}" var="quadrangle" varStatus="stat">${stat.count gt 1 ? ", " : ""}<a href="../search#quadrangle_id=${quadrangle.ID}">${quadrangle.name}</a></c:forEach>
					</dd>
				</dl>
				</c:if>
				<dl>
					<dt>Onshore</dt>
					<dd><span title="${borehole.onshore ? 'true' : 'false'}" class="glyphicon glyphicon-${borehole.onshore ? 'ok' : 'remove'}"></span></dd>
				</dl>
			</div>
		</div>

		<div style="clear:both"></div>

		<c:set var="inventory_count" value="0" />
		<c:forEach items="${keywords}" var="keyword">
			<c:set var="inventory_count" value="${inventory_count + keyword.count}" />
		</c:forEach>

		<ul id="tabs" class="nav nav-tabs" style="width: 100%; margin-top: 15px">
			<li class="active"><a href="#organizations">Organizations <span class="badge">${fn:length(borehole.organizations)}</span></a></li>
			<li><a href="#notes">Notes <span class="badge">${fn:length(borehole.notes)}</span></a></li>
			<li><a href="#inventory">Inventory <span class="badge">${inventory_count}</span></a></li>
			<li><a href="#urls">URLs <span class="badge">${fn:length(borehole.URLs)}</span></a></li>
			<li><a href="#files">Files</a></li>
		</ul>

		<div id="tab-organizations">
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

		<div id="tab-notes" class="hidden">
			<c:forEach items="${borehole.notes}" var="note" varStatus="stat">
			<div class="container">
				<div class="notehd"><fmt:formatDate pattern="M/d/yyyy" value="${note.date}"/>, ${note.type.name} (${note.username}, ${note.isPublic ? 'public' : 'private'})</div>
				<pre>${fn:escapeXml(note.note)}</pre>
			</div>
			</c:forEach>
		</div>

		<div id="tab-inventory" class="hidden">
			<div class="container" id="keyword_container">
				<c:if test="${!empty keywords}">
				<div>
					<span class="label label-info">Keywords</span>
					<ul class="nav nav-pills" id="keywords">
					<c:forEach items="${keywords}" var="keyword">
					<li><a href="#" data-keyword-id="${keyword.ids}">${keyword.keywords} <span class="badge">${keyword.count}</span></a></li>
					</c:forEach>
					</ul>
				</div>
				</c:if>
			</div>

			<div id="inventory_container" class="container">
				<table class="datagrid datagrid-info"> 
					<thead>
						<tr>
							<td colspan="13" style="text-align: right">
								<input type="hidden" name="borehole_id" id="borehole_id" value="${borehole.ID}">
								<input type="hidden" name="wkt" id="wkt" value="${wkt}">
								<input type="hidden" name="start" id="start" value="0">
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

								<label for="sort">Sort by</label>
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

								<span class="spacer">|</span>

								Displaying <span id="page_start"></span>
								- <span id="page_end"></span> of
								<span id="page_found"></span>

								<span class="spacer">|</span>

								<ul class="pagination" id="page_control"></ul>
							</td>
						</tr>
						<tr>
							<th>ID</th>
							<th>Box /<br>Set</th>
							<th>Top /<br>Bottom</th>
							<th>Keywords</th>
							<th>Collection</th>
							<th>Barcode</th>
							<th>Location</th>
						</tr>
					</thead>
					<tbody id="inventory_body"></tbody>
				</table>
			</div>
		</div>

		<div id="tab-files" class="hidden"></div>

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

		<script src="../js/jquery-1.10.2.min.js"></script>
		<script type="text/javascript" src="https://maps.google.com/maps/api/js?v=3.7&sensor=false"></script>
		<script src="../ol/2.13.1/OpenLayers.js"></script>
		<script src="../js/util${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
		<script src="../js/view${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
	</body>
</html>
