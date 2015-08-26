package gov.alaska.dggs.igneous.page;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;

import org.apache.commons.io.FileCleaningTracker;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.FileCleanerCleanup;


public class InventoryImportServlet extends HttpServlet
{
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		StringBuilder results = new StringBuilder();
		try {
			if(ServletFileUpload.isMultipartContent(request)){
				FileCleaningTracker tracker = FileCleanerCleanup.getFileCleaningTracker(
					context
				);
				DiskFileItemFactory factory = new DiskFileItemFactory(
					1048576, new File(System.getProperty("java.io.tmpdir"))
				);
				factory.setFileCleaningTracker(tracker);
				ServletFileUpload upload = new ServletFileUpload(factory);
				List<FileItem> items = upload.parseRequest(request);

				for(FileItem item : items){
					// Ignore stuff that isn't a file
					if(item.isFormField()) continue;

					results.append("File: " + item.getName());
				}
			}
		} catch(Exception ex){
			results.append("Error: " + ex.getMessage());
		}

		if(results.length() > 0){
			request.setAttribute("results", results);
		}

		request.getRequestDispatcher(
			"/WEB-INF/tmpl/inventory_import.jsp"
		).forward(request, response);
	}
}
