package gov.alaska.dggs.igneous.model;

import java.io.Serializable;
import java.util.Date;


public class Note implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private NoteType type;
	public NoteType getType(){ return type; }

	private String note;
	public String getNote(){ return note; }

	private Date date;
	public Date getDate(){ return date; }

	private Boolean is_public;
	public Boolean getIsPublic(){ return is_public; }

	private String username;
	public String getUsername(){ return username; }

	private Boolean active;
	public Boolean getActive(){ return active; }
}
