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
			dt, dd { display: table-cell; vertical-align: top; }
			dt { width: 160px; }
			dd { margin: 0px; }
			pre { margin: 0px; }
			.notehd, .qualityhd, .loghd { color: #777; }
			#tab-notes > div:not(:first-child) { margin-top: 30px; }

			#stash-dd table { border-collapse: collapse; font-size: 12px; font-family: Tahoma, Geneva, sans-serif; }
			#stash-dd table th { text-align: left; }
			#stash-dd table th, #stash-dd table td { border: 1px solid #bbb; padding: 4px 8px; }
			#stash-dd table tr:nth-child(odd){ background-color: #eee; }
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
			<c:if test="${!empty inventory.coreNumber}">
			<dl>
				<dt>Core Number</dt>
				<dd>${inventory.coreNumber}</dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.coreDiameter}">
			<dl>
				<dt>Core Diameter</dt>
				<dd>${inventory.coreDiameter.diameter} <c:if test="${!empty inventory.coreDiameter.unit}">${inventory.coreDiameter.unit.abbr}</c:if> <c:if test="${!empty inventory.coreDiameter.name}"> (${inventory.coreDiameter.name})</c:if></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.intervalTop}">
			<dl>
				<dt>Interval Top</dt>
				<dd><fmt:formatNumber value="${inventory.intervalTop}" /> <c:if test="${!empty inventory.intervalUnit}"> ${inventory.intervalUnit.abbr}</c:if></dd>
			</dl>
			</c:if>
			<c:if test="${!empty inventory.intervalBottom}">
			<dl>
				<dt>Interval Bottom</dt>
				<dd><fmt:formatNumber value="${inventory.intervalBottom}" /> <c:if test="${!empty inventory.intervalUnit}"> ${inventory.intervalUnit.abbr}</c:if></dd>
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
				<dd><fmt:formatNumber value="${inventory.weight}" /> <c:if test="${!empty inventory.weightUnit}"> ${inventory.weightUnit.abbr}</c:if></dd>
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
				<dd><span title="${inventory.canPublish ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.canPublish ? 'ok' : 'remove'}"></span></dd>
			</dl>
			<dl>
				<dt>Active</dt>
				<dd><span title="${inventory.active ? 'true' : 'false'}" class="glyphicon glyphicon-${inventory.active ? 'ok' : 'remove'}"></span></dd>
			</dl>
			<dl>
				<dt><a id="stash-link" href="#">Show Stash</a></dt>
				<dd id="stash-dd"></dd>
			</dl>

			<ul id="tabs" class="nav nav-tabs" style="width: 100%">
				<li class="active"><a href="#related">Related <span class="badge">${fn:length(inventory.wells) + fn:length(inventory.outcrops) + fn:length(inventory.boreholes) + fn:length(inventory.shotlines) + fn:length(inventory.publications)}</span></a></li>
				<li><a href="#notes">Notes <span class="badge">${fn:length(inventory.notes)}</span></a></li>
				<li><a href="#qualities">Quality Checks <span class="badge">${fn:length(inventory.qualities)}</span></a></li>
				<li><a href="#containerlog">Container Log <span class="badge">${fn:length(inventory.containerLog)}</span></a></li>
				<li><a href="#urls">URLs <span class="badge">${fn:length(inventory.URLs)}</span></a></li>
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
						<c:if test="${quality.needsDetail}"><span class="tag tag-danger">NEEDS DETAIL</span></c:if>
						<c:if test="${quality.unsorted}"><span class="tag tag-danger">UNSORTED</span></c:if>
						<c:if test="${quality.possibleRadiation}"><span class="tag tag-danger">POSSIBLE RADIATION</span></c:if>
						<c:if test="${quality.damaged}"><span class="tag tag-danger">DAMAGED</span></c:if>
						<c:if test="${quality.boxDamaged}"><span class="tag tag-danger">BOX DAMAGED</span></c:if>
						<c:if test="${quality.missing}"><span class="tag tag-danger">MISSING</span></c:if>
						<c:if test="${quality.dataMissing}"><span class="tag tag-danger">DATA MISSING</span></c:if>
						<c:if test="${quality.labelObscured}"><span class="tag tag-danger">LABEL OBSCURED</span></c:if>
						<c:if test="${quality.insufficientMaterial}"><span class="tag tag-danger">INSUFFICIENT MATERIAL</span></c:if>
						<c:if test="${!quality.needsDetail && !quality.unsorted && !quality.possibleRadiation && !quality.damaged && !quality.boxDamaged && !quality.missing && !quality.dataMissing && !quality.labelObscured && !quality.insufficientMaterial}"><span class="tag tag-success">GOOD</span></c:if>
					</div>
					<c:if test="${!empty quality.remark}"><pre>${fn:escapeXml(quality.remark)}</pre></c:if>
				</div>
				</c:forEach>
			</div>

			<div id="tab-containerlog" class="hidden">
				<c:forEach items="${inventory.containerLog}" var="log" varStatus="stat">
				<div class="container">
					<span class="loghd"><fmt:formatDate pattern="M/d/yyyy k:mm" value="${log.date}"/></span>, ${log.pathCache}
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

				$('#tabs a').click(function(e){
					$('#tabs a').each(function(i, e){
						var name = $(e).attr('href').substring(1);
						$('#tab-'+name).hide();
					});

					$('#tabs li').removeClass('active');
					$(this).parent().addClass('active');

					var ref = $(this).attr('href').substring(1);
					$('#tab-'+ref).show();

					e.preventDefault();
					return false;
				});

				$('#stash-link').click(function(e){
					var anchor = $(this);
					if(anchor.text() === 'Show Stash'){
						$.getJSON('../stash.json', {id: ${inventory.ID}}, function(json){
							var el = parseJSON(json);
							document.getElementById('stash-dd').appendChild(el);
							anchor.text('Hide Stash');
						});
					} else {
						$('#stash-dd').empty();
						anchor.text('Show Stash');
					}

					e.preventDefault();
					return false;
				});
			});

			function parseJSON(obj){
				var type = Object.prototype.toString.call(obj);

				switch(type){
					case '[object Boolean]':
						return document.createTextNode(obj.toString());

					case '[object String]':
						return document.createTextNode(obj);

					case '[object Number]':
						return document.createTextNode(obj.toString());

					case '[object Null]':
						return document.createTextNode('(null)');

					case '[object Object]':
						var tbl = document.createElement('table');
						var count = 0;
						for(var i in obj){
							var tr = document.createElement('tr');

							var th = document.createElement('th');
							th.appendChild(document.createTextNode(i));
							tr.appendChild(th);

							var td = document.createElement('td');
							td.appendChild(parseJSON(obj[i]));
							tr.appendChild(td);

							tbl.appendChild(tr);
							count++;
						}
						if(count > 0) return tbl;
						else return document.createTextNode('(Empty Object)');

					case '[object Array]':
						if(obj.length < 1) return document.createTextNode('(Empty List)');

						var tbl = document.createElement('table');
						for(var i = obj.length; i--;){
							var tr = document.createElement('tr');

							var th = document.createElement('th');
							th.appendChild(document.createTextNode(i));
							tr.appendChild(th);

							var td = document.createElement('td');
							td.appendChild(parseJSON(obj[i]));
							tr.appendChild(td);

							tbl.appendChild(tr);
						}
						return tbl;

					default:
						return document.createTextNode('Unknown - ' + type);
				}
			}

		</script>
	</body>
</html>
