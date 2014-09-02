package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStreamWriter;

import java.math.BigDecimal;
import java.util.zip.GZIPOutputStream;
import java.util.List;
import java.util.LinkedList;
import java.util.HashMap;
import java.util.Date;
import java.util.Properties;

import flexjson.JSONSerializer;
import flexjson.transformer.DateTransformer;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;
import gov.alaska.dggs.igneous.model.Keyword;
import gov.alaska.dggs.igneous.transformer.ExcludeTransformer;
import gov.alaska.dggs.igneous.transformer.IterableTransformer;
import gov.alaska.dggs.SQLQueryParser;


public class SearchServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static { 
		serializer = new JSONSerializer();
		serializer.include("list");
		serializer.include("list.collection");
		serializer.include("list.project");
		serializer.include("list.coreDiameter");
		serializer.include("list.unit");
		serializer.include("list.keywords");
		serializer.include("list.boreholes");
		serializer.include("list.wells");
		serializer.include("list.outcrops");
		serializer.include("list.shotlines");
		serializer.include("list.shotlines.shotpoints");

		serializer.exclude("list.class");	
		serializer.exclude("list.keywords.class");
		serializer.exclude("list.keywords.code");
		serializer.exclude("list.keywords.description");
		serializer.exclude("list.keywords.group");
		serializer.exclude("list.collection.class");
		serializer.exclude("list.project.class");
		serializer.exclude("list.boreholes.class");
		serializer.exclude("list.boreholes.prospect.class");
		serializer.exclude("list.wells.class");	
		serializer.exclude("list.outcrops.class");	
		serializer.exclude("list.shotlines.class");	
		serializer.exclude("list.shotlines.shotpoints.class");	
		serializer.exclude("list.intervalUnit.class");
		serializer.exclude("list.coreDiameter.class");
		serializer.exclude("list.coreDiameter.unit.class");

