package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class CoreDiameter implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, diameter;
	private Unit unit;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getDiameter(){ return diameter; }
	public Unit getUnit(){ return unit; }
}
