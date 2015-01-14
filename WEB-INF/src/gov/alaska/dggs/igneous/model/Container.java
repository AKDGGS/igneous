package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;


public class Container implements Serializable
{
	private static final long serialVersionUID = 1L;

	private Integer id;
	public Integer getID(){ return id; }

	private String barcode;
	public String getBarcode(){ return barcode; }
	public void setBarcode(String barcode){ this.barcode = barcode; }

	private String alt_barcode;
	public String getAltBarcode(){ return alt_barcode; }
	public void setAltBarcode(String alt_barcode){ this.alt_barcode = alt_barcode; }

	private String remark;
	public String getRemark(){ return remark; }
	public void setRemark(String remark){ this.remark = remark; }

	private String name;
	public String getName(){ return name; }
	public void setName(String name){ this.name = name; }

	private String path_cache;
	public String getPathCache(){ return path_cache; }

	private ContainerType type;
	public ContainerType getType(){ return type; }
	public void setType(ContainerType type){ this.type = type; }
}
