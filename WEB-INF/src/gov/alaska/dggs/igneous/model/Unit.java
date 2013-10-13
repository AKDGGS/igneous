package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Unit implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, abbr, description;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getAbbr(){ return abbr; }
	public String getDescription(){ return description; }
}
