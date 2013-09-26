<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style> #inventory_table { display: none; } </style>
	</head>
	<body>
		<div class="navbar">
			<div class="navbar-head">
				<a href="#">Geologic Materials Center</a>
			</div>

			<div class="navbar-form">
				<input type="text" id="q" name="q" tabindex="1">
				<button id="search">
					<span class="glyphicon glyphicon-search"></span> Search
				</button>
			</div>
		</div>

		<div class="container">
			<table class="datagrid datagrid-info space-top" id="inventory_table">
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
								<option value="1">Branch</option>
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
						<th>Top /<br>Bottom</th>
						<th>Diameter</th>
						<th>Branch /<br>Keywords</th>
						<th>Collection</th>
						<th>Location</th>
					</tr>
				</thead>
				<tbody id="inventory_body"></tbody>
			</table>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
		<script src="${pageContext.request.contextPath}/js/search${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
	</body>
</html>
