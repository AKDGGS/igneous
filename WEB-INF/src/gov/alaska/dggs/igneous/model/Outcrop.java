package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


public class Outcrop implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String name;
	public String getName(){ return name; }

	private String number;
	public String getNumber(){ return number; }

	private Integer year;
	public Integer getYear(){ return year; }

	private Boolean is_onshore;
	// Only "getX" because JSTL requires "isX" methods to return boolean
	public Boolean getOnshore(){ return is_onshore; }

	private List<Note> notes;
	public List<Note> getNotes(){ return notes; }

	private List<Organization> organizations;
	public List<Organization> getOrganizations(){ return organizations; }

	private List<File> files;
	public List<File> getFiles(){ return files; }
}
