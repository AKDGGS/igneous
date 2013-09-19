package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Date;
import java.util.Map;


public class Well implements Serializable
{
	private static final long serialVersionUID = 1L;

	private long id;
	private String name, alt_names;
	private String well_number, api_number;
	private boolean is_onshore;
	private Date completion, spud;
	private long measured_depth;
	private Unit measured_depth_unit;
	private long vertical_depth;
	private Unit vertical_depth_unit;
	private long elevation;
	private Unit elevation_unit;
	private String permit_status, completion_status;


	public long getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public String getAPINumber(){ return api_number; }
	public String getWellNumber(){ return well_number; }
	public boolean isOnshore(){ return is_onshore; }
	public Date getCompletion(){ return completion; }
	public Date getSpud(){ return spud; }
	public long getMeasuredDepth(){ return measured_depth; }
	public Unit getMeasuredDepthUnit(){ return measured_depth_unit; }
	public long getVerticalDepth(){ return vertical_depth; }
	public Unit getVerticalDepthUnit(){ return vertical_depth_unit; }
	public long getElevation(){ return elevation; }
	public Unit getElevationUnit(){ return elevation_unit; }
	public String getPermitStatus(){ return permit_status; }
	public String getCompletionStatus(){ return completion_status; }
}
