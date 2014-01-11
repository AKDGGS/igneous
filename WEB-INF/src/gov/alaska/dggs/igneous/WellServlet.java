package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import java.util.zip.GZIPOutputStream;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

import flexjson.JSONSerializer;

import org.sphx.api.SphinxClient;
import org.sphx.api.SphinxResult;
import org.sphx.api.SphinxMatch;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Well;


public class WellServlet extends HttpServlet
{
	private static final JSONSerializer serializer = new JSONSerializer(){{
		include("well");
		include("summary");
		include("quadrangles");
		include("miningdistricts");
		include("wkts");

		exclude("well.class");
		exclude("well.unit.class");
		exclude("quadrangles.class");
		exclude("miningdistricts.class");
		exclude("class");
	}};


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		int id = 0;
		try { id = Integer.parseInt(request.getParameter("id")); }
		catch(Exception ex){ }

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			Well well = (Well)sess.selectOne(
				"gov.alaska.dggs.igneous.Well.getByID", id
			);
			if(well == null){ throw new Exception("Well not found."); }

			HashMap map = new HashMap();
			map.put("well", well);

			map.put("summary", sess.selectList(
				"gov.alaska.dggs.igneous.Well.getInventorySummary", id
			));

			map.put("quadrangles", sess.selectList(
				"gov.alaska.dggs.igneous.Quadrangle.getByWellID", id
			));
			
			map.put("wkts", sess.selectList(
				"gov.alaska.dggs.igneous.Well.getWKT", id
			));
			
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

				serializer.serialize(map, out);
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
			sess.close();	
		}
	}
}
