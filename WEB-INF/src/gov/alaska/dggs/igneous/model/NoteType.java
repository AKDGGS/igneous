package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class NoteType implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String description;
	public String getDescription(){ return description; }
}
