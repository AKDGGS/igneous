package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Unit implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, abbr, description;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getAbbr(){ return abbr; }
	public String getDescription(){ return description; }
}
