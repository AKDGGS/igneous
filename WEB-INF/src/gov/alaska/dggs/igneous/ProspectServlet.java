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
import gov.alaska.dggs.igneous.model.Prospect;
import gov.alaska.dggs.igneous.transformer.ExcludeTransformer;


public class ProspectServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.include("prospect.boreholes");
		serializer.include("prospect");
		serializer.include("summary");
		serializer.include("diameters");
		serializer.include("quadrangles");
		serializer.include("miningdistricts");
		serializer.include("wkts");

		// Extremely important: Ignores circular reference
		serializer.exclude("prospect.boreholes.prospect");

		serializer.exclude("prospect.boreholes.class");
		serializer.exclude("prospect.class");
		serializer.exclude("diameters.class");
		serializer.exclude("diameters.unit.class");
		serializer.exclude("quadrangles.class");
		serializer.exclude("miningdistricts.class");
		serializer.exclude("class");

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
			Prospect prospect = (Prospect)sess.selectOne(
				"gov.alaska.dggs.igneous.Prospect.getByID", id
			);
			if(prospect == null){ throw new Exception("Prospect not found."); }

			HashMap map = new HashMap();
			map.put("prospect", prospect);

			map.put("summary", sess.selectList(
				"gov.alaska.dggs.igneous.Prospect.getInventorySummary", id
			));

			map.put("diameters", sess.selectList(
				"gov.alaska.dggs.igneous.CoreDiameter.getByProspectID", id
			));

			map.put("quadrangles", sess.selectList(
				"gov.alaska.dggs.igneous.Quadrangle.getByProspectID", id
			));
			
			map.put("miningdistricts", sess.selectList(
				"gov.alaska.dggs.igneous.MiningDistrict.getByProspectID", id
			));

			map.put("wkts", sess.selectList(
				"gov.alaska.dggs.igneous.Prospect.getWKT", id
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
