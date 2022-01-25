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
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String alt_names;
	public String getAltNames(){ return alt_names; }

	private String well_number;
	public String getWellNumber(){ return well_number; }

	private String api_number;
	public String getAPINumber(){ return api_number; }

	private Boolean is_onshore;
	// Only "getX" because JSTL requires "isX" methods to return boolean
	public Boolean getOnshore(){ return is_onshore; }

	private Boolean is_federal;
	// Only "getX" because JSTL requires "isX" methods to return boolean
	public Boolean getFederal(){ return is_federal; }

	private Date completion_date;
	public Date getCompletionDate(){ return completion_date; }

	private Date spud_date;
	public Date getSpudDate(){ return spud_date; }

	private BigDecimal measured_depth;
	public BigDecimal getMeasuredDepth(){ return measured_depth; }

	private BigDecimal vertical_depth;
	public BigDecimal getVerticalDepth(){ return vertical_depth; }

	private BigDecimal elevation;
	public BigDecimal getElevation(){ return elevation; }

	private BigDecimal elevation_kb;
	public BigDecimal getElevationKB(){ return elevation_kb; }
	
	private String unit;
	public String getUnit(){ return unit; }

	private String permit_status;
	public String getPermitStatus(){ return permit_status; }

	private Integer permit_number;
	public Integer getPermitNumber(){return permit_number;}

	private String completion_status;
	public String getCompletionStatus(){ return completion_status; }

	private List<Organization> operators;
	public List<Organization> getOperators(){ return operators; }

	private List<Note> notes;
	public List<Note> getNotes(){ return notes; }

	private List<URL> urls;
	public List<URL> getURLs(){ return urls; }

	private List<File> files;
	public List<File> getFiles(){ return files; }
}
