package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.Date;


public class Token implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String token;
	public String getToken(){ return token; }

	private String description;
	public String getDescription(){ return description; }
}
