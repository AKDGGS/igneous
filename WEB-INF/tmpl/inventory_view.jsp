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
		<meta name="viewport" content="width=device-width,initial-scale=0.75,user-scalable=no">
		<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
		<link rel="stylesheet" href="../css/apptmpl-fullscreen.css">
		<link rel="stylesheet" href="../leaflet/leaflet.css">
		<link rel="stylesheet" href="../leaflet/leaflet.mouseposition.css">
		<link rel="stylesheet" href="../css/view.css" media="screen">
		<style>
			.notehd, .qualityhd, .loghd { color: #777; }
			#tab-notes > div:not(:first-child) { margin-top: 30px; }

			#stash-dd table { border-collapse: collapse; font-size: 12px; font-family: Tahoma, Geneva, sans-serif; }
			#stash-dd table th { text-align: left; }
			#stash-dd table th, #stash-dd table td { border: 1px solid #bbb; padding: 4px 8px; }
			#stash-dd table tr:nth-child(odd){ background-color: #eee; }
		</style>
	</head>
	<body>
		<div class="soa-apptmpl-header">
			<div class="soa-apptmpl-header-top">
				<a class="soa-apptmpl-logo" title="The Great State of Alaska" href="https://alaska.gov"></a>
				<a class="soa-apptmpl-logo-dggs" title="The Division of Geological &amp; Geophysical Surveys" href="https://dggs.alaska.gov"></a>
				<div class="soa-apptmpl-header-nav">
					<c:if test="${not empty pageContext.request.userPrincipal}">
					<a href="../container_log.html">Move Log</a>
					<a href="../quality_report.html">Quality Assurance</a>
					<a href="../audit_report.html">Audit</a>
					<a href="../import.html">Data Importer</a>
					<a href="../logout/">Logout</a>
					</c:if>
					<c:if test="${empty pageContext.request.userPrincipal}">
					<a href="../login/">Login</a>
					</c:if>
					<a href="../help">Help/Contact</a>
				</div>
			</div>
			<div class="soa-apptmpl-header-breadcrumb">
				<a href="https://alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">State of Alaska</span>
					<span class="soa-apptmpl-breadcrumb-sm">Alaska</span>
				</a>
				|
				<a href="http://dnr.alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">Natural Resources</span>
					<span class="soa-apptmpl-breadcrumb-sm">DNR</span>
				</a>
				|
				<a href="https://dggs.alaska.gov">
					<span class="soa-apptmpl-breadcrumb-lg">Geological &amp; Geophysical Surveys</span>
					<span class="soa-apptmpl-breadcrumb-sm">DGGS</span>
				</a>
				|
				<a href="https://dggs.alaska.gov/gmc/">
					<span class="soa-apptmpl-breadcrumb-lg">Geologic Materials Center</span>
					<span class="soa-apptmpl-breadcrumb-sm">GMC</span>
				</a>
				|
				<a href="../search">
					<span class="soa-apptmpl-breadcrumb-lg">Inventory</span>
					<span class="soa-apptmpl-breadcrumb-sm">Inventory</span>
				</a>
			</div>
		</div>
		<div class="apptmpl-content">
			<div class="container">
				<dl>
					<dt>ID</dt>
					<dd>
						${inventory.ID}
						<c:if test="${not empty pageContext.request.userPrincipal}">
							[<a href="../edit_inventory/${inventory.ID}">Edit</a>]
						</c:if>
					</dd>
				</dl>
				<c:if test="${not empty pageContext.request.userPrincipal}">
				<c:if test="${!empty inventory.container}">
				<dl>
					<dt>Location</dt>
					<dd>${inventory.container.pathCache}</dd>
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
					<dd>${inventory.publishedNumberHasSuffix ? 'Yes' : 'No'}</dd>
				</dl>
				</c:if>
				<c:if test="${!empty inventory.collection}">
				<dl>
					<dt>Collection</dt>
					<dd>${inventory.collection.name}</dd>
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
				<c:if test="${!empty inventory.labReportID}">
				<dl>
					<dt>Lab Report ID</dt>
					<dd>${inventory.labReportID}</dd>
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
					<dd>${inventory.coreDiameter.diameter} <c:if test="${!empty inventory.coreDiameter.unit}">${inventory.coreDiameter.unit}</c:if> <c:if test="${!empty inventory.coreDiameter.name}"> (${inventory.coreDiameter.name})</c:if></dd>
				</dl>
				</c:if>
				<c:if test="${!empty inventory.intervalTop}">
				<dl>
					<dt>Interval Top</dt>
					<dd><fmt:formatNumber value="${inventory.intervalTop}" /> <c:if test="${!empty inventory.intervalUnit}"> ${inventory.intervalUnit}</c:if></dd>
				</dl>
				</c:if>
				<c:if test="${!empty inventory.intervalBottom}">
				<dl>
					<dt>Interval Bottom</dt>
					<dd><fmt:formatNumber value="${inventory.intervalBottom}" /> <c:if test="${!empty inventory.intervalUnit}"> ${inventory.intervalUnit}</c:if></dd>
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
				<c:if test="${not empty pageContext.request.userPrincipal}">
				<c:if test="${!empty inventory.tray}">
				<dl>
					<dt>Tray</dt>
					<dd>${inventory.tray}</dd>
				</dl>
				</c:if>
				</c:if>
				<c:if test="${!empty inventory.weight}">
				<dl>
					<dt>Weight</dt>
					<dd><fmt:formatNumber value="${inventory.weight}" /> <c:if test="${!empty inventory.weightUnit}"> ${inventory.weightUnit}</c:if></dd>
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
					<dd><c:forEach items="${inventory.keywords}" var="keyword" varStatus="stat">${stat.count gt 1 ? ", " : ""} <a href="../search#keyword=${keyword}">${keyword}</a></c:forEach></dd>
				</dl>
				</c:if>

				<c:if test="${not empty pageContext.request.userPrincipal}">
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
				<c:if test="${!empty inventory.user}">
				<dl>
					<dt>Last Modified By</dt>
					<dd>${inventory.user}</dd>
				</dl>
				</c:if>
				<c:if test="${!empty inventory.modified}">
				<dl>
					<dt>Modified Date</dt>
					<dd><fmt:formatDate pattern="M/d/yyyy" value="${inventory.modified}"/></dd>
				</dl>
				</c:if>
				<dl>
					<dt>Publish</dt>
					<dd>${inventory.canPublish ? 'Yes' : 'No'}</dd>
				</dl>
				<dl>
					<dt>Active</dt>
					<dd>${inventory.active ? 'Yes' : 'No'}</dd>
				</dl>
				<dl>
					<dt><a id="stash-link" href="#">Show Stash</a></dt>
					<dd id="stash-dd"></dd>
				</dl>
				</c:if>
				
				<ul id="tabs" class="nav nav-tabs" style="width: 100%">
					<li class="active"><a href="#related">Related <span class="badge">${fn:length(inventory.wells) + fn:length(inventory.outcrops) + fn:length(inventory.boreholes) + fn:length(inventory.shotlines) + fn:length(inventory.publications)}</span></a></li>
					<li><a href="#urls">URLs <span class="badge">${fn:length(inventory.URLs)}</span></a></li>
					<li><a href="#files">Files <span class="badge">${fn:length(inventory.files)}</span></a></li>
					<c:if test="${not empty pageContext.request.userPrincipal}">
					<li><a href="#notes">Notes <span class="badge">${fn:length(inventory.notes)}</span></a></li>
					<li><a href="#qualities">QA <span class="badge">${fn:length(inventory.qualities)}</span></a></li>
					<li><a href="#containerlog">Tracking <span class="badge">${fn:length(inventory.containerLog)}</span></a></li>
					</c:if>
				</ul>

				<div id="tab-related">
					<c:forEach items="${inventory.publications}" var="publication">
					<div class="container">
						<dl>
							<dt>Publication Title</dt>
							<dd>${publication.title}</dd>
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
							<dd>${publication.canPublish ? 'Yes' : 'No'}</dd>
						</dl>
					</div>
					</c:forEach>

					<c:forEach items="${inventory.boreholes}" var="borehole">
					<div class="container">
						<c:if test="${!empty borehole.prospect}">
						<dl>
							<dt>Prospect Name</dt>
							<dd><a href="../prospect/${borehole.prospect.ID}">${borehole.prospect.name}</a></dd>
						</dl>
						<c:if test="${!empty borehole.prospect.ARDF}">
						<dl>
							<dt>Prospect ARDF</dt>
							<dd><a href="http://tin.er.usgs.gov/ardf/show.php?labno=${borehole.prospect.ARDF}">${borehole.prospect.ARDF}</a></dd>
						</dl>
						</c:if>
						</c:if>
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
						<c:forEach items="${well.operators}" var="operator">
						<dl>
							<dt>${operator.current ? 'Current' : 'Previous'} Operator</dt>
							<dd>${operator.name} <c:if test="${!empty operator.abbr}">(${operator.abbr})</c:if></dd>
						</dl>
						<dl>
							<dt>Operator Type</dt>
							<dd>${operator.type.name}</dd>
						</dl>
						</c:forEach>
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

					<c:forEach items="${inventory.outcrops}" var="outcrop">
					<div class="container">
						<dl>
							<dt>Outcrop Name</dt>
							<dd><a href="../outcrop/${outcrop.ID}">${outcrop.name}</a></dd>
						</dl>
						<c:if test="${!empty outcrop.number}">
						<dl>
							<dt>Outcrop Number</dt>
							<dd>${outcrop.number}</dd>
						</dl>
						</c:if>
						<c:if test="${!empty outcrop.number}">
						<dl>
							<dt>Outcrop Year</dt>
							<dd>${outcrop.year}</dd>
						</dl>
						</c:if>
					</div>
					</c:forEach>
				</div>

				<div id="tab-urls" class="hidden">
					<c:forEach items="${inventory.URLs}" var="url" varStatus="stat">
					<div class="container">
						<dl>
							<dt>URL Description</dt>
							<dd>${url.description}</dd>
						</dl>
						<c:if test="${!empty url.type}">
						<dl>
							<dt>URL Type</dt>
							<dd>${url.type.name}</dd>
						</dl>
						</c:if>
						<dl>
							<dt>URL</dt>
							<dd><a href="${url.URL}">${url.URL}</a></dd>
						</dl>
					</div>
					</c:forEach>
				</div>

				<div id="tab-files" class="hidden">
					<div id="filelist">
					<c:forEach items="${inventory.files}" var="file">
						<a href="../file/${file.ID}" title="${empty file.description ? file.filename : file.description} (${file.sizeString})">
							<img src="../img/icons/${file.simpleType}.png"><br>${file.filename}
						</a>
					</c:forEach>
					</div>

					<c:if test="${not empty pageContext.request.userPrincipal}">
					<br>

					<form action="../upload" method="POST" enctype="multipart/form-data">
						<input type="hidden" name="inventory_id" value="${inventory.ID}">
						<fieldset id="uploadcontainer">
							<legend>Upload File(s)</legend>

							<table>
								<tr>
									<td>Description:</td>
									<td style="text-align: right">
										<input type="text" name="description" size="35">
									</td>
								</tr>
								<tr>
									<td>
										Select files:
									</td>
									<td style="text-align: right">
										<input type="file" id="fileselect" name="files" multiple="multiple">
										<input type="submit" id="filesubmit" value="Upload">
									</td>
								</tr>
							</table>
						</fieldset>
					</form>
					</c:if>
				</div>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<div id="tab-notes" class="hidden">
					<c:forEach items="${inventory.notes}" var="note" varStatus="stat">
					<div class="container">
						<div class="notehd"><fmt:formatDate pattern="M/d/yyyy" value="${note.date}"/>, ${note.type.name} (${note.username}, ${note.isPublic ? 'public' : 'private'})</div>
						<pre>${fn:escapeXml(note.note)}</pre>
					</div>
					</c:forEach>
				</div>

				<div id="tab-qualities" class="hidden">
					<c:forEach items="${inventory.qualities}" var="quality" varStatus="stat">
					<div class="container">
						<div class="qualityhd">
							<fmt:formatDate pattern="M/d/yyyy" value="${quality.date}"/>, ${quality.username}
							<c:if test="${!empty quality.issues}">
								<c:forEach items="${quality.issues}" var="issue"><span class="tag tag-danger">${fn:toUpperCase(fn:replace(issue, '_', ' '))}</span></c:forEach>
							</c:if>
							<c:if test="${empty quality.issues}"><span class="tag tag-success">GOOD</span></c:if>
						</div>
						<c:if test="${!empty quality.remark}"><pre>${fn:escapeXml(quality.remark)}</pre></c:if>
					</div>
					</c:forEach>
				</div>

				<div id="tab-containerlog" class="hidden">
					<c:forEach items="${inventory.containerLog}" var="log" varStatus="stat">
					<div class="container">
						<span class="loghd"><fmt:formatDate pattern="M/d/yyyy k:mm" value="${log.date}"/></span>, ${log.destination}
					</div>
					</c:forEach>
				</div>
				</c:if>
			</div>
		</div>
		<script src="../leaflet/leaflet.js"></script>
		<script src="../leaflet/leaflet.mouseposition.js"></script>
		<script src="../js/utility.js"></script>
		<script>
			initTabs();
			<c:if test="${not empty pageContext.request.userPrincipal}">
			// If clicked, show the stash
			var stash = document.getElementById('stash-link');
			if(stash !== null){
				stash.onclick = function(evt){
					var anchor = this;
					if(this.innerHTML === 'Show Stash'){
						var xhr = (window.ActiveXObject ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest());
						xhr.onreadystatechange = function(){
							if(xhr.readyState === 4 && xhr.status === 200){
								var json = JSON.parse(xhr.responseText);
								var el = JSONToElement(json);
								document.getElementById('stash-dd').appendChild(el);
								anchor.innerHTML = 'Hide Stash';
							}
						};
						xhr.open('GET', '../stash.json?id=${inventory.ID}', true);
						xhr.send();
					} else {
						anchor.innerHTML = 'Show Stash';
						var dd = document.getElementById('stash-dd');
						if(dd !== null){
							while(dd.lastChild) dd.removeChild(dd.lastChild);
						}
					}

					var e = evt === undefined ? window.event : evt;	
					if('preventDefault' in e) e.preventDefault();
					return false;
				};
			}
			</c:if>
		</script>
	</body>
</html>
