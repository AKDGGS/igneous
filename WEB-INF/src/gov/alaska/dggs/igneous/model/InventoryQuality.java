package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;


public class InventoryQuality implements Serializable
{
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Inventory inventory;
	private String remark;
	private String username;

	private Boolean needs_detail;
	private Boolean unsorted;
	private Boolean possible_radiation;
	private Boolean damaged;
	private Boolean box_damaged;
	private Boolean missing;
	private Boolean data_missing;
	private Boolean barcode_missing;
	private Boolean label_obscured;
	private Boolean insufficient_material;

	public InventoryQuality(Inventory i)
	{
		inventory = i;

		needs_detail = Boolean.valueOf(false);
		unsorted = Boolean.valueOf(false);
		possible_radiation = Boolean.valueOf(false);
		damaged = Boolean.valueOf(false);
		box_damaged = Boolean.valueOf(false);
		missing = Boolean.valueOf(false);
		data_missing = Boolean.valueOf(false);
		barcode_missing = Boolean.valueOf(false);
		label_obscured = Boolean.valueOf(false);
		insufficient_material = Boolean.valueOf(false);
	}

	public InventoryQuality(){ this(null);	}

	public Integer getID(){ return id; }

	public Inventory getInventory(){ return inventory; }
	public void setInventory(Inventory i){ inventory = i; }

	public String getRemark(){ return remark; }
	public void setRemark(String remark){ this.remark = remark; }

	public String getUsername(){ return username; }
	public void setUsername(String username){ this.username = username; }


	public Boolean getNeedsDetail(){ return needs_detail; }
	public void setNeedsDetail(Boolean b){ needs_detail = b; }

	public Boolean getUnsorted(){ return unsorted; }
	public void setUnsorted(Boolean b){ unsorted = b; }

	public Boolean getPossibleRadiation(){ return possible_radiation; }
	public void setPossibleRadiation(Boolean b){ possible_radiation = b; }

	public Boolean getDamaged(){ return damaged; }
	public void setDamaged(Boolean b){ damaged = b; }

	public Boolean getBoxDamaged(){ return box_damaged; }
	public void setBoxDamaged(Boolean b){ box_damaged = b; }

	public Boolean getMissing(){ return missing; }
	public void setMissing(Boolean b){ missing = b; }

	public Boolean getDataMissing(){ return data_missing; }
	public void setDataMissing(Boolean b){ data_missing = b; }

	public Boolean getBarcodeMissing(){ return barcode_missing; }
	public void setBarcodeMissing(Boolean b){ barcode_missing = b; }

	public Boolean getLabelObscured(){ return label_obscured; }
	public void setLabelObscured(Boolean b){ label_obscured = b; }

	public Boolean getInsufficientMaterial(){ return insufficient_material; }
	public void setInsufficientMaterial(Boolean b){ insufficient_material = b; }
}
