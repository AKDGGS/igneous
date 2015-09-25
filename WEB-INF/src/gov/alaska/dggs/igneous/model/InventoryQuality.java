package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.Date;
import java.util.List;


public class InventoryQuality implements Serializable
{
	private static final long serialVersionUID = 1L;


	private Integer id;
	public Integer getID(){ return id; }


	private Inventory inventory;
	public Inventory getInventory(){ return inventory; }
	public void setInventory(Inventory i){ inventory = i; }


	private Date date;
	public Date getDate(){ return date; }
	public void setDate(Date d){ date = d; }


	private String remark;
	public String getRemark(){ return remark; }
	public void setRemark(String remark){ this.remark = remark; }


	private String username;
	public String getUsername(){ return username; }
	public void setUsername(String username){ this.username = username; }


	private String issues;
	public String getIssues(){ return issues; }
	public void setIssues(String issues){ this.issues = issues; }


	public InventoryQuality(Inventory i)
	{
		inventory = i;

		date = new Date();
		issues = null;
	}


	public InventoryQuality(){ this(null);	}
}
