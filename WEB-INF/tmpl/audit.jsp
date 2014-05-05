<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			.pass { background-color: #B2FFB2; }
			.fail { background-color: #FF8080; }
			#dest { margin: 10px 0px 0px 0px; }
			#dest p { margin: 0px 0px 10px 0px; }
			#dest span { margin: 0px 5px; padding: 0px 5px; }
			#detail { margin: 0px 0px 15px 30px; border-collapse: collapse; }
			#detail th { border-bottom: 1px solid black; }
			#detail td, #detail th { padding: 0px 7px; }
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
			<label for="start">Start Date: </label>
			<input type="text" id="start" name="start" size="10" tabindex="2" value="1/1/10" />

			<label for="end">End Date: </label>
			<input type="text" id="end" name="end" size="10" tabindex="3" value="1/1/20" />

			<button class="btn btn-primary" id="query">
				<span class="glyphicon glyphicon-book"></span> Query
			</button>

			<div id="dest"></div>
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

				$('#start, #end').keypress(function(e){
					if(e.keyCode === 13){ $('#query').click(); }
				});

				$('#query').click(function(){
					$('#dest').empty();


					$.ajax({
						url: 'audit_report.json',
						data: {'start': $('#start').val(), 'end': $('#end').val()},
						dataType: 'json',
						success: function(json){
							$.each(json, function(i, e){
								var result = $('<span></span>');
								if(e['difference'] !== 0 || e['wrong_shelf'] !== 0 || e['no_match'] !== 0){
									var err_text = '';
									if(e['difference'] !== 0){
										if(err_text.length > 0){ err_text += ' / '; }
										err_text += 'COUNT MISMATCH';
									}

									if(e['wrong_shelf'] !== 0){
										if(err_text.length > 0){ err_text += ' / '; }
										err_text += 'INCONSISTENT LOCATION';
									}

									if(e['no_match'] !== 0){
										if(err_text.length > 0){ err_text += ' / '; }
										err_text += 'BARCODE NOT FOUND';
									}
									
									result.text(err_text);
									result.attr('class', 'fail');
								} else {
									result.attr('class', 'pass');
									result.text('PASSED');
								}

								var div = $('<div></div>');

								var link = $('<a href="#"></a>');
								link.text(e['path']);
								link.click(function(){
									getdetail(e['audit_group_id'], e['container_id'], div);
									return false;
								});

								div
									.append(link)
									.append(' [' + e['remark'] + ']')
									.append(result)
									.appendTo('#dest');
							});
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
						$.each(json, function(i, e){
							var row = $('<tr></tr>');

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
								row.append('<td></td>');
							}

							row.appendTo(table);
						});
						table.appendTo(ele);
					}
				});
			}
		</script>
	</body>
</html>
