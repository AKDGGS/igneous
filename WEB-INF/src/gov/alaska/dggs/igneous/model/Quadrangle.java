package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Quadrangle implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String alt_name;
	public String getAltName(){ return alt_name; }

	private String abbr;
	public String getAbbr(){ return abbr; }

	private String alt_abbr;
	public String getAltAbbr(){ return alt_abbr; }

	private Long scale;
	public Long getScale(){ return scale; }

	// This is a wrapper for the "geog" field
	private String geojson;
	public String getGeoJSON(){ return geojson; }
}
