package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Keyword implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, description, code;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getDescription(){ return description; }
	public String getCode(){ return code; }
}
