package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


public class Inventory implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String sample_number, barcode, alt_barcode;
	private String box, set, core, state;
	private String wkt;
	private int interval_top, interval_bottom;
	private Unit interval_unit;
	private InventoryBranch branch;
	private Collection collection;

	private CoreDiameter core_diameter;

	private String container_path;

	private List<Keyword> keywords;
	private List<Borehole> boreholes;
	private List<Well> wells;
	private List<Outcrop> outcrops;

	public int getID(){ return id; }
	public String getBarcode(){ return barcode; }
	public String getAltBarcode(){ return alt_barcode; }
	public String getSampleNumber(){ return sample_number; }
	public String getContainerPath(){ return container_path; }
	public String getBox(){ return box; }
	public String getState(){ return state; }
	public String getCore(){ return core; }
	public String getSet(){ return set; }
	public String getWKT(){ return wkt; }

	public int getIntervalTop(){ return interval_top; }
	public int getIntervalBottom(){ return interval_bottom; }
	public Unit getIntervalUnit(){ return interval_unit; }

	public CoreDiameter getCoreDiameter(){ return core_diameter; }

	public InventoryBranch getBranch(){ return branch; }
	public Collection getCollection(){ return collection; }

	public List<Keyword> getKeywords(){ return keywords; }
	public List<Borehole> getBoreholes(){ return boreholes; }
	public List<Well> getWells(){ return wells; }
	public List<Outcrop> getOutcrops(){ return outcrops; }
}
