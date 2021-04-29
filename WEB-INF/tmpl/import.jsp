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
			fieldset { margin-top: 20px; text-align: center; }
			#file { width: 50%; }
			#results { margin: 8px 4px; }
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
				<a href="import.html">Data Importer</a>
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
		</div>
	</body>
</html>
