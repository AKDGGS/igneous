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

import flexjson.JSONSerializer;

import org.sphx.api.SphinxClient;
import org.sphx.api.SphinxResult;
import org.sphx.api.SphinxMatch;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;


public class InventoryServlet extends HttpServlet
{
	private static final JSONSerializer serializer = new JSONSerializer(){{
		include("keywords");
		include("boreholes");

		exclude("class");	
		exclude("keywords.class");
		exclude("keywords.code");
		exclude("keywords.description");
		exclude("branch.description");
		exclude("branch.class");
		exclude("boreholes.class");
		exclude("boreholes.altNames");
		exclude("boreholes.altProspectNames");
	}};


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		int sphinx_port = Integer.parseInt(context.getInitParameter("sphinx_port"));
		String sphinx_host = (String)context.getInitParameter("sphinx_host");

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SphinxClient sphinx = new SphinxClient(sphinx_host, sphinx_port);
		try {
			sphinx.SetMatchMode(SphinxClient.SPH_MATCH_EXTENDED);
			
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

			if(ids.length > 0){
				SqlSession sess = IgneousFactory.openSession();
				try {
					List<Inventory> items = sess.selectList("gov.alaska.dggs.igneous.Inventory.getResults", ids);

					response.setContentType("application/json");
					serializer.serialize(items, response.getWriter());
				} finally {
					sess.close();	
				}
			} else {
				response.setContentType("application/json");
				serializer.serialize(new ArrayList(0), response.getWriter());
			}
		} catch(Exception ex){
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
			ex.printStackTrace();

		} finally {
			sphinx.Close();
		}
	}

}
