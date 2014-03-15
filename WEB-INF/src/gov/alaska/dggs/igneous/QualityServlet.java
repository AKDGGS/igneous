package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.HashMap;
import java.util.List;
import java.util.zip.GZIPOutputStream;
import java.util.ArrayList;

import java.io.OutputStreamWriter;
import java.io.IOException;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import flexjson.JSONSerializer;


public class QualityServlet extends HttpServlet
{
	private static final HashMap<String,String> warning;
	static {
		warning = new HashMap<String,String>();
		warning.put("getMissingContainer", "Inventory without a container");
		warning.put("getMissingType", "Inventory missing a keyword for \"type\"");
		warning.put("getMissingBranch", "Inventory missing a keyword for \"branch\"");
	}

	private static final HashMap<String,String> critical;
	static { 
		critical = new HashMap<String,String>();
		critical.put("getMissingMetadata", "Inventory without well, borehole, outcrop, shotpoint or publication");
		critical.put("getSeparatedBarcodes", "Barcodes that span multiple containers (excludes MSLIDEs)");
		critical.put("getBarcodeOverlap", "Barcodes overlaps with others when hypen is removed");
	}

	private static final JSONSerializer serializer = new JSONSerializer();

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext ctx = getServletContext();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			HashMap<String, Object> map = new HashMap<String,Object>();
			for(String key : warning.keySet()){
				Integer i = (Integer)sess.selectOne(
					"gov.alaska.dggs.igneous.Quality." + key + "Count"
				);
				map.put(key,i);
			}
			request.setAttribute("warnings", map);

			map = new HashMap<String,Object>();
			for(String key : critical.keySet()){
				Integer i = (Integer)sess.selectOne(
					"gov.alaska.dggs.igneous.Quality." + key + "Count"
				);
				map.put(key, i);
			}
			request.setAttribute("criticals", map);

			map = new HashMap<String,Object>();
			map.putAll(warning);
			map.putAll(critical);
			request.setAttribute("descriptions", map);

			request.getRequestDispatcher(
				"/WEB-INF/tmpl/quality.jsp"
			).forward(request, response);
		} finally {
			sess.close();	
		}
	}


	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext ctx = getServletContext();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			List<HashMap> map = null;

			String detail = request.getParameter("detail");
			if(detail != null && (critical.containsKey(detail) || warning.containsKey(detail))){
				map = sess.selectList("gov.alaska.dggs.igneous.Quality." + detail);
			}
			if(map == null){ map = new ArrayList<HashMap>(); }

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
		} finally {
			sess.close();	
		}
	
	}

}
