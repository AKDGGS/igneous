<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="${pageContext.request.contextPath}/css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			.ok { background-color: green; color: white; }
			.warning { background-color: yellow; }
			.critical { background-color: red; color: white; }
			.nowrap, #dest { white-space: nowrap; }
			#detail img { margin: 30px; }
			table { width: 100%; }
			td { vertical-align: top; }
			th { text-align: left; }
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
			<table>
				<tbody>
					<tr>
						<td id="dest"></td>
						<td id="detail"></td>
					</tr>
				</tbody>
			</table>
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

				$.ajax({
					url: 'quality.json',
					dataType: 'json',
					success: function(json){
						$.each(json, function(i,e){
							$('<div class="result">')
								.attr('id', i)
								.text(e['desc'] + ' : ')
								.append('<span> Running .. </span>')
								.appendTo('#dest');
						});

						$.each(json, function(i, e){
							var type = e['type'];
							var method = i;

							$.ajax({
								url: 'quality.json',
								data: {r: i+'Count'},
								success: function(json){
									var count = json[0];
									
									if(count == 0){
										$('#'+method).find('span')
											.attr('class', 'ok')
											.text('PASSED');
									} else {
										var link = $('<a href="#">'+count+'</a>').click(function(e){
											$('#detail').empty().append('<img src="${pageContext.request.contextPath}/img/big_loading.gif" />');

											$.ajax({
												url: 'quality.json',
												data: { r: method },
												success: function(json){
													show_detail(json);
												}
											});

											e.preventDefault();	
											return false;
										});

										$('#'+method).find('span')
											.attr('class', type.toLowerCase())
											.text(type.toUpperCase())
											.parent()
												.append(' (')
												.append(link)
												.append(')');
									}
								}
							});
						});
					}
				});
			});

			function show_detail(json){
				$('#detail').empty();

				var table = document.createElement('table');
				var thead = document.createElement('thead');
				var tr = document.createElement('tr');
				var th = document.createElement('th');
				th.appendChild(document.createTextNode('ID'));
				tr.appendChild(th);

				th = document.createElement('th');
				th.appendChild(document.createTextNode('Description'));
				tr.appendChild(th);

				thead.appendChild(tr);
				table.appendChild(thead);

				var tbody = document.createElement('tbody');
				for(var i in json){
					tr = document.createElement('tr');

					var td = document.createElement('td');
					td.className = 'nowrap';
					td.appendChild(document.createTextNode(json[i]['id']));
					tr.appendChild(td);

					td = document.createElement('td');
					td.appendChild(document.createTextNode(json[i]['desc']));
					tr.appendChild(td);

					tbody.appendChild(tr);
				}
				table.appendChild(tbody);

				$('#detail').append(table);
			}
		</script>
	</body>
</html>
