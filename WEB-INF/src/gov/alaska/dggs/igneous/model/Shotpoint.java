package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.math.BigDecimal;


public class Shotpoint implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private BigDecimal number;
	private Shotline shotline;

	public int getID(){ return id; }
	public BigDecimal getNumber(){ return number; }
	public Shotline getShotline(){ return shotline; }
}
