<%@
	page trimDirectiveWhitespaces="true"
%><%@
	taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><!DOCTYPE html>
<html lang="en">
	<head>
		<title>Alaska Division of Geological &amp; Geophysical Surveys Geologic Materials Center</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,initial-scale=0.75,user-scalable=no">
		<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
		<link rel="stylesheet" href="css/apptmpl-fullscreen.css">
		<style>
			h2, h3, h4, h5 { margin: 16px 0; }
			th { text-align: left; }
			pre { margin-left: 30px; }
			.apptmpl-content { padding: 8px 16px; }
			.gmc-block {
				width: 100%;
				margin: auto;
				padding: 10px 8px 10px 0px;
				overflow: auto;
			}
			.gmc-help ul {
				list-style: none;
				margin: 0;
				padding: 0;    
			}
			.gmc-help ul > li.gmc-help, h5.gmc-help {
				display: inline;
				margin: 5px 10px 5px 0;
			}
			.apptmpl-content { padding: 8px 16px; }
			.search-examples th { padding: 0; margin: 0; }
			.search-examples td { padding: 0 16px 0 0; }
			.fields td { padding: 0 16px 0 0; }
		</style>
	</head>
	<body>
		<div class="soa-apptmpl-header">
			<div class="soa-apptmpl-header-top">
				<a class="soa-apptmpl-logo" title="The Great State of Alaska" href="https://alaska.gov"></a>
				<a class="soa-apptmpl-logo-dggs" title="The Division of Geological &amp; Geophysical Surveys" href="https://dggs.alaska.gov"></a>
				<div class="soa-apptmpl-header-nav">
					<c:if test="${not empty pageContext.request.userPrincipal}">
					<a href="container_log.html">Move Log</a>
					<a href="quality_report.html">Quality Assurance</a>
					<a href="audit_report.html">Audit</a>
					<a href="import.html">Data Importer</a>
					<a href="logout/">Logout</a>
					</c:if>
					<c:if test="${empty pageContext.request.userPrincipal}">
					<a href="login/">Login</a>
					</c:if>
					<a href="help">Help/Contact</a>
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
				<a href="search">
					<span class="soa-apptmpl-breadcrumb-lg">Inventory</span>
					<span class="soa-apptmpl-breadcrumb-sm">Inventory</span>
				</a>
			</div>
		</div>
		<div class="apptmpl-content">
			<a name="top"></a>
			<h2 style="margin: 0 0 8px 0">GMC Inventory Search Help</h2>
			<div class="gmc-help">
				<ul id="gmc-help">
					<li class="gmc-help">
						<a href="#interface">Interface Features</a>
					</li>
					<li class="gmc-help">
						<a href="#hints">Search Hints</a>
					</li>
					<li class="gmc-help">
						<a href="#basic">Basic Search Options</a>
					</li>
					<li class="gmc-help">
						<a href="#advanced">Advanced Search Options</a>
					</li>
				</ul>
			</div>
			<div class="gmc-block">
				<h3 id="interface">Interface Features</h3>
				<p>
					"<b>Red oval</b>" at top right of image below shows location of help
					link in inventory search interface
				</p>
				<img src="img/help.jpg" style="border: 1px solid black">
				<h4>Initial Search Options</h4>
				<ul style="list-style: none">
					<li>
						<b>1.</b> Zoom Map - Adjust map scale in/out by selecting +/-
						symbols or scrolling with middle mouse button
					</li>
					<li>
						<b>2.</b> Search Area - Define rectangular search area by
						selecting bounding box symbol then dragging mouse
						cursor across desired region
					</li>
					<li>
						<b>3.</b> Map Base Layers - Select desired map base layers from
						drop-down menu
					</li>
					<li>
						<b>4.</b> Map Scale - Shows automatic map scale in kilometers and
						miles
					</li>
					<li>
						<b>5.</b> Location - Shows point location of cursor over map in
						WGS84 latitude/longitude coordinates
					</li>
					<li>
						<b>6.</b> Search Filter - Open/close advanced drop-down search
						filters by selecting 3-bars icon
					</li>
					<li>
						<b>7.</b> Text Search Bar - Enter simple search text or use <a
						href="#advanced">Advanced Search</a> filters
					</li>
				</ul>
				<h4>Search Results Options</h4>
				<ul style="list-style: none">
					<li>
						<b>8.</b> Reset - Clear all search results by selecting
						<b>Reset</b> button
					</li>
					<li>
						<b>9.</b> Showing - Limit displayed search results by selecting
						count from drop-down <b>Showing</b> menu
					</li>
					<li>
						<b>10.</b> Displaying - Cycle through displayed search results by
						selecting <b>Previous</b> and <b>Next</b> buttons
					</li>
					<li>
						<b>11.</b> PDF/CSV - Download search results to <b>PDF</b> format
						or to <b>CSV</b> file compatible with spreadsheets
					</li>
					<li>
						<b>12.</b> Sort By - Sort search results by selecting choices
						from two <b>Sort by</b> drop-down menus
					</li>
					<li>
						<b>13.</b> Record Link - Find more details on individual sample
						by selecting the <b>ID</b> link
					</li>
					<li>
						<b>14.</b> Header Links - Find more details related to well,
						prospect, borehole, or sample site by selecting the
						<b>Related</b> link
					</li>
				</ul>
				<a href="#top">Back to Top</a>
			</div>
			<div class="gmc-block">
				<h3 id="hints">Search Hints</h3>
				<h4>General</h4>
				<ul>
					<li>
						After first search change <b>Showing</b> (#9)
						count from 25 to 1000
					</li>
					<li>
						Try to get specific, focus on single well or
						prospect
					</li>
				</ul>
				<h4>Narrow Search Results</h4>
				<ul>
					<li>
						Draw a bounding box with <b>Search Area</b> (#2) to
						narrow down your region of interest
					</li>
					<li>
						Entering "<b>well:*</b>", "<b>borehole:*</b>",
						"<b>outcrop:*</b>", or "<b>shotline:*</b>" in the
						<b>Search Bar</b> (#7) to narrow down your results
					</li>
					<li>
						Once you find your well, highlight the API number and
						cut &amp; paste it into the <b>Search Bar</b> (#7)
					</li>
				</ul>
				<h4>Common Search Examples</h4>
				<table class="search-examples">
					<tr>
						<th>Search</th>
						<th>Example Link</th>
					</tr>
					<tr>
						<td>well and core</td>
						<td>
							<a href="./#q=50137200030000%20AND%20keyword%3Araw%20AND%20keyword%3Acore&amp;sort=collection&amp;sort=sort_keyword">50137200030000 AND keyword:raw AND keyword:core</a>
						</td>
					</tr>
					<tr>
						<td>well and cuttings</td>
						<td>
							<a href="./#q=50137200030000%20AND%20keyword%3Araw%20AND%20keyword%3Acuttings&amp;sort=collection&amp;sort=sort_keyword">50137200030000 AND keyword:raw AND keyword:cuttings</a>
						</td>
					</tr>
					<tr>
						<td>well and processed</td>
						<td>
							<a href="./#q=50137200030000%20AND%20keyword%3Aprocessed&amp;sort=collection&amp;sort=sort_keyword">50137200030000 AND keyword:processed</a>
						</td>
					</tr>
					<tr>
						<td>well and thin section</td>
						<td>
							<a href="./#q=50137200030000%20AND%20keyword%3Aprocessed%20AND%20keyword%3Athin%20section&amp;sort=collection&amp;sort=sort_keyword">50137200030000 AND keyword:processed AND keyword:thin section</a>
						</td>
					</tr>
					<tr>
						<td>well and unprocessed(raw)</td>
						<td>
							<a href="./#q=50137200030000%20AND%20keyword%3Araw&amp;sort=collection&amp;sort=sort_keyword">50137200030000 AND keyword:raw</a>
						</td>
					</tr>
					<tr>
						<td>borehole in a bounding box</td>
						<td>
							<a href="./#q=borehole%3A*&amp;aoi=%7B%22type%22%3A%22Polygon%22%2C%22coordinates%22%3A%5B%5B%5B-158.6426%2C66.2137%5D%2C%5B-158.6426%2C67.9581%5D%2C%5B-150.7324%2C67.9581%5D%2C%5B-150.7324%2C66.2137%5D%2C%5B-158.6426%2C66.2137%5D%5D%5D%7D">borehole:*</a>
						</td>
					</tr>
					<tr>
						<td>outcrop in a bounding box</td>
						<td>
							<a href="./#q=outcrop%3A*&amp;aoi=%7B%22type%22%3A%22Polygon%22%2C%22coordinates%22%3A%5B%5B%5B-158.6426%2C66.2137%5D%2C%5B-158.6426%2C67.9581%5D%2C%5B-150.7324%2C67.9581%5D%2C%5B-150.7324%2C66.2137%5D%2C%5B-158.6426%2C66.2137%5D%5D%5D%7D">outcrop:*</a>
						</td>
					</tr>
					<tr>
						<td>shothole in a bounding box</td>
						<td>
							<a href="./#q=shotline%3A*&amp;aoi=%7B%22type%22%3A%22Polygon%22%2C%22coordinates%22%3A%5B%5B%5B-159.6973%2C68.4477%5D%2C%5B-159.6973%2C70.0656%5D%2C%5B-151.8750%2C70.0656%5D%2C%5B-151.8750%2C68.4477%5D%2C%5B-159.6973%2C68.4477%5D%5D%5D%7D">shotline:*</a>
						</td>
					</tr>
					<tr>
						<td>pulp in a bounding box</td>
						<td>
							<a href="./#q=keyword%3Apulp&amp;aoi=%7B%22type%22%3A%22Polygon%22%2C%22coordinates%22%3A%5B%5B%5B-139.5703%2C55.3541%5D%2C%5B-139.5703%2C58.8819%5D%2C%5B-129.0234%2C58.8819%5D%2C%5B-129.0234%2C55.3541%5D%2C%5B-139.5703%2C55.3541%5D%5D%5D%7D&amp;sort=sample&amp;sort=sort_keyword">keyword:pulp</a>
						</td>
					</tr>
					<tr>
						<td>map in a bounding box</td>
						<td>
							<a href="./#q=keyword%3Amap&amp;aoi=%7B%22type%22%3A%22Polygon%22%2C%22coordinates%22%3A%5B%5B%5B-158.7305%2C66.1427%5D%2C%5B-158.7305%2C67.7926%5D%2C%5B-149.7656%2C67.7926%5D%2C%5B-149.7656%2C66.1427%5D%2C%5B-158.7305%2C66.1427%5D%5D%5D%7D">keyword:map</a>
						</td>
					</tr>
				</table>
				<h4>Ask For Help</h4>
				<p>
					Email the URL of search results to GMC staff: copy this
					from contents of the address bar on top of browser
				</p>
				<a href="#top">Back to Top</a>
			</div>
			<div class="gmc-block">
				<h3 id="basic">Basic Search Options</h3>
				<h4>Using the Search Bar to Locate Inventory</h4>
				<ul>
					<li>
						Well: Enter first few letters of well name followed by
						an asterisk or a valid API number
						(<a href="./#q=well%3Akup*%20OR%2055307000010000"><b>well:kup*</b> OR <b>55307000010000</b></a>)
					</li>
					<li>
						Prospect: Enter first few letters of prospect name followed by
						an asterisk
						(<a href="./#q=prospect%3Agold*"><b>prospect:gold*</b></a>)
					</li>
					<li>
						Outcrop: Enter first few letters of sample number followed
						by an asterisk
						(<a href="./#q=outcrop%3A06DL*"><b>outcrop:06DL*</b></a>)
					</li>
					<li>
						Seismic Shotline: Enter first few letters of shotline followed by
						an asterisk
						(<a href="./#q=shotline%3A37*"><b>shotline:37*</b></a>)
					</li>
				</ul>
				<h4>Bounding Search Box</h4>
				<ul>
					<li>
						Use <b>Map Base Layers</b> icon to select desired base layer
					</li>
					<li>Zoom and pan into area of interest</li>
					<li>Click <b>Search Area</b> icon</li>
					<li>
						Move mouse cursor to upper left corner of search area
					</li>
					<li>
						Click corner, hold button, and drag bounding box to
						lower right corner
					</li>
					<li>Release button</li>
					<li>
						To remove bounding search box click the <b>Search
						Area</b> icon then click <b>Cancel</b>
					</li>
				</ul>
				<h4>Refine Search Results with Search Filter</h4>
				<ul>
					<li>
						Click the <b>Search Filter</b> 3-Bar icon to view
						drop-down filter lists
					</li>
					<li>
						Core: Scroll through <b>Keywords</b> menu and select
						both the <b>raw</b> and <b>core</b> options
						(Ctrl-Click in Windows)
					</li>
					<li>
						Cuttings: Scroll through <b>Keywords</b> menu and select
						both the <b>raw</b> and <b>cuttings</b> options
					</li>
					<li>
						Enter both top and bottom of <b>Interval</b> of interest
					</li>
					<li>
						All active filters and drop-down menu selections must
						be true for some inventory to be displayed.
					</li>
				</ul>
				<h4>Organize Search Results</h4>
				<ul>
					<li>
						Select <b>Showing</b> menu to select largest
						number to display most if not all search results
					</li>
					<li>
						Select <b>Sort by</b> menus to sort search
						results (e.g. Select <b>Keywords</b> in menu 1 and
						<b>Top</b> in menu 2 to sort single well or
						borehole)
					</li>
				</ul>
				<h4>Retain Search Results</h4>
				<ul>
					<li>
						Search page url - Highlight and save the browser url to
						share your search parameters with others
					</li>
					<li>
						Select <b>PDF</b> link to save search results
						as PDF table (the search url is also saved)
					</li>
					<li>
						Click <b>CSV</b> link to save search results
						as comma-delimited text file that can be imported into
						spreadsheet
					</li>
				</ul>
				<h4>No Search Results</h4>
				<ul>
					<li>
						Click the <b>Reset</b> button - Former search
						selections maybe interfering with the current search
						operation
					</li>
					<li>
						Remove individual <b>Search Filter</b>
						parameters - there maybe no samples that fit the current
						search criteria
					</li>
				</ul>
				<a href="#top">Back to Top</a>
			</div>
			<div class="gmc-block">
				<h3 id="advanced">Advanced Search Options</h3>
				<p>
					The Search Bar queries many different database fields.
					Users may indicate which fields to query by specifying the
					field name followed by a colon. For example, if you wanted
					to query the USGS collection, looking for inventory around
					the Barrow area you could search:
					<pre><a href="./#q=barrow%20collection%3AUSGS">barrow collection:USGS</a></pre>
				</p>

				<p>
					Numeric fields can be searched exactly the same as
					string fields. For example, if you wanted to query all
					cuttings in the database that had a top interval of 100,
					you could search:
					<pre><a href="./#q=cuttings%20top%3A100">cuttings top:100</a></pre>
				</p>

				<p>
					It is also possible to search for ranges in numeric
					fields. For example, if you wanted to query all core in the
					database that had a top interval between 500 and 550, you
					could search:
					<pre><a href="./#q=core%20top%3A[500%20TO%20500]">core top:[500 TO 550]</a></pre>
					<i><b>* Note:</b> "TO" inside the range is case sensitive</i>
				</p>

				<p>
					It is also possible to search for items that do not
					match specific criteria. For example, if you wanted to find
					mineral-related inventory that was not from an outcrop, you
					could search:
					<pre><a href="./#q=keyword%3Amineral%20NOT%20keyword%3Aoutcrop">keyword:mineral NOT keyword:outcrop</a></pre>
					<i><b>* Note:</b> "NOT" is case sensitive</i>
				</p>

				<p>
					By default, searches are conducted using logical
					conjunction (AND), it is however possible to search using
					logical disjunction (OR) using the OR operator. So if you
					wanted to find inventory that was either core or cuttings,
					you could search:
					<pre><a href="./#q=keyword%3Acuttings%20OR%20keyword%3Acore">keyword:cuttings OR keyword:core</a></pre>
					<i><b>* Note:</b> "OR" is case sensitive</i>
				</p>

				<p>
					In certain instances, it is helpful to be able to
					search for partial terms. For example, if you wanted to
					find inventory with a well name that had terms starting
					with "al", you could search:
					<pre><a href="./#q=well%3Aal*">well:al*</a></pre>
				</p>

				<p>
					Wildcard searching pairs well with the NOT operator.
					For example, if you wanted to search for terms that began
					with "en" but not include any inventory with the "energy"
					keyword, you could search:
					<pre><a href="./#q=en*%20NOT%20keyword%3Aenergy">en* NOT keyword:energy</a></pre>
				</p>

				<p>
					Often it is useful to group searches that feature
					logical operators. For example, if you wanted to show any
					wells name that had terms starting with "al" or "en", but
					omit cuttings for both, you could search:
					<pre><a href="./#q=(well%3Aen*%20OR%20well%3Aal*)%20NOT%20keyword%3Acuttings">(well:en* OR well:al*) NOT keyword:cuttings</a></pre>
				</p>
				<h4>Keyword Search Options</h4>
				<p>
					A complete list of fields available for searching can be
					found below.
				</p>
				<table class="fields">
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
							<td>slide</td>
							<td>Slide Number (string)</td>
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
							<td>publicationtitle</td>
							<td>
								Title of publication attached to inventory (string)
							</td>
						</tr>
						<tr>
							<td>publicationdescription</td>
							<td>
								Description of publication attached to inventory (string)
							</td>
						</tr>
						<tr>
							<td>publicationnumber</td>
							<td>
								Number from publication attached to inventory (string)
							</td>
						</tr>
						<tr>
							<td>publicationseries</td>
							<td>
								Series from publication attached to inventory (string)
							</td>
						</tr>
						<tr>
							<td>everything</td>
							<td>All fields (string) (implicit)</td>
						</tr>
					</tbody>
				</table>
			</div>
			<a href="#top">Back to Top</a>
		</div>
	</body>
</html>
