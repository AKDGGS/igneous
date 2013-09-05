package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


public class Inventory implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String samplenumber, barcode;
	private String box, set, core, state;
	private int interval_top, interval_bottom;
	private Unit interval_unit;
	private InventoryBranch branch;
	private Collection collection;

	private CoreDiameter core_diameter;

	private String container_path;

	private List<Keyword> keywords;
	private List<Borehole> boreholes;

	public long getID(){ return id; }
	public String getBarcode(){ return barcode; }
	public String getSampleNumber(){ return samplenumber; }
	public String getContainerPath(){ return container_path; }
	public String getBox(){ return box; }
	public String getState(){ return state; }
	public String getCore(){ return core; }
	public String getSet(){ return set; }

	public int getIntervalTop(){ return interval_top; }
	public int getIntervalBottom(){ return interval_bottom; }
	public Unit getIntervalUnit(){ return interval_unit; }

	public CoreDiameter getCoreDiameter(){ return core_diameter; }

	public InventoryBranch getBranch(){ return branch; }
	public Collection getCollection(){ return collection; }

	public List<Keyword> getKeywords(){ return keywords; }
	public List<Borehole> getBoreholes(){ return boreholes; }
}
