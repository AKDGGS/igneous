package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;

import javax.naming.Context;
import javax.naming.InitialContext;

import java.math.BigDecimal;

import java.util.zip.GZIPOutputStream;
import java.util.ArrayList;
import java.util.Date;

import java.text.DateFormat;
import java.text.NumberFormat;

import java.awt.Color;

import mjson.Json;

import gov.alaska.dggs.solr.SolrQuery;
import gov.alaska.dggs.igneous.api.SearchServlet;

import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.Document;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Element;
import com.lowagie.text.Phrase;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Font;
import com.lowagie.text.Chunk;
import com.lowagie.text.PageSize;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Table;
import com.lowagie.text.Cell;
import com.lowagie.text.Rectangle;


public class SearchServletPDF extends HttpServlet
{
	private final static int PAGE_SIZE = 512;


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		try {
			String app_url = (String)getServletContext().getInitParameter("app_url");

			Context initcontext = new InitialContext();

			String solr_url = (String)initcontext.lookup(
				"java:comp/env/igneous/solr-url"
			);

			String solr_user = null, solr_pass = null;
			try {
				solr_user = (String)initcontext.lookup(
					"java:comp/env/igneous/solr-user"
				);
				solr_pass = (String)initcontext.lookup(
					"java:comp/env/igneous/solr-pass"
				);
			} catch(Exception exe){
				// Explicitly do nothing
			}

			SolrQuery query = (solr_user != null && solr_pass != null) ?
				new SolrQuery(solr_url, solr_user, solr_pass) :
				new SolrQuery(solr_url);

			query.setFields(
				"id, bottom, top, sample, slide, core," +
				"core_diameter, core_diameter_name, core_diameter_unit," +
				"set, box, unit, collection, project, keyword," +
				"wells:[json], boreholes:[json]," +
				"shotlines:[json], outcrops:[json]," +
				"longitude, latitude, description, remark" +
				(
					request.getUserPrincipal() != null ?
					", display_barcode, location" :
					""
				)
			);
			SearchServlet.buildParameters(query, request);
			query.setLimit(PAGE_SIZE);

			OutputStream out = null;
			PdfWriter writer = null;
			try { 
				response.setContentType("application/pdf");

				// If GZIP is supported by the requesting browser, use it.
				String encoding = request.getHeader("Accept-Encoding");
				if(encoding != null && encoding.contains("gzip")){
					response.setHeader("Content-Encoding", "gzip");
					out = new GZIPOutputStream(response.getOutputStream(), 8196);
				} else {
					out = response.getOutputStream();
				}
				
				String last_keyword = "";
				boolean sort_keyword = false;
				String sorts[] = request.getParameterValues("sort");
				if(sorts != null){
					for(int i = 0; i < sorts.length; i++){
						if("sort_keyword".equals(sorts[i])){
							sort_keyword = true;
							break;
						}
					}
				}

				Document d = new Document(PageSize.A4, 15, 15, 10, 10);
				writer = PdfWriter.getInstance(d, out);

				DateFormat fmt = DateFormat.getDateTimeInstance(
					DateFormat.LONG, DateFormat.LONG
				);

				HeaderFooter footer = new HeaderFooter(
					new Phrase(
						(fmt.format(new Date()) + ", Page "),
						FontFactory.getFont(FontFactory.HELVETICA, 10)
					), true
				);
				footer.setAlignment(HeaderFooter.ALIGN_RIGHT);
				footer.setBorder(HeaderFooter.TOP);
				footer.setBorderWidth(1.0f);
				d.setFooter(footer);
				d.open();

				Paragraph p = new Paragraph(
					"Query Results",
					FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16)
				);
				p.setAlignment(Element.ALIGN_CENTER);
				d.add(p);

				Chunk c = new Chunk(
					app_url,
					FontFactory.getFont(FontFactory.HELVETICA, 12, Color.BLUE)
				);
				c.setAnchor(app_url);
				c.setUnderline(0.2f, -3f);

				p = new Paragraph(
					15, "Geologic Materials Center (GMC)\n" +
					"Alaska Department of Natural Resources\n" +
					"Phone: 907-696-0079 || Fax: 907-696-0078\n",
					FontFactory.getFont(FontFactory.HELVETICA, 12)
				);
				p.setAlignment(Element.ALIGN_CENTER);
				p.add(c);

				d.add(p);

				p = new Paragraph(
					10, "Search:\n",
					FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12)
				);
				p.setSpacingAfter(15);
				p.setSpacingBefore(30);
				d.add(p);

				c = new Chunk(
					app_url + "#" + request.getQueryString(),
					FontFactory.getFont(FontFactory.HELVETICA, 12, Color.BLUE)
				);
				c.setAnchor(app_url + "#" + request.getQueryString());
				c.setUnderline(0.2f, -3f);

				p = new Paragraph(c);
				d.add(p);

