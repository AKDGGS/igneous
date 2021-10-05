package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.naming.InitialContext;
import javax.naming.Context;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;
import gov.alaska.dggs.igneous.model.InventoryQuality;
import gov.alaska.dggs.igneous.model.Token;

public class AddInventoryQualityServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
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
			String barcode = request.getParameter("barcode");
			if(barcode == null || (barcode = barcode.trim()).length() == 0){
				throw new Exception("Barcode cannot be empty.");
			}

			List<Integer> inventory_ids = sess.selectList(
				"gov.alaska.dggs.igneous.Inventory.getInventoryIDsByBarcode",
				barcode
			);

			if(inventory_ids == null || inventory_ids.size() < 1){
				throw new Exception("Not found in Inventory");
			}

			String[] issues = request.getParameterValues("i");
			if (issues != null && issues.length == 0){
				issues = null;
			}

			for (Integer inventory_id : inventory_ids){
				Inventory i = new Inventory();
				i.setID(inventory_id);
				InventoryQuality iq = new InventoryQuality(i);
				iq.setUsername("token_id " + String.valueOf(token.getID()));
				String remark = request.getParameter("remark");
				if(remark != null){
					iq.setRemark(remark);
				} else {
					iq.setRemark("Added via scanner.");
				}
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
