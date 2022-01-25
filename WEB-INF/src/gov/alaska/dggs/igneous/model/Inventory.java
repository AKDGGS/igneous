package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;
import java.util.Date;
import java.text.DateFormat;
import flexjson.JSON;


public class Inventory implements Serializable
{
	private static final long serialVersionUID = 1L;


	private Integer id;
	public Integer getID(){ return id; }
	public void setID(Integer id){ this.id = id; }

	private Integer parent_id;
	public Integer getParentID(){ return parent_id; }

	private Collection collection;
	public Collection getCollection(){ return collection; }

	private Project project;
	public Project getProject(){ return project; }

	private Container container;
	public Container getContainer(){ return container; }
	public void setContainer(Container container){ this.container = container; }

	private Long dggs_sample_id;
	public Long getDGGSSampleID(){ return dggs_sample_id; }
	public void setDGGSSampleID(Long dggs_sample_id){ this.dggs_sample_id = dggs_sample_id; }
	public void setDGGSSampleIDString(String dggs_sample_id) throws Exception
	{
		if(dggs_sample_id == null || dggs_sample_id.trim().length() == 0){
			this.dggs_sample_id = null;
		} else {
			try { this.dggs_sample_id = Long.valueOf(dggs_sample_id); }
			catch(Exception ex){
				throw new Exception("Invalid ID");
			}
		}
	}

	private String lab_report_id;
	public String getLabReportID(){ return lab_report_id; }
	public void setLabReportID(String lab_report_id) throws Exception
	{
		if(lab_report_id != null){
			lab_report_id = lab_report_id.trim();
			if(lab_report_id.length() == 0) lab_report_id = null;
			else if(lab_report_id.length() > 100)
				throw new Exception("ID too large (>100 characters)");
		}	
		this.lab_report_id = lab_report_id;
	}

	private String sample_number;
	public String getSampleNumber(){ return sample_number; }
	public void setSampleNumber(String sample_number) throws Exception
	{
		if(sample_number != null){
			sample_number = sample_number.trim();
			if(sample_number.length() == 0) sample_number = null;
			else if(sample_number.length() > 50)
				throw new Exception("Number too large (>50 characters)");
		}	
		this.sample_number = sample_number;
	}

	private String sample_number_prefix;
	public String getSampleNumberPrefix(){ return sample_number_prefix; }
	public void setSampleNumberPrefix(String sample_number_prefix) throws Exception
	{
		if(sample_number_prefix != null){
			sample_number_prefix = sample_number_prefix.trim();
			if(sample_number_prefix.length() == 0) sample_number_prefix = null;
			else if(sample_number_prefix.length() > 25)
				throw new Exception("Prefix too large (>25 characters)");
		}	
		this.sample_number_prefix = sample_number_prefix;
	}

	private String alt_sample_number;
	public String getAltSampleNumber(){ return alt_sample_number; }
	public void setAltSampleNumber(String alt_sample_number) throws Exception
	{
		if(alt_sample_number != null){
			alt_sample_number = alt_sample_number.trim();
			if(alt_sample_number.length() == 0) alt_sample_number = null;
			else if(alt_sample_number.length() > 25)
				throw new Exception("Number too large (>25 characters)");
		}	
		this.alt_sample_number = alt_sample_number;
	}

	private String published_sample_number;
	public String getPublishedSampleNumber(){ return published_sample_number; }
	public void setPublishedSampleNumber(String published_sample_number) throws Exception
	{
		if(published_sample_number != null){
			published_sample_number = published_sample_number.trim();
			if(published_sample_number.length() == 0)
				published_sample_number = null;
			else if(published_sample_number.length() > 25)
				throw new Exception("Number too large (>25 characters)");
		}	
		this.published_sample_number = published_sample_number;
	}

