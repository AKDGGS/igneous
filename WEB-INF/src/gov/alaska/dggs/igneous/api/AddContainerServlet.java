package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.naming.Context;
import javax.naming.InitialContext;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import java.util.HashMap;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Container;
import gov.alaska.dggs.igneous.model.ContainerType;


public class AddContainerServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();
		try {
			Context initcontext = new InitialContext();
			String apikey = (String)initcontext.lookup(
				"java:comp/env/igneous/apikey"
			);
			Auth.CheckHeader(
				apikey,
				request.getHeader("Authorization"),
				request.getDateHeader("Date"),
				request.getQueryString()
			);
		} catch(Exception ex){
			response.setStatus(403);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
			return;
		}

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		try(SqlSession sess = IgneousFactory.openSession()) {
			String barcode = request.getParameter("barcode");
			if(barcode == null || (barcode = barcode.trim()).length() == 0){
				throw new Exception("Barcode cannot be empty.");
			}

			int count = sess.selectOne(
				"gov.alaska.dggs.igneous.Container.getCountByBarcode",
				barcode
			);
			if(count > 0){
				throw new Exception("Barcode already exists");
			}

			String name = request.getParameter("name");
			if(name == null || (name = name.trim()).length() == 0){
				name = barcode;
			}

			String remark = request.getParameter("remark");
			if(remark != null) remark = remark.trim();

			Container c = new Container();
			c.setBarcode(barcode);
			c.setName(name);
			c.setRemark(remark);

			ContainerType type = (ContainerType)sess.selectOne(
				"gov.alaska.dggs.igneous.Container.getContainerTypeByName", "unknown"
			);
			c.setType(type);

			sess.insert("gov.alaska.dggs.igneous.Container.insert", c);
			if(c.getID() == null) throw new Exception("Container insert failed.");

			sess.commit();
			response.setContentType("application/json");
			response.getOutputStream().print("{\"success\":true}");
		} catch(Exception ex){
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
		}
	}
}
