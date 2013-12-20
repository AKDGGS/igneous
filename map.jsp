<%@ page import="
	javax.naming.InitialContext,
	javax.sql.DataSource,
	java.sql.Connection,
	java.sql.Statement,
	java.sql.ResultSet
"%><%
	String query = request.getParameter("q");
	query = query == null ? "" : query.trim();
%><!DOCTYPE HTML>
<html>
	<head>
		<title>Map Test</title>
		<style>
			#map { width: 960px; height: 480px; }
		</style>
	</head>
	<body onload="init();">
		<div>
			<form method="get" action="map.jsp">
				<textarea rows="4" cols="80" name="q"><%= query.length() == 0 ? "SELECT ST_AsText(ST_Transform(geog::GEOMETRY, 3857)) FROM place LIMIT 100" : query %></textarea>
				<div><input type="submit" value="Execute and Display"></div>
			</form>
		</div>

		<br/><br/>

		<div id="map"></div>

		<script src="ol/2.13.1/OpenLayers.js"></script>
		<script>
			var wkts = [<%
				if(query.length() > 0){
					DataSource ds = (DataSource)new InitialContext().lookup("java:comp/env/jdbc/igneous");
					Connection conn = ds.getConnection();
					try {
						Statement st = conn.createStatement(
							ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY
						);

						ResultSet rs = st.executeQuery(query.trim()); 

						for(int i = 0; rs.next(); i++){
							if(i != 0){ out.print(","); }

							out.print("\"" + rs.getString(1) + "\"");
						}
					} finally {
						conn.close();
					}
				}
			%>];
			
			var map;

			function init()
			{
				var display_layer = new OpenLayers.Layer.Vector('Display Layer');
				var wkt_parser = new OpenLayers.Format.WKT();
				var features = [];
				for(var i in wkts){ features.push( wkt_parser.read(wkts[i]) ); }
				display_layer.addFeatures(features);

				map = new OpenLayers.Map('map', {
					maxExtent: new OpenLayers.Bounds(
						-20037508.34, -20037508.34, 20037508.34, 20037508.34
					),
					maxResolution: 156543.0339,
					center: new OpenLayers.LonLat(-17900000, 9100000),
					zoom: 3,
					projection: new OpenLayers.Projection('EPSG:3857'),
					units: 'm',
					layers: [
						new OpenLayers.Layer.XYZ(
							'GINA Satellite',
							'http://tiles.gina.alaska.edu/tilesrv/bdl/tile/${'${x}'}/${'${y}'}/${'${z}'}', {
								isBaseLayer: true, sphericalMercator: true,
								transitionEffect: 'resize', wrapDateLine: true
							}
						),
						display_layer
					],
					controls: [
						new OpenLayers.Control.PanZoom(),
						new OpenLayers.Control.Navigation(),
						new OpenLayers.Control.LayerSwitcher(),
					]
				});
			}
		</script>
	</body>
</html>