	private Boolean published_number_has_suffix;
	public Boolean getPublishedNumberHasSuffix(){ return published_number_has_suffix; }
	public void setPublishedNumberHasSuffix(Boolean published_number_has_suffix){ this.published_number_has_suffix = published_number_has_suffix; }
	public void setPublishedNumberHasSuffixString(String published_number_has_suffix)
	{
		this.published_number_has_suffix = Boolean.valueOf(published_number_has_suffix);
	}

	private String barcode;
	public String getBarcode(){ return barcode; }
	public void setBarcode(String barcode) throws Exception
	{
		if(barcode != null){
			barcode = barcode.trim();
			if(barcode.length() == 0) barcode = null;
			else if(barcode.length() > 25)
				throw new Exception("Barcode too large (>25 characters)");
		}
		this.barcode = barcode;
	}

	private String alt_barcode;
	public String getAltBarcode(){ return alt_barcode; }
	public void setAltBarcode(String alt_barcode) throws Exception
	{
		if(alt_barcode != null){
			alt_barcode = alt_barcode.trim();
			if(alt_barcode.length() == 0) alt_barcode = null;
			else if(alt_barcode.length() > 25)
				throw new Exception("Barcode too large (>25 characters)");
		}
		this.alt_barcode = alt_barcode;
	}

	private String state_number;
	public String getStateNumber(){ return state_number; }
	public void setStateNumber(String state_number) throws Exception
	{
		if(state_number != null){
			state_number = state_number.trim();
			if(state_number.length() == 0) state_number = null;
			else if(state_number.length() > 50)
				throw new Exception("Number too large (>50 characters)");
		}
		this.state_number = state_number;
	}

	private String box_number;
	public String getBoxNumber(){ return box_number; }
	public void setBoxNumber(String box_number) throws Exception
	{
		if(box_number != null){
			box_number = box_number.trim();
			if(box_number.length() == 0) box_number = null;
			else if(box_number.length() > 50)
				throw new Exception("Number too large (>50 characters)");
		}
		this.box_number = box_number;
	}

	private String set_number;
	public String getSetNumber(){ return set_number; }
	public void setSetNumber(String set_number) throws Exception
	{
		if(set_number != null){
			set_number = set_number.trim();
			if(set_number.length() == 0) set_number = null;
			else if(set_number.length() > 50)
				throw new Exception("Number too large (>50 characters)");
		}
		this.set_number = set_number;
	}

	private String split_number;
	public String getSplitNumber(){ return split_number; }
	public void setSplitNumber(String split_number) throws Exception
	{
		if(split_number != null){
			split_number = split_number.trim();
			if(split_number.length() == 0) split_number = null;
			else if(split_number.length() > 10)
				throw new Exception("Number too large (>50 characters)");
		}
		this.split_number = split_number;
	}

	private String slide_number;
	public String getSlideNumber(){ return slide_number; }
	public void setSlideNumber(String slide_number) throws Exception
	{
		if(slide_number != null){
			slide_number = slide_number.trim();
			if(slide_number.length() == 0) slide_number = null;
			else if(slide_number.length() > 10)
				throw new Exception("Number too large (>50 characters)");
		}
		this.slide_number = slide_number;
	}

	private Integer slip_number;
	public Integer getSlipNumber(){ return slip_number; }
	public void setSlipNumber(Integer slip_number){ this.slip_number = slip_number; }
	public void setSlipNumberString(String slip_number) throws Exception
	{
		if(slip_number == null || slip_number.trim().length() == 0)
			this.slip_number = null;
		else {
			try { this.slip_number = Integer.valueOf(slip_number); }
			catch(Exception ex){
				throw new Exception("Invalid number");
			}
		}
	}

	private String lab_number;
	public String getLabNumber(){ return lab_number; }
	public void setLabNumber(String lab_number) throws Exception
	{
		if(lab_number != null){
			lab_number = lab_number.trim();
			if(lab_number.length() == 0) lab_number = null;
			else if(lab_number.length() > 100)
				throw new Exception("Number too large (>100 characters)");
		}
		this.lab_number = lab_number;
	}

