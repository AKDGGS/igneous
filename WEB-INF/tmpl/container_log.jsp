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
		<link href="css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			.barcode a div { margin-left: 5px; font-size: 11px; font-weight: bold; }
		</style>
	</head>
	<body>
		<div class="navbar">
			<div class="navbar-head">
				<a href="search">Geologic Materials Center</a>
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
			<h3>Move Log</h3>
			<form method="get" action="container_log.html">
				<label for="start">Start Date: </label>
				<input type="text" id="start" name="start" size="15" tabindex="2" value="${fn:escapeXml(start)}">

				<label for="end">End Date: </label>
				<input type="text" id="end" name="end" size="15" tabindex="3" value="${fn:escapeXml(end)}">

				<button class="btn btn-primary" id="query">
					<span class="glyphicon glyphicon-book"></span> Query
				</button>
			</form>
		</div>

		<c:if test="${!empty logs}">
		<div class="container">
			<table class="datagrid datagrid-info">
				<thead>
					<tr>
						<th>Time/Date</th>
						<th>Source</th>
						<th>Inventory</th>
						<th>Destination</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${logs}" var="log">
					<tr>
						<td><fmt:formatDate pattern="M/d/yyyy HH:mm:ss" value="${log.log_date}" /></td>
						<td>${log.src}</td>
						<td class="barcode">
							
							<a href="inventory/${log.inventory_id}">${empty log.barcode ? 'NO BARCODE' : log.barcode}</a>
						</td>
						<td>${log.dst}</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>
		</c:if>

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

		<script src="js/jquery-1.10.2.min.js"></script>
		<script>
			$(function(){
				$('#search').click(function(){
					window.location.href = 'search#q=' + $('#q').val();
				});

				$('#help').click(function(){
					window.location.href = 'help';
				});

				$('#q').keypress(function(e){
					if(e.keyCode === 13){ $('#search').click(); }
				});

				$('#start, #end').keypress(function(e){
					if(e.keyCode === 13){ $('#query').click(); }
				});

				$('#query').click(function(){
					$('form').get(0).submit();
				});
			});
		</script>
	</body>
</html>
