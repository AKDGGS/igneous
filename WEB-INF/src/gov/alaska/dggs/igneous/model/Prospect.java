package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Prospect implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, alt_names;
	private String ardf;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public String getARDF(){ return ardf; }
}
