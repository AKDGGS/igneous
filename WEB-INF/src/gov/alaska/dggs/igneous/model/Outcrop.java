package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


public class Outcrop implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, number;
	private int year;
	private boolean is_onshore;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getNumber(){ return number; }
	public int getYear(){ return year; }
	public boolean isOnshore(){ return is_onshore; }
}
