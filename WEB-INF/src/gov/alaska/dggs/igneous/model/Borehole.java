package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Date;
import java.util.Map;
import java.math.BigDecimal;


public class Borehole implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, alt_names;
	private Prospect prospect;
	private boolean is_onshore;
	private Date completion;
	private BigDecimal measured_depth;
	private Unit measured_depth_unit;
	private BigDecimal elevation;
	private Unit elevation_unit;
	private List<Inventory> inventory;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public boolean isOnshore(){ return is_onshore; }
	public Prospect getProspect(){ return prospect; }
	public Date getCompletion(){ return completion; }
	public BigDecimal getMeasuredDepth(){ return measured_depth; }
	public Unit getMeasuredDepthUnit(){ return measured_depth_unit; }
	public BigDecimal getElevation(){ return elevation; }
	public Unit getElevationUnit(){ return elevation_unit; }
	public List<Inventory> getInventory(){ return inventory; }
}
