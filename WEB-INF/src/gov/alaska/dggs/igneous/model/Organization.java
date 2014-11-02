package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Organization implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String abbr;
	public String getAbbr(){ return abbr; }

	private String remark;
	public String getRemark(){ return remark; }

	private OrganizationType type;
	public OrganizationType getType(){ return type; }

	// For well_operator.is_current
	private Boolean is_current;
	public boolean isCurrent(){
		return is_current == null ? false : is_current;
	}
}
