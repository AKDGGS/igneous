<%@
	taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
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
			<dl>
				<c:if test="${!empty inventory.sampleNumber}">
				<dt>Sample Number</dt>
				<dd>${inventory.sampleNumber}</dd>
				</c:if>

				<c:if test="${!empty inventory.barcode}">
				<dt>Barcode</dt>
				<dd>${inventory.barcode}</dd>
				</c:if>

				<c:if test="${!empty inventory.altBarcode}">
				<dt>Alt. Barcode</dt>
				<dd>${inventory.altBarcode}</dd>
				</c:if>

				<c:if test="${!empty inventory.box}">
				<dt>Box</dt>
				<dd>${inventory.box}</dd>
				</c:if>

				<c:if test="${!empty inventory.set}">
				<dt>Set</dt>
				<dd>${inventory.set}</dd>
				</c:if>

				<c:if test="${!empty inventory.core}">
				<dt>Core</dt>
				<dd>${inventory.core}</dd>
				</c:if>

				<c:if test="${!empty inventory.state}">
				<dt>State</dt>
				<dd>${inventory.state}</dd>
				</c:if>

				<c:if test="${!empty inventory.intervalTop}">
				<dt>Interval Top</dt>
				<dd>${inventory.intervalTop}</dd>
				</c:if>

				<c:if test="${!empty inventory.intervalBottom}">
				<dt>Interval Bottom</dt>
				<dd>${inventory.intervalBottom}</dd>
				</c:if>

				<c:if test="${!empty inventory.description}">
				<dt>Description</dt>
				<dd>${inventory.description}</dd>
				</c:if>

				<c:if test="${!empty inventory.remark}">
				<dt>Remark</dt>
				<dd>${inventory.remark}</dd>
				</c:if>

				<c:if test="${!empty inventory.remark}">
				<dt>Remark</dt>
				<dd>${inventory.remark}</dd>
				</c:if>

				<c:if test="${!empty inventory.container}">
				<dt>Location</dt>
				<dd>${inventory.container.pathCache}</dd>
				</c:if>
			</dl>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
	</body>
</html>
