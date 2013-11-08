package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStreamWriter;

import java.util.zip.GZIPOutputStream;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import flexjson.JSONSerializer;

import org.sphx.api.SphinxClient;
import org.sphx.api.SphinxResult;
import org.sphx.api.SphinxMatch;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;


public class SearchServlet extends HttpServlet
{
	private static final JSONSerializer serializer = new JSONSerializer(){{
		include("list");
		include("list.keywords");
		include("list.boreholes");
		include("list.wells");

		exclude("list.class");	
		exclude("list.keywords.class");
		exclude("list.keywords.code");
		exclude("list.keywords.description");
		exclude("list.branch.description");
		exclude("list.branch.class");
		exclude("list.collection.description");
		exclude("list.collection.class");
		exclude("list.boreholes.class");
		exclude("list.boreholes.prospect.class");
		exclude("list.wells.class");	
		exclude("list.outcrops.class");	
		exclude("list.intervalUnit.class");
		exclude("list.intervalUnit.description");
		exclude("list.coreDiameter.class");
		exclude("list.coreDiameter.unit.class");
	}};


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		int max_matches = Integer.parseInt(context.getInitParameter("sphinx_max_matches"));
		int sphinx_port = Integer.parseInt(context.getInitParameter("sphinx_port"));
		int sphinx_max_filter_values = Integer.parseInt(context.getInitParameter("sphinx_max_filter_values"));
		String sphinx_host = (String)context.getInitParameter("sphinx_host");

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SphinxClient sphinx = new SphinxClient(sphinx_host, sphinx_port);
		try {
			sphinx.SetMatchMode(SphinxClient.SPH_MATCH_EXTENDED);

			int start = 0;
			String s_start = request.getParameter("start");
			if(s_start != null){ start = Integer.parseInt(s_start); }

			int max = 25;
			String s_max = request.getParameter("max");
			if(s_max != null){ max = Integer.parseInt(s_max); }
				
			sphinx.SetLimits(start, max, max_matches);

			int sort = 0;
			String s_sort = request.getParameter("sort");
			if(s_sort != null){ sort = Integer.parseInt(s_sort); }

			int dir = 0;
			String s_dir = request.getParameter("dir");
			if(s_dir != null){ dir = Integer.parseInt(s_dir); }

			switch(sort){
				case 1:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_collection DESC, collection " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 2:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_core DESC, core " + 
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 3:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_location DESC, location " + 
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 4:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_set DESC, set " + 
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 5:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_top DESC, top " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 6:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_bottom DESC, bottom " + 
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 7:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_well_null DESC, sort_well " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 8:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_well_number_null DESC, sort_well_number " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 9:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_barcode DESC, barcode " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 10:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_borehole_null DESC, sort_borehole " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 11:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_box_null DESC, sort_box " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				case 12:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_prospect_null DESC, sort_prospect " +
						(dir == 0 ? "ASC" : "DESC")
					);
				break;

				default: sphinx.SetSortMode(SphinxClient.SPH_SORT_RELEVANCE, null);
			}

			String[] keywords = request.getParameterValues("keyword_id");
			if(keywords != null){
				for(String keyword : keywords){
					try {
						long keyword_id = Long.parseLong(keyword);
						sphinx.SetFilter("keyword_id", keyword_id, false);
					} catch(Exception ex){
						// Explicitly ignore faulty IDs
					}
				}
			}

			String prospect = request.getParameter("prospect_id");
			if(prospect != null){
				long prospect_id = Long.parseLong(prospect);
				sphinx.SetFilter("prospect_id", prospect_id, false);
			}

			HashMap json = new HashMap();

			SqlSession sess = IgneousFactory.openSession();
			try {
				String wkt = request.getParameter("wkt");
				if(wkt != null){
					HashMap params = new HashMap();
					params.put("wkt", wkt);
					params.put("limit", sphinx_max_filter_values + 1);

					List<Integer> ids = sess.selectList(
						"gov.alaska.dggs.igneous.Inventory.getIDByWKT", params
					);

					if(ids.size() > sphinx_max_filter_values){
						throw new Exception(
							"Spatial search area too large: Too many results. " +
							"Please try again using a smaller search area."
						);
					} else if(ids == null || ids.size() == 0){
						sphinx.SetFilter("id", 0, false);
					} else {
						int inventory_ids[] = new int[ids.size()];
						Iterator<Integer> itr = ids.iterator();
						for(int i = 0; i < inventory_ids.length; i++){
							inventory_ids[i] = itr.next().intValue();
						}

						sphinx.SetFilter("id", inventory_ids, false);
					}
				}

				String borehole = request.getParameter("borehole_id");
				if(borehole != null){
					long borehole_id = Long.parseLong(borehole);
					sphinx.SetFilter("borehole_id", borehole_id, false);
				}

				StringBuilder query = new StringBuilder();
				if(request.getParameter("q") != null){
					query.append(request.getParameter("q").trim());
				}

				sphinx.SetSelect("id");

				SphinxResult sr = sphinx.Query(query.toString(), "inventory");
				if(sr == null){ throw new Exception(sphinx.GetLastError()); }

				long[] ids = new long[sr.matches.length];
				for(int i = 0; i < sr.matches.length; i++){
					ids[i] = sr.matches[i].docId;
				}

				json.put("size", sr.total);
				json.put("found", sr.totalFound);

				if(ids.length > 0){
					List<Inventory> items = sess.selectList(
						"gov.alaska.dggs.igneous.Inventory.getSearchResults", ids
					);
					json.put("list", items);
				} else {
					json.put("list", new ArrayList(0));
				}
			} finally {
				sess.close();
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
			ex.printStackTrace();

		} finally {
			sphinx.Close();
		}
	}

}
