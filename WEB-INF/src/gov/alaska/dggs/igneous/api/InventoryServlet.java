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


public class InventoryServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.include("wells");
		serializer.include("boreholes");
		serializer.include("outcrops");
		serializer.include("keywords");
		serializer.include("files");
		serializer.include("shotpoints");
		serializer.include("publications");

		serializer.exclude("class");
		serializer.exclude("intervalUnit.class");
		serializer.exclude("collection.class");
		serializer.exclude("keywords.class");
		serializer.exclude("keywords.group.class");
		serializer.exclude("wells.class");
		serializer.exclude("wells.unit.class");
		serializer.exclude("boreholes.class");
		serializer.exclude("boreholes.measuredDepthUnit.class");
		serializer.exclude("boreholes.prospect.class");
		serializer.exclude("outcrops.class");
		serializer.exclude("shotpoints.class");
		serializer.exclude("shotpoints.shotline.class");
		serializer.exclude("files.class");
		serializer.exclude("files.type.class");
		serializer.exclude("publications.class");
		serializer.exclude("WKT");

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
			List output = null;

			if(id != null){
				output = sess.selectList(
					"gov.alaska.dggs.igneous.Inventory.getByID", id
				);
			} else if(barcode != null){
				output = sess.selectList(
					"gov.alaska.dggs.igneous.Inventory.getByBarcode", barcode
				);

				if(output.size() == 0){
					output = new ArrayList();

					List<Map> containers = sess.selectList(
						"gov.alaska.dggs.igneous.Container.getTotalsByBarcode", barcode
					);
					
					for(Map container : containers){
						HashMap row = new HashMap(8);
						Integer container_id = (Integer)container.get("container_id");

						row.put("container_id", container_id);
						row.put("name", container.get("name"));
						row.put("total", container.get("total"));

						row.put("collections", sess.selectList(
							"gov.alaska.dggs.igneous.Container.getCollectionTotalsByID",
							container_id
						));
						row.put("wells", sess.selectList(
							"gov.alaska.dggs.igneous.Container.getWellTotalsByID",
							container_id
						));
						row.put("boreholes", sess.selectList(
							"gov.alaska.dggs.igneous.Container.getBoreholeTotalsByID",
							container_id
						));
						row.put("outcrops", sess.selectList(
							"gov.alaska.dggs.igneous.Container.getOutcropTotalsByID",
							container_id
						));
						row.put("shotlines", sess.selectList(
							"gov.alaska.dggs.igneous.Container.getShotlineTotalsByID",
							container_id
						));

						output.add(row);
					}
				}
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
			ex.printStackTrace();
		} finally {
			sess.close();	
		}
	}
}
