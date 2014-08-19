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
			dl { display: table; margin: 8px 4px; }
			dt, dd { display: table-cell; }
			dt { width: 160px; }
			dd { margin: 0px; }
			pre { margin: 0px; }
			.hidden { display: none; }
			.notehd { color: #777; }
			#tab-notes > div:not(:first-child) { margin-top: 30px; }
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
			<dl>
				<dt>ID</dt>
				<dd>${inventory.ID}</dd>
			</dl>
			<c:if test="${!empty inventory.container}">
			<dl>
				<dt>Location</dt>
				<dd><a href="../container/${inventory.container.ID}">${inventory.container.pathCache}</a></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.DGGSSampleID}">
			<dl>
				<dt>DGGS Sample ID</dt>
				<dd>${inventory.DGGSSampleID}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.sampleNumber}">
			<dl>
				<dt>Sample Number</dt>
				<dd>${inventory.sampleNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.sampleNumberPrefix}">
			<dl>
				<dt>Sample Number Prefix</dt>
				<dd>${inventory.sampleNumberPrefix}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.altSampleNumber}">
			<dl>
				<dt>Alt. Sample Number</dt>
				<dd>${inventory.altSampleNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.publishedSampleNumber}">
			<dl>
				<dt>Published Sample No.</dt>
				<dd>${inventory.publishedSampleNumber}</dd>
			</dl>
			<dl>
				<dt>Published No. Suffix</dt>
				<dd><span title="${inventory.publishedNumberHasSuffix ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.publishedNumberHasSuffix ? 'ok' : 'remove'}"></span></dd>
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
			<c:if test="${!empty inventory.stateNumber}">
			<dl>
				<dt>State Number</dt>
				<dd>${inventory.stateNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.boxNumber}">
			<dl>
				<dt>Box Number</dt>
				<dd>${inventory.boxNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.setNumber}">
			<dl>
				<dt>Set Number</dt>
				<dd>${inventory.setNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.splitNumber}">
			<dl>
				<dt>Split Number</dt>
				<dd>${inventory.splitNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.slideNumber}">
			<dl>
				<dt>Slide Number</dt>
				<dd>${inventory.slideNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.slipNumber}">
			<dl>
				<dt>Slip Number</dt>
				<dd>${inventory.slipNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.labNumber}">
			<dl>
				<dt>Lab Number</dt>
				<dd>${inventory.labNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.coreNumber}">
			<dl>
				<dt>Core Number</dt>
				<dd>${inventory.coreNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.coreDiameter}">
			<dl>
				<dt>Core Diameter</dt>
				<dd>${inventory.coreDiameter.diameter} <c:if test="${!empty inventory.coreDiameter.unit}">${inventory.coreDiameter.unit.abbr}</c:if> <c:if test="${!empty inventory.coreDiameter.name}">(${inventory.coreDiameter.name})</c:if></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.intervalTop}">
			<dl>
				<dt>Interval Top</dt>
				<dd><fmt:formatNumber value="${inventory.intervalTop}" /> <c:if test="${!empty inventory.intervalUnit}">${inventory.intervalUnit.abbr}</c:if></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.intervalBottom}">
			<dl>
				<dt>Interval Bottom</dt>
				<dd><fmt:formatNumber value="${inventory.intervalBottom}" /> <c:if test="${!empty inventory.intervalUnit}">${inventory.intervalUnit.abbr}</c:if></dd>
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
			<c:if test="${!empty inventory.tray}">
			<dl>
				<dt>Tray</dt>
				<dd>${inventory.tray}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.weight}">
			<dl>
				<dt>Weight</dt>
				<dd><fmt:formatNumber value="${inventory.weight}" /> <c:if test="${!empty inventory.weightUnit}">${inventory.weightUnit.abbr}</c:if></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.sampleFrequency}">
			<dl>
				<dt>Sample Frequency</dt>
				<dd>${inventory.sampleFrequency}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.recovery}">
			<dl>
				<dt>Recovery</dt>
				<dd>${inventory.recovery}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.radiationMSVH}">
			<dl>
				<dt>Radiation</dt>
				<dd><fmt:formatNumber value="${inventory.radiationMSVH}" /> mSv/h</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.keywords}">
			<dl>
				<dt>Keywords</dt>
				<dd><c:forEach items="${inventory.keywords}" var="keyword" varStatus="stat">${stat.count gt 1 ? ", " : ""} <a href="../search#keyword_id=${keyword.ID}">${keyword.name}</a></c:forEach></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.received}">
			<dl>
				<dt>Received Date</dt>
				<dd><fmt:formatDate pattern="M/d/yyyy" value="${inventory.received}"/></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.entered}">
			<dl>
				<dt>Entered Date</dt>
				<dd><fmt:formatDate pattern="M/d/yyyy" value="${inventory.entered}"/></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.modified}">
			<dl>
				<dt>Modified Date</dt>
				<dd><fmt:formatDate pattern="M/d/yyyy" value="${inventory.modified}"/></dd>
			</dl>
			</c:if>
			<dl>
				<dt>Skeleton</dt>
				<dd><span title="${inventory.skeleton ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.skeleton ? 'ok' : 'remove'}"></span></dd>
			</dl>
			<dl>
				<dt>Publish</dt>
				<dd><span title="${inventory.canPublish ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.canPublish ? 'ok' : 'remove'}"></span></dd>
			</dl>
			<dl>
				<dt>Active</dt>
				<dd><span title="${inventory.active ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.active ? 'ok' : 'remove'}"></span></dd>
			</dl>

			<ul id="tabs" class="nav nav-tabs" style="width: 100%">
				<li class="active"><a href="#related">Related <span class="badge">${fn:length(inventory.wells) + fn:length(inventory.boreholes) + fn:length(inventory.shotlines) + fn:length(inventory.publications)}</span></a></li>
				<li><a href="#notes">Notes <span class="badge">${fn:length(inventory.notes)}</span></a></li>
			</ul>

			<div id="tab-related">
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
					<c:if test="${!empty borehole.prospect}">
					<dl>
						<dt>Prospect Name</dt>
						<dd><a href="../prospect/${borehole.prospect.ID}">${borehole.prospect.name}</a></dd>
					</dl>
					</c:if>
				</div>
				</c:forEach>

				<c:forEach items="${inventory.wells}" var="well">
				<div class="container">
					<dl>
						<dt>Well Name</dt>
						<dd><a href="../well/${well.ID}">${well.name}</a></dd>
					</dl>
					<c:if test="${!empty well.altNames}">
					<dl>
						<dt>Well Alt. Names</dt>
						<dd>${well.altNames}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.wellNumber}">
					<dl>
						<dt>Well Number</dt>
						<dd>${well.wellNumber}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty well.APINumber}">
					<dl>
						<dt>API Number</dt>
						<dd>${well.APINumber}</dd>
					</dl>
					</c:if>
				</div>
				</c:forEach>

				<c:forEach items="${inventory.shotlines}" var="shotline">
				<div class="container">
					<dl>
						<dt>Shotline Name</dt>
						<dd><a href="../shotline/${shotline.ID}">${shotline.name}</a></dd>
					</dl>
					<c:if test="${!empty shotline.altNames}">
					<dl>
						<dt>Shotline Alt. Names</dt>
						<dd>${shotline.altNames}</dd>
					</dl>
					</c:if>
					<c:if test="${!empty shotline.year}">
					<dl>
						<dt>Shotline Year</dt>
						<dd>${shotline.year}</dd>
					</dl>
					</c:if>
					<dl>
						<dt>Shotpoint(s)</dt>
						<dd><c:forEach items="${shotline.shotpoints}" var="shotpoint" varStatus="stat">${stat.count gt 1 ? ', ' : ''}<fmt:formatNumber groupingUsed="false" value="${shotpoint.number}"/></c:forEach></dd>
					</dl>
				</div>
				</c:forEach>
			</div>

			<div id="tab-notes" class="hidden">
				<c:forEach items="${inventory.notes}" var="note" varStatus="stat">
				<div class="container">
					<div class="notehd"><fmt:formatDate pattern="M/d/yyyy" value="${note.date}"/>, ${note.type.name} (${note.username}, ${note.isPublic ? 'public' : 'private'})</div>
					<pre>${fn:escapeXml(note.note)}</pre>
				</div>
				</c:forEach>
			</div>
		</div>

		<script src="${pageContext.request.contextPath}/js/jquery-1.10.2.min.js"></script>
		<script>
			$(function(){
				$('#tabs a').click(function(e){
					$('#tab-related, #tab-notes').hide();

					$('#tabs li').removeClass('active');
					$(this).parent().addClass('active');

					var ref = $(this).attr('href').substring(1);
					$('#tab-'+ref).show();

					e.preventDefault();
					return false;
				});
			});
		</script>
	</body>
</html>
