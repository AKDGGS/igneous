package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Keyword implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, alias, description;

	private KeywordGroup group;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getAlias(){ return alias; }
	public String getDescription(){ return description; }

	public KeywordGroup getGroup(){ return group; }
}
