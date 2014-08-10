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

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Audit;
import gov.alaska.dggs.igneous.model.AuditGroup;


public class AuditServlet extends HttpServlet
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
			String t = request.getParameter("t"); // List of barcodes in "t"
			if(t == null) throw new Exception("Barcode list cannot be empty.");

			t = t.trim();
			if(t.length() < 1) throw new Exception("Barcode list cannot be empty.");

			String codes[] = t.split(";");

			String n = request.getParameter("n"); // Note in "n"
			if(n != null){
				n = n.trim();
				if(n.length() == 0){ n = null; }
			}

			AuditGroup group = new AuditGroup();
			group.setRemark(n);

			sess.insert("gov.alaska.dggs.igneous.Audit.insertGroup", group);
			if(group.getID() == 0){ throw new Exception("Audit group insert failed"); }

			for(String code : codes){
				Audit a = new Audit();
				a.setGroup(group);
				a.setBarcode(code);

				sess.insert("gov.alaska.dggs.igneous.Audit.insert", a);
				if(a.getID() == 0){ throw new Exception("Audit insert failed."); }
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