	private String map_number;
	public String getMapNumber(){ return map_number; }
	public void setMapNumber(String map_number) throws Exception
	{
		if(map_number != null){
			map_number = map_number.trim();
			if(map_number.length() == 0) map_number = null;
			else if(map_number.length() > 25)
				throw new Exception("Number too large (>25 characters)");
		}
		this.map_number = map_number;
	}

	private String description;
	public String getDescription(){ return description; }
	public void setDescription(String description)
	{
		if(description != null){
			description = description.trim();
			if(description.length() == 0) description = null;
		}
		this.description = description;
	}

	private String remark;
	public String getRemark(){ return remark; }
	public void setRemark(String remark)
	{
		if(remark != null){
			remark = remark.trim();
			if(remark.length() == 0) remark = null;
		}
		this.remark = remark;
	}

	private Integer tray;
	public Integer getTray(){ return tray; }
	public void setTray(Integer tray){ this.tray = tray; }
	public void setTrayString(String tray) throws Exception
	{
		if(tray == null || tray.trim().length() == 0)
			this.tray = null;
		else {
			try { this.tray = Integer.valueOf(tray); }
			catch(Exception ex){
				throw new Exception("Invalid number");
			}
		}
	}

	private BigDecimal intervalTop;
	public BigDecimal getIntervalTop(){ return intervalTop; }
	public void setIntervalTop(BigDecimal intervalTop){ this.intervalTop = intervalTop; }
	public void setIntervalTopString(String intervalTop) throws Exception
	{
		if(intervalTop == null || intervalTop.trim().length() == 0){
			this.intervalTop = null;
		} else {
			BigDecimal n = null;
			try { n = new BigDecimal(intervalTop); }
			catch(Exception ex){ throw new Exception("Invalid number"); }
			if(n.precision() > 8 || n.scale() > 2){
				throw new Exception("Number too big (precision>8 or scale>2)");
			}
			this.intervalTop = n;
		}
	}

	private BigDecimal intervalBottom;
	public BigDecimal getIntervalBottom(){ return intervalBottom; }
	public void setIntervalBottom(BigDecimal intervalBottom) throws Exception {
		this.intervalBottom = intervalBottom;
	}
	public void setIntervalBottomString(String intervalBottom) throws Exception {
		if(intervalBottom == null || intervalBottom.trim().length() == 0){
			this.intervalBottom = null;
		} else {
			BigDecimal n = null;
			try { n = new BigDecimal(intervalBottom); }
			catch(Exception ex){ throw new Exception("Invalid number"); }
			if(n.precision() > 8 || n.scale() > 2){
				throw new Exception("Number too big (precision>8 or scale>2)");
			}
			this.intervalBottom = n;
		}
	}

	private String interval_unit;
	public String getIntervalUnit(){ return interval_unit; }

	private String core_number;
	public String getCoreNumber(){ return core_number; }
	public void setCoreNumber(String core_number) throws Exception
	{
		if(core_number != null){
			core_number = core_number.trim();
			if(core_number.length() == 0) core_number = null;
			else if(core_number.length() > 25)
				throw new Exception("Number too large (>25 characters)");
		}
		this.core_number = core_number;
	}

	private CoreDiameter core_diameter;
	public CoreDiameter getCoreDiameter(){ return core_diameter; }

	private BigDecimal weight;
	public BigDecimal getWeight(){ return weight; }
	public void setWeight(BigDecimal weight){ this.weight = weight; }
	public void setWeightString(String weight) throws Exception {
		if(weight == null || weight.trim().length() == 0){
			this.weight = null;
		} else {
			BigDecimal n = null;
			try { n = new BigDecimal(weight); }
			catch(Exception ex){ throw new Exception("Invalid number"); }
			if(n.precision() > 8 || n.scale() > 2){
				throw new Exception("Number too big (precision>8 or scale>2)");
			}
			this.weight = n;
		}
	}

