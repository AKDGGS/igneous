package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Borehole implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, alt_names;
	private Prospect prospect;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public Prospect getProspect(){ return prospect; }
}
