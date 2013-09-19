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
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

import flexjson.JSONSerializer;

import org.sphx.api.SphinxClient;
import org.sphx.api.SphinxResult;
import org.sphx.api.SphinxMatch;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;


public class InventoryServlet extends HttpServlet
{
	private static final JSONSerializer serializer = new JSONSerializer(){{
		include("keywords");

		exclude("class");	
		exclude("keywords.class");
		exclude("keywords.code");
		exclude("keywords.description");
	}};


	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		int borehole_id = 0;
		try {
			borehole_id = Integer.parseInt(request.getParameter("borehole_id"));
		} catch(Exception ex){ }

		List keyword_ids = new ArrayList();
		try {
			String kids[] = request.getParameterValues("keyword_id");
			if(kids != null && kids.length > 0){
				for(int i = 0; i < kids.length; i++){
					keyword_ids.add(Integer.valueOf(kids[i]));
				}
			}
		} catch(Exception ex){ }

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			Map params = new HashMap();
			if(borehole_id != 0){ params.put("borehole_id", borehole_id); }
			if(!keyword_ids.isEmpty()){ params.put("keyword_ids", keyword_ids); }

			List<Inventory> items = sess.selectList(
				"gov.alaska.dggs.igneous.Inventory.getByKeywordBorehole", params
			);

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

				serializer.serialize(items, out);
			} finally {
				if(out != null){ out.close(); }
				if(gos != null){ gos.close(); }
			}
		} catch(Exception ex){
			ex.printStackTrace();
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
		} finally {
			sess.close();	
		}
	}
}
