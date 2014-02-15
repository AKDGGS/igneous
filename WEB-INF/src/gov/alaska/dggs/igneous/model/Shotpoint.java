package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;


public class Shotpoint implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name;
	private Shotline shotline;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public Shotline getShotline(){ return shotline; }
}
