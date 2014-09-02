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

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Borehole;
import gov.alaska.dggs.igneous.transformer.ExcludeTransformer;


public class BoreholeServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();

		serializer.include("borehole");
		serializer.include("borehole.prospect");
		serializer.include("summary");
		serializer.include("diameters");
		serializer.include("quadrangles");
		serializer.include("miningdistricts");
		serializer.include("wkts");

		serializer.exclude("borehole.class");
		serializer.exclude("borehole.prospect.class");
		serializer.exclude("borehole.elevationUnit.class");
		serializer.exclude("borehole.measuredDepthUnit.class");
		serializer.exclude("borehole.inventory");
		serializer.exclude("quadrangles.class");
		serializer.exclude("miningdistricts.class");
		serializer.exclude("diameters.class");
		serializer.exclude("class");

		// Extremely important: Ignores circular reference
		serializer.exclude("borehole.prospect.boreholes");

		serializer.transform(new ExcludeTransformer(), void.class);
	}


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
			Borehole borehole = (Borehole)sess.selectOne(
				"gov.alaska.dggs.igneous.Borehole.getByID", id
			);
			if(borehole == null){ throw new Exception("Borehole not found."); }

			HashMap map = new HashMap();
			map.put("borehole", borehole);

			map.put("summary", sess.selectList(
				"gov.alaska.dggs.igneous.Borehole.getInventorySummary", id
			));

			map.put("diameters", sess.selectList(
				"gov.alaska.dggs.igneous.CoreDiameter.getByBoreholeID", id
			));
	
			map.put("quadrangles", sess.selectList(
				"gov.alaska.dggs.igneous.Quadrangle.getByBoreholeID", id
			));
	
			map.put("miningdistricts", sess.selectList(
				"gov.alaska.dggs.igneous.MiningDistrict.getByBoreholeID", id
			));

			map.put("wkts", sess.selectList(
				"gov.alaska.dggs.igneous.Borehole.getWKT", id
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
