package gov.alaska.dggs.igneous.page;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;

import java.text.DateFormat;
import java.util.GregorianCalendar;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Prospect;
import gov.alaska.dggs.igneous.model.Quadrangle;


public class ContainerLogViewServlet extends HttpServlet
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
			Calendar now = new GregorianCalendar();
			DateFormat fmt = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);

			String start = request.getParameter("start");
			String end = request.getParameter("end");

			if(start != null && start.trim().length() > 0 && end != null && end.trim().length() > 0){
				Map<String,String> params = new HashMap<String,String>();
				params.put("start", start);
				params.put("end", end);
				request.setAttribute("logs", sess.selectList(
					"gov.alaska.dggs.igneous.Container.getContainerLogByDate",
					params
				));
			} else {
				if(start == null || start.trim().length() == 0){
					now.set(Calendar.HOUR_OF_DAY, now.getMinimum(Calendar.HOUR_OF_DAY));
					now.set(Calendar.MINUTE, now.getMinimum(Calendar.MINUTE));
					now.set(Calendar.SECOND, now.getMinimum(Calendar.SECOND));
					now.set(Calendar.MILLISECOND, now.getMinimum(Calendar.MILLISECOND));
					start = fmt.format(now.getTime());
				}

				if(end == null || end.trim().length() == 0){
					now.set(Calendar.HOUR_OF_DAY, now.getMaximum(Calendar.HOUR_OF_DAY));
					now.set(Calendar.MINUTE, now.getMaximum(Calendar.MINUTE));
					now.set(Calendar.SECOND, now.getMaximum(Calendar.SECOND));
					now.set(Calendar.MILLISECOND, now.getMaximum(Calendar.MILLISECOND));
					end = fmt.format(now.getTime());
				}
			}

			request.setAttribute("start", start);
			request.setAttribute("end", end);

			request.getRequestDispatcher(
				"/WEB-INF/tmpl/container_log.jsp"
			).forward(request, response);
		} catch(Exception ex){
			throw new ServletException(ex);
		} finally {
			sess.close();	
		}
	}
}
