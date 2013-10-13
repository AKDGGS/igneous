package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Quadrangle implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, alt_name, abbr, alt_abbr;
	private long scale;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getAltName(){ return alt_name; }
	public String getAbbr(){ return abbr; }
	public String getAltAbbr(){ return alt_abbr; }
	public long getScale(){ return scale; }
}
