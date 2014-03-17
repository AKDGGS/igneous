package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.GZIPOutputStream;
import java.util.ArrayList;

import java.io.OutputStreamWriter;
import java.io.IOException;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import flexjson.JSONSerializer;


public class QualityServlet extends HttpServlet
{
	private static final JSONSerializer serializer = new JSONSerializer();

	private static Map<String, Map<String, String>> reports = null;
	static {
		reports = new LinkedHashMap<String, Map<String, String>>();

		addReport(reports, "critical", "getMissingMetadata",
			"Inventory without well, borehole, outcrop, shotpoint or publication"
		);
		addReport(reports, "critical", "getMissingMetadataNoBLM",
			"Inventory without well, borehole, outcrop, shotpoint or publication (excluding BLM)"
		);
		addReport(reports, "critical", "getSeparatedBarcodes",
			"Barcodes that span multiple containers (excludes MSLIDEs)"
		);
		addReport(reports, "critical", "getBarcodeOverlap",
			"Barcodes overlaps with others when hypen is removed"
		);
		addReport(reports, "critical", "getWellNumberEmpty",
			"Wells with an empty well number"
		);
		addReport(reports, "critical", "getAPIBadLength",
			"Wells with an API number that is not exactly 14 characters"
		);
		addReport(reports, "critical", "getMissingBarcode",
			"Inventory has no barcode or alternate barcode"
		);
		addReport(reports, "warning", "getMissingContainer",
			"Inventory without a container"
		);
		addReport(reports, "warning", "getMissingType",
			"Inventory missing a keyword for \"type\""
		);
		addReport(reports, "warning", "getMissingBranch",
			"Inventory missing a keyword for \"branch\""
		);
		addReport(reports, "warning", "getBottomOverTop",
			"Inventory interval bottom less than interval top"
		);
		addReport(reports, "warning", "getWellNoSpatial",
			"Well does not have one kind of spatial data"
		);
		addReport(reports, "warning", "getBoreholeNoSpatial",
			"Borehole does not have one kind of spatial data"
		);
		addReport(reports, "warning", "getOutcropNoSpatial",
			"Outcrop does not have one kind of spatial data"
		);
		addReport(reports, "warning", "getShotpointNoSpatial",
			"Shotpoint does not have one kind of spatial data"
		);
		addReport(reports, "warning", "getOutcropInventoryNoSampleNumber",
			"Outcrop Inventory with an empty sample number"
		);
		addReport(reports, "warning", "getInventoryDeeperThanWell",
			"Well Inventory bottom greater than well bottom"
		);
	}


	private static void addReport(Map<String, Map<String, String>> map,
	                              String type, String key, String desc)
	{
		Map<String, String> value = new HashMap<String, String>();
		value.put("type", type);
		value.put("desc", desc);

		map.put(key, value);
	}


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext ctx = getServletContext();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			String method = request.getParameter("r");
			String report = method;
			if(report != null && report.endsWith("Count")){
				report = report.substring(0, report.length() - 5);
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

				if(report == null || !reports.containsKey(report)){
					serializer.serialize(reports, out);
				} else {
					serializer.serialize(
						sess.selectList("gov.alaska.dggs.igneous.Quality." + method),
						out
					);
				}
			} finally {
				if(out != null){ out.close(); }
				if(gos != null){ gos.close(); }
			}
		} finally {
			sess.close();	
		}
	}
}
