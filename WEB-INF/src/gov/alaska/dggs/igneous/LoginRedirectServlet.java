package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;


public class LoginRedirectServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		PrintWriter out = response.getWriter();
		out.println("<!DOCTYPE html>");
		out.println("<html lang=\"en\">");
		out.println("\t<head>");
		out.println("\t\t<meta charset=\"utf-8\">");
		out.println("\t\t<title>login redirect</title>");
		out.println("\t\t<meta http-equiv=\"refresh\" content=\"1;url=..\">");
		out.println("\t\t<script type=\"text/javascript\">");
		out.println("\t\t\twindow.location.href = '..';");
		out.println("\t\t</script>");
		out.println("\t</head>");
		out.println("\t<body>");
		out.println("\t\tIf you are not immediately redirected, ");
		out.println("\t\t<a href=\"..\">click here</a>");
		out.println("\t</body>");
		out.println("</html>");
		out.flush();
		out.close();
	}
}
