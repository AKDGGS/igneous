package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class MiningDistrict implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name;
	private String wkt;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getWKT(){ return wkt; }
}
