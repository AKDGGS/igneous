package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStreamWriter;

import javax.naming.Context;
import javax.naming.InitialContext;

import java.math.BigDecimal;
import java.util.zip.GZIPOutputStream;
import java.util.ArrayList;

import mjson.Json;

import gov.alaska.dggs.solr.SolrQuery;
import gov.alaska.dggs.igneous.api.SearchServlet;

import org.supercsv.io.CsvListWriter;
import org.supercsv.prefs.CsvPreference;
import org.supercsv.cellprocessor.ift.CellProcessor;
import org.supercsv.cellprocessor.Optional;
import org.supercsv.cellprocessor.constraint.NotNull;
import org.supercsv.cellprocessor.StrReplace;


public class SearchServletCSV extends HttpServlet
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

			OutputStreamWriter out = null;
			GZIPOutputStream gos = null;
			CsvListWriter writer = null;
			try { 
				response.setContentType("text/csv");

				// If GZIP is supported by the requesting browser, use it.
				String encoding = request.getHeader("Accept-Encoding");
				if(encoding != null && encoding.contains("gzip")){
					response.setHeader("Content-Encoding", "gzip");
					gos = new GZIPOutputStream(response.getOutputStream(), 8196);
					out = new OutputStreamWriter(gos, "utf-8");
				} else {
					out = new OutputStreamWriter(response.getOutputStream(), "utf-8");
				}
				writer = new CsvListWriter(
					out, CsvPreference.EXCEL_PREFERENCE
				);

				CellProcessor processors[] = null;
				String header[] = null;
				if(request.getUserPrincipal() != null){
					processors = new CellProcessor[]{
						new NotNull(),  // ID
						new Optional(new StrReplace("(\r\n|\n|\r)", ";")), // Related
						new Optional(), // Sample
						new Optional(), // Slide
						new Optional(), // Box
						new Optional(), // Set
						new Optional(), // Core Number
						new Optional(), // Core Diameter
						new Optional(), // Core Diameter Units
						new Optional(), // Top
						new Optional(), // Bottom
						new Optional(), // Top/Bottom Units
						new Optional(), // Keywords
						new Optional(), // Collection
						new Optional(), // Barcode
						new Optional(), // Location
						new Optional(), // Longitude
						new Optional(), // Latitude
						new Optional(), // Datum
						new Optional(), // Description
						new Optional()  // Remarks
					};
					header = new String[]{
						"id", "Related", "Sample", "Slide",
						"Box", "Set", "Core Number",
						"Core Diameter", "Core Diameter Units", 
						"Top", "Bottom", "Top/Bottom Units",
						"Keywords", "Collection", "Barcode", "Location",
						"Longitude", "Latitude",
						"Datum", "Description", "Remarks"
					};
				} else {
					processors = new CellProcessor[]{
						new NotNull(),  // ID
						new Optional(new StrReplace("(\r\n|\n|\r)", ";")), // Related
						new Optional(), // Sample
						new Optional(), // Slide
						new Optional(), // Box
						new Optional(), // Set
						new Optional(), // Core Number
						new Optional(), // Core Diameter
						new Optional(), // Core Diameter Units
						new Optional(), // Top
						new Optional(), // Bottom
						new Optional(), // Top/Bottom Units
						new Optional(), // Keywords
						new Optional(), // Collection
						new Optional(), // Longitude
						new Optional(), // Latitude
						new Optional(), // Datum
						new Optional(), // Description
						new Optional()  // Remarks
					};
					header = new String[]{
						"id", "Related", "Sample", "Slide", 
						"Box", "Set", "Core Number",
						"Core Diameter", "Core Diameter Units", 
						"Top", "Bottom", "Top/Bottom Units",
						"Keywords", "Collection",
						"Longitude", "Latitude",
						"Datum", "Description", "Remarks"
					};
				}

				writer.writeHeader(header);

				int pages = 1;
				for(int pg = 0; pg < pages; pg++){
					query.setPage(pg);

					Json json = query.execute();
					if(json.at("error") != null){
						throw new Exception("Error: " +
							json.at("error").at("msg").asString()
						);
					}

					Json docs = json.at("docs");
					if(docs == null || !docs.isArray()){
						throw new Exception("Invalid result format.");
					}

					// Set total number of pages if unset
					if(pages == 1){
						Json nf = json.at("numFound");
						if(nf != null && nf.isNumber()){
							double d = Math.max(Math.ceil((nf.asInteger() / PAGE_SIZE) + 1), 1);
							pages = Double.valueOf(d).intValue();
						}
					}

					for(Json doc : docs.asJsonList()){
						ArrayList<Object> row = new ArrayList<Object>(header.length);

						// ID
						if(doc.at("id") != null){
							row.add(doc.at("id").getValue());
						} else row.add(null);
	
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
									related.append("Propsect: ");
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

						if(related.length() > 0){
							row.add(related.toString());
						} else row.add(null);
						// END - Related
						
						// Sample
						if(doc.at("sample") != null){
							row.add(doc.at("sample").getValue());	
						} else row.add(null);

						// Slide
						if(doc.at("slide") != null){
							row.add(doc.at("slide").getValue());
						} else row.add(null);

						// Box
						if(doc.at("box") != null){
							row.add(doc.at("box").getValue());
						} else row.add(null);

						// Set
						if(doc.at("set") != null){
							row.add(doc.at("set").getValue());
						} else row.add(null);

						// Core Number
						if(doc.at("core") != null){
							row.add(doc.at("core").getValue());
						} else row.add(null);

						// Core Diameter
						if(doc.at("core_diameter_name") != null){
							row.add(doc.at("core_diameter_name").getValue());
							row.add(null);
						} else if(doc.at("core_diameter") != null){
							row.add(doc.at("core_diameter").getValue());
							if(doc.at("core_diameter_unit") != null){
								row.add(doc.at("core_diameter_unit").getValue());
							} else row.add(null);
						} else {
							row.add(null);
							row.add(null);
						}

						// Top
						if(doc.at("top") != null){
							row.add(doc.at("top").getValue());
						} else row.add(null);

						// Bottom
						if(doc.at("bottom") != null){
							row.add(doc.at("bottom").getValue());
						} else row.add(null);

						// Top/Bottom Units
						if(doc.at("unit") != null && (doc.at("bottom") != null || doc.at("top") != null)){
							row.add(doc.at("unit").getValue());	
						} else row.add(null);

						// Keywords
						if(doc.at("keyword") != null){
							StringBuilder keywords = new StringBuilder();
							for(Json keyword : doc.at("keyword").asJsonList()){
								if(keywords.length() > 0) keywords.append(", ");
								keywords.append(keyword.getValue());
							}

							if(keywords.length() > 0){
								row.add(keywords.toString());
							} else row.add(null);
						} else row.add(null);

						// Collection
						if(doc.at("collection") != null){
							row.add(doc.at("collection").getValue());
						} else row.add(null);

						if(request.getUserPrincipal() != null){
							// Barcode
							if(doc.at("display_barcode") != null){
								row.add(doc.at("display_barcode").getValue());
							} row.add(null);

							// Location
							if(doc.at("location") != null){
								row.add(doc.at("location").getValue());
							} row.add(null);
						}

						// Latitude
						if(doc.at("latitude") != null){
							row.add(doc.at("latitude").getValue());
						} else row.add(null);

						// Longitude
						if(doc.at("longitude") != null){
							row.add(doc.at("longitude").getValue());
						} else row.add(null);

						// Datum
						if(doc.at("longitude") != null && doc.at("latitude") != null){
							row.add("WGS84");
						} else row.add(null);

						// Description
						if(doc.at("description") != null){
							row.add(doc.at("description").getValue());
						} else row.add(null);

						// Remark
						if(doc.at("remark") != null){
							row.add(doc.at("remark").getValue());
						} else row.add(null);

						writer.write(row, processors);
					}
					writer.flush();
				}
			} finally {
				if(writer != null) writer.close();
				if(out != null) out.close();
				if(gos != null) gos.close();
			}
		} catch(Exception ex){
			if(!"java.io.IOException: Broken pipe".equals(ex.getMessage())){
				ex.printStackTrace();
			}
		}
	}
}
