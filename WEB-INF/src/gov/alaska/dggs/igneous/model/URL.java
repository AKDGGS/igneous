package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.Date;

public class URL implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String url;
	public String getURL(){ return url; }

	private String description;
	public String getDescription(){ return description; }

	private String url_type;
	public String getURLType(){ return url_type; }
}
