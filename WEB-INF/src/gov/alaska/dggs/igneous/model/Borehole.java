package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Borehole implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, alt_names;
	private String prospect_name, alt_prospect_names;
	private String ardf;

	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public String getProspectName(){ return prospect_name; }
	public String getAltProspectNames(){ return alt_prospect_names; }
	public String getARDF(){ return ardf; }
}
