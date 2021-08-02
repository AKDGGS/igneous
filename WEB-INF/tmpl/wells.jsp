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
		<script>
			const popupContainer = document.getElementById('popup');
			const content = document.getElementById('popup-content');
			const closer = document.getElementById('popup-closure');
			const overlay = new ol.Overlay({
				element: popupContainer,
				autoPan: true,
				autoPanAnimation: {
					duration: 100
				},
				autoPanMargin: 300
			});
			let fts = [];
			let width = 2.5;

			function handleError(err) {
				alert(err);
			}

			let markerStyle = new ol.style.Style({
				image: new ol.style.Circle({
					radius: width * 2,
					fill: new ol.style.Fill({
						color: 'rgba(44, 126,167, 0.25)'
					}),
					stroke: new ol.style.Stroke({
						color: 'rgba(44, 126,167, 255)',
						width: width / 1.5
					})
				}),
				zIndex: Infinity
			});

			let labelStyle = new ol.style.Style({
				text: new ol.style.Text({
					offsetY: -9,
					font: '13px Calibri, sans-serif',
					fill: new ol.style.Fill({
						color: 'rgba(0,0,0,255)'
					}),
					backgroundFill: new ol.style.Fill({
						color: 'rgba(255, 255, 255, 0.1)'
					})
				})
			});

			let wellPointLayer = new ol.layer.Vector({
				source: new ol.source.Vector(),
				style: markerStyle
			});

			let wellPointLabelLayer = new ol.layer.Vector({
				source: new ol.source.Vector(),
				renderBuffer: 1e3,
				style: function(feature) {
					labelStyle.getText().setText(feature.label);
					return labelStyle;
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
					d.forEach(({geog, name, well_id}) => {
						let f = new ol.Feature(new ol.format.WKT().readGeometry(geog));
						f.getGeometry().transform("EPSG:4326", "EPSG:3857");
						f.label = name + ' - ' + well_id;
						f.well_id = well_id;
						f.setId(well_id);
						wellPointLabelLayer.getSource().addFeature(f);
						markers.push(f);
					});
					wellPointLayer.getSource().addFeatures(markers);
				})
				.catch(error => {
					handleError(error);
				});

			let map = new ol.Map({
				layers: [new ol.layer.Tile({
					source: new ol.source.OSM()
				}), wellPointLayer, wellPointLabelLayer],
				target: 'map',
				overlays: [overlay],
				view: new ol.View({
					center: ol.proj.fromLonLat([-150, 64]),
					zoom: 3,
					maxZoom: 24
				}),
				controls: ol.control.defaults({
					attribution: false
				}).extend([new ol.control.ScaleLine({
					units: "us"
				})]),
			})

			//Allows the overlay to be visible.
			//Needed because the overlay was being displayed when the page loaded
			const tabs = document.getElementById('topBar');
			tabs.style.visibility = 'visible';
			popupContainer.style.visibility = 'visible';

			//Pagination Code
			//Fetch the well data
			let currentPage;
			let running = false;

			function displayOverlayContents(e) {
				if (!running) {
					content.scrollTop = 0;
					running = true;
					switch (e.target.id) {
						case "prevBtn":
							if (!(currentPage < 0)) {
								currentPage--;
							}
							break;
						case "nextBtn":
							if (!(currentPage > fts.length - 1)) {
								currentPage++;
							}
							break;
						default:
							currentPage = 0;
					}

					if (currentPage > 0) {
						prevBtn.style.visibility = 'visible';
					} else {
						prevBtn.style.visibility = 'hidden';
					}
					if (currentPage < (fts.length - 1)) {
						nextBtn.style.visibility = 'visible';
					} else {
						nextBtn.style.visibility = 'hidden';
					}

					pageNumber.innerHTML = (currentPage + 1) + " of " + fts.length;

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
							if (e instanceof ol.events.Event) {
								overlay.setPosition(e.coordinate);
							}
							running = false;
						})
						.catch(error => {
							handleError(error);
							running = false;
						});
				}
			}

			//Popup
			const prevBtn = document.getElementById('prevBtn');
			const nextBtn = document.getElementById('nextBtn');
			prevBtn.addEventListener("click", displayOverlayContents);
			nextBtn.addEventListener("click", displayOverlayContents);

			closer.addEventListener("click", function() {
				overlay.setPosition(undefined);
				closer.blur();
				return false;
			});

			map.on('click', function(e) {
				fts = map.getFeaturesAtPixel(e.pixel);
				if (fts.length > 0) {
					displayOverlayContents(e);
				} else {
					overlay.setPosition(undefined);
				}
			});
		</script>
	</body>
</html>
