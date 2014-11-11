package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.math.BigDecimal;


public class Shotline implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String alt_names;
	public String getAltNames(){ return alt_names; }

	private Integer year;
	public Integer getYear(){ return year; }

	private String remark;
	public String getRemark(){ return remark; }

	private List<Shotpoint> shotpoints;
	public List<Shotpoint> getShotpoints(){ return shotpoints; }

	private List<Note> notes;
	public List<Note> getNotes(){ return notes; }

	private List<URL> urls;
	public List<URL> getURLs(){ return urls; }

	// Aggregate fields that have no database counter-part
	private BigDecimal shotline_min;
	public BigDecimal getShotlineMin(){ return shotline_min; }

	private BigDecimal shotline_max;
	public BigDecimal getShotlineMax(){ return shotline_max; }
}
