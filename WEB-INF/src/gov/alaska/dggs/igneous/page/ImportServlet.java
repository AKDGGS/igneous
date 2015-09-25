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
import java.util.HashMap;
import java.util.regex.Pattern;

import java.math.BigDecimal;

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


public class ImportServlet extends HttpServlet
{
	private static Pattern isnumeric = Pattern.compile("-?\\d+(\\.\\d+)?");

	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.transform(new ExcludeTransformer(), void.class);
	}


	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

	@SuppressWarnings("unchecked")
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
				String method = null;
				try {
					for(FileItem item : items){
						// Deal with form fields
						if(item.isFormField()){
							// Destination is important
							if("destination".equals(item.getFieldName())){
								switch(item.getString()){
									case "inventory":
										method = "gov.alaska.dggs.igneous.Inventory.insertStash";
									break;

									case "borehole":
										method = "gov.alaska.dggs.igneous.Borehole.insertStash";
									break;

									case "outcrop":
										method = "gov.alaska.dggs.igneous.Outcrop.insertStash";
									break;

									case "well":
										method = "gov.alaska.dggs.igneous.Well.insertStash";
									break;

									default:
									 throw new Exception("Invalid destination");
								}
							}

							continue;
						}

						if(method == null) throw new Exception("Unknown destination");

						InputStreamReader isr = new InputStreamReader(item.getInputStream());
						try {
							CsvMapReader cmr = new CsvMapReader(
								isr, CsvPreference.EXCEL_PREFERENCE
							);

							String[] header = cmr.getHeader(true);
							for(Map<String,String> row; (row = cmr.read(header)) != null;){
								HashMap map = new HashMap(row.size());
								for(String h : header){
									String value = (String)row.get(h);
									if(value == null) continue;

									map.put(h, value.trim());

									if(isnumeric.matcher(value).matches()){
										try {
											BigDecimal b = new BigDecimal(value);
											// Check for data loss
											if(b.toString().equals(value)){
												map.put(h, b);
											}
										} catch(Exception ex){
											// Ignore errors generated by attempted
											// conversion.
										}
									}
								}
							
								if(!map.isEmpty()){
									sess.insert(method, serializer.serialize(map));
									count++;
								}
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
			"/WEB-INF/tmpl/import.jsp"
		).forward(request, response);
	}
}