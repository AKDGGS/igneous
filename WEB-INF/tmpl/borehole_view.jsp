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
	</head>
	<body>
		<div class="container">
			<div class="row">
				<div class="col-lg-6" id="overview">Loading ..</div>
			</div>
			<div class="row">
				<div class="col-lg-6" id="summary"></div>
			</div>
		</div>

		<div class="modal" id="error_modal" role="dialog" aria-labelledby="Error" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
						<h4 class="modal-title">Retrieval Error</h4>
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
		<script src="${pageContext.request.contextPath}/js/boreholeview${initParam['dev_mode'] == true ? '' : '-min'}.js"></script>
		<script>$(function(){ load(${id}); });</script>
	</body>
</html>
