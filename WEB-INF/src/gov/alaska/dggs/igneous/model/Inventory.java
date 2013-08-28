package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


public class Inventory implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String samplenumber, barcode;
	private InventoryBranch branch;

	private List<Keyword> keywords;
	private List<Borehole> boreholes;

	public long getID(){ return id; }
	public String getBarcode(){ return barcode; }
	public String getSampleNumber(){ return samplenumber; }
	public InventoryBranch getBranch(){ return branch; }

	public List<Keyword> getKeywords(){ return keywords; }
	public List<Borehole> getBoreholes(){ return boreholes; }
}
