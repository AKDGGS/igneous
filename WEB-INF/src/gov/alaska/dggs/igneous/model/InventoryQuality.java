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


	private Boolean needs_detail;
	public Boolean getNeedsDetail(){ return needs_detail; }
	public void setNeedsDetail(Boolean b){ needs_detail = b; }


	private Boolean unsorted;
	public Boolean getUnsorted(){ return unsorted; }
	public void setUnsorted(Boolean b){ unsorted = b; }


	private Boolean radiation;
	public Boolean getRadiation(){ return radiation; }
	public void setRadiation(Boolean b){ radiation = b; }


	private Boolean damaged;
	public Boolean getDamaged(){ return damaged; }
	public void setDamaged(Boolean b){ damaged = b; }


	private Boolean box_damaged;
	public Boolean getBoxDamaged(){ return box_damaged; }
	public void setBoxDamaged(Boolean b){ box_damaged = b; }


	private Boolean missing;
	public Boolean getMissing(){ return missing; }
	public void setMissing(Boolean b){ missing = b; }


	private Boolean data_missing;
	public Boolean getDataMissing(){ return data_missing; }
	public void setDataMissing(Boolean b){ data_missing = b; }


	private Boolean barcode_missing;
	public Boolean getBarcodeMissing(){ return barcode_missing; }
	public void setBarcodeMissing(Boolean b){ barcode_missing = b; }


	private Boolean label_obscured;
	public Boolean getLabelObscured(){ return label_obscured; }
	public void setLabelObscured(Boolean b){ label_obscured = b; }


	private Boolean insufficient_material;
	public Boolean getInsufficientMaterial(){ return insufficient_material; }
	public void setInsufficientMaterial(Boolean b){ insufficient_material = b; }


	public InventoryQuality(Inventory i)
	{
		inventory = i;

		date = new Date();
		needs_detail = Boolean.valueOf(false);
		unsorted = Boolean.valueOf(false);
		radiation = Boolean.valueOf(false);
		damaged = Boolean.valueOf(false);
		box_damaged = Boolean.valueOf(false);
		missing = Boolean.valueOf(false);
		data_missing = Boolean.valueOf(false);
		barcode_missing = Boolean.valueOf(false);
		label_obscured = Boolean.valueOf(false);
		insufficient_material = Boolean.valueOf(false);
	}


	public InventoryQuality(){ this(null);	}
}
