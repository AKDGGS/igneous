package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


public class Prospect implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, alt_names;
	private String ardf;
	private List<Map> inventory_summary;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public String getARDF(){ return ardf; }
	public List<Map> getInventorySummary(){ return inventory_summary; }
}
