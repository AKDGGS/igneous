const popupContainer = document.getElementById('popup');
const content = document.getElementById('popup-content');
const closer = document.getElementById('popup-closure');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');

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
});

//Allows the overlay to be visible.
//The overlay needs to be hidden by default to prevent it being 
//displayed at startup
document.getElementById('topBar').style.visibility = 'visible';
popupContainer.style.visibility = 'visible';

//Pagination Code
//Fetch the well data
let currentPage;
let running = false;

function displayOverlayContents(e) {
	if (!running) {
		content.scrollTop = 0;
		running = true;
		if (e instanceof MouseEvent) {
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
			}
			prevBtn.disable = true;
			prevBtn.style.color = "rgba(134, 134, 134, 0.75)";
			nextBtn.disable = true;
			nextBtn.style.color = "rgba(134,134,134, 0.75)";
		} else {
			currentPage = 0;
		}

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
					data.keywords[i].keywords = data.keywords[i]
						.keywords.replaceAll(",", ", ");
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
				pageNumber.innerHTML = (currentPage + 1) + " of " + fts.length;

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
				prevBtn.style.color = "#ffffff";
				nextBtn.style.color = "#ffffff";
				running = false;
			})
			.catch(error => {
				handleError(error);
				running = false;
			});
	}
}

//Popup
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
