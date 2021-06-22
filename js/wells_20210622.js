var map;

function init()
{
	function markerOnClick(e){
		var marker = e.target;
		fetch('well.json?id=' + marker.well_id)
			.then(response => response.json())
			.then(data => {
				for(let i = 0; i < data.keywords.length; i++){
					var keywordArr = data.keywords[i].keywords.split(",");  //needed for the keyword set's hyperlinks
					var searchParams = "";
					for (let j = 0; j < keywordArr.length; j++){
						searchParams = searchParams.concat("&keyword=" + keywordArr[j]);
					}
					data.keywords[i].keywords = data.keywords[i].keywords.replaceAll(",", ", ");
					data.keywords[i]["keyword_url"] = encodeURI("search#q=well_id:" + marker.well_id + searchParams);
				}
				data["nameURL"] = encodeURI("well/" + marker.well_id);
				popup = L.popup({minWidth: 300, maxHeight: 100, classname:'popupCustom'})
					.setLatLng(e.latlng)
					.setContent(Mustache.render(
						document.getElementById('tmpl-well-popup').innerHTML, data
						)
					)
					.openOn(map);
			});
		}
// Center on Fairbanks
	map =  L.map('map')
		.setView([64.843611, -147.723056], 3);
	
	L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png')
		.addTo(map);
	
	var geoJSONMarkerOptions = {
		radius: 8,
		fill: false,
		weight: 5,
		opacity: 0.75
	}

	function textMarker(latLng, txt, circleOptions){
		var icon = L.divIcon({
			html:'<div class="txt">' + txt + '</div>',
			classname:'circle-with-txt',
			iconSize:[20, 20]
			});

		var circle = L.circleMarker(latLng,circleOptions);
		var marker = L.marker(latLng, {
			icon: icon,
			color: "blue"
			});
			var group = L.layerGroup([circle, marker])
		return group;
	}

	fetch('wellpoint.json')
		.then(response => response.json())
		.then(wellPoints => {
			const layerGroup = L.featureGroup().addTo(map);
			wellPoints.forEach(({geog, well_id}) => {
				//marker = L.circleMarker([geog.coordinates[1], geog.coordinates[0]], geoJSONMarkerOptions);
				//marker.well_id = well_id;
				//marker.on("click", markerOnClick);
				textMarker([geog.coordinates[1], geog.coordinates[0]], well_id, {radius: 20}).addTo(map);
				//map.addLayer(marker);
				
				//marker = L.marker([geog.coordinates[1], geog.coordinates[0]], {
				//icon:L.divIcon({
					//	html: well_id,
					//	classname:'text-below-marker'
					//})		
				//});
			//	map.addLayer(marker);
			});
	});
}
