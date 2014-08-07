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

		String barcode = request.getParameter("barcode");
		if(barcode == null){
			throw new ServletException("Barcode cannot be empty.");
		} barcode = barcode.trim();

		String remark = request.getParameter("remark");
		if(remark != null) remark = remark.trim();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			Inventory i = new Inventory();
			i.setBarcode(barcode);
			i.setRemark(remark);

			sess.insert("gov.alaska.dggs.igneous.Inventory.insert", i);
			if(i.getID() == null) throw new Exception("Inventory insert failed.");

			InventoryQuality iq = new InventoryQuality(i);
			iq.setUsername("gmc_app");
			iq.setRemark("Added via scanner");
			iq.setNeedsDetail(true);

			sess.insert("gov.alaska.dggs.igneous.Inventory.insertQuality", iq);
			if(iq.getID() == null) throw new Exception("Inventory quality insert failed.");

			sess.commit();
			response.setContentType("application/json");
			response.getOutputStream().print("{\"success\":true}");
		} catch(Exception ex){
			sess.rollback();
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
			ex.printStackTrace();
		} finally {
			sess.close();	
		}
	}
}
