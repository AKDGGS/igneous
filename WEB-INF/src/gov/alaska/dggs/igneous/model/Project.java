package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.Date;


public class Project implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, description, remark;
	private Date start_date, end_date;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getDescription(){ return description; }
	public String getRemark(){ return remark; }
	public Date getStartDate(){ return start_date; }
	public Date getEndDate(){ return end_date; }
}
