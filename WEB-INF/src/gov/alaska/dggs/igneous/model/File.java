package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class File implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	public int getID(){ return id; }

	private String filename;
	public String getFilename(){ return filename; }

	private String description;
	public String getDescription(){ return description; }

	private String mimetype;
	public String getMimeType(){ return mimetype; }

	// Returns a simplified version of the mime type for easy classification
	public String getSimpleType()
	{
		if(this.mimetype == null){ return "unknown"; }
		if(this.mimetype.indexOf("text") == 0){ return "text"; }
		if(this.mimetype.indexOf("image") == 0){ return "image"; }
		if(this.mimetype.indexOf("audio") == 0){ return "audio"; }
		if(this.mimetype.indexOf("application") == 0){ return "application"; }
		if(this.mimetype.indexOf("video") == 0){ return "video"; }
		return "unknown";
	}

	private Long size;
	public Long getSize(){ return size; }
	public String getSizeString()
	{
		if(size > 1073741824){
			return String.valueOf(Math.round(size / 1073741824)) + "Gb";
		}

		if(size > 1048567){
			return String.valueOf(Math.round(size / 1048567)) + "Mb";
		}

		if(size > 1024){
			return String.valueOf(Math.round(size / 1024)) + "Kb";
		}

		return String.valueOf(size) + "b";
	}


	private FileType type;
	public FileType getType(){ return type; }
}
