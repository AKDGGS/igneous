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


public class AuditReportServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.exclude("class");
	}

	@SuppressWarnings("unchecked")
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext ctx = getServletContext();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		int container_id = 0;
		try { container_id = Integer.parseInt(request.getParameter("container_id")); }
		catch(Exception ex){ }

		int audit_group_id = 0;
		try { audit_group_id = Integer.parseInt(request.getParameter("audit_group_id")); }
		catch(Exception ex){ }

		String start = request.getParameter("start");
		String end = request.getParameter("end");

		if(audit_group_id == 0 && container_id == 0 && start == null && end == null){
			throw new ServletException("Invalid request.");
		}

		SqlSession sess = IgneousFactory.openSession();
		try {
			List<Map> result;
			if(audit_group_id != 0 && container_id != 0){
				HashMap params = new HashMap();
				params.put("container_id", container_id);
				params.put("audit_group_id", audit_group_id);

				result = sess.selectList(
					"gov.alaska.dggs.igneous.Audit.getReportDetail", params
				);
			} else {
				HashMap params = new HashMap();
				params.put("start", start);
				params.put("end", end);

				result = sess.selectList(
					"gov.alaska.dggs.igneous.Audit.getReportByDate", params
				);
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

				serializer.serialize(result, out);
			} finally {
				if(out != null){ out.close(); }
				if(gos != null){ gos.close(); }
			}
		} finally {
			sess.close();	
		}
	}
}
