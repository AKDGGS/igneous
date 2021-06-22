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
import java.io.ByteArrayOutputStream;

import java.util.zip.GZIPOutputStream;
import java.util.List;
import java.util.Date;
import java.util.HashMap;
import java.util.ArrayList;

import flexjson.JSONSerializer;
import flexjson.transformer.DateTransformer; 

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.transformer.ExcludeTransformer;
import gov.alaska.dggs.igneous.transformer.IterableTransformer;
import gov.alaska.dggs.igneous.transformer.RawTransformer;
import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.ETagUtil;
import gov.alaska.dggs.igneous.model.Well;


public class WellViewServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.include("keywords");
		serializer.exclude("*.class");
		serializer.transform(new ExcludeTransformer(), void.class);
		serializer.transform(new DateTransformer("MM/dd/yyyy"), Date.class);
		serializer.transform(new RawTransformer(), "geog");
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }

	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		SqlSession sess = IgneousFactory.openSession();
		try {
			String path = request.getPathInfo();
			Integer id = Integer.valueOf(request.getParameter("id"));

			HashMap<String, Object> output = new HashMap<String, Object>();
			Well well = sess.selectOne("gov.alaska.dggs.igneous.Well.getByID", id);

			if(null == well){throw new Exception("ID not Found.");}

			output.put("well", well);
			output.put("keywords", sess.selectList("gov.alaska.dggs.igneous.Keyword.getGroupsByWellID", id));

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
