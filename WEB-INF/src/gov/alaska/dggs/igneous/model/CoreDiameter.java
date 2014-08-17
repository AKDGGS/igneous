package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.math.BigDecimal;


public class CoreDiameter implements Serializable
{
	private static final long serialVersionUID = 1L;


	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	BigDecimal diameter;
	public BigDecimal getDiameter(){ return diameter; }

	private Unit unit;
	public Unit getUnit(){ return unit; }
}
