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
			<c:forEach items="${criticals}" var="critical">
				<div class="result">${descriptions[critical.key]} :
				<c:choose>
					<c:when test="${critical.value > 0}">
					<span class="crit">CRITICAL</span>
					(<a href="#${critical.key}" class="expand">${critical.value}</a>)
					</span>
					</c:when>

					<c:otherwise>
					<span class="ok">PASSED</span>
					</c:otherwise>
				</c:choose>
				</div>
			</c:forEach>

			<c:forEach items="${warnings}" var="warning">
				<div class="result">${descriptions[warning.key]} :
				<c:choose>
					<c:when test="${warning.value > 0}">
					<span class="warn">WARNING</span>
					(<a href="#${warning.key}" class="expand">${warning.value}</a>)
					</span>
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
					var tables = $(this).parent().find('table');
					if(tables.length > 0){ tables.remove(); }
					else {

						var dest = $(this).parent().get(0);
						var data = $(this).attr('href').substring(1);

						$.ajax({
							url: 'quality.html',
							dataType: 'json',
							data: { 'detail': data },
							type: 'POST',
							success: function(json){
								var table = document.createElement('table');
								var thead = document.createElement('thead');
								var tr = document.createElement('tr');
								var th = document.createElement('th');
								th.appendChild(document.createTextNode('ID'));
								tr.appendChild(th);

								th = document.createElement('th');
								th.appendChild(document.createTextNode('Description'));
								tr.appendChild(th);

								thead.appendChild(tr);
								table.appendChild(thead);

								var tbody = document.createElement('tbody');
								for(var i in json){
									tr = document.createElement('tr');

									var td = document.createElement('td');
									td.className = 'nowrap';
									td.appendChild(document.createTextNode(json[i]['id']));
									tr.appendChild(td);

									td = document.createElement('td');
									td.appendChild(document.createTextNode(json[i]['desc']));
									tr.appendChild(td);

									tbody.appendChild(tr);
								}
								table.appendChild(tbody);
								dest.appendChild(table);
							}
						});
					}

					e.preventDefault();
					return false;
				});
			});
		</script>
	</body>
</html>
