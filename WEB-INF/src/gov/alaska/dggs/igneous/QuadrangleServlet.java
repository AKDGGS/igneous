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
import java.util.ArrayList;

import flexjson.JSONSerializer;

import org.sphx.api.SphinxClient;
import org.sphx.api.SphinxResult;
import org.sphx.api.SphinxMatch;


public class QuadrangleServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static { serializer = new JSONSerializer(); }


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		String query = request.getParameter("q");
		if(query == null || query.length() < 1){
			response.setContentType("application/json");
			response.getOutputStream().print("[]");
			return;
		}

		ServletContext context = getServletContext();
		int max_matches = Integer.parseInt(context.getInitParameter("sphinx_max_matches"));
		int sphinx_port = Integer.parseInt(context.getInitParameter("sphinx_port"));
		String sphinx_host = (String)context.getInitParameter("sphinx_host");
		
		SphinxClient sphinx = new SphinxClient(sphinx_host, sphinx_port);
		try {
			sphinx.SetConnectTimeout(5000);
			sphinx.SetMatchMode(SphinxClient.SPH_MATCH_EXTENDED2);
			sphinx.SetSortMode(SphinxClient.SPH_SORT_EXTENDED, "scale DESC, name ASC");
			sphinx.SetLimits(0, 5, max_matches);
			sphinx.SetSelect("name");

			ArrayList json = new ArrayList();

			SphinxResult sr = sphinx.Query(query, "quadrangle");
			if(sr == null){ throw new Exception(sphinx.GetLastError()); }

			for(int i = 0; i < sr.matches.length; i++){
				json.add(sr.matches[i].attrValues.get(0));
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
