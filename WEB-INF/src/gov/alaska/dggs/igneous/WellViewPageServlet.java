package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;


public class WellViewPageServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext ctx = getServletContext();

		String id = request.getPathInfo();
		if(id != null){ id = id.length() > 1 ? id.substring(1) : null; }

		request.setAttribute("id", id);

		request.getRequestDispatcher(
			"/WEB-INF/tmpl/well_view.jsp"
		).forward(request, response);
	}
}
