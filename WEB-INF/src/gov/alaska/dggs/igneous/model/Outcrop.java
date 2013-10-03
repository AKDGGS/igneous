package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


public class Outcrop implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, outcrop_number;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getOutcropNumber(){ return outcrop_number; }
}
