package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Date;
import java.util.Map;
import java.math.BigDecimal;


public class Well implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String name, alt_names, well_number, api_number;
	private boolean is_onshore, is_federal;
	private Date completion_date, spud_date;
	private BigDecimal measured_depth, vertical_depth, elevation, elevation_kb;
	private Unit unit;
	private String permit_status, completion_status;

	public int getID(){ return id; }
	public String getName(){ return name; }
	public String getAltNames(){ return alt_names; }
	public String getWellNumber(){ return well_number; }
	public String getAPINumber(){ return api_number; }
	public boolean isOnshore(){ return is_onshore; }
	public boolean isFederal(){ return is_federal; }
	public Date getCompletionDate(){ return completion_date; }
	public Date getSpudDate(){ return spud_date; }
	public BigDecimal getMeasuredDepth(){ return measured_depth; }
	public BigDecimal getVerticalDepth(){ return vertical_depth; }
	public BigDecimal getElevation(){ return elevation; }
	public BigDecimal getElevationKB(){ return elevation_kb; }
	public Unit getUnit(){ return unit; }
	public String getPermitStatus(){ return permit_status; }
	public String getCompletionStatus(){ return completion_status; }
}
