package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
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
import gov.alaska.dggs.ETagUtil;


public class FileUploadServlet extends HttpServlet
{
	private static int UPLOAD_LIMIT = 77594624;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		try {
			TokenAuth.Check(request.getHeader("Authorization"));
		} catch(Exception ex) {
			response.setStatus(403);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
			return;
		}

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

			String barcode = null;
			//Integer id = null;
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
						case "barcode":
							barcode = item.getString();
							op = "inventory";
						break;
					}
				}
			}

			Integer id = sess.selectOne(
				"gov.alaska.dggs.igneous.Inventory.getInventoryIDsByBarcode",
				barcode
			);

			if(id == null) throw new Exception("No ID provided.");

			// Insert data into file
			Connection conn = sess.getConnection();
			PreparedStatement ps = null;
			try{
				ps = conn.prepareStatement(
					"INSERT INTO file (" +
						"description, mimetype, size, filename, " +
						"content, content_md5" +
					") VALUES (" +
						"?, ?, ?, ?, ?, ?" +
					")",
					new String[]{"file_id"}
				);

				// Second pass, insert files
				for(FileItem item : items){
					if(!item.isFormField()){
						String hash = ETagUtil.md5(item.get());
						Integer file_id = getFileIDByMD5(conn, hash);

						if(file_id == null){
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
							ps.setString(6, hash);

							ps.execute();

							ResultSet rs = ps.getGeneratedKeys();
							rs = ps.getGeneratedKeys();
							try {
								if(rs.next()) file_id = rs.getInt(1);
							} finally {
								try { rs.close(); }
								catch(Exception exe){ }
								}
						}
						if(file_id == null){
							throw new Exception("Cannot acquire file_id");
						}
							insertLink(conn, op, id, file_id);
					}
				}
				conn.commit();
			} finally {
				try { ps.close(); }
				catch(Exception exe){ }
				try { conn.close(); }
				catch(Exception exe){ }
			}
			response.setContentType("application/json");
			response.getOutputStream().print("{\"success\":true}");
		} catch(Exception ex) {
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
		} finally {
			sess.close();
		}
	}

	private void insertLink(Connection conn, String op, Integer id,
			                   Integer file_id) throws Exception{
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

	private Integer getFileIDByMD5(Connection conn, String hash) throws Exception{
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			ps = conn.prepareStatement(
				"SELECT file_id FROM file " +
				"WHERE content_md5 = ?"
			);
			ps.setString(1, hash);
			rs = ps.executeQuery();
			if(rs.next()) return rs.getInt(1);
			return null;
		} finally {
			try { rs.close(); }
			catch(Exception exe){ }

			try { ps.close(); }
			catch(Exception exe){ }
		}
	}
}
