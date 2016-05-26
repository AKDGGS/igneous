package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Types;
import java.sql.ResultSet;
import java.util.List;

import java.security.MessageDigest;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;


public class FileUploadServlet extends HttpServlet
{
	private static int UPLOAD_LIMIT = 77594624;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();
		SqlSession sess = IgneousFactory.openSession();
		try {
			if(!ServletFileUpload.isMultipartContent(request)){
				throw new Exception("Not a multipart request!");
			}

			DiskFileItemFactory factory = new DiskFileItemFactory(
				UPLOAD_LIMIT, new File(System.getProperty("java.io.tmpdir"))
			);
			// Cleanup shouldn't be necessary, as everything is in memory
			factory.setFileCleaningTracker(null);

			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setFileSizeMax(UPLOAD_LIMIT);

			List<FileItem> items = upload.parseRequest(request);

			Integer id = null;
			String description = null;
			String op = null;

			// First pass, fetch variables
			for(FileItem item : items){
				if(item.isFormField()){
					String field = item.getFieldName();
					if(field == null) continue;
					field = field.toLowerCase();

					switch(field){
						case "description":
							description = item.getString();
						break;

						case "inventory_id":
							id = Integer.valueOf(item.getString());
							op = "inventory";
						break;
					}
				}
			}

			if(id == null) throw new Exception("No ID provided.");

			// Insert data into file
			Connection conn = sess.getConnection();
			PreparedStatement ps = null;
			try {
				ps = conn.prepareStatement(
					"INSERT INTO file (" +
						"description, mimetype, size, filename, content" +
					") VALUES (" +
						"?, ?, ?, ?, ?" +
					")",
					new String[]{"file_id"}	
				);

				// Second pass, insert files
				for(FileItem item : items){
					if(!item.isFormField()){
						ps.clearParameters();

						if(description == null){
							ps.setNull(1, Types.VARCHAR);
						} else {
							ps.setString(1, description);
						}

						if(item.getContentType() == null){
							ps.setNull(2, Types.VARCHAR);
						} else {
							ps.setString(2, item.getContentType());
						}

						ps.setInt(3, (int)item.getSize());
						ps.setString(4, item.getName());
						ps.setBytes(5, item.get());

						ps.execute();

						ResultSet rs = ps.getGeneratedKeys();
						try {
							if(!rs.next()){
								throw new Exception("Cannot acquire generated ID");
							}

							insertLink(conn, op, id, rs.getInt(1));
						} finally {
							try { rs.close(); }
							catch(Exception exe){ }
						}
					}
				}

				conn.commit();
			} finally {
				try { ps.close(); }
				catch(Exception exe){ }

				try { conn.close(); }
				catch(Exception exe){ }
			}

			response.sendRedirect(op + "/" + id);
		} catch(Exception ex){
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
		} finally {
			sess.close();	
		}
	}


	private void insertLink(Connection conn, String op, Integer id,
	                   Integer file_id) throws Exception
	{
		PreparedStatement ps = null;
		try {
			ps = conn.prepareStatement(
				"INSERT INTO " + op + "_file (" +
					op + "_id, file_id" +
				") VALUES (" +
					"?, ?" +
				")"
			);
			ps.setInt(1, id);
			ps.setInt(2, file_id);
			ps.execute();
		} finally {
			try { ps.close(); }
			catch(Exception exe){ }
		}
	}
}
