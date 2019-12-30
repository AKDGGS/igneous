package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;

import java.util.List;
import java.util.Map;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamWriter;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;


public class NationalDigitalCatalogXMLServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { doPostGet(request,response); }

	@SuppressWarnings("unchecked")
	public void doPostGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		SqlSession sess = IgneousFactory.openSession();
		try {
			List<Map> rows = sess.selectList(
				"gov.alaska.dggs.igneous.Inventory.getNDC"
			);

			XMLOutputFactory factory = XMLOutputFactory.newInstance();
			XMLStreamWriter writer = factory.createXMLStreamWriter(
				response.getOutputStream(), "utf-8"
			);
			writer.writeStartDocument("utf-8", "1.0");
			writer.writeStartElement("samples");
			writer.writeNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance");
			writer.writeAttribute(
				"http://www.w3.org/2001/XMLSchema-instance",
				"noNamespaceSchemaLocation",
				"http://data.usgs.gov/nggdpp/NGGDPPMetadataSample_v4.xsd"
			);
			for(Map row : rows){
				writer.writeStartElement("sample");

				writer.writeStartElement("collectionID");
				writer.writeCharacters(context.getInitParameter("collectionid"));
				writer.writeEndElement();

				writer.writeStartElement("title");
				writer.writeCharacters("Alaska sample number ");
				writer.writeCharacters(row.get("sample_number").toString());
				writer.writeCharacters(" for inventory number ");
				writer.writeCharacters(row.get("inventory_id").toString());
				writer.writeEndElement();

				writer.writeStartElement("abstract");
				writer.writeCharacters("The Alaska ");
				writer.writeCharacters(row.get("collection").toString());
				writer.writeCharacters(
					" geological sample collection contains sample number "
				);
				writer.writeCharacters(row.get("sample_number").toString());
				writer.writeCharacters(" with the following attributes ");
				writer.writeCharacters(row.get("keywords").toString());
				writer.writeEndElement();

				writer.writeStartElement("dataType");
				for(String keyword : row.get("keywords").toString().split(", ")){
					writer.writeStartElement("type");
					writer.writeCharacters(keyword);
					writer.writeEndElement();
				}
				writer.writeEndElement();

				writer.writeStartElement("supplementalInformation");
				writer.writeStartElement("info");
				writer.writeCharacters(
					"All samples, processed materials, maps, documents, and data " + 
					"reports at the Alaska Geologic Materials Center are available " + 
					"to the public for examination except those designated by the " + 
					"Curator as confidential. Please see the website for more " + 
					"information: http://dggs.alaska.gov/gmc/access-samples.html"
				);
				writer.writeEndElement();
				writer.writeEndElement();

				writer.writeStartElement("coordinates");
				writer.writeCharacters(row.get("longitude").toString());
				writer.writeCharacters(",");
				writer.writeCharacters(row.get("latitude").toString());
				writer.writeEndElement();

				writer.writeStartElement("alternateGeometry");
				writer.writeCharacters(
					"The coordinates are represented in World Geodetic System 1984 " +
					"(WGS84)"
				);
				writer.writeEndElement();

				/*
				writer.writeStartElement("dates");
				writer.writeStartElement("date");
				writer.writeCharacters("?");
				writer.writeEndElement();
				writer.writeEndElement();
				*/

				writer.writeStartElement("onlineResource");
				writer.writeStartElement("resourceURL");
				writer.writeCharacters("https://maps.dggs.alaska.gov/gmc/inventory/");
				writer.writeCharacters(row.get("inventory_id").toString());
				writer.writeEndElement();
				writer.writeEndElement();

				writer.writeStartElement("datasetReferenceDate");
				writer.writeCharacters(row.get("received").toString());
				writer.writeEndElement();

				writer.writeEndElement();
			}
			writer.writeEndElement();
			writer.writeEndDocument();
			writer.close();

		} catch(Exception ex){
			throw new ServletException(ex);
		} finally {
			sess.close();	
		}
	}
}
