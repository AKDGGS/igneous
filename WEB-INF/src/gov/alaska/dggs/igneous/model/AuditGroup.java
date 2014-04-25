package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.Date;


public class AuditGroup implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private Date create_date;
	private String remark;

	public int getID(){ return id; }
	public Date getCreateDate(){ return create_date; }

	public void setRemark(String remark){ this.remark = remark; }
	public String getRemark(){ return remark; }
}