				p = new Paragraph(
					15, "Search Results:",
					FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12)
				);
				p.setSpacingAfter(5);
				p.setSpacingBefore(30);
				d.add(p);

				// Font used for table header
				Font hfont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9);
				// Font used for table body
				Font bfont = FontFactory.getFont(FontFactory.HELVETICA, 9);
				// Default "Leading" property (leading being the space between lines
				float leading = 9;
				// Color for zebra striping odd rows
				Color oddzebra = Color.WHITE;
				// Color for zebra striping even rows
				Color evenzebra = new Color(221, 221, 221);

				NumberFormat nformat = NumberFormat.getInstance();

				Table table = new Table(
					request.getUserPrincipal() != null ? 9 : 7
				);
				table.setWidth(100); // Table's percentage width

				if(request.getUserPrincipal() != null){
					table.setWidths(new float[]{ // Cells percentage widths
						18,// Related
						10,// Sample/Slide
						7, // Box/Set
						8, // Core No/Diameter
						7, // Top/Bottom
						14,// Keywords
						9, // Collection
						13,// Barcode
						14 // Location
					});
				} else {
					table.setWidths(new float[]{ // Cells percentage widths
						18,// Related
						10,// Sample/Slide
						7, // Box/Set
						8, // Core No/Diameter
						7, // Top/Bottom
						14,// Keywords
						9  // Collection
					});
				}

				table.setBorder(Rectangle.NO_BORDER);
				table.setPadding(1);
				table.setSpacing(0);
				table.setCellsFitPage(true); // Force cells to exist on same page

				// Use this to force a table to fit on a page, and not be broken
				// - this directive is ignored if the table is too big
				// to fit on a page, even alone
				// table.setTableFitsPage(true);

				Cell cell = new Cell();
				cell.setBorder(Rectangle.NO_BORDER);
				cell.setVerticalAlignment(Element.ALIGN_BOTTOM);
				table.setDefaultCell(cell);

				table.addCell(new Paragraph(leading, "Related", hfont));
				table.addCell(new Paragraph(leading, "Sample /\nSlide", hfont));
				table.addCell(new Paragraph(leading, "Box /\nSet", hfont));
				table.addCell(new Paragraph(leading, "Core No /\nDiameter", hfont));
				table.addCell(new Paragraph(leading, "Top /\nBottom", hfont));
				table.addCell(new Paragraph(leading, "Keywords", hfont));
				table.addCell(new Paragraph(leading, "Collection", hfont));
				if(request.getUserPrincipal() != null){
					table.addCell(new Paragraph(leading, "Barcode", hfont));
					table.addCell(new Paragraph(leading, "Location", hfont));
				}
				table.endHeaders();

				cell.setVerticalAlignment(Element.ALIGN_TOP);

				boolean zebra = true;

				// Query a single "page" of PAGE_SIZE
				int pages = 1;
				for(int pg = 0; pg < pages; pg++){
					query.setPage(pg);

					// If Solr returns an error, throw an error
					Json json = query.execute();
					if(json.at("error") != null){
						throw new Exception("Error: " +
							json.at("error").at("msg").asString()
						);
					}

					// Docs should exist and be an array, if not
					// throw an exception
					Json docs = json.at("docs");
					if(docs == null || !docs.isArray()){
						throw new Exception("Invalid result format.");
					}

					// Set total number of pages if unset
					if(pages == 1){
						Json nf = json.at("numFound");
						if(nf != null && nf.isNumber()){
							double pd = Math.max(Math.ceil((nf.asInteger() / PAGE_SIZE) + 1), 1);
							pages = Double.valueOf(pd).intValue();

							// Artifially limit total number of results
							// (since it has to render in memory)
							if(pages > 20) pages = 20;
						}
					}

					// Loop over each result in the page
					for(Json doc : docs.asJsonList()){
						// Generate the keyword field first, as we might need it
						StringBuilder keywords = new StringBuilder();
						if(doc.at("keyword") != null){
							for(Json keyword : doc.at("keyword").asJsonList()){
								if(keywords.length() > 0) keywords.append(", ");
								keywords.append(keyword.getValue());
							}
						}

						// If we're sorting by keyword and the keyword has changed
						// show the keyword as if it were a header
						if(sort_keyword && !last_keyword.equals(keywords.toString())){
							Paragraph kwparagraph = new Paragraph(
								30, keywords.toString(),
								FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13)
							);

							Cell kwcell = new Cell(kwparagraph);
							kwcell.setBackgroundColor(Color.WHITE);
							kwcell.setColspan((request.getUserPrincipal() != null ? 9 : 7));
							table.addCell(kwcell);
							last_keyword = keywords.toString();
							zebra = false;
						} else {
							zebra = !zebra;
						}

						cell.setBackgroundColor(zebra ? oddzebra : evenzebra);
	
						// BEGIN - Related
						StringBuilder related = new StringBuilder();

						// Related - wells
						Json wells = doc.at("wells");
						if(wells != null && wells.isArray()){
							for(Json well : wells.asJsonList()){
								if(related.length() > 0) related.append("\n");

								related.append("Well: ");
								related.append(well.at("name").getValue());

								if(well.at("number") != null){
									related.append(" - ");
									related.append(well.at("number").getValue());
								}

								if(well.at("api") != null){
									related.append("\nAPI: ");
									related.append(well.at("api").getValue());
								}
							}
						}

						// Related - boreholes
						Json boreholes = doc.at("boreholes");
						if(boreholes != null && boreholes.isArray()){
							for(Json borehole : boreholes.asJsonList()){
								if(related.length() > 0) related.append("\n");
								
								Json prospect = borehole.at("prospect");
								if(prospect != null){
									related.append("Prospect: ");
									related.append(prospect.at("name").getValue());
									related.append("\n");
								}

								related.append("Borehole: ");
								related.append(borehole.at("name").getValue());
							}
						}

						// Related - outcrops
						Json outcrops = doc.at("outcrops");
						if(outcrops != null && outcrops.isArray()){
							for(Json outcrop : outcrops.asJsonList()){
								if(related.length() > 0) related.append("\n");

								related.append("Outcrop: ");
								related.append(outcrop.at("name").getValue());

								if(outcrop.at("number") != null){
									related.append(" - ");
									related.append(outcrop.at("number").getValue());
								}
							}
						}

						// Related - shotlines
						Json shotlines = doc.at("shotlines");
						if(shotlines != null && shotlines.isArray()){
							for(Json shotline : shotlines.asJsonList()){
								if(related.length() > 0) related.append("\n");

								related.append("Shotline: ");
								related.append(shotline.at("name").getValue());
								
								if(shotline.at("year") != null){
									related.append(", ");
									related.append(shotline.at("year").getValue());
								}

								if(shotline.at("max") != null){
									related.append("\nShotpoints: ");
									related.append(shotline.at("min").getValue());
									related.append(" - ");
									related.append(shotline.at("max").getValue());
								}
							}
						}

						// Related - project
						if(doc.at("project") != null){
							if(related.length() > 0) related.append("\n");
							related.append("Project: ");
							related.append(doc.at("project").getValue());
						}
						table.addCell(new Paragraph(leading, related.toString(), bfont));
						// END - Related
					
						// Sample/Slide
						StringBuilder sample = new StringBuilder();
						if(doc.at("sample") != null){
							sample.append(doc.at("sample").getValue());
						}
						if(doc.at("slide") != null){
							sample.append("\n");
							sample.append(doc.at("slide").getValue());
						}
						table.addCell(new Paragraph(leading, sample.toString(), bfont));

						// Box/Set
						StringBuilder box = new StringBuilder();
						if(doc.at("box") != null){
							box.append(doc.at("box").getValue());
						}
						if(doc.at("set") != null){
							box.append("\n");
							box.append(doc.at("set").getValue());
						}
						table.addCell(new Paragraph(leading, box.toString(), bfont));

						// Begin "Core No/Diameter"
						StringBuilder core = new StringBuilder();
						if(doc.at("core") != null){
							core.append(doc.at("core").getValue());
						}
						if(doc.at("core_diameter_name") != null){
							core.append("\n");
							core.append(doc.at("core_diameter_name").getValue());
						} else if(doc.at("core_diameter") != null){
							core.append("\n");
							core.append(doc.at("core_diameter").getValue());
							if(doc.at("core_diameter_unit") != null){
								core.append(doc.at("core_diameter_unit").getValue());
							}
						}
						table.addCell(new Paragraph(leading, core.toString(), bfont));
						// End "Core No/Diameter"

						// Begin "Top/Bottom"
						StringBuilder tobo = new StringBuilder();
						if(doc.at("top") != null && doc.at("top").isNumber()){
							tobo.append(nformat.format(
									doc.at("top").asDouble()
							));
							if(doc.at("unit") != null){
								tobo.append(" ");
								tobo.append(doc.at("unit").getValue());
							}
						}
						if(doc.at("bottom") != null && doc.at("bottom").isNumber()){
							tobo.append("\n");
							tobo.append(nformat.format(
								doc.at("bottom").asDouble()
							));
							if(doc.at("unit") != null){
								tobo.append(" ");
								tobo.append(doc.at("unit").getValue());
							}
						}
						table.addCell(new Paragraph(leading, tobo.toString(), bfont));
						// End "Top/Bottom"

						// Keywords - built above
						table.addCell(new Paragraph(leading, keywords.toString(), bfont));

						// Collection
						StringBuilder collection = new StringBuilder();
						if(doc.at("collection") != null){
							collection.append(doc.at("collection").getValue());
						}
						table.addCell(new Paragraph(leading, collection.toString(), bfont));

						if(request.getUserPrincipal() != null){
							// Barcode
							StringBuilder barcode = new StringBuilder();
							if(doc.at("display_barcode") != null){
								barcode.append(doc.at("display_barcode").getValue());
							}
							table.addCell(new Paragraph(leading, barcode.toString(), bfont));

							// Location
							StringBuilder location = new StringBuilder();
							if(doc.at("location") != null){
								location.append(doc.at("location").getValue());
							}
							table.addCell(new Paragraph(leading, location.toString(), bfont));
						}
					}
				}
				d.add(table);
				d.close();
			} finally {
				if(writer != null) writer.close();
				if(out != null) out.close();
			}
		} catch(Exception ex){
			if(!"java.io.IOException: Broken pipe".equals(ex.getMessage())){
				ex.printStackTrace();
			}
		}
	}
}
