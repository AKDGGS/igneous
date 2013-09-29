package gov.alaska.dggs.igneous;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;

import com.google.zxing.common.BitMatrix;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;



public class BarcodeServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		String code = request.getParameter("c");
		try {
			if(code == null){ throw new Exception("Empty barcode."); }

			MultiFormatWriter writer = new MultiFormatWriter();
			BitMatrix matrix = writer.encode(code, BarcodeFormat.CODE_39, 1, 20);

			response.setContentType("image/png");
			MatrixToImageWriter.writeToStream(
				matrix, "png", response.getOutputStream()
			);
		} catch(Exception ex){
			throw new ServletException(ex);
		}
	}
}
