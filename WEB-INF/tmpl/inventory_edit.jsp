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
		<link rel="stylesheet" href="../css/apptmpl.min.css">
		<style>
			dl { display: table; margin: 8px 4px; }
			dt, dd { display: table-cell; vertical-align: top; }
			dt { width: 160px; }
			dd { margin: 0px; }
			dd.span { display: none; }
			dd.err input { background-color: #fcc; }
			dd.err span { display: inline-block; color: #f00; font-size: 12px; margin-left: 5px; }
			pre { margin: 0px; }
			div.message { font-size: 18px; color: green; text-align: center; }
			div.err { font-size: 18px; color: red; text-align: center; }
		</style>
	</head>
	<body>
		<div class="apptmpl-container">
			<div class="apptmpl-goldbar">
				<a class="apptmpl-goldbar-left" href="http://alaska.gov"></a>
				<span class="apptmpl-goldbar-right"></span>

				<c:if test="${not empty pageContext.request.userPrincipal}">
				<a href="../container_log.html">Move Log</a>
				<a href="../quality_report.html">Quality Assurance</a>
				<a href="../audit_report.html">Audit</a>
				<c:if test="${pageContext.request.isUserInRole('admin')}">
				<a href="../import.html">Data Importer</a>
				</c:if>
				<a href="../logout/">Logout</a>
				</c:if>
				<c:if test="${empty pageContext.request.userPrincipal}">
				<a href="../login/">Login</a>
				</c:if>
				<a href="../help">Search Help</a>
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
				<a href="../search">Inventory</a>
			</div>

			<div class="apptmpl-content">
				<c:if test="${not empty message}"><div class="${empty err ? 'message' : 'err'}">${message}</div></c:if>
				<form method="post">
					<dl>
						<dt>ID</dt>
						<dd><a href="../inventory/${inventory.ID}">${inventory.ID}</a></dd>
					</dl>
					<dl>
						<dt>DGGS Sample ID</dt>
						<dd${!empty err.dggs_sample_id ? ' class="err"' : ''}>
							<input type="text" name="dggs_sample_id" value="${fn:escapeXml(empty param.dggs_sample_id ? inventory.DGGSSampleID : param.dggs_sample_id)}">
							<span>${fn:escapeXml(err.dggs_sample_id)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Sample Number</dt>
						<dd${!empty err.sample_number ? ' class="err"' : ''}>
							<input type="text" name="sample_number" value="${fn:escapeXml(empty param.sample_number ? inventory.sampleNumber : param.sample_number)}">
							<span>${fn:escapeXml(err.sample_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Sample Number Prefix</dt>
						<dd${!empty err.sample_number_prefix ? ' class="err"' : ''}>
							<input type="text" name="sample_number_prefix" value="${fn:escapeXml(empty param.sample_number_prefix ? inventory.sampleNumberPrefix: param.sample_number_prefix)}">
							<span>${fn:escapeXml(err.sample_number_prefix)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Alt. Sample Number</dt>
						<dd${!empty err.alt_sample_number ? ' class="err"' : ''}>
							<input type="text" name="alt_sample_number" value="${fn:escapeXml(empty param.alt_sample_number ? inventory.altSampleNumber : param.alt_sample_number)}">
							<span>${fn:escapeXml(err.alt_sample_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Published Sample No.</dt>
						<dd${!empty err.published_sample_number ? ' class="err"' : ''}>
							<input type="text" name="published_sample_number" value="${fn:escapeXml(empty param.published_sample_number ? inventory.publishedSampleNumber : param.published_sample_number)}">
							<span>${fn:escapeXml(err.published_sample_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Published No. Suffix</dt>
						<dd>
							<select name="published_number_has_suffix">
								<option value="true" ${inventory.publishedNumberHasSuffix ? 'selected' : ''}>True</option>
								<option value="false" ${inventory.publishedNumberHasSuffix ? '' : 'selected'}>False</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>Barcode</dt>
						<dd${!empty err.barcode ? ' class="err"' : ''}>
							<input type="text" name="barcode" value="${fn:escapeXml(empty param.barcode ? inventory.barcode : param.barcode)}">
							<span>${fn:escapeXml(err.barcode)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Alt. Barcode</dt>
						<dd${!empty err.alt_barcode ? ' class="err"' : ''}>
							<input type="text" name="alt_barcode" value="${fn:escapeXml(empty param.alt_barcode ? inventory.altBarcode : param.alt_barcode)}">
							<span>${fn:escapeXml(err.alt_barcode)}</span>
						</dd>
					</dl>
					<dl>
						<dt>State Number</dt>
						<dd${!empty err.state_number ? ' class="err"' : ''}>
							<input type="text" name="state_number" value="${fn:escapeXml(empty param.state_number ? inventory.stateNumber : param.state_number)}">
							<span>${fn:escapeXml(err.state_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Box Number</dt>
						<dd${!empty err.box_number ? ' class="err"' : ''}>
							<input type="text" name="box_number" value="${fn:escapeXml(empty param.box_number ? inventory.boxNumber : param.box_number)}">
							<span>${fn:escapeXml(err.box_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Set Number</dt>
						<dd${!empty err.set_number ? ' class="err"' : ''}>
							<input type="text" name="set_number" value="${fn:escapeXml(empty param.set_number ? inventory.setNumber : param.set_number)}">
							<span>${fn:escapeXml(err.set_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Split Number</dt>
						<dd${!empty err.split_number ? ' class="err"' : ''}>
							<input type="text" name="split_number" value="${fn:escapeXml(empty param.split_number ? inventory.splitNumber : param.split_number)}">
							<span>${fn:escapeXml(err.split_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Slide Number</dt>
						<dd${!empty err.slide_number ? ' class="err"' : ''}>
							<input type="text" name="slide_number" value="${fn:escapeXml(empty param.slide_number ? inventory.slideNumber : param.slide_number)}">
							<span>${fn:escapeXml(err.slide_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Slip Number</dt>
						<dd${!empty err.slip_number ? ' class="err"' : ''}>
							<input type="text" name="slip_number" value="${fn:escapeXml(empty param.slip_number ? inventory.slipNumber : param.slip_number)}">
							<span>${fn:escapeXml(err.slip_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Lab Number</dt>
						<dd${!empty err.lab_number ? ' class="err"' : ''}>
							<input type="text" name="lab_number" value="${fn:escapeXml(empty param.lab_number ? inventory.labNumber : param.lab_number)}">
							<span>${fn:escapeXml(err.lab_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Lab Report ID</dt>
						<dd${!empty err.lab_report_id ? ' class="err"' : ''}>
							<input type="text" name="lab_report_id" value="${fn:escapeXml(empty param.lab_report_id ? inventory.labReportID : param.lab_report_id)}">
							<span>${fn:escapeXml(err.lab_report_id)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Map Number</dt>
						<dd${!empty err.map_number ? ' class="err"' : ''}>
							<input type="text" name="map_number" value="${fn:escapeXml(empty param.map_number ? inventory.mapNumber : param.map_number)}">
							<span>${fn:escapeXml(err.map_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Core Number</dt>
						<dd${!empty err.core_number ? ' class="err"' : ''}>
							<input type="text" name="core_number" value="${fn:escapeXml(empty param.core_number ? inventory.coreNumber : param.core_number)}">
							<span>${fn:escapeXml(err.core_number)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Weight</dt>
						<dd${!empty err.weight ? ' class="err"' : ''}>
							<input type="text" name="weight" value="${fn:escapeXml(empty param.weight ? inventory.weight : param.weight)}">
							<c:if test="${!empty inventory.weightUnit}"> ${inventory.weightUnit.abbr}</c:if>
							<span>${fn:escapeXml(err.weight)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Interval Top</dt>
						<dd${!empty err.interval_top ? ' class="err"' : ''}>
							<input type="text" size="8" name="interval_top" value="${fn:escapeXml(empty param.interval_top ? inventory.intervalTop : param.interval_top)}">
							<c:if test="${!empty inventory.intervalUnit}"> ${inventory.intervalUnit.abbr}</c:if>
							<span>${fn:escapeXml(err.interval_top)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Interval Bottom</dt>
						<dd${!empty err.interval_bottom ? ' class="err"' : ''}>
							<input type="text" size="8" name="interval_bottom" value="${fn:escapeXml(empty param.interval_bottom ? inventory.intervalBottom : param.interval_bottom)}">
							<c:if test="${!empty inventory.intervalUnit}">${inventory.intervalUnit.abbr}</c:if>
							<span>${fn:escapeXml(err.interval_bottom)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Description</dt>
						<dd>
							<textarea rows="4" cols="30" name="description">${fn:escapeXml(empty param.description ? inventory.description : param.description)}</textarea>
						</dd>
					</dl>
					<dl>
						<dt>Remark</dt>
						<dd>
							<textarea rows="4" cols="30" name="remark">${fn:escapeXml(empty param.remark ? inventory.remark : param.remark)}</textarea>
						</dd>
					</dl>
					<dl>
						<dt>Tray</dt>
						<dd${!empty err.tray ? ' class="err"' : ''}>
							<input type="text" name="tray" value="${fn:escapeXml(empty param.tray ? inventory.tray : param.tray)}">
							<span>${fn:escapeXml(err.tray)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Sample Frequency</dt>
						<dd${!empty err.sample_frequency ? ' class="err"' : ''}>
							<input type="text" name="sample_frequency" value="${fn:escapeXml(empty param.sample_frequency ? inventory.sampleFrequency : param.sample_frequency)}">
							<span>${fn:escapeXml(err.sample_frequency)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Recovery</dt>
						<dd${!empty err.recovery ? ' class="err"' : ''}>
							<input type="text" name="recovery" value="${fn:escapeXml(empty param.recovery ? inventory.recovery : param.recovery)}">
							<span>${fn:escapeXml(err.recovery)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Radiation</dt>
						<dd${!empty err.radiation_msvh ? ' class="err"' : ''}>
							<input type="text" size="5" name="radiation_msvh" value="${fn:escapeXml(empty param.radiation_msvh ? inventory.radiationMSVH : param.radiation_msvh)}"> mSv/h
							<span>${fn:escapeXml(err.radiation_msvh)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Received Date (M/D/YYYY)</dt>
						<dd${!empty err.received ? ' class="err"' : ''}>
								<fmt:formatDate pattern="M/d/yyyy" var="received" value="${inventory.received}"/>
							<input type="text" name="received" value="${fn:escapeXml(empty param.received ? received : param.received)}">
							<span>${fn:escapeXml(err.received)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Entered Date (M/D/YYYY)</dt>
						<dd${!empty err.entered ? ' class="err"' : ''}>
							<fmt:formatDate pattern="M/d/yyyy" var="entered" value="${inventory.entered}"/>
							<input type="text" size="10" name="entered" value="${fn:escapeXml(empty param.entered ? entered : param.entered)}">
							<span>${fn:escapeXml(err.entered)}</span>
						</dd>
					</dl>
					<dl>
						<dt>Publish</dt>
						<dd>
							<select name="can_publish">
								<option value="true" ${inventory.canPublish ? 'selected' : ''}>True</option>
								<option value="false" ${inventory.canPublish ? '' : 'selected'}>False</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>Active</dt>
						<dd>
							<select name="active">
								<option value="true" ${inventory.active ? 'selected' : ''}>True</option>
								<option value="false" ${inventory.active ? '' : 'selected'}>False</option>
							</select>
						</dd>
					</dl>
					<dl>
						<dt>&nbsp;</dt>
						<dd>
							<button class="btn btn-primary" id="save">
								<span class="glyphicon glyphicon-save"></span> Save
							</button>
						</dd>
					</dl>
				</form>
			</div>
		</div>
	</body>
</html>
