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
		<title>Alaska Division of Geological &amp; Geophysical Surveys Geologic Materials Center</title>
		<meta charset="utf-8">
		<meta http-equiv="x-ua-compatible" content="IE=edge" >
		<link rel="stylesheet" href="css/apptmpl.min.css">
		<style>
			h2 { margin: 8px 0; }
			table { width: 100%; }
			th { text-align: left; }
			.loc { white-space: nowrap; }
		</style>
	</head>
	<body>
		<div class="apptmpl-container">
			<div class="apptmpl-goldbar">
				<a class="apptmpl-goldbar-left" href="http://alaska.gov"></a>
				<span class="apptmpl-goldbar-right"></span>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<a href="container_log.html">Move Log</a>
				<a href="quality_report.html">Quality Assurance</a>
				<a href="audit_report.html">Audit</a>
				<c:if test="${pageContext.request.isUserInRole('admin')}">
				<a href="import.html">Data Importer</a>
				</c:if>
				<a href="logout/">Logout</a>
				</c:if>
				<c:if test="${empty pageContext.request.userPrincipal}">
				<a href="login/">Login</a>
				</c:if>
				<a href="help">Search Help</a>
			</div>

			<div class="apptmpl-banner">
				<a class="apptmpl-banner-logo" href="http://dggs.alaska.gov"></a>
				<div class="apptmpl-banner-title">Geologic Materials Center Inventory</div>
				<div class="apptmpl-banner-desc">Alaska Division of Geological &amp; Geophysical Surveys</div>
			</div>

			<div class="apptmpl-breadcrumb">
				<a href="http://alaska.gov">State of Alaska</a> &gt;
				<a href="http://dnr.alaska.gov">Natural Resources</a> &gt;
				<a href="http://dggs.alaska.gov">Geological &amp; Geophysical Surveys</a> &gt;
				<a href="http://dggs.alaska.gov/gmc">Geologic Materials Center</a> &gt;
				<a href="search">Inventory</a>
			</div>

			<div class="apptmpl-content">
				<div>
					<h2>Move Log</h2>
					<form method="get" action="container_log.html">
						<label for="start">Start Date: </label>
						<input type="text" id="start" name="start" size="15" tabindex="2" value="${fn:escapeXml(start)}">

						<label for="end">End Date: </label>
						<input type="text" id="end" name="end" size="15" tabindex="3" value="${fn:escapeXml(end)}">

						<input type="submit" value="Query">
					</form>
				</div>

				<c:if test="${!empty logs}">
				<br>

				<div>
					<table>
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
								<td class="loc">
									<a href="inventory/${log.inventory_id}">${empty log.barcode ? 'NO BARCODE' : log.barcode}</a>
								</td>
								<td>${log.dst}</td>
							</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>
				</c:if>
			</div>
		</div>
	</body>
</html>
