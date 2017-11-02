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

import mjson.Json;

import gov.alaska.dggs.solr.SolrQuery;


public class SearchServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		Json json = null;
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
				"description, " +
				"wells:[json], boreholes:[json]," +
				"shotlines:[json], outcrops:[json]," +
				"geojson:[geo f=geog w=GeoJSON]" +
				(
					request.getUserPrincipal() != null ?
					", display_barcode, location, issue" :
					""
				)
			);

			buildParameters(query, request);

			if(request.getParameter("max") != null){
				query.setLimit(request.getParameter("max"));
			}

			if(request.getParameter("page") != null){
				query.setPage(request.getParameter("page"));
			}

			json = query.execute();
			Json docs = json.at("docs");
			if(docs != null && docs.isArray()){
				for(Json j : docs.asJsonList()){
					Json jdesc = j.at("description");
					if(jdesc != null && jdesc.isString()){
						String desc = jdesc.asString();
						if(desc.length() > 50){
							j.set("description", (desc.substring(0, 46) + " ..."));
						}
					}
				}
			}
		} catch(Exception ex){
			ex.printStackTrace();
			json = Json.object(
				"error", Json.object(
					"msg", ex.getMessage(), "code", 400
				)
			);
		}


		OutputStreamWriter out = null;
		GZIPOutputStream gos = null;
		try { 
			response.setContentType("application/json");

			// If GZIP is supported by the requesting browser, use it.
			String encoding = request.getHeader("Accept-Encoding");
			if(encoding != null && encoding.contains("gzip")){
				response.setHeader("Content-Encoding", "gzip");
				gos = new GZIPOutputStream(response.getOutputStream(), 8196);
				out = new OutputStreamWriter(gos, "utf-8");
			} else {
				out = new OutputStreamWriter(response.getOutputStream(), "utf-8");
			}

			out.write(json.toString());
		} finally {
			if(out != null){ out.close(); }
			if(gos != null){ gos.close(); }
		}
	}


	// Builds up query parameters based on a provide servlet request
	public static void buildParameters(SolrQuery query, HttpServletRequest request) throws Exception
	{
		String q = request.getParameter("q");
		if(q != null && q.trim().length() > 0){
			query.setQuery(q);
		}

		// Don't show can't publish stuff if the
		// user isn't logged in.
		if(request.getUserPrincipal() == null){
			query.setFilter("canpublish", "true");
		}

		// Handle spatial queries
		String aoi = request.getParameter("aoi");
		if(aoi != null && aoi.trim().length() > 0){
			query.setFilter(
				"{!field f=geog format=GeoJSON}",
				"Intersects(" + aoi + ")"
			);
		}
		
		// Handle top/bottom range queries
		String top = request.getParameter("top");
		String bottom = request.getParameter("bottom");
		if(top != null || bottom != null){
			// If one is null, populate the other
			if(top == null){ top = bottom; }
			else if(bottom == null){ bottom = top; }

			try {
				BigDecimal bd_top = new BigDecimal(top);
				BigDecimal bd_bottom = new BigDecimal(bottom);

				query.setFilter("top","[" + bd_top.toString() + " TO *]");
				query.setFilter("bottom", "[* TO " + bd_bottom.toString() + "]");
			} catch(Exception ex){
				throw new Exception("Invalid Interval");
			}
		}

		// Handle keyword query
		String[] keywords = request.getParameterValues("keyword");
		if(keywords != null){
			for(int i = 0; i < keywords.length; i++){
				query.addFilter("keyword", keywords[i]);
			}
		}

		// Handle borehole_ids
		String[] boreholes = request.getParameterValues("borehole_id");
		if(isIntegerArray(boreholes)){
			for(int i = 0; i < boreholes.length; i++){
				query.addFilter("borehole_id", boreholes[i]);
			}
		}

		// Handle well_ids
		String[] wells = request.getParameterValues("well_id");
		if(isIntegerArray(wells)){
			for(int i = 0; i < wells.length; i++){
				query.addFilter("well_id", wells[i]);
			}
		}

		// Handle prospect_ids
		String[] prospects = request.getParameterValues("prospect_id");
		if(isIntegerArray(prospects)){
			for(int i = 0; i < prospects.length; i++){
				query.addFilter("prospect_id", prospects[i]);
			}
		}

		// Handle shotpoint_ids
		String[] shotpoints = request.getParameterValues("shotpoint_id");
		if(isIntegerArray(shotpoints)){
			for(int i = 0; i < shotpoints.length; i++){
				query.addFilter("shotpoint_id", shotpoints[i]);
			}
		}

		// Handle shotline_ids
		String[] shotlines = request.getParameterValues("shotline_id");
		if(isIntegerArray(shotlines)){
			for(int i = 0; i < shotlines.length; i++){
				query.addFilter("shotline_id", shotlines[i]);
			}
		}

		// Handle outcrop_ids
		String[] outcrops = request.getParameterValues("outcrop_id");
		if(isIntegerArray(outcrops)){
			for(int i = 0; i < outcrops.length; i++){
				query.addFilter("outcrop_id", outcrops[i]);
			}
		}

		// Handle quadrangle_ids -
		// IN() is faster in this context than ANY() becase of
		// the larger number of rows
		String[] quads = request.getParameterValues("quadrangle_id");
		if(isIntegerArray(quads)){
			for(int i = 0; i < quads.length; i++){
				query.addFilter("quadrangle_id", quads[i]);
			}
		}

		// Handle mining_district_ids 
		String[] mds = request.getParameterValues("mining_district_id");
		if(isIntegerArray(mds)){
			for(int i = 0; i < mds.length; i++){
				query.addFilter("mining_district_id", mds[i]);
			}
		}

		// Handle collection_ids 
		String[] cids = request.getParameterValues("collection_id");
		if(isIntegerArray(cids)){
			for(int i = 0; i < cids.length; i++){
				query.addFilter("collection_id", cids[i]);
			}
		}

		// Only proceed is there's some kind of filter on the results
		String dirs[] = request.getParameterValues("dir");
		String sorts[] = request.getParameterValues("sort");
		StringBuilder sort = new StringBuilder();
		if(sorts != null && dirs != null && dirs.length == sorts.length){
			for(int i = 0; i < sorts.length; i++){
				if(sorts[i].trim().length() > 0 && dirs[i].trim().length() > 0){
					if(sort.length() > 0) sort.append(",");
					sort.append(sorts[i]);
					sort.append(" ");
					sort.append(dirs[i]);
				}
			}
		}
		if(sort.length() > 0) query.setSort(sort.toString());
	}


	// This function returns false if a provided string array
	// contains anything besides integers. It's used to santize input
	// directly from connecting clients, when they send ID numbers
	// for filtering
	public static boolean isIntegerArray(String[] arr){
		if(arr != null && arr.length > 0){
			try {
				for(String el : arr){ Integer.valueOf(el); }
				return true;
			} catch(Exception ex){ }
		}

		return false;
	}
}
