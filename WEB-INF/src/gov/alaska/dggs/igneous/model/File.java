package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class File implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private String filename, description, mimetype;
	private long size;
	private FileType type;

	public int getID(){ return id; }
	public String getFilename(){ return filename; }
	public String getDescription(){ return description; }
	public String getMimeType(){ return mimetype; }
	public long getSize(){ return size; }

	public FileType getType(){ return type; }
}
