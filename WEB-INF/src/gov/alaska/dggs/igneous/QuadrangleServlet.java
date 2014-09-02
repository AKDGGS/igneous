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
import java.util.List;

import flexjson.JSONSerializer;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Quadrangle;
import gov.alaska.dggs.ETagUtil;


public class QuadrangleServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.exclude("altName");
		serializer.exclude("abbr");
		serializer.exclude("altAbbr");
		serializer.exclude("scale");
		serializer.exclude("class");
	}


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		SqlSession sess = IgneousFactory.openSession();
		try {
			List<Quadrangle> quads = sess.selectList(
				"gov.alaska.dggs.igneous.Quadrangle.getList"
			);
			
			OutputStreamWriter out = null;
			GZIPOutputStream gos = null;
			ByteArrayOutputStream baos = null;
			try {
				// Quadrangles are slightly less than 40k uncompressed
				baos = new ByteArrayOutputStream(40960);

				// If GZIP is supported by the requesting browser, use it.
				String encoding = request.getHeader("Accept-Encoding");
				if(encoding != null && encoding.contains("gzip")){
					response.setHeader("Content-Encoding", "gzip");
					gos = new GZIPOutputStream(baos, 8196);
					out = new OutputStreamWriter(gos, "utf-8");
				} else {
					out = new OutputStreamWriter(baos, "utf-8");
				}

				serializer.serialize(quads, out);
				out.flush(); if(gos != null){ gos.finish(); }

				byte[] output = baos.toByteArray();

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
				if(baos != null){ baos.close(); }
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
