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
import java.io.ByteArrayOutputStream;

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
import gov.alaska.dggs.igneous.model.MiningDistrict;
import gov.alaska.dggs.ETagUtil;


public class MiningDistrictServlet extends HttpServlet
{
	private static final JSONSerializer serializer = new JSONSerializer(){{
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
			List<MiningDistrict> districts = sess.selectList(
				"gov.alaska.dggs.igneous.MiningDistrict.getList"
			);

			ByteArrayOutputStream baos = null;
			OutputStreamWriter out = null;
			GZIPOutputStream gos = null;
			try {
				baos = new ByteArrayOutputStream(102400);

				// If GZIP is supported by the requesting browser, use it.
				String encoding = request.getHeader("Accept-Encoding");
				if(encoding != null && encoding.contains("gzip")){
					response.setHeader("Content-Encoding", "gzip");
					gos = new GZIPOutputStream(baos, 8196);
					out = new OutputStreamWriter(gos, "utf-8");
				} else {
					out = new OutputStreamWriter(baos, "utf-8");
				}
			
				serializer.serialize(districts, out);
				byte output[] = baos.toByteArray();

				String tag = request.getHeader("If-None-Match");
				String etag = ETagUtil.tag(output);

				if(etag.equals(tag)){
					response.sendError(HttpServletResponse.SC_NOT_MODIFIED);
				} else {
					response.setContentType("application/json");
					response.setContentLength(baos.size());
					response.setHeader("ETag", etag);
					response.getOutputStream().write(output);
				}
			} finally {
				if(out != null){ out.close(); }
				if(gos != null){ gos.close(); }
				if(baos != null){ baos.close(); }
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
