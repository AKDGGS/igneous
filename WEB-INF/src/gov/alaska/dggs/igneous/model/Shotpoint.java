package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.math.BigDecimal;


public class Shotpoint implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private BigDecimal number;
	public BigDecimal getNumber(){ return number; }

	private Shotline shotline;
	public Shotline getShotline(){ return shotline; }
}
