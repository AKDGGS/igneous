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

import java.util.HashMap;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;
import gov.alaska.dggs.igneous.model.InventoryQuality;


public class AddInventoryServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			String barcode = request.getParameter("barcode");
			if(barcode == null || (barcode = barcode.trim()).length() == 0){
				throw new Exception("Barcode cannot be empty.");
			}

			String remark = request.getParameter("remark");
			if(remark != null) remark = remark.trim();

			Inventory i = new Inventory();
			i.setBarcode(barcode);
			i.setRemark(remark);

			sess.insert("gov.alaska.dggs.igneous.Inventory.insert", i);
			if(i.getID() == null) throw new Exception("Inventory insert failed.");

			InventoryQuality iq = new InventoryQuality(i);
			iq.setUsername("gmc_app");
			iq.setRemark("Added via scanner");
			iq.setIssues(new String[]{"needs_detail"});

			sess.insert("gov.alaska.dggs.igneous.InventoryQuality.insert", iq);
			if(iq.getID() == null) throw new Exception("Inventory quality insert failed.");

			sess.commit();
			response.setContentType("application/json");
			response.getOutputStream().print("{\"success\":true}");
		} catch(Exception ex){
			sess.rollback();
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
		} finally {
			sess.close();	
		}
	}
}
