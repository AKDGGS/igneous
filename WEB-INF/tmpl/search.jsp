<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			.barcode { min-width: 205px; }
			.barcode div { margin-left: 5px; font-size: 11px; font-weight: bold; }
			.tbl_container { padding: 0px; margin: 0px; width: 100%; border-collapse: collapse; }
			.tbl_container td, .tbl_container tr { padding: 0px; margin: 0px; }

			#inventory_container { display: none; }
			#map { width: 100%; height: 450px; }
			#spatial { width: 250px; display: none; padding: 4px 8px; vertical-align: top; }

			label { font-size: 14px; }
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
			</div>
		</div>

		<div class="container">
			<table class="tbl_container">
				<tr>
					<td>
						<div id="map"></div>
					</td>
					<td id="spatial">
						<label for="mining_district_id">Mining District</label>
						<select name="mining_district_id" id="mining_district_id">
							<option value="">None</option>
						</select>
					</td>
				</tr>
			</table>
		</div>

		<div id="inventory_container" class="container">
			<table class="datagrid datagrid-info"> 
				<thead>
					<tr>
						<td colspan="13" style="text-align: right">
							<input type="hidden" name="start" id="start" value="0" />
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
							<select name="sort" id="sort">
								<option value="0">Best Match</option>
								<option value="9">Barcode</option>
								<option value="10">Borehole</option>
								<option value="11">Box</option>
								<option value="1">Collection</option>
								<option value="2">Core Number</option>
								<option value="3">Location</option>
								<option value="12">Prospect</option>
								<option value="4">Set Number</option>
								<option value="5">Top</option>
								<option value="6">Bottom</option>
								<option value="7">Well Name</option>
								<option value="8">Well Number</option>
							</select>

							<select name="dir" id="dir">
								<option value="0">Ascending</option>
								<option value="1">Descending</option>
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
						<th>Related</th>
						<th>Sample</th>
						<th>Core</th>
						<th>Box</th>
						<th>Set</th>
						<th class="al-r">Top /<br>Bottom</th>
						<th>Diameter</th>
						<th>Keywords</th>
						<th>Collection</th>
						<th>Barcode</th>
						<th>Location</th>
					</tr>
				</thead>
				<tbody id="inventory_body"></tbody>
			</table>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
		<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3&sensor=false"></script>
		<script src="${pageContext.request.contextPath}/ol/2.13.1/OpenLayers.js"></script>
		<script src="${pageContext.request.contextPath}/js/util${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
		<script src="${pageContext.request.contextPath}/js/search${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
	</body>
</html>
