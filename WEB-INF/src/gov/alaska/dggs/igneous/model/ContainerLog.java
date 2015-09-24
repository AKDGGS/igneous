package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.Date;


public class ContainerLog implements Serializable
{
	private static final long serialVersionUID = 1L;

	private Integer id;
	public Integer getID(){ return id; }

	private String container;
	public String getContainer(){ return container; }

	private Date date;
	public Date getDate(){ return date; }
}
