<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			th { text-align: left; }
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
			</div>
		</div>

		<div class="container">
			<h2>Search Help</h2>

			<h3>The Search Bar</h3>
			<table>
				<thead>
					<tr>
						<th>Field</th>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>top</td>
						<td>Interval Top (numeric)</td>
					</tr>
					<tr>
						<td>bottom</td>
						<td>Interval Top (numeric)</td>
					</tr>
					<tr>
						<td>sample</td>
						<td>Sample Number (string)</td>
					</tr>
					<tr>
						<td>core</td>
						<td>Core Number (string)</td>
					</tr>
					<tr>
						<td>set</td>
						<td>Set Number (string)</td>
					</tr>
					<tr>
						<td>box</td>
						<td>Box Number (string)</td>
					</tr>
					<tr>
						<td>collection</td>
						<td>Collection (string)</td>
					</tr>
					<tr>
						<td>project</td>
						<td>Project (string)</td>
					</tr>
					<tr>
						<td>barcode</td>
						<td>Barcode (string)</td>
					</tr>
					<tr>
						<td>location</td>
						<td>Location (string)</td>
					</tr>
					<tr>
						<td>well</td>
						<td>Well Name (string)</td>
					</tr>
					<tr>
						<td>wellnumber</td>
						<td>Well Number (string)</td>
					</tr>
					<tr>
						<td>api</td>
						<td>Well API Number (string)</td>
					</tr>
					<tr>
						<td>borehole</td>
						<td>Borehole Name (string)</td>
					</tr>
					<tr>
						<td>prospect</td>
						<td>Prospect Name (string)</td>
					</tr>
					<tr>
						<td>ardf</td>
						<td>ARDF Number (string)</td>
					</tr>
					<tr>
						<td>outcrop</td>
						<td>Outcrop Name (string)</td>
					</tr>
					<tr>
						<td>outcropnumber</td>
						<td>Outcrop Number (string)</td>
					</tr>
					<tr>
						<td>shotline</td>
						<td>Shotline Name (string)</td>
					</tr>
					<tr>
						<td>keyword</td>
						<td>Keyword Name (string)</td>
					</tr>
					<tr>
						<td>quadrangle</td>
						<td>Quadrangle Name (string)</td>
					</tr>
				</tbody>
			</table>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
		<script>
			$(function(){
				$('#search').click(function(){
					window.location.href = '${pageContext.request.contextPath}/search#q=' + $('#q').val();
				});

				$('#q').keypress(function(e){
					if(e.keyCode === 13){ $('#search').click(); }
				});

				$('#help').click(function(){
					window.location.href = '${pageContext.request.contextPath}/help';
				});
			});
		</script>
	</body>
</html>
