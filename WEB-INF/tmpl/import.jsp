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
			fieldset { margin-top: 20px; text-align: center; }
			#file { width: 50%; }
			#results { margin: 8px 4px; }
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
			<fieldset>
				<legend>Import Tool</legend>

				<form action="import.html" method="POST" enctype="multipart/form-data">
					<select name="destination">
						<option value="borehole">Into Borehole</option>
						<option selected="selected" value="inventory">Into Inventory</option>
						<option value="outcrop">Into Outcrop</option>
						<option value="well">Into Well</option>
					</select>
					<input type="file" id="file" name="file">
					<input type="submit" value="Import">
				</form>
			</fieldset>

			<c:if test="${!empty results}">
				<div id="results">${results}</div>
			</c:if>
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
