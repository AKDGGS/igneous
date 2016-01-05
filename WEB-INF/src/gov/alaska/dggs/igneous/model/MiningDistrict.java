package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class MiningDistrict implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String geojson;
	public String getGeoJSON(){ return geojson; }
}
