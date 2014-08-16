package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;


public class Container implements Serializable
{
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String barcode, alt_barcode;
	private String remark, name, path_cache;

	public Integer getID(){ return id; }

	public String getBarcode(){ return barcode; }
	public void setBarcode(String barcode){ this.barcode = barcode; }

	public String getAltBarcode(){ return alt_barcode; }
	public void setAltBarcode(String alt_barcode){ this.alt_barcode = alt_barcode; }

	public String getRemark(){ return remark; }
	public void setRemark(String remark){ this.remark = remark; }

	public String getName(){ return name; }
	public void setName(String name){ this.name = name; }

	public String getPathCache(){ return path_cache; }
}
