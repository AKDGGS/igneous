package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;
import java.util.Date;


public class Inventory implements Serializable
{
	private static final long serialVersionUID = 1L;


	private Integer id;
	public Integer getID(){ return id; }

	private Integer parent_id;
	public Integer getParentID(){ return parent_id; }

	private Collection collection;
	public Collection getCollection(){ return collection; }

	private Project project;
	public Project getProject(){ return project; }

	private Container container;
	public Container getContainer(){ return container; }

	private BigDecimal dggs_sample_id;
	public BigDecimal getDGGSSampleID(){ return dggs_sample_id; }

	private String sample_number;
	public String getSampleNumber(){ return sample_number; }

	private String sample_number_prefix;
	public String getSampleNumberPrefix(){ return sample_number_prefix; }

	private String alt_sample_number;
	public String getAltSampleNumber(){ return alt_sample_number; }

	private String published_sample_number;
	public String getPublishedSampleNumber(){ return published_sample_number; }

	private Boolean published_number_has_suffix;
	public Boolean getPublishedNumberHasSuffix(){ return published_number_has_suffix; }

	private String barcode;
	public String getBarcode(){ return barcode; }
	public void setBarcode(String barcode){ this.barcode = barcode; }

	private String alt_barcode;
	public String getAltBarcode(){ return alt_barcode; }

	private String state_number;
	public String getStateNumber(){ return state_number; }

	private String box_number;
	public String getBoxNumber(){ return box_number; }

	private String set_number;
	public String getSetNumber(){ return set_number; }

	private String split_number;
	public String getSplitNumber(){ return split_number; }

	private String slide_number;
	public String getSlideNumber(){ return slide_number; }

	private String slip_number;
	public String getSlipNumber(){ return slip_number; }

	private String lab_number;
	public String getLabNumber(){ return lab_number; }

	private String map_number;
	public String getMapNumber(){ return map_number; }

	private String description;
	public String getDescription(){ return description; }

	private String remark;
	public String getRemark(){ return remark; }
	public void setRemark(String remark){ this.remark = remark; }

	private Integer tray;
	public Integer getTray(){ return tray; }

	private BigDecimal interval_top;
	public BigDecimal getIntervalTop(){ return interval_top; }

	private BigDecimal interval_bottom;
	public BigDecimal getIntervalBottom(){ return interval_bottom; }

	private Unit interval_unit;
	public Unit getIntervalUnit(){ return interval_unit; }

	private String core_number;
	public String getCoreNumber(){ return core_number; }

	private CoreDiameter core_diameter;
	public CoreDiameter getCoreDiameter(){ return core_diameter; }

	private BigDecimal weight;
	public BigDecimal getWeight(){ return weight; }

	private Unit weight_unit;
	public Unit getWeightUnit(){ return weight_unit; }

	private String sample_frequency;
	public String getSampleFrequency(){ return sample_frequency; }

	private String recovery;
	public String getRecovery(){ return recovery; }

	private Boolean can_publish;
	public Boolean getCanPublish(){ return can_publish; }

	private Boolean skeleton;
	public Boolean getSkeleton(){ return skeleton; }

	private BigDecimal radiation_msvh;
	public BigDecimal getRadiationMSVH(){ return radiation_msvh; }

	private Date received;
	public Date getReceived(){ return received; }

	private Date entered;
	public Date getEntered(){ return entered; }

	private Date modified;
	public Date getModified(){ return modified; }

	private Boolean active;
	public Boolean getActive(){ return active; }


	// Many-to-many object links
	private List<Keyword> keywords;
	public List<Keyword> getKeywords(){ return keywords; }

	private List<Borehole> boreholes;
	public List<Borehole> getBoreholes(){ return boreholes; }

	private List<Well> wells;
	public List<Well> getWells(){ return wells; }

	private List<Outcrop> outcrops;
	public List<Outcrop> getOutcrops(){ return outcrops; }

	private List<Shotpoint> shotpoints;
	public List<Shotpoint> getShotpoints(){ return shotpoints; }

	private List<File> files;
	public List<File> getFiles(){ return files; }

	private List<Publication> publications;
	public List<Publication> getPublications(){ return publications; }

	private List<Note> notes;
	public List<Note> getNotes(){ return notes; }

	private List<InventoryQuality> qualities;
	public List<InventoryQuality> getQualities(){ return qualities; }

	private List<ContainerLog> containerlog;
	public List<ContainerLog> getContainerLog(){ return containerlog; }


	// Fields that do not corrospond to a field in the database
	private List<Shotline> shotlines;
	public List<Shotline> getShotlines(){ return shotlines; }

	private String container_path;
	public String getContainerPath(){ return container_path; }

	private String wkt;
	public String getWKT(){ return wkt; }

	private String bin;
	public String getBin(){ return bin; }
}