		serializer.transform(new DateTransformer("M/d/yyyy"), Date.class);
		serializer.transform(new ExcludeTransformer(), void.class);
		serializer.transform(new IterableTransformer(), Iterable.class);
	}

	private static final Properties FIELDS;
	static {
		FIELDS = new Properties();
		FIELDS.setProperty("top", "numeric");
		FIELDS.setProperty("bottom", "numeric");

		FIELDS.setProperty("sample", "simple");
		FIELDS.setProperty("core", "simple");
		FIELDS.setProperty("set", "simple");
		FIELDS.setProperty("box", "simple");
		FIELDS.setProperty("collection", "simple");
		FIELDS.setProperty("project", "simple");
		FIELDS.setProperty("barcode", "simple");
		FIELDS.setProperty("location", "simple");
		FIELDS.setProperty("well", "simple");
		FIELDS.setProperty("wellnumber", "simple");
		FIELDS.setProperty("api", "simple");
		FIELDS.setProperty("borehole", "simple");
		FIELDS.setProperty("prospect", "simple");
		FIELDS.setProperty("ardf", "simple");
		FIELDS.setProperty("outcrop", "simple");
		FIELDS.setProperty("outcropnumber", "simple");
		FIELDS.setProperty("shotline", "simple");
		FIELDS.setProperty("keyword", "simple");

		FIELDS.setProperty("everything", "simple");
	}

	private static final String SQL_QUERY = 
		"SELECT inventory_id FROM inventory_search WHERE ";
	private static final String SQL_COUNT = 
		"SELECT COUNT(*) inventory_id FROM inventory_search WHERE ";

	public HashMap<String, Object> buildParameters(HttpServletRequest request) throws Exception
	{
		HashMap<String, Object> params;
		StringBuilder query = new StringBuilder();

		// Parse the textual query using our custom Lucene-based parser
		SQLQueryParser parser = null;
		String q = request.getParameter("q");
		if(q != null && q.trim().length() > 0){
			parser = new SQLQueryParser(FIELDS);
			parser.parse(q, "everything");

			query.append(parser.getWhereClause());
			params = new HashMap<String, Object>(parser.getParameters());	
		} else {
			params = new HashMap<String, Object>();
		}

		// Handle spatial queries
		String wkt = request.getParameter("wkt");
		if(wkt != null && wkt.trim().length() > 0){
			if(query.length() > 0){ query.append(" AND "); }
			query.append(
				"ST_Intersects(geog, ST_Transform(ST_GeomFromText(#{wkt}, 3857), 4326))"
			);
			params.put("wkt", wkt);
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

				if(query.length() > 0){ query.append(" AND "); }
				query.append("numrange(");
				query.append(" LEAST(#{top}, #{bottom}),");
				query.append(" GREATEST(#{top}, #{bottom}),");
				query.append(" '[]') && intervalrange");

				params.put("top", bd_top);
				params.put("bottom", bd_bottom);
			} catch(Exception ex){
				throw new Exception("Invalid Interval");
			}
		}

		// Handle keyword_id query - Keywords are cached in an
		// array of integers in the materialized view
		// inventory_search because there are so many keywords
		// that this is the fastest approach as an average. Joins
		// are faster assuming smaller numbers of keywords, but
		// get significantly more expensive as keywords are added
		String[] keywords = request.getParameterValues("keyword_id");
		if(isIntegerArray(keywords)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("SORT(ARRAY[");
			for(int i = 0; i < keywords.length; i++){
				if(i > 0){ query.append(","); }
				query.append(keywords[i]);
			}
			query.append("]) <@ keyword_ids");
		}

		// Handle borehole_ids -
		// ANY() is faster than IN() in this context because of
		// the smaller number of rows
		String[] boreholes = request.getParameterValues("borehole_id");
		if(isIntegerArray(boreholes)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("inventory_id = ANY((SELECT ARRAY(");
			query.append("SELECT inventory_id FROM inventory_borehole");
			query.append(" WHERE borehole_id IN (");
			for(int i = 0; i < boreholes.length; i++){
				if(i > 0){ query.append(","); }
				query.append(boreholes[i]);
			}
			query.append(")))::int[])");
		}

		// Handle well_ids -
		// ANY() is faster than IN() in this context because of
		// the smaller number of rows
		String[] wells = request.getParameterValues("well_id");
		if(isIntegerArray(wells)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("inventory_id = ANY((SELECT ARRAY(");
			query.append("SELECT inventory_id FROM inventory_well");
			query.append(" WHERE well_id IN (");
			for(int i = 0; i < wells.length; i++){
				if(i > 0){ query.append(","); }
				query.append(wells[i]);
			}
			query.append(")))::int[])");
		}

		// Handle prospect_ids -
		// ANY() is faster than IN() in this context because of
		// the smaller number of rows
		String[] prospects = request.getParameterValues("prospect_id");
		if(isIntegerArray(prospects)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("inventory_id = ANY((SELECT ARRAY(");
			query.append("SELECT inventory_id FROM inventory_prospect");
			query.append(" WHERE prospect_id IN (");
			for(int i = 0; i < prospects.length; i++){
				if(i > 0){ query.append(","); }
				query.append(prospects[i]);
			}
			query.append(")))::int[])");
		}

		// Handle shotpoint_ids -
		// ANY() is faster than IN() in this context because of
		// the smaller number of rows
		String[] shotpoints = request.getParameterValues("shotpoint_id");
		if(isIntegerArray(shotpoints)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("inventory_id = ANY((SELECT ARRAY(");
			query.append("SELECT inventory_id FROM inventory_shotpoint");
			query.append(" WHERE shotpoint_id IN (");
			for(int i = 0; i < shotpoints.length; i++){
				if(i > 0){ query.append(","); }
				query.append(shotpoints[i]);
			}
			query.append(")))::int[])");
		}

		// Handle shotline_ids -
		// ANY() is faster than IN() in this context because of
		// the smaller number of rows
		String[] shotlines = request.getParameterValues("shotline_id");
		if(isIntegerArray(shotlines)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("inventory_id = ANY((SELECT ARRAY(");
			query.append("SELECT inventory_id FROM inventory_shotline");
			query.append(" WHERE shotline_id IN (");
			for(int i = 0; i < shotlines.length; i++){
				if(i > 0){ query.append(","); }
				query.append(shotlines[i]);
			}
			query.append(")))::int[])");
		}

		// Handle quadrangle_ids -
		// IN() is faster in this context than ANY() becase of
		// the larger number of rows
		String[] quads = request.getParameterValues("quadrangle_id");
		if(isIntegerArray(quads)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("inventory_id IN (");
			query.append("SELECT inventory_id FROM inventory_quadrangle");
			query.append(" WHERE quadrangle_id IN (");
			for(int i = 0; i < quads.length; i++){
				if(i > 0){ query.append(","); }
				query.append(quads[i]);
			}
			query.append("))");
		}

		// Handle mining_district_ids 
		// ANY() is faster than IN() in this context because of
		// the smaller number of rows
		String[] mds = request.getParameterValues("mining_district_id");
		if(isIntegerArray(mds)){
			if(query.length() > 0){ query.append(" AND "); }
			query.append("inventory_id = ANY((SELECT ARRAY(");
			query.append("SELECT inventory_id FROM inventory_mining_district");
			query.append(" WHERE mining_district_id IN (");
			for(int i = 0; i < mds.length; i++){
				if(i > 0){ query.append(","); }
				query.append(mds[i]);
			}
			query.append(")))::int[])");
		}

		// Only proceed is there's some kind of filter on the results
		if(query.length() > 0){
			StringBuilder order = new StringBuilder();

			int sort = 0;
			String s_sort = request.getParameter("sort");
			if(s_sort != null){ sort = Integer.parseInt(s_sort); }

			int dir = 0;
			String s_dir = request.getParameter("dir");
			if(s_dir != null){ dir = Integer.parseInt(s_dir); }

			switch(sort){
				// Sort by collection
				case 1:
					order.append(
						" ORDER BY collection_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by core
				case 2:
					order.append(
						" ORDER BY core_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by location/container
				case 3:
					order.append(
						" ORDER BY location_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sorty by set
				case 4:
					order.append(
						" ORDER BY set_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by top
				case 5:
					order.append(
						" ORDER BY top " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by bottom
				case 6:
					order.append(
						" ORDER BY bottom IS NULL " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by well
				case 7:
					order.append(
						" ORDER BY well_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by well_number
				case 8:
					order.append(
						" ORDER BY well_number_sort " + 
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by barcode
				case 9:
					order.append(
						" ORDER BY barcode_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by borehole
				case 10:
					order.append(
						" ORDER BY borehole_sort " + 
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by box
				case 11:
					order.append(
						" ORDER BY box_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by prospect
				case 12:
					order.append(
						" ORDER BY prospect_sort " +
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				// Sort by sample number
				case 13:
					order.append(
						" ORDER BY sample_sort " + 
						(dir == 0 ? "ASC" : "DESC") +
						" NULLS LAST"
					);
				break;

				default:
					// If possible, use ranked sorting order
					if(parser != null && parser.getOrderClause().length() > 0){
						order.append(" ORDER BY " + parser.getOrderClause());
					}
			}

			int max = 25;
			String s_max = request.getParameter("max");
			if(s_max != null){ max = Integer.parseInt(s_max); }
			order.append(" LIMIT ");
			order.append(max);

			int start = 0;
			String s_start = request.getParameter("start");
			if(s_start != null){ start = Integer.parseInt(s_start); }
			order.append(" OFFSET ");
			order.append(start);

			params.put("_query",
				"(" +
					SQL_COUNT + query.toString() +
				") UNION ALL (" +
					SQL_QUERY + query.toString() + order.toString() +
				")"
			);
		}

		return params;
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			HashMap json = new HashMap();

			HashMap<String, Object> params = buildParameters(request);
			if(!params.isEmpty()){
				//System.out.println("q: " + params.get("_query"));
				List<Integer> list = sess.selectList(
					"gov.alaska.dggs.igneous.SearchMapper.search", params
				);
				Integer found = list.remove(0);

				if(!list.isEmpty()){
					json.put("found", found);
					List<Inventory> items = sess.selectList(
						"gov.alaska.dggs.igneous.Inventory.getSearchResults", list
					);
					json.put("list", items);
				}
			}

			response.setContentType("application/json");

			OutputStreamWriter out = null;
			GZIPOutputStream gos = null;
			try { 
				// If GZIP is supported by the requesting browser, use it.
				String encoding = request.getHeader("Accept-Encoding");
				if(encoding != null && encoding.contains("gzip")){
					response.setHeader("Content-Encoding", "gzip");
					gos = new GZIPOutputStream(response.getOutputStream(), 8196);
					out = new OutputStreamWriter(gos, "utf-8");
				} else {
					out = new OutputStreamWriter(response.getOutputStream(), "utf-8");
				}
				
				serializer.serialize(json, out);
			} finally {
				if(out != null){ out.close(); }
				if(gos != null){ gos.close(); }
			}
		} catch(Exception ex){
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
			//ex.printStackTrace();
		} finally {
			sess.close();
		}
	}

	// This function returns false if a provided string array
	// contains anything besides integers. It's used to santize input
	// directly from connecting clients, when they send ID numbers
	// for filtering
	private boolean isIntegerArray(String[] arr){
		if(arr != null && arr.length > 0){
			try {
				for(String el : arr){ Integer.valueOf(el); }
				return true;
			} catch(Exception ex){ }
		}

		return false;
	}
}
