package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


public class Inventory implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String sample_number, barcode, alt_barcode;
	private String description;
	private String box, set, core, state;
	private String wkt;
	private Integer interval_top, interval_bottom;
	private Unit interval_unit;
	private Collection collection;
	private CoreDiameter core_diameter;
	private Project project;

	private String container_path;

	private List<Keyword> keywords;
	private List<Borehole> boreholes;
	private List<Well> wells;
	private List<Outcrop> outcrops;
	private List<Shotpoint> shotpoints;
	private List<File> files;

	public int getID(){ return id; }
	public String getBarcode(){ return barcode; }
	public String getAltBarcode(){ return alt_barcode; }
	public String getSampleNumber(){ return sample_number; }
	public String getContainerPath(){ return container_path; }
	public String getBox(){ return box; }
	public String getState(){ return state; }
	public String getCore(){ return core; }
	public String getSet(){ return set; }
	public String getDescription(){ return description; }
	public String getWKT(){ return wkt; }

	public Integer getIntervalTop(){ return interval_top; }
	public Integer getIntervalBottom(){ return interval_bottom; }
	public Unit getIntervalUnit(){ return interval_unit; }

	public CoreDiameter getCoreDiameter(){ return core_diameter; }
	public Collection getCollection(){ return collection; }
	public Project getProject(){ return project; }

	public List<Keyword> getKeywords(){ return keywords; }
	public List<Borehole> getBoreholes(){ return boreholes; }
	public List<Well> getWells(){ return wells; }
	public List<Outcrop> getOutcrops(){ return outcrops; }
	public List<Shotpoint> getShotpoints(){ return shotpoints; }
	public List<File> getFiles(){ return files; }
}
