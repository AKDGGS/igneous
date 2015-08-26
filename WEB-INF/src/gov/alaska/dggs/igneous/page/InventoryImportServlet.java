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
import java.io.InputStreamReader;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;

import org.apache.commons.io.FileCleaningTracker;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.FileCleanerCleanup;

import org.supercsv.prefs.CsvPreference;
import org.supercsv.io.CsvMapReader;

import flexjson.JSONSerializer;
import gov.alaska.dggs.igneous.transformer.ExcludeTransformer;


public class InventoryImportServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.transform(new ExcludeTransformer(), void.class);
	}


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

				SqlSession sess = IgneousFactory.openSession();
				int count = 0;
				try {
					for(FileItem item : items){
						// Ignore stuff that isn't a file
						if(item.isFormField()) continue;

						InputStreamReader isr = new InputStreamReader(item.getInputStream());
						try {
							CsvMapReader cmr = new CsvMapReader(
								isr, CsvPreference.EXCEL_PREFERENCE
							);

							String[] header = cmr.getHeader(true);
							for(Map<String,String> row; (row = cmr.read(header)) != null;){
								sess.insert(
									"gov.alaska.dggs.igneous.Inventory.insertStash",
									serializer.serialize(row)
								);
								count++;
							}
						} finally {
							isr.close();
						}
					}
					sess.commit();

					results.append("Success, inserted " + count + " rows.");
				} catch(Exception ex){
					// Rollback on error, trickle the error up
					sess.rollback();
					throw ex;
				}
			}
		} catch(Exception ex){
			ex.printStackTrace();

			// Return the error to the user
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
