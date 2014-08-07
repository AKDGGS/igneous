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


public class RecodeServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		String oldcode = request.getParameter("old");
		if(oldcode == null){
			throw new ServletException("Old barcode cannot be empty.");
		} oldcode = oldcode.trim();

		String newcode = request.getParameter("new");
		if(newcode == null){
			throw new ServletException("New barcode cannot be empty.");
		} newcode = newcode.trim();

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			HashMap<String, String> params = new HashMap<String, String>();
			int r = 0;

			params.put("old_barcode", oldcode);
			params.put("new_barcode", newcode);

			// First, try updating the barcode
			r += sess.update(
				"gov.alaska.dggs.igneous.Inventory.updateBarcode",
				params
			);

			// Update any container barcodes you find, as well
			r += sess.update(
				"gov.alaska.dggs.igneous.Container.updateBarcode",
				params
			);

			// If those updates fail, try updating the alt_barcode
			if(r == 0){
				r += sess.update(
					"gov.alaska.dggs.igneous.Inventory.updateAltBarcode",
					params
				);

				r += sess.update(
					"gov.alaska.dggs.igneous.Container.updateAltBarcode",
					params
				);
			}

			// Finally, if all that fails, try appending "GMC-" to it
			if(r == 0){
				params.put("old_barcode", "GMC-" + oldcode);

				r += sess.update(
					"gov.alaska.dggs.igneous.Inventory.updateBarcode",
					params
				);

				r += sess.update(
					"gov.alaska.dggs.igneous.Container.updateBarcode",
					params
				);
			}

			if(r == 0) throw new Exception("No codes updated.");

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
