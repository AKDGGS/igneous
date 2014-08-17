<%@
	taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><%@
	taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			dl { display: table; margin: 8px 4px; }
			dt { display: table-cell; width: 160px; }
			dd { display: table-cell; margin: 0px; }
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
			<c:if test="${!empty inventory.sampleNumber}">
			<dl>
				<dt>Sample Number</dt>
				<dd>${inventory.sampleNumber}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.barcode}">
			<dl>
				<dt>Barcode</dt>
				<dd>${inventory.barcode}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.altBarcode}">
			<dl>
				<dt>Alt. Barcode</dt>
				<dd>${inventory.altBarcode}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.box}">
			<dl>
				<dt>Box</dt>
				<dd>${inventory.box}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.set}">
			<dl>
				<dt>Set</dt>
				<dd>${inventory.set}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.core}">
			<dl>
				<dt>Core</dt>
				<dd>${inventory.core}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.state}">
			<dl>
				<dt>State</dt>
				<dd>${inventory.state}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.intervalTop}">
			<dl>
				<dt>Interval Top</dt>
				<dd>${inventory.intervalTop}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.intervalBottom}">
			<dl>
				<dt>Interval Bottom</dt>
				<dd>${inventory.intervalBottom}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.description}">
			<dl>
				<dt>Description</dt>
				<dd>${inventory.description}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.remark}">
			<dl>
				<dt>Remark</dt>
				<dd>${inventory.remark}</dd>
			</dl>
			</c:if>

			<c:if test="${!empty inventory.container}">
			<dl>
				<dt>Location</dt>
				<dd>${inventory.container.pathCache}</dd>
			</dl>
			</c:if>

			<dl>
				<dt>Publish</dt>
				<dd><span title="${inventory.canPublish ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.canPublish ? 'ok' : 'remove'}"></span></dd>
			</dl>

			<dl>
				<dt>Active</dt>
				<dd><span title="${inventory.active ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.active ? 'ok' : 'remove'}"></span></dd>
			</dl>

			<hr />

			<div id="crapo">
				<c:forEach items="${inventory.publications}" var="publication">
				<div class="container">
					<dl>
						<dt>Publication Title</dt>
						<dd><a href="../publication/${publication.ID}">${publication.title}</a></dd>
					</dl>
					<c:if test="${!empty publication.year}">
					<dl>
						<dt>Publication Year</dt>
						<dd>${publication.year}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty publication.type}">
					<dl>
						<dt>Publication Type</dt>
						<dd>${publication.type}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty publication.number}">
					<dl>
						<dt>Publication Number</dt>
						<dd>${publication.number}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty publication.series}">
					<dl>
						<dt>Publication Series</dt>
						<dd>${publication.series}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty publication.description}">
					<dl>
						<dt>Publication Description</dt>
						<dd>${publication.description}</dd>
					</dl>
					</c:if>
					<dl>
						<dt>Publication Publish</dt>
						<dd><span title="${publication.canPublish ? 'true' : 'false'}" class="glyphicon glyphicon-${publication.canPublish ? 'ok' : 'remove'}"></span></dd>
					</dl>
				</div>
				</c:forEach>

				<c:forEach items="${inventory.boreholes}" var="borehole">
				<div class="container">
					<dl>
						<dt>Borehole Name</dt>
						<dd><a href="../borehole/${borehole.ID}">${borehole.name}</a></dd>
					</dl>
					<c:if test="${!empty borehole.altNames}">
					<dl>
						<dt>Borehole Alt. Names</dt>
						<dd>${borehole.altNames}</dd>
					</dl>
					</c:if>
				</div>
				</c:forEach>
			</div>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
	</body>
</html>
