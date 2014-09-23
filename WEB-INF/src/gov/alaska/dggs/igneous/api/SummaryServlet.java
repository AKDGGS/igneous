package gov.alaska.dggs.igneous.api;

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
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Date;
import java.util.Arrays;

import flexjson.JSONSerializer;
import flexjson.transformer.DateTransformer;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;
import gov.alaska.dggs.igneous.transformer.ExcludeTransformer;
import gov.alaska.dggs.igneous.transformer.IterableTransformer;


public class SummaryServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.include("wells");
		serializer.include("boreholes");
		serializer.include("outcrops");
		serializer.include("keywords");
		serializer.include("shotpoints");
		serializer.include("collections");

		serializer.exclude("class");

		serializer.transform(new DateTransformer("M/d/yyyy"), Date.class);
		serializer.transform(new ExcludeTransformer(), void.class);
		serializer.transform(new IterableTransformer(), Iterable.class);
	}


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		Integer id = null;
		try { id = Integer.valueOf(request.getParameter("id")); }
		catch(Exception ex){ }
		String barcode = request.getParameter("barcode");

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			HashMap output = new HashMap();

			List<Map> containers = sess.selectList(
				"gov.alaska.dggs.igneous.Container.getTotalsByBarcode", barcode
			);

			if(containers.size() > 0){
				Long total = new Long(0);
				String name = null;

				List<Integer> ids = new ArrayList<Integer>();
				for(Map container : containers){
					if(name == null && container.containsKey("name")){
						name = (String)container.get("name");
					}
					ids.add((Integer)container.get("container_id"));
					total += (Long)container.get("total");
				}

				output.put("containerPath", name);
				output.put("barcode", barcode);
				output.put("total", total);

				output.put("collections", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getCollectionTotalsByID",
					ids
				));
				output.put("keywords", sess.selectOne(
					"gov.alaska.dggs.igneous.Container.getKeywordSummaryByID",
					ids
				));
				output.put("wells", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getWellTotalsByID",
					ids
				));
				output.put("boreholes", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getBoreholeTotalsByID",
					ids
				));
				output.put("shotlines", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getShotlineTotalsByID",
					ids
				));
			}

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

				response.setContentType("application/json");
				serializer.serialize(output, out);
			} finally {
				if(out != null){ out.close(); }
				if(gos != null){ gos.close(); }
			}
		} catch(Exception ex){
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
		} finally {
			sess.close();	
		}
	}
}