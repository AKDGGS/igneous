package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.util.Iterator;
import java.util.List;
import java.util.HashMap;
import java.util.zip.GZIPOutputStream;

import org.apache.ibatis.session.SqlSession;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.xhtmlrenderer.pdf.ITextRenderer;
import org.xhtmlrenderer.resource.FSEntityResolver;
import org.xml.sax.InputSource;
import java.io.StringReader;

import org.apache.commons.lang3.StringEscapeUtils;


public class OilGasServlet extends HttpServlet
{
	@SuppressWarnings("unchecked")
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		StringBuilder html = new StringBuilder();

		SqlSession sess = IgneousFactory.openSession();
		try {
			List<HashMap> wells = sess.selectList(
				"gov.alaska.dggs.igneous.Well.getOilGas"
			);

			html.append("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n");
			html.append("<html xmlns=\"http://www.w3.org/1999/xhtml\">\n");
			html.append("	<head>\n");
			html.append("		<title>Oil Gas Wells Inventory Summary</title>\n");
			html.append("		<style type=\"text/css\">\n");
			html.append("			body { padding: 4px 8px; margin: 0px; }\n");
			html.append("			h1 { text-align: center; }\n");
			html.append("			table { border-collapse: collapse; }\n");
			html.append("			th { text-align: left; }\n");
			html.append("			td, th { vertical-align: top; padding: 4px 8px; font-size: 14px; }\n");
			html.append("			tbody th { font-weight: normal; border-top: 1px solid black; padding-top: 8px; }\n");
			html.append("			td.r { text-align: right; }\n");
			html.append("		</style>\n");
			html.append("	</head>\n");
			html.append("	<body>\n");
			html.append("		<h1>Oil Gas Wells Inventory Summary</h1>\n");
			html.append("		<table>\n");
			html.append("			<thead>\n");
			html.append("				<tr>\n");
			html.append("					<th>Well Name</th>\n");
			html.append("					<th>Material</th>\n");
			html.append("					<th>Top</th>\n");
			html.append("					<th>Bottom</th>\n");
			html.append("					<th>Count</th>\n");
			html.append("					<th>Latitude/Longitude</th>\n");
			html.append("				</tr>\n");
			html.append("			</thead>\n");
			html.append("			<tbody>\n");

			if(wells != null){
				Iterator<HashMap> witr = wells.iterator();

				int last_well_id = 0;

				for(int i = 0; witr.hasNext(); i++){
					HashMap well = witr.next();
					int well_id = (Integer)well.get("well_id");

					if(well_id != last_well_id){
						html.append("				<tr>\n");

						html.append("					<th>");
						html.append(StringEscapeUtils.escapeHtml4(
							String.valueOf(well.get("well_name"))
						));
						if(well.get("well_number") != null){
							html.append(" #");
							html.append(StringEscapeUtils.escapeHtml4(
								String.valueOf(well.get("well_number"))
							));
						}
						if(well.get("api_number") != null){
							html.append("<br/>");
							html.append(StringEscapeUtils.escapeHtml4(
								String.valueOf(well.get("api_number"))
							));
						}
						html.append("</th>\n");

						html.append("					<th>&nbsp;</th>\n");
						html.append("					<th>&nbsp;</th>\n");
						html.append("					<th>&nbsp;</th>\n");
						html.append("					<th>&nbsp;</th>\n");

						html.append("					<th>");
						if(well.get("lonlat") != null){
							html.append(StringEscapeUtils.escapeHtml4(
								String.valueOf(well.get("lonlat"))
							));
						} else {
							html.append("&nbsp;");
						}
						html.append("</th>\n");

						html.append("				</tr>\n");
					}

					if(well.get("name") != null){
						html.append("				<tr>\n");
						html.append("					<td>&nbsp;</td>\n");
						html.append("					<td>");
						html.append(StringEscapeUtils.escapeHtml4(
							String.valueOf(well.get("name"))
						));
						html.append("</td>\n");

						html.append("					<td>");
						if(well.get("top") != null){
							html.append(StringEscapeUtils.escapeHtml4(
								String.valueOf(well.get("top"))
							));
						} else {
							html.append("&nbsp;");
						}
						html.append("</td>\n");

						html.append("					<td>");
						if(well.get("bottom") != null){
							html.append(StringEscapeUtils.escapeHtml4(
								String.valueOf(well.get("bottom"))
							));
						} else {
							html.append("&nbsp;");
						}
						html.append("</td>\n");

						html.append("					<td class=\"r\">");
						html.append(StringEscapeUtils.escapeHtml4(
							String.valueOf(well.get("total"))
						));
						html.append("</td>\n");

						html.append("					<td>&nbsp;</td>\n");
						html.append("				</tr>\n");
					}

					last_well_id = well_id;
				}
			}

			html.append("			</tbody>\n");
			html.append("		</table>\n");
			html.append("	</body>\n");
			html.append("</html>\n");

			OutputStream out = null;
			try { 
				// If GZIP is supported by the requesting browser, use it.
				String encoding = request.getHeader("Accept-Encoding");
				if(encoding != null && encoding.contains("gzip")){
					response.setHeader("Content-Encoding", "gzip");
					out = (OutputStream)new GZIPOutputStream(response.getOutputStream(), 8196);
				} else {
					out = response.getOutputStream();
				}

				String path = request.getServletPath();
				if(path.endsWith("pdf")){
					DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
					factory.setNamespaceAware(true);
					factory.setValidating(false);
					DocumentBuilder builder = factory.newDocumentBuilder();
					builder.setEntityResolver(FSEntityResolver.instance());

					Document doc = builder.parse(
						new InputSource(new StringReader(html.toString()))
					);

					ITextRenderer renderer = new ITextRenderer();
					renderer.setDocument(doc, null);
					renderer.layout();

					response.setContentType("application/pdf");
					renderer.createPDF(out);
				} else {
					response.setContentType("text/html");
					out.write(html.toString().getBytes("UTF-8"));
				}
			} finally {
				if(out != null){ out.close(); }
			}
		} catch(Exception ex){
			if(!response.isCommitted()){
				response.reset();
				response.setStatus(500);
				response.setContentType("text/plain");
				response.getOutputStream().print(ex.getMessage());
			}
			ex.printStackTrace();
		} finally {
			sess.close();
		}
	}
}
