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
import gov.alaska.dggs.igneous.model.Prospect;
import gov.alaska.dggs.igneous.model.Quadrangle;


public class ProspectViewServlet extends HttpServlet
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

			Prospect prospect = sess.selectOne(
				"gov.alaska.dggs.igneous.Prospect.getByID", id
			);
			if(prospect == null){ throw new Exception("ID not found."); }

			request.setAttribute("prospect", prospect);
			request.setAttribute("boreholes", sess.selectList(
				"gov.alaska.dggs.igneous.Borehole.getByProspectID", id
			));
			request.setAttribute("keywords", sess.selectList(
				"gov.alaska.dggs.igneous.Keyword.getGroupsByProspectID", id
			));
			request.setAttribute("quadrangles", sess.selectList(
				"gov.alaska.dggs.igneous.Quadrangle.getByProspectID", id
			));
			request.setAttribute("geojson", sess.selectOne(
				"gov.alaska.dggs.igneous.Prospect.getGeoJSONByID", id
			));

			request.getRequestDispatcher(
				"/WEB-INF/tmpl/prospect_view.jsp"
			).forward(request, response);
		} catch(Exception ex){
			throw new ServletException(ex);
		} finally {
			sess.close();	
		}
	}
}