	private String weight_unit;
	public String getWeightUnit(){ return weight_unit; }

	private String sample_frequency;
	public String getSampleFrequency(){ return sample_frequency; }
	public void setSampleFrequency(String sample_frequency) throws Exception
	{
		if(sample_frequency != null){
			sample_frequency = sample_frequency.trim();
			if(sample_frequency.length() == 0) sample_frequency = null;
			else if(sample_frequency.length() > 25)
				throw new Exception("Frequency too large (>25 characters)");
		}
		this.sample_frequency = sample_frequency;
	}

	private String recovery;
	public String getRecovery(){ return recovery; }
	public void setRecovery(String recovery) throws Exception
	{
		if(recovery != null){
			recovery = recovery.trim();
			if(recovery.length() == 0) recovery = null;
			else if(recovery.length() > 25)
				throw new Exception("Recovery too large (>25 characters)");
		}
		this.recovery = recovery;
	}

	private Boolean can_publish;
	public Boolean getCanPublish(){ return can_publish; }
	public void setCanPublish(Boolean can_publish){ this.can_publish = can_publish; }
	public void setCanPublishString(String can_publish)
	{
		this.can_publish = Boolean.valueOf(can_publish);
	}

	private BigDecimal radiation_msvh;
	public BigDecimal getRadiationMSVH(){ return radiation_msvh; }
	public void setRadiationMSVH(BigDecimal radiation_msvh){ this.radiation_msvh = radiation_msvh; }
	public void setRadiationMSVHString(String radiation_msvh) throws Exception {
		if(radiation_msvh == null || radiation_msvh.trim().length() == 0){
			this.radiation_msvh = null;
		} else {
			BigDecimal n = null;
			try { n = new BigDecimal(radiation_msvh); }
			catch(Exception ex){ throw new Exception("Invalid number"); }
			if(n.precision() > 10 || n.scale() > 2){
				throw new Exception("Number too big (precision>10 or scale>2)");
			}
			this.radiation_msvh = n;
		}
	}

	private Date received;
	public Date getReceived(){ return received; }
	public void setReceived(Date received){ this.received = received; }
	public void setReceivedString(String received) throws Exception
	{
		if(received == null || received.trim().length() == 0){
			this.received = null;
		} else {
			DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);
			try { this.received = df.parse(received); }
			catch(Exception ex){
				throw new Exception("Invalid date");
			}
		}
	}

	private Date entered;
	public Date getEntered(){ return entered; }
	public void setEntered(Date entered){ this.entered = entered; }
	public void setEnteredString(String entered) throws Exception
	{
		if(entered == null || entered.trim().length() == 0){
			this.entered = null;
		} else {
			DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);
			try { this.entered = df.parse(entered); }
			catch(Exception ex){
				throw new Exception("Invalid date");
			}
		}
	}

	private Date modified;
	public Date getModified(){ return modified; }

	private String user;
	public String getUser(){ return user; }
	public void setUser(String user){ this.user = user; }

	private Boolean active;
	public Boolean getActive(){ return active; }
	public void setActive(Boolean active){ this.active = active; }
	public void setActiveString(String active)
	{
		this.active = Boolean.valueOf(active);
	}

	private String[] keywords;
	public String[] getKeywords(){ return keywords; }
	public void setKeywords(String[] keywords){ this.keywords = keywords; }


	// Many-to-many object links
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

	private List<URL> urls;
	public List<URL> getURLs(){ return urls; }


	// Fields that do not corrospond to a field in the database
	private List<Shotline> shotlines;
	public List<Shotline> getShotlines(){ return shotlines; }

	private String container_path;
	public String getContainerPath(){ return container_path; }

	private String geojson;
	public String getGeoJSON(){ return geojson; }

	private BigDecimal longitude;
	public BigDecimal getLongitude(){ return longitude; }

	private BigDecimal latitude;
	public BigDecimal getLatitude(){ return latitude; }

	private String bin;
	public String getBin(){ return bin; }
}
