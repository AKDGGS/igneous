package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


public class Outcrop implements Serializable
{
	private static final long serialVersionUID = 1L;


	private int id;
	public int getID(){ return id; }


	private String name;
	public String getName(){ return name; }


	private String number;
	public String getNumber(){ return number; }


	private Integer year;
	public Integer getYear(){ return year; }


	private boolean is_onshore;
	public boolean isOnshore(){ return is_onshore; }
}
