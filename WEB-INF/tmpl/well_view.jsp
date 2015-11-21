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
		<link href=",,/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
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
					<dd>${well.APINumber}</dd>
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
				<c:if test="${!empty quadrangles}">
				<dl>
					<dt>Quadrangle</dt>
					<dd><c:forEach items="${quadrangles}" var="quadrangle" varStatus="stat">${stat.count gt 1 ? ", " : ""}<a href="../search#quadrangle_id=${quadrangle.ID}">${quadrangle.name}</a></c:forEach>
					</dd>
				</dl>
				</c:if>
			</div>
		</div>

		<div style="clear:both"></div>

		<c:set var="inventory_count" value="0" />
		<c:forEach items="${keywords}" var="keyword">
			<c:set var="inventory_count" value="${inventory_count + keyword.count}" />
		</c:forEach>

		<ul id="tabs" class="nav nav-tabs" style="width: 100%; margin-top: 15px">
			<li class="active"><a href="#operators">Operators <span class="badge">${fn:length(well.operators)}</span></a></li>
			<li><a href="#notes">Notes <span class="badge">${fn:length(well.notes)}</span></a></li>
			<li><a href="#inventory">Inventory <span class="badge">${inventory_count}</span></a></li>
			<li><a href="#urls">URLs <span class="badge">${fn:length(well.URLs)}</span></a></li>
			<li><a href="#files">Files</a></li>
		</ul>

		<div id="tab-operators">
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

		<div id="tab-notes" class="hidden">
			<c:forEach items="${well.notes}" var="note" varStatus="stat">
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
								<input type="hidden" name="well_id" id="well_id" value="${well.ID}">
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

		<script src="../js/jquery-1.10.2.min.js"></script>
		<script type="text/javascript" src="https://maps.google.com/maps/api/js?v=3.7&sensor=false"></script>
		<script src="../ol/2.13.1/OpenLayers.js"></script>
		<script src="../js/util${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
		<script src="../js/view${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
	</body>
</html>
