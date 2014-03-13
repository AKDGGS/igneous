package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.HashMap;
import java.util.List;

import java.io.IOException;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;


public class QualityServlet extends HttpServlet
{
	private static final HashMap<String,String> warning;
	static {
		warning = new HashMap<String,String>();
		warning.put("getMissingContainer", "Inventory without a container");
		warning.put("getMissingType", "Inventory missing a keyword for \"type\"");
		warning.put("getMissingBranch", "Inventory missing a keyword for \"branch\"");
	}

	private static final HashMap<String,String> critical;
	static { 
		critical = new HashMap<String,String>();
		critical.put("getMissingMetadata", "Inventory without well, borehole, outcrop or shotpoint");
		critical.put("getSeparatedBarcodes", "Barcodes that span multiple containers (excludes MSLIDEs)");
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
			HashMap<String,List> results = new HashMap<String,List>();
			for(String key : warning.keySet()){
				List<HashMap> l = sess.selectList(
					"gov.alaska.dggs.igneous.Quality." + key
				);
				if(l != null){ results.put(warning.get(key), l); }
			}
			request.setAttribute("warnings", results);

			results = new HashMap<String,List>();
			for(String key : critical.keySet()){
				List<HashMap> l = sess.selectList(
					"gov.alaska.dggs.igneous.Quality." + key
				);
				if(l != null){ results.put(critical.get(key), l); }
			}
			request.setAttribute("criticals", results);

			request.getRequestDispatcher(
				"/WEB-INF/tmpl/quality.jsp"
			).forward(request, response);
		} finally {
			sess.close();	
		}

	}
}
