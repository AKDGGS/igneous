package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Place implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, type;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getType(){ return type; }
}
