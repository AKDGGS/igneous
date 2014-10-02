package gov.alaska.dggs.igneous.page;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Well;
import gov.alaska.dggs.igneous.model.Quadrangle;


public class WellViewServlet extends HttpServlet
{
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		SqlSession sess = IgneousFactory.openSession();
		try {
			String path = request.getPathInfo();
			if(path == null){ throw new Exception("No ID provided."); }

			Integer id = Integer.valueOf(path.substring(1));

			Well well = sess.selectOne(
				"gov.alaska.dggs.igneous.Well.getByID", id
			);
			if(well == null){ throw new Exception("ID not found."); }

			request.setAttribute("well", well);
			request.setAttribute("keywords", sess.selectList(
				"gov.alaska.dggs.igneous.Keyword.getGroupsByWellID", id
			));
			request.setAttribute("quadrangles", sess.selectList(
				"gov.alaska.dggs.igneous.Quadrangle.getByWellID", id
			));
			request.setAttribute("wkt", sess.selectOne(
				"gov.alaska.dggs.igneous.Well.getWKTByID", id
			));

			request.getRequestDispatcher(
				"/WEB-INF/tmpl/well_view.jsp"
			).forward(request, response);
		} catch(Exception ex){
			throw new ServletException(ex);
		} finally {
			sess.close();	
		}
	}
}
