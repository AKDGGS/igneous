package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.List;


public class Publication implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String title, description;
	private Integer year;
	private String type, number, series;
	private boolean can_publish;

	public int getID(){ return id; }
	public String getTitle(){ return title; }
	public String getDescription(){ return description; }
	public Integer getYear(){ return year; }
	public String getType(){ return type; }
	public String getNumber(){ return number; }
	public String getSeries(){ return series; }

	public boolean getCanPublish(){ return can_publish; }
}
