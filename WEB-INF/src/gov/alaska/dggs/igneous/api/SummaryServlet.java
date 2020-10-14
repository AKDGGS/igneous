package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.naming.Context;
import javax.naming.InitialContext;

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
		serializer.include("containers");

		serializer.exclude("*.class");

		serializer.transform(new DateTransformer("M/d/yyyy"), Date.class);
		serializer.transform(new ExcludeTransformer(), void.class);
		serializer.transform(new IterableTransformer(), Iterable.class);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();
		try {
			Context initcontext = new InitialContext();
			String apikey = (String)initcontext.lookup(
				"java:comp/env/igneous/apikey"
			);
			Auth.CheckHeader(
				apikey,
				request.getHeader("Authorization"),
				request.getDateHeader("Date"),
				request.getQueryString()
			);
		} catch(Exception ex){
			response.setStatus(403);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
			return;
		}

		String barcode = request.getParameter("barcode");

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			HashMap<String,Object> output = new HashMap<String,Object>();

			List<Map<String,Object>> results = sess.selectList(
				"gov.alaska.dggs.igneous.Container.getTotalsByBarcode", barcode
			);

			if(results.size() > 0){
				Long count = new Long(0);
				ArrayList<Map<String,Object>> containers = new ArrayList<Map<String,Object>>();
				ArrayList<Integer> ids = new ArrayList<Integer>();

				for(Map result : results){
					Boolean include = (Boolean)result.get("include");
					if(include) ids.add((Integer)result.get("container_id"));

					String name = (String)result.get("path_cache");
					Long total = (Long)result.get("total");

					count += total;

					HashMap<String,Object> container = new HashMap<String,Object>(2);
					container.put("container", name);
					container.put("total", total);
					containers.add(container);
				}

				output.put("total", count);
				output.put("containers", containers);

				HashMap<String,Object> params = new HashMap<String,Object>(2);
				if(!ids.isEmpty()) params.put("container_id", ids); 
				params.put("barcode", barcode);

				output.put("barcode", barcode);
				output.put("collections", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getCollectionTotals",
					params
				));
				output.put("keywords", sess.selectOne(
					"gov.alaska.dggs.igneous.Container.getKeywordSummary",
					params
				));
				output.put("wells", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getWellTotals",
					params
				));
				output.put("boreholes", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getBoreholeTotals",
					params
				));
				output.put("shotlines", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getShotlineTotals",
					params
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
