<!doctype html>
<html lang="en">
	<head>
		<title>Wells Overview Map</title>
		<link rel="stylesheet" href="ol/6.5.0/ol.css" type="text/css" />
		<style>
			html, body {
				height: 100%;
				padding: 0;
				margin: 0;
				font-size: 18px;
				font-family: 'Times New Roman', serif;
			}

			#map {
				height: 100%;
				width: 100%;
			}

			.ol-popup {
				position: absolute;
				background-color: white;
				box-shadow: 0 1px 4px rgba(0, 0, 0, 0.2);
				padding-bottom: 5px;
				border: 1px solid #cccccc;
				bottom: 12px;
				left: -50px;
				min-width: 320px;
				visibility: hidden;
			}

			.ol-popup-after,
			.ol-popup-before {
				top: 100%;
				border: solid transparent;
				content: " ";
				height: 0;
				width: 0;
				position: absolute;
				pointer-events: none;
			}

			.ol-popup:after {
				border-top-color: white;
				border-width: 10px;
				left: 48px;
				margin-left: -10px;
			}

			.ol-popup:before {
				border-top-color: #cccccc;
				border-width: 11px;
				left: 48px;
				margin-left: -11px;

			}

			.ol-popup-closer:after {
				content: "\2715";
				font-size: 20px;
				margin-left: auto;
			}

			.popup-content {
				padding: 10px 5px 5px 5px;
				max-height: 175px;
				overflow: auto;
				font-size: 16px;
			}

			.topBar {
				background: rgba(39, 111, 147, 1);
				padding: 5px;
				display: flex;
				align-items: center;
				font-size: 20px;
				cursor: default;
				visibility: hidden;
			}

			.topBar div {
				color: white;
				padding: 2px;
				display: flex;
				letter-spacing: 0.5px;
				text-decoration: none;
				tranisition: 0.6s;
				-webkit-touch-callout: none;
				-webkit-user-select: none;
				-moz-user-select: none;
				-ms-user-select: none;
				-user-select: none;
			}

			.prevBtn {
				width: 33%;
				display: flex;
				justify-content: center;
			}

			.pageNumber {
				width: 33%;
				display: flex;
				justify-content: center;
			}

			.nextBtn {
				width: 33%;
				display: flex;
				justify-content: center;
			}

			.wellList {
				display: block
			}
		</style>
	</head>

	<body>
		<div id="map"></div>
		<div id="popup" class="ol-popup">
			<div id="topBar" class="topBar">
				<div id="prevBtn" class="prevBtn">&#x25C0;</div>
				<div id="pageNumber" class="pageNumber"></div>
				<div id="nextBtn" class="nextBtn">&#x25B6;</div>
				<div id="popup-closure" class="ol-popup-closer"></div>
			</div>
			<div id="popup-content" class="popup-content"></div>
		</div>

		<script src="ol/6.5.0/ol.js"></script>
		<script src="js/mustache-2.2.0.min.js"></script>
		<script id="templ_well_popup" type="x-tmpl-mustache">
			<div>
				{{#well.name}}<div><b>Name:</b><a href="{{nameURL}}">{{well.name}} {{#well_id}} - {{well_id}} {{/well_id}}</a></div>{{/well.name}}
				{{#well.APINumber}}<div><b>API Number:</b> {{well.APINumber}}</div>{{/well.APINumber}}
				{{#well.wellNumber}}<div><b>Well Number:</b> {{well.wellNumber}}</div>{{/well.wellNumber}}
				{{#well.measuredDepth}}<div><b>Measured Depth:</b> {{well.measuredDepth}} {{#well.unit.abbr}}{{well.unit.abbr}}{{/well.unit.abbr}}</div>{{/well.measuredDepth}}
				{{#well.verticalDepth}}<div><b>Vertical Depth:</b> {{well.verticalDepth}} {{#well.unit.abbr}}{{well.unit.abbr}}{{/well.unit.abbr}}</div>{{/well.verticalDepth}}
				{{#well.elevation}}<div><b>Elevation:</b> {{well.elevation}} {{#well.unit.abbr}} {{well.unit.abbr}}{{/well.unit.abbr}}</div>{{/well.elevation}}
				{{#well.onshore}}<div><b>Onshore:</b> {{well.onshore}}<br/></div>{{/well.onshore}}
				{{#well.federal}}<div><b>Federal:</b> {{well.federal}}<br/></div>{{/well.federal}}
				{{#well.permitStatus}}<div><b>Permit Status:</b> {{well.permitStatus}}</div>{{/well.permitStatus}}
				{{#well.permitNumber}}<div><b>Permit Number:</b> {{well.permitNumber}}</div>{{/well.permitNumber}}
				{{#well.completionStatus}}<div><b>Completion Status:</b> {{well.completionStatus}}</div>{{/well.completionStatus}}
				{{#well.completionDate}}<div><b>Completion Date:</b> {{well.completionDate}}</div>{{/well.completionDate}}
				{{#well.spudDate}}<div><b>Spud Date:</b> {{well.spudDate}}</div>{{/well.spudDate}}
				<div><br/><b>Keywords:</b></div>
				{{#keywords}}<div style="padding-left:10px"><a href="{{keywordsURL}}">{{keywords}}</a> {{count}}</div>{{/keywords}}
			</div>
		</script>
		<script src="js/wells.js"></script>
	</body>
</html>
