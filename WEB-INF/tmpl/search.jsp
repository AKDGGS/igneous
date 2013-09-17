<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet" media="screen">
		<link href="${pageContext.request.contextPath}/css/igneous${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<!--[if lt IE 9]>
		<script src="${pageContext.request.contextPath}/js/html5shiv.js"></script>
		<script src="${pageContext.request.contextPath}/js/respond.min.js"></script>
		<![endif]-->
		<style>
			.row label { margin: 0; }
			.pagination { margin: 0; vertical-align: middle; }
		</style>
	</head>
	<body>
		<input type="hidden" name="start" id="start" value="0">

		<div class="navbar navbar-default navbar-static-top">
			<div class="container">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</button>
					<a class="navbar-brand" href="#">Geologic Materials Center</a>
				</div>
				<div class="navbar-collapse collapse">
					<form class="navbar-form navbar-right">
						<div class="form-group">
							<input type="text" tabindex="1" placeholder="Search inventory" class="form-control input-fat" id="q">
							<button type="submit" class="btn btn-primary" id="search"><span class="glyphicon glyphicon-search"></span> Search</button>
						</div>
					</form>
				</div>
			</div>
		</div>
		
		<div class="container">
			<div class="panel panel-info" id="inventory_panel">
				<div class="panel-heading">
					<div class="row">
						<div class="col-md-2">Inventory Search</div>
						<div class="col-md-2 col-md-offset-2">
							<div class="pull-right">
								<label for="max">Showing</label>
							</div>
						</div>
						<div class="col-md-2">
							<div class="pull-right">
								<label for="sort">Sort by</label>
							</div>
						</div>
						<div class="col-md-4">
							<div class="pull-right">
								Displaying <span id="page_start"></span>
								- <span id="page_end"></span> of
								<span id="page_found"></span>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-md-2 col-md-offset-4">
							<div class="pull-right">
								<select name="max" id="max">
									<option value="10">10</option>
									<option value="25" selected="selected">25</option>
									<option value="50">50</option>
									<option value="100">100</option>
									<option value="250">250</option>
									<option value="500">500</option>
									<option value="1000">1000</option>
								</select>
							</div>
						</div>
						<div class="col-md-2">
							<div class="pull-right">
								<select name="sort" id="sort">
									<option value="0">Best Match</option>
									<option value="1">Branch</option>
								</select>
							</div>
						</div>
						<div class="col-md-4">
							<div class="pull-right">
								<ul class="pagination pagination-sm" id="page_control"></ul>
							</div>
						</div>
					</div>
				</div>
				<div class="panel-body">
					<p id="inventory_message"></p>
					<table id="inventory_table" class="table table-striped table-condensed" style="margin-bottom: 0">
						<thead>
							<tr>
								<th>ID</th>
								<th>Related</th>
								<th>Sample</th>
								<th>Core</th>
								<th>Box</th>
								<th>Set</th>
								<th>Top</th>
								<th>Bottom</th>
								<th>Diameter</th>
								<th>Branch</th>
								<th>Collection</th>
								<th>Keywords</th>
								<th>Location</th>
							</tr>
						</thead>
						<tbody id="inventory_body"></tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="modal" id="error_modal" role="dialog" aria-labelledby="Error" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
						<h4 class="modal-title">Query Error</h4>
					</div>
					<div class="modal-body" id="error_body"></div>
					<div class="modal-footer">
						<button type="button" data-dismiss="modal" class="btn btn-primary">Okay</button>
					</div>
				</div>
			</div>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
		<script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
		<script src="${pageContext.request.contextPath}/js/search${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
	</body>
</html>
