package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.List;
import java.util.HashMap;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Audit;
import gov.alaska.dggs.igneous.model.AuditGroup;


public class MoveServlet extends HttpServlet
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
			// Destination - the barcode attached to the container
			// we're moving all this stuff into
			String dest = request.getParameter("dest");
			if(dest == null || (dest = dest.trim()).length() < 1){
				throw new Exception("Destination barcode cannot be empty.");
			}

			String barcodes = request.getParameter("barcodes");
			if(barcodes == null || (barcodes = barcodes.trim()).length() < 1){
				throw new Exception("List of barcodes to be moved cannot be empty.");
			}

			String codes[] = barcodes.split(";");
			if(codes.length < 1){
				throw new Exception("List of barcodes to be moved cannot be empty.");
			}

			List<Integer> container_ids = sess.selectList(
				"gov.alaska.dggs.igneous.Container.getContainerIDsByBarcode",
				dest
			);

			if(container_ids.isEmpty()){
				throw new Exception("Destination barcode not found.");
			}

			if(container_ids.size() > 1){
				throw new Exception("Destination barcode refers to multiple containers.");
			}

			Integer container_id = container_ids.get(0);
			for(String code : codes){
				HashMap params = new HashMap();
				params.put("barcode", code);
				params.put("container_id", container_id);

				int rc = sess.update(
					"gov.alaska.dggs.igneous.Container.moveContainerByBarcode",
					params
				);

				int ic = sess.update(
					"gov.alaska.dggs.igneous.Inventory.moveInventoryByBarcode",
					params
				);

				if(rc < 1 && ic < 1){
					throw new Exception("Barcode " + code + " not found.");
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
