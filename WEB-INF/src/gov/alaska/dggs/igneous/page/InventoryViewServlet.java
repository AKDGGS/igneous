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
import gov.alaska.dggs.igneous.model.Inventory;


public class InventoryViewServlet extends HttpServlet
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

			Inventory iv = sess.selectOne(
				"gov.alaska.dggs.igneous.Inventory.getByID", id
			);
			if(iv == null){ throw new Exception("ID not found."); }

			// Hide inactive and unpublished inventory
			// from unauthenticated users
			if(request.getUserPrincipal() == null){
				if(!iv.getCanPublish() || !iv.getActive()){
					throw new Exception("ID not found."); 
				}
			}

			request.setAttribute("inventory", iv);
			request.getRequestDispatcher(
				"/WEB-INF/tmpl/inventory_view.jsp"
			).forward(request, response);
		} catch(Exception ex){
			throw new ServletException(ex);
		} finally {
			sess.close();	
		}
	}
}
