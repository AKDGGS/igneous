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
		String sphinx_host = (String)context.getInitParameter("sphinx_host");

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SphinxClient sphinx = new SphinxClient(sphinx_host, sphinx_port);
		try {
			sphinx.SetMatchMode(SphinxClient.SPH_MATCH_EXTENDED);

			int start = 0;
			try { start = Integer.parseInt(request.getParameter("start")); }
			catch(Exception ex){ }

			int max = 25;
			try { max = Integer.parseInt(request.getParameter("max")); }
			catch(Exception ex){ }

			sphinx.SetLimits(start, max, max_matches);

			int sort = 0;
			try { sort = Integer.parseInt(request.getParameter("sort")); }
			catch(Exception ex){ }

			switch(sort){
				case 1:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_collection DESC, collection ASC"
					);
				break;

				case 2:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_core DESC, core ASC"
					);
				break;

				case 3:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_location DESC, location ASC"
					);
				break;

				case 4:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_set DESC, set ASC"
					);
				break;

				case 5:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_top DESC, top ASC"
					);
				break;

				case 6:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_bottom DESC, bottom ASC"
					);
				break;

				case 7:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_well DESC, well ASC"
					);
				break;

				case 8:
					sphinx.SetSortMode(
						SphinxClient.SPH_SORT_EXTENDED,
						"sort_well_number DESC, well_number ASC"
					);
				break;

				default: sphinx.SetSortMode(SphinxClient.SPH_SORT_RELEVANCE, null);
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

			HashMap json = new HashMap();
			json.put("size", sr.total);
			json.put("found", sr.totalFound);

			if(ids.length > 0){
				SqlSession sess = IgneousFactory.openSession();
				try {
					List<Inventory> items = sess.selectList(
						"gov.alaska.dggs.igneous.Inventory.getSearchResults", ids
					);
					json.put("list", items);
				} finally {
					sess.close();	
				}
			} else {
				json.put("list", new ArrayList(0));
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
