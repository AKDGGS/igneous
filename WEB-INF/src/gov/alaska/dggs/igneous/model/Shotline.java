package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;


public class Shotline implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, alt_names;
	private Integer year;
	private String remark;

	private List<Shotpoint> shotpoints;


	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public Integer getYear(){ return year; }
	public String getRemark(){ return remark; }

	public List<Shotpoint> getShotpoints(){ return shotpoints; }
}
