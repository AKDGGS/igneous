<%@
	page session="false"
%><%@
	taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"
%><%@
	taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			.ok { background-color: green; color: white; }
			.warn { background-color: yellow; }
			.crit { background-color: red; color: white; }
			.nowrap { white-space: nowrap; }
			.result table { display: none; }
			.result td { vertical-align: top; }
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
			<c:forEach items="${warnings}" var="warning">
				<div class="result">${warning.key} :
				<c:choose>
					<c:when test="${fn:length(warning.value) > 0}">
					<span class="warn">WARNING</span>
					(<a href="#" class="expand">${fn:length(warning.value)}</a>)
					</span>
					<table>
						<thead>
							<tr>
								<th colspan="2">${result.key}</td>
							</tr>
							<tr>
								<th>ID</th>
								<th>Description</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${warning.value}" var="src">
							<tr>
								<td class="nowrap">${src.id}</td>
								<td>${src.desc}</td>
							</tr>
							</c:forEach>
						</tbody>
					</table>
					</c:when>

					<c:otherwise>
					<span class="ok">PASSED</span>
					</c:otherwise>
				</c:choose>
				</div>
			</c:forEach>

			<c:forEach items="${criticals}" var="critical">
				<div class="result">${critical.key} :
				<c:choose>
					<c:when test="${fn:length(critical.value) > 0}">
					<span class="crit">CRITICAL</span>
					(<a href="#" class="expand">${fn:length(critical.value)}</a>)
					</span>
					<table>
						<thead>
							<tr>
								<th colspan="2">${result.key}</td>
							</tr>
							<tr>
								<th>ID</th>
								<th>Description</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${critical.value}" var="src">
							<tr>
								<td class="nowrap">${src.id}</td>
								<td>${src.desc}</td>
							</tr>
							</c:forEach>
						</tbody>
					</table>
					</c:when>

					<c:otherwise>
					<span class="ok">PASSED</span>
					</c:otherwise>
				</c:choose>
				</div>
			</c:forEach>

		</div>
		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
		<script>
			$(function(){
				$('.expand').click(function(e){
					$(this).parent().find('table').toggle();
					e.preventDefault();
					return false;
				});
			});
		</script>
	</body>
</html>
