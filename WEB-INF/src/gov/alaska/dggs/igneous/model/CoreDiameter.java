package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.math.BigDecimal;


public class CoreDiameter implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name;
	BigDecimal diameter;
	private Unit unit;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public BigDecimal getDiameter(){ return diameter; }
	public Unit getUnit(){ return unit; }
}
