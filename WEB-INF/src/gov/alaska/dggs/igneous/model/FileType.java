package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class FileType implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name;

	public int getID(){ return id; }
	public String getName(){ return name; }
}
