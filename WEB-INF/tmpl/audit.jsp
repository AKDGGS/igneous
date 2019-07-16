<%@
	page trimDirectiveWhitespaces="true"
%><%@
	taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<meta http-equiv="x-ua-compatible" content="IE=edge" >
		<link rel="stylesheet" href="css/apptmpl.min.css">
		<link rel="stylesheet" href="css/view.css" media="screen">
		<style>
			.pass { background-color: #B2FFB2; }
			.fail { background-color: #FF8080; }
			#dest { margin: 10px 0px 0px 0px; }
			#dest p { margin: 20px 0px 0px 0px; font-size: 18px; font-weight: bold; text-align: center; }
			#dest span { margin: 0px 5px; padding: 0px 5px; }
			#detail { margin: 0px 0px 15px 30px; border-collapse: collapse; }
			#detail th { border-bottom: 1px solid black; }
			#detail th:not(:last-child) { border-right: 1px solid black; }
			#detail td, #detail th { padding: 0px 7px; }
			
			#detail tr.summary td { font-weight: bold; border-top: 1px solid black; }
			#detail tr.summary td:not(:last-child) { border-right: 1px solid black; }
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
				<a href="https://${pageContext.request.serverName}${pageContext.request.contextPath}/login/">Login</a>
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
				<a href="../search">Inventory</a>
			</div>

			<div class="apptmpl-content">
				<h3>Audit Log</h3>

				<label for="start">Start Date: </label>
				<input type="text" id="start" name="start" size="20" tabindex="2" value="1/1/10 00:00:00" />

				<label for="end">End Date: </label>
				<input type="text" id="end" name="end" size="20" tabindex="3" value="1/1/20 23:59:59" />

				<button class="btn btn-primary" id="query"> Query </button>

				<br/>

				<label for="hide_passed">Hide passed:</label>
				<input type="checkbox" id="hide_passed" name="hide_passed" value="true" />

				<label for="path">Location Filter:</label>
				<input type="text" id="path" name="path" size="35" value="" />

				<div id="dest"></div>
			</div>
		</div>
		<script src="js/jquery-1.10.2.min.js"></script>
		<script>
			$(function(){
				var btn_search = document.getElementById('search');
				if(btn_search){
					btn_search.onclick = function(){
						window.location.href = 'search#q=' + $('#q').val();
					};
				}

				var iq = document.getElementById('q');
				if(iq){
					iq.onkeypress = function(e){
						if(e.keyCode === 13){
							var search = document.getElementById('search');
							if(search) search.click();
						}
					};
				}

				var startendfunc = function(e){
					if(e.keyCode === 13){
						var query = document.getElementById('query');
						if(query) query.click();
					}
				};

				$('#start, #end').keypress(function(e){
					if(e.keyCode === 13){ $('#query').click(); }
				});

				$('#query').click(function(){
					var hide_passed = $('#hide_passed').is(':checked');

					$('#dest').empty();

					$.ajax({
						url: 'audit_report.json',
						data: {
							'start': $('#start').val(), 'end': $('#end').val(),
							'path': $('#path').val()
						},
						dataType: 'json',
						success: function(json){
							var total = 0, good = 0;

							$.each(json, function(i, e){
								total++;
								var passed = true;
								var result_text = '';

								if('difference' in e && e['difference'] !== 0){
									passed = false; result_text += 'COUNT MISMATCH';
								}

								if('wrong_shelf' in e && e['wrong_shelf'] !== 0){
									if(result_text.length > 0){ result_text += ' / '; }
									passed = false; result_text += 'INCONSISTENT LOCATION';
								}

								if('no_match' in e && e['no_match'] !== 0){
									if(result_text.length > 0){ result_text += ' / '; }
									passed = false; result_text += 'BARCODE NOT FOUND';
								}

								if('duplicates' in e && e['duplicates'] !== 0){
									if(result_text.length > 0){ result_text += ' / '; }
									passed = false; result_text += 'DUPLICATES';
								}

								if(!('container_id' in e)){
									if(result_text.length > 0){ result_text += ' / '; }
									passed = false; result_text += 'CONTAINER NOT FOUND';
								}

								if(passed){ ++good; result_text = 'PASSED'; }

								if(!passed || !hide_passed){
									var result = $('<span></span>');
									result.text(result_text);
									result.attr('class', passed ? 'pass' : 'fail');

									var div = $('<div></div>');

									var link = $('<a href="#"></a>');
									if('path' in e){ link.text(e['path']); }
									else { link.text('UNKNOWN LOCATION'); }

									link.click(function(){
										getdetail(e['audit_group_id'], e['container_id'], div);
										return false;
									});

									div.append(link);
									if('remark' in e){ div.append(' [' + e['remark'] + ']'); }
									div.append(' #' + e['audit_group_id']);
									div.append(result).appendTo('#dest');
								}
							});

							$('#dest').append(
								$('<p></p>').text(
									good + ' of ' + total + ' passed, ' +
									((good / total) * 100).toFixed(2) + '% good'
								)
							);
						}
					});
				});
			});


			function getdetail(audit_group_id, container_id, ele){
				var ocid = $('#detail').data('container_id');
				var oaid = $('#detail').data('audit_group_id');
				
				$('#detail').remove();
				
				if(audit_group_id === oaid && container_id === ocid){	return; }

				$.ajax({
					url: 'audit_report.json',
					data: {'audit_group_id':audit_group_id, 'container_id':container_id},
					dataType: 'json',
					success: function(json){
						var table = $('<table id="detail"></table>');
						table.data('container_id', container_id);
						table.data('audit_group_id', audit_group_id);

						table.append('<tr><th>Scanned Barcode</th><th>Database Barcode</th><th>Location</th></tr>');
						var i_count = 0, s_count = 0;

						$.each(json, function(i, e){
							var row = $('<tr></tr>');

							if('s_barcode' in e){ ++s_count; }
							if('i_barcode' in e){ ++i_count; }

							row.append(
								$('<td></td>')
									.text('s_barcode' in e ? e['s_barcode'] : '')
									.attr('class', 's_barcode' in e ? 'pass' : 'fail')
							);

							row.append(
								$('<td></td>')
									.text('i_barcode' in e ? e['i_barcode'] : '')
									.attr('class', 'i_barcode' in e ? 'pass' : 'fail')
							);

							if('container_id' in e){
								row.append(
									$('<td></td>').text(e['path'])
									.attr('class', e['container_id'] === container_id ? 'pass' : 'fail')
								);
							} else {
								row.append(
									$('<td>&nbsp;</td>').attr(
										'class', (typeof container_id) === 'undefined' ? 'pass' : 'fail'
									)
								);
							}


							row.appendTo(table);
						});

						var row = $('<tr class="summary"></tr>');
						row.append('<td>Scanned Total: ' + s_count + '</td>');
						row.append('<td>Database Total: ' + i_count + '</td>');
						row.append('<td></td>');
						row.appendTo(table);

						table.appendTo(ele);
					}
				});
			}
		</script>
	</body>
</html>
