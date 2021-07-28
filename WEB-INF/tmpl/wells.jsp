<!doctype html>
<html lang="en">
<head>
	<link rel="stylesheet" href="ol/6.5.0/ol.css" type="text/css" />
	<style>
		html,
		body {
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
			padding-left: 2px;
			padding-right: 2px;
			content: "\2715";
			font-size: 20px;
		}

		#popup-content {
			padding: 10px 5px 5px 5px;
			max-height: 175px;
			overflow: auto;
		}

		.tabs {
			background: rgba(18, 72, 106, 255);
			padding-left: 2px;
			padding-right: 2px;
			display: flex;
			cursor: default;
		}

		.tabs div {
			color: white;
			padding: 3px;
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

		#prev {
			width: 30%;
			display: flex;
			justify-content: center;
		}

		#numOf {
			width: 40%;
			display: flex;
			justify-content: center;
			font-size: 18px;
		}

		#currentPageDiv {
			justify-content: flex-end;
			width: 35%;
		}

		#totalPageDiv {
			width: 65%;
		}

		#next {
			width: 30%;
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
		<div class="tabs">
			<div style="width:100%">
				<div id="prev">&#x25C0;</div>
				<div id="numOf">
					<div id="currentPageDiv"></div>
					<div id="totalPageDiv"></div>
				</div>
				<div id="next">&#x25B6;</div>
			</div>
			<div style="margin-left:auto">
				<div id="popup-closure" class="ol-popup-closer"></div>
			</div>
		</div>
		<div id="popup-content"></div>
	</div>

	<script src="ol/6.5.0/ol.js"></script>
	<script>
		let overlayCoor;
		const content = document.getElementById('popup-content');
		const overlay = new ol.Overlay({
			element: document.getElementById('popup'),
			autoPan: true,
			autoPanAnimation: {
				duration: 100
			},
			autoPanMargin: 300
		});

		function handleError(err) {
			alert(err);
		}

		// Initialize the map and base layer
		let map = new ol.Map({
			controls: ol.control.defaults().extend([new ol.control.ScaleLine({
				units: "us"
			})]),
			overlays: [overlay],
			target: 'map',
			layers: [new ol.layer.Tile({
				source: new ol.source.OSM()
			})],
			view: new ol.View({
				center: ol.proj.fromLonLat([-150, 64]),
				zoom: 3,
				maxZoom: 24
			})
		})

		let vectorSource = new ol.source.Vector();
		let wellPointLayer = new ol.layer.VectorImage({
			source: vectorSource,
			style: new ol.style.Style({
				image: new ol.style.Circle({
					radius: 5,
					fill: new ol.style.Fill({
						color: 'rgba(189, 84, 73, 0.5)'
					})
				})
			})
		});

		map.addLayer(wellPointLayer);

		//Label the markers
		let labelStyle = new ol.style.Style({
			text: new ol.style.Text({
				font: 4 * map.getView().getZoom() + 'px Calibri, sans-serif',
				textBaseline: 'middle',
				textAlign: 'center',
				fill: new ol.style.Fill({
					color: 'rgba(0,0,0,a)'
				}),
				stroke: new ol.style.Stroke({
					color: 'rgba(0,0,0,.5)',
					width: 0.01
				})
			})
		});

		let style = [labelStyle];

		let wellPointLabelLayer = new ol.layer.VectorImage({
			source: vectorSource,
			style: function(feature) {
				labelStyle.getText().setText(feature.label);
				return style;
			},
			declutter: true
		});

		//Fetch the makers
		fetch('wellpoint.json')
			.then(response => {
				if (!response.ok) throw new Error(response.status + " " +
					response.statusText);
				return response.json();
			})
			.then(d => {
				let markers = [];
				d.forEach(({
					geog,
					name,
					well_id
				}) => {
					let f = new ol.Feature(new ol.format.WKT().readGeometry(geog));
					f.getGeometry().transform("EPSG:4326", "EPSG:3857");
					f.label = name + ' - ' + well_id;
					f.well_id = well_id;
					markers.push(f);
				});
				vectorSource.addFeatures(markers);
			})
			.catch(error => {
				handleError(error);
			});

		map.addLayer(wellPointLabelLayer);

		//Pagination Code
		//Fetch the well data
		let currentPage;
		let clicked = false;

		function displayOverlayContents() {
			if (!clicked) {
				clicked = true;
				switch (event.target.id) {
					case "prev":
						if (!(currentPage < 0)) {
							currentPage--;
						}
						break;
					case "next":
						if (!(currentPage > fts.length - 1)) {
							currentPage++;
						}
						break;
					default:
						currentPage = 0;
				}

				if (currentPage > 0) {
					prev.style.visibility = 'visible';
				} else {
					prev.style.visibility = 'hidden';
				}
				if (currentPage < (fts.length - 1)) {
					next.style.visibility = 'visible';
				} else {
					next.style.visibility = 'hidden';
				}

				currentPageDiv.innerHTML = (currentPage + 1)
				totalPageDiv.innerHTML = " of  " + fts.length;

				let well_id = fts[currentPage].well_id;
				fetch('well.json?id=' + well_id)
					.then(response => {
						if (!response.ok) throw new Error(response.status + " " +
							response.statusText);
						return response.json();
					})
					.then(data => {
						for (let i = 0; i < data.keywords.length; i++) {
							let arr = data.keywords[i].keywords.split(",");
							let qParams = "";
							for (let j = 0; j < arr.length; j++) {
								qParams = qParams.concat("&keyword=" + arr[j]);
							}
							data.keywords[i].keywords = data.keywords[i].
							keywords.replaceAll(",", ", ");
							data.keywords[i]["keywordsURL"] = encodeURI("search#q=well_id:" +
								well_id + qParams);
						}
						data["nameURL"] = encodeURI("well/" + well_id);
						data["well_id"] = well_id;
						content.innerHTML = Mustache.render(
							document.getElementById('templ_well_popup').innerHTML, data
						);
						overlay.setPosition(overlayCoor);
						clicked = false;
					})
					.catch(error => {
						handleError(error);
					});
			}
		}

		//Popup
		const prev = document.getElementById('prev');
		const next = document.getElementById('next');
		prev.addEventListener("click", displayOverlayContents);
		next.addEventListener("click", displayOverlayContents);

		const closer = document.getElementById('popup-closure');
		closer.addEventListener("click", function() {
			overlay.setPosition(undefined);
			closer.blur();
			return false;
		});

		const currentPageDiv = document.getElementById('currentPageDiv');
		const totalPageDiv = document.getElementById('totalPageDiv');
		let fts = [];
		map.on('click', function(e) {
			fts = map.getFeaturesAtPixel(e.pixel);
			if (fts.length > 0) {
				displayOverlayContents();
				overlayCoor = e.coordinate;
			} else {
				overlay.setPosition(undefined);
			}
		});
	</script>

	<script src="js/mustache-2.2.0.min.js"></script>
	<script id="templ_well_popup" type="x-tmpl-mustchache">
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
</body>
</html>
