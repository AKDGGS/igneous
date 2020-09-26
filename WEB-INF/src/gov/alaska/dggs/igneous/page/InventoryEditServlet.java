package gov.alaska.dggs.igneous.page;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;

import java.util.Map;
import java.util.HashMap;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;


public class InventoryEditServlet extends HttpServlet
{
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		SqlSession sess = IgneousFactory.openSession();
		try {
			String path = request.getPathInfo();
			if(path == null){ throw new Exception("No ID provided."); }

			Integer id = Integer.valueOf(path.substring(1));

			Inventory iv = sess.selectOne(
				"gov.alaska.dggs.igneous.Inventory.getByID", id
			);
			if(iv == null){ throw new Exception("ID not found."); }

			Map<String, String> err = new HashMap<String, String>();

			String[] fields = {
				"dggs_sample_id", "lab_report_id", "sample_number",
				"sample_number_prefix", "alt_sample_number",
				"published_sample_number", "published_number_has_suffix",
				"barcode", "alt_barcode", "state_number", "box_number",
				"set_number", "split_number", "slide_number",
				"slip_number", "lab_number", "map_number",
				"description", "remark", "tray", "interval_top",
				"interval_bottom", "core_number", "weight",
				"sample_frequency", "recovery", "can_publish",
				"radiation_msvh", "received", "entered",
				"active"
			};

			boolean dirty = false;
			for(String field : fields){
				String param = request.getParameter(field);
				if(param != null){
					try{ 
						switch(field){
							case "dggs_sample_id":
								iv.setDGGSSampleIDString(param);
							break;
							case "lab_report_id":
								iv.setLabReportID(param);
							break;
							case "sample_number":
								iv.setSampleNumber(param);
							break;
							case "sample_number_prefix": 
								iv.setSampleNumberPrefix(param);
							break;
							case "alt_sample_number":
								iv.setAltSampleNumber(param);
							break;
							case "published_sample_number":
								iv.setPublishedSampleNumber(param);
							break;
							case "published_number_has_suffix":
								iv.setPublishedNumberHasSuffixString(param);
							break;
							case "barcode":
								iv.setBarcode(param);
							break;
							case "alt_barcode":
								iv.setAltBarcode(param);
							break;
							case "state_number":
								iv.setStateNumber(param);
							break;
							case "box_number":
								iv.setBoxNumber(param);
							break;
							case "set_number":
								iv.setSetNumber(param);
							break;
							case "split_number":
								iv.setSplitNumber(param);
							break;
							case "slide_number":
								iv.setSlideNumber(param);
							break;
							case "slip_number":
								iv.setSlipNumberString(param);
							break;
							case "lab_number":
								iv.setLabNumber(param);
							break;
							case "map_number":
								iv.setMapNumber(param);
							break;
							case "description":
								iv.setDescription(param);
							break;
							case "remark":
								iv.setRemark(param);
							break;
							case "tray":
								iv.setTrayString(param);
							break;
							case "interval_top":
								iv.setIntervalTopString(param);
							break;
							case "interval_bottom":
								iv.setIntervalBottomString(param);
							break;
							case "core_number":
								iv.setCoreNumber(param);
							break;
							case "weight":
								iv.setWeightString(param);
							break;
							case "sample_frequency":
								iv.setSampleFrequency(param);
							break;
							case "recovery":
								iv.setRecovery(param);
							break;
							case "can_publish":
								iv.setCanPublishString(param);
							break;
							case "radiation_msvh":
								iv.setRadiationMSVHString(param);
							break;
							case "received":
								iv.setReceivedString(param);
							break;
							case "entered":
								iv.setEnteredString(param);
							break;
							case "active":
								iv.setActiveString(param);
							break;
						}
						dirty = true;
					} catch(Exception ex){
						err.put(field, ex.getMessage());
					}
				}
			}

			if(dirty && err.isEmpty()){
				// Set the modified user to the current web user
				iv.setUser(request.getUserPrincipal().getName());

				int r = sess.update("gov.alaska.dggs.igneous.Inventory.update", iv);

				if(r < 1){
					request.setAttribute("message", "Save failed");
				} else {
					sess.commit();
					request.setAttribute("message", "Data saved");
				}
			} else if(dirty && !err.isEmpty()){
				request.setAttribute("message", "Could not save, error(s) in data");
			}

			request.setAttribute("inventory", iv);
			request.setAttribute("err", err);

			request.getRequestDispatcher(
				"/WEB-INF/tmpl/inventory_edit.jsp"
			).forward(request, response);
		} catch(Exception ex){
			sess.rollback();
			throw new ServletException(ex);
		} finally {
			sess.close();	
		}
	}
}
