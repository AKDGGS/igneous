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
import java.util.List;
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


public class InventoryServlet extends HttpServlet
{
	private static final JSONSerializer serializer = new JSONSerializer(){{
		include("wells");
		include("boreholes");
		include("outcrops");
		include("keywords");

		exclude("class");
		exclude("intervalUnit.class");
		exclude("collection.class");
		exclude("keywords.class");
		exclude("keywords.group.class");
		exclude("wells.class");
		exclude("wells.unit.class");
		exclude("boreholes.class");
		exclude("boreholes.measuredDepthUnit.class");
		exclude("boreholes.prospect.class");
		exclude("outcrops.class");
		exclude("WKT");

		transform(new DateTransformer("M/d/yyyy"), Date.class);
		transform(new ExcludeTransformer(), void.class);
		transform(new IterableTransformer(), Iterable.class);
	}};


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
			List<Inventory> inventory = null;

			if(id != null){
				inventory = sess.selectList(
					"gov.alaska.dggs.igneous.Inventory.getByID", id
				);
				if(inventory == null){ throw new Exception("Inventory not found."); }
			} else if(barcode != null){
				HashMap<String, String> query = new HashMap<String, String>();
				query.put("barcode", barcode);

				inventory = sess.selectList(
					"gov.alaska.dggs.igneous.Inventory.getByBarcode", barcode
				);

				if(inventory.size() == 0 && !barcode.startsWith("GMC")){
					inventory = sess.selectList(
						"gov.alaska.dggs.igneous.Inventory.getByBarcode",
						("GMC-" + barcode)
					);
				}

				if(inventory.size() == 0){
					inventory = sess.selectList(
						"gov.alaska.dggs.igneous.Inventory.getByAltBarcode", query
					);
				}
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

				serializer.serialize(inventory, out);
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
