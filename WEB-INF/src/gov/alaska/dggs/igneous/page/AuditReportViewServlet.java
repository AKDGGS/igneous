package gov.alaska.dggs.igneous.page;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;


public class AuditReportViewServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
	  LocalDateTime end = LocalDate.now().atTime(LocalTime.MAX);
		LocalDateTime start = LocalDate.now().minusDays(7).atTime(LocalTime.MIN);
		DateTimeFormatter dtf = DateTimeFormatter.ofPattern("M/d/yy HH:mm:ss");

		request.setAttribute("start", dtf.format(start));
		request.setAttribute("end", dtf.format(end));
		
		request.getRequestDispatcher(
			"/WEB-INF/tmpl/audit.jsp"
		).forward(request, response);
	}
}
