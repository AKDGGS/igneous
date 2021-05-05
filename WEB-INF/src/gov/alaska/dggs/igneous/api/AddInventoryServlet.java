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
import gov.alaska.dggs.igneous.model.Token;

public class AddInventoryServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Token token = null;
		try {
			token = TokenAuth.Check(request.getHeader("Authorization"));
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

		SqlSession sess = IgneousFactory.openSession();
		try {
			Inventory i = new Inventory();
			String barcode = request.getParameter("barcode");
			if(barcode == null || (barcode = barcode.trim()).length() == 0){
				throw new Exception("Barcode cannot be empty.");
			}
			i.setBarcode(barcode);
			String remark = request.getParameter("remark");
			if(remark != null) i.setRemark(remark.trim());
			sess.insert("gov.alaska.dggs.igneous.Inventory.insert", i);
			if(i.getID() == null) throw new Exception("Inventory insert failed.");

			String[] issues = request.getParameterValues("i");
			if(issues != null){
				InventoryQuality iq = new InventoryQuality(i);
				iq.setUsername("token_id " + String.valueOf(token.getID()));
				iq.setRemark("Added via scanner.");
				iq.setIssues(issues);
				sess.insert("gov.alaska.dggs.igneous.InventoryQuality.insert", iq);
				if(iq.getID() == null){ 
					throw new Exception("Inventory quality insert failed.");
				}
			}		
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
