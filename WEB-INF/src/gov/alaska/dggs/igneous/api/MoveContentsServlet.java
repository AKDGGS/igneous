package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.naming.InitialContext;
import javax.naming.Context;

import java.util.List;
import java.util.HashMap;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;
import gov.alaska.dggs.igneous.model.InventoryQuality;
import gov.alaska.dggs.igneous.model.Container;


public class MoveContentsServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		try {
			TokenAuth.Check(request.getHeader("Authorization"));
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
			// Destination - the barcode attached to the container
			// we're moving all this stuff into
			String dest = request.getParameter("dest");
			if(dest == null || (dest = dest.trim()).length() < 1){
				throw new Exception("Destination barcode cannot be empty.");
			}

			String src = request.getParameter("src");
			if(src == null || (src = src.trim()).length() < 1){
				throw new Exception("Source barcode cannot be empty.");
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

			HashMap<String,Object> params = new HashMap<String,Object>();
			params.put("src", src);
			params.put("dest", container_ids.get(0));

			int rc = sess.update(
				"gov.alaska.dggs.igneous.Container.moveContainerByParentBarcode",
				params
			);
			rc += sess.update(
				"gov.alaska.dggs.igneous.Inventory.moveInventoryByContainerBarcode",
				params
			);

			if(rc < 1){
				throw new Exception("Nothing moved.");
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
