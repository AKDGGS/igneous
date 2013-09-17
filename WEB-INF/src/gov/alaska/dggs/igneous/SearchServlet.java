package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStreamWriter;

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
						"gov.alaska.dggs.igneous.Inventory.getResults", ids
					);
					json.put("list", items);
				} finally {
					sess.close();	
				}
			} else {
				json.put("list", new ArrayList(0));
			}

			response.setContentType("application/json");
			serializer.serialize(json, response.getWriter());
		} catch(Exception ex){
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
			ex.printStackTrace();

		} finally {
			sphinx.Close();
		}
	}

}
