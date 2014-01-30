package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;


public class FileDownloadServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }


	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		int id = 0;
		try { id = Integer.parseInt(request.getPathInfo().substring(1)); }
		catch(Exception ex){ }

		System.out.println("ID: " + id);

		SqlSession sess = IgneousFactory.openSession();
		Connection conn = sess.getConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			ps = conn.prepareStatement(
				"SELECT mimetype, size, filename, content " +
				"FROM file WHERE file_id = ?",
				ResultSet.TYPE_FORWARD_ONLY,
				ResultSet.CONCUR_READ_ONLY,
				ResultSet.CLOSE_CURSORS_AT_COMMIT
			);
			ps.setInt(1, id);

			rs = ps.executeQuery();

			if(rs.next()){
				response.setContentLength(rs.getInt("size"));
				response.setContentType(rs.getString("mimetype"));
				response.setHeader(
					"Content-Disposition",
					"inline; filename=" + rs.getString("filename")
				);

				byte buf[] = new byte[4096];
				InputStream is = rs.getBinaryStream("content");
				ServletOutputStream out = response.getOutputStream();
				for(int i = 0; (i = is.read(buf)) > 0; out.write(buf, 0, i));
				is.close();
				out.flush();
				out.close();
			} else {
				response.sendError(response.SC_NOT_FOUND, "File not found.");
			}
		} catch(Exception ex){
			throw new ServletException(ex);
		} finally {
			try { rs.close(); }
			catch(Exception exe){ }

			try { ps.close(); }
			catch(Exception exe){ }

			try { conn.close(); }
			catch(Exception exe){ }

			sess.close();	
		}
	}
}
