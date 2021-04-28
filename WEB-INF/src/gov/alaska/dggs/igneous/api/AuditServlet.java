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

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Audit;
import gov.alaska.dggs.igneous.model.AuditGroup;


public class AuditServlet extends HttpServlet
{
	@SuppressWarnings("unchecked")
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
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

		SqlSession sess = IgneousFactory.openSession();
		try {
			String[] codes = request.getParameterValues("c");
			if(codes == null || codes.length < 1){
				codes = new String[0];
			}

			String remark = request.getParameter("remark");
			if(remark != null){
				remark = remark.trim();
				if(remark.length() == 0) remark = null;
			}

			AuditGroup group = new AuditGroup();
			group.setRemark(remark);

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
