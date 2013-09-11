package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Date;
import java.util.Map;


public class Borehole implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, alt_names;
	private Prospect prospect;
	private boolean is_onshore;
	private Date completion;
	private long measured_depth;
	private Unit measured_depth_unit;
	private long elevation;
	private Unit elevation_unit;
	private List<Inventory> inventory;
	private List<Map> inventory_summary;


	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public boolean isOnshore(){ return is_onshore; }
	public Prospect getProspect(){ return prospect; }
	public Date getCompletion(){ return completion; }
	public long getMeasuredDepth(){ return measured_depth; }
	public Unit getMeasuredDepthUnit(){ return measured_depth_unit; }
	public long getElevation(){ return elevation; }
	public Unit getElevationUnit(){ return elevation_unit; }
	public List<Inventory> getInventory(){ return inventory; }
	public List<Map> getInventorySummary(){ return inventory_summary; }
}
