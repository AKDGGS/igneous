package gov.alaska.dggs.igneous.model;

import java.io.Serializable;


public class Audit implements Serializable
{
	private static final long serialVersionUID = 1L;

	private int id;
	private AuditGroup group;
	private String barcode;

	public int getID(){ return id; }

	public AuditGroup getGroup(){ return group; }
	public void setGroup(AuditGroup group){ this.group = group; }
	public String getBarcode(){ return barcode; }
	public void setBarcode(String barcode){ this.barcode = barcode; }
}
