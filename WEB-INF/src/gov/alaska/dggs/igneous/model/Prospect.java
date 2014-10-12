package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Prospect implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String alt_names;
	public String getAltNames(){ return alt_names; }

	private String ardf;
	public String getARDF(){ return ardf; }
}
