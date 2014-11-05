package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Date;
import java.math.BigDecimal;


public class Borehole implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }
	
	private String alt_names;
	public String getAltNames(){ return alt_names; }

	private Boolean is_onshore;
	// Only "getX" because JSTL requires "isX" methods to return boolean
	public Boolean getOnshore(){ return is_onshore; }

	private Date completion_date;
	public Date getCompletionDate(){ return completion_date; }

	private BigDecimal measured_depth;
	public BigDecimal getMeasuredDepth(){ return measured_depth; }

	private Unit measured_depth_unit;
	public Unit getMeasuredDepthUnit(){ return measured_depth_unit; }

	private BigDecimal elevation;
	public BigDecimal getElevation(){ return elevation; }

	private Unit elevation_unit;
	public Unit getElevationUnit(){ return elevation_unit; }

	private Prospect prospect;
	public Prospect getProspect(){ return prospect; }

	private List<Inventory> inventory;
	public List<Inventory> getInventory(){ return inventory; }

	private List<Organization> organizations;
	public List<Organization> getOrganizations(){ return organizations; }
}
