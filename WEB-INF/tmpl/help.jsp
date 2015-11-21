<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Geologic Materials Center</title>
		<link href="css/noose${initParam['dev_mode'] == true ? '' : '-min'}.css" rel="stylesheet" media="screen">
		<style>
			th { text-align: left; }
			pre { margin-left: 30px; }
		</style>
	</head>
	<body>
		<div class="navbar">
			<div class="navbar-head">
				<a href="search">Geologic Materials Center</a>
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
			<h2>Search Help</h2>

			<h3>The Search Bar</h3>
			<p>
				The Search Bar queries many different database fields.
				Users may indicate which fields to query by specifying
				the field name followed by a colon. For example,
				if you wanted to query the USGS collection, looking
				for inventory around the Anchorage area you could search:

				<pre>anchorage collection:usgs</pre>
			<p>

			<p>
				Numeric fields can be searched exactly the same as string fields.
				For example, if you wanted to query all cuttings in the database
				that had a top interval of 100, you could search:

				<pre>cuttings top:100</pre>

				It is also possible to search for ranges in numeric fields. For
				example, if you wanted to query all core in the database
				that had a top interval between 500 and 550, you could search:

				<pre>core top:[500 TO 550]</pre>

				<i><b>* Note:</b> "TO" inside the range is case sensitive</i>
			</p>

			<p>
				It's also possible to search for items that do not match
				specific criteria. For example, if you wanted to find
				mineral-related inventory that was not from an outcrop,
				you could search:

				<pre>keyword:mineral NOT keyword:outcrop</pre>

				<i><b>* Note:</b> "NOT" is case sensitive</i>
			</p>

			<p>
				By default, searches are conducted using logical conjuction (AND),
				it is however possible to search using logical disjunction (OR)
				using the OR operator. So if you wanted to find inventory
				that was either core or cuttings, you could search:

				<pre>keyword:cuttings OR keyword:core</pre>

				<i><b>* Note:</b> "OR" is case sensitive</i>
			</p>

			<p>
				In certain instances, it's helpful to be able to search for partial
				terms. For example, if you wanted to find inventory with a well
				name that had terms starting with "al", you could search:

				<pre>well:al*</pre>

				Wildcard searching pairs well with the NOT operator. For example,
				if you wanted to search for terms that began with "en" but
				not include any inventory with the "energy" keyword, you could
				search:

				<pre>en* NOT keyword:energy</pre>
			</p>

			<p>
				Often it is useful to group searches that feature logical operators.
				For example, if you wanted to show any wells name that had terms
				starting with "al" or "en", but omit cuttings for both, you
				could search:

				<pre>(well:en* OR well:al*) NOT keyword:cuttings</pre>
			</p>

			<p>
				A complete list of fields available for searching can be found
				below.
			</p>

			<br>
	
			<table>
				<thead>
					<tr>
						<th>Field</th>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>top</td>
						<td>Interval Top (numeric)</td>
					</tr>
					<tr>
						<td>bottom</td>
						<td>Interval Top (numeric)</td>
					</tr>
					<tr>
						<td>sample</td>
						<td>Sample Number (string)</td>
					</tr>
					<tr>
						<td>core</td>
						<td>Core Number (string)</td>
					</tr>
					<tr>
						<td>set</td>
						<td>Set Number (string)</td>
					</tr>
					<tr>
						<td>box</td>
						<td>Box Number (string)</td>
					</tr>
					<tr>
						<td>collection</td>
						<td>Collection (string)</td>
					</tr>
					<tr>
						<td>project</td>
						<td>Project (string)</td>
					</tr>
					<tr>
						<td>barcode</td>
						<td>Barcode (string)</td>
					</tr>
					<tr>
						<td>location</td>
						<td>Location (string)</td>
					</tr>
					<tr>
						<td>well</td>
						<td>Well Name (string)</td>
					</tr>
					<tr>
						<td>wellnumber</td>
						<td>Well Number (string)</td>
					</tr>
					<tr>
						<td>api</td>
						<td>Well API Number (string)</td>
					</tr>
					<tr>
						<td>borehole</td>
						<td>Borehole Name (string)</td>
					</tr>
					<tr>
						<td>prospect</td>
						<td>Prospect Name (string)</td>
					</tr>
					<tr>
						<td>ardf</td>
						<td>ARDF Number (string)</td>
					</tr>
					<tr>
						<td>outcrop</td>
						<td>Outcrop Name (string)</td>
					</tr>
					<tr>
						<td>outcropnumber</td>
						<td>Outcrop Number (string)</td>
					</tr>
					<tr>
						<td>shotline</td>
						<td>Shotline Name (string)</td>
					</tr>
					<tr>
						<td>keyword</td>
						<td>Keyword Name (string)</td>
					</tr>
					<tr>
						<td>quadrangle</td>
						<td>Quadrangle Name (string)</td>
					</tr>
					<tr>
						<td>note</td>
						<td>Notes attached to inventory (string)</td>
					</tr>
					<tr>
						<td>notetype</td>
						<td>Type of notes attached to inventory (string)</td>
					</tr>
					<tr>
						<td>everything</td>
						<td>All fields (string) (implicit)</td>
					</tr>
				</tbody>
			</table>
		</div>

		<script src="js/jquery-1.10.2.min.js"></script>
		<script>
			$(function(){
				$('#search').click(function(){
					window.location.href = 'search#q=' + $('#q').val();
				});

				$('#q').keypress(function(e){
					if(e.keyCode === 13){ $('#search').click(); }
				});

				$('#help').click(function(){
					window.location.href = 'help';
				});
			});
		</script>
	</body>
</html>
