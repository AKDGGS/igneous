package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


public class Prospect implements Serializable
{
	private static final long serialVersionUID = 1L;


	private int id;
	private String name, alt_names;
	private String ardf;
	private List<Borehole> boreholes;


	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public String getARDF(){ return ardf; }

	public List<Borehole> getBoreholes(){ return boreholes; }
	public void setBoreholes(List<Borehole> boreholes){ this.boreholes = boreholes; }
}
