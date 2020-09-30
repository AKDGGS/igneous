package gov.alaska.dggs.igneous.api;

import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.naming.Context;
import javax.naming.InitialContext;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import java.util.zip.GZIPOutputStream;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Date;
import java.util.Arrays;
import java.util.TimeZone;
import java.util.Base64;

import java.text.SimpleDateFormat;

import flexjson.JSONSerializer;
import flexjson.transformer.DateTransformer;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.IgneousFactory;
import gov.alaska.dggs.igneous.model.Inventory;
import gov.alaska.dggs.igneous.transformer.ExcludeTransformer;
import gov.alaska.dggs.igneous.transformer.IterableTransformer;


public class InventoryServlet extends HttpServlet
{
	private static JSONSerializer serializer;
	static {
		serializer = new JSONSerializer();
		serializer.include("wells");
		serializer.include("wells.operators");
		serializer.include("boreholes");
		serializer.include("outcrops");
		serializer.include("keywords");
		serializer.include("files");
		serializer.include("shotpoints");
		serializer.include("collections");
		serializer.include("publications");
		serializer.include("container");

		serializer.exclude("*.class");
		serializer.exclude("WKT");

		serializer.transform(new DateTransformer("M/d/yyyy"), Date.class);
		serializer.transform(new ExcludeTransformer(), void.class);
		serializer.transform(new IterableTransformer(), Iterable.class);
	}

	public static boolean CheckAuthHeader(String secret, String auth, long authdate, String payload)
	{
		try {
			if(authdate < 1){ return false; }

			// Is the authdate within 30 seconds of now?
			long currdate = System.currentTimeMillis();
			long diff = currdate - authdate;
			if(diff < -30000 || diff > 30000){ return false; }

			if(auth == null){ return false; }
			
			// Right now this only supports BASE64 encoded HMAC-SHA256
			if(!auth.startsWith("BASE64-HMAC-SHA256 ")){ return false; }

			String remotehmac = auth.substring(19);

			SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss zzz");
			sdf.setTimeZone(TimeZone.getTimeZone("GMT"));

			String msg = String.format("%s\n%s", 
				sdf.format(new Date(authdate)),
				payload
			);

			Mac mac = Mac.getInstance("HmacSHA256");
			SecretKeySpec spec = new SecretKeySpec(
				secret.getBytes("UTF-8"), "HmacSHA256"
			);
			mac.init(spec);
			String localhmac = Base64.getEncoder().encodeToString(
				mac.doFinal(msg.getBytes("UTF-8"))
			);

			if(localhmac.equals(remotehmac)){
				return true;
			}
		} catch(Exception ex){
			// Explicitly do nothing
		}
		return false;
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		ServletContext context = getServletContext();

		boolean auth = false;
		try {
			Context initcontext = new InitialContext();
			String apikey = (String)initcontext.lookup(
				"java:comp/env/igneous/apikey"
			);
			auth = CheckAuthHeader(
				apikey,
				request.getHeader("Authorization"),
				request.getDateHeader("Date"),
				request.getQueryString()
			);
		} catch(Exception ex){
			// Explicitly do nothing
		}
		if(auth == false){
			response.sendError(
				HttpServletResponse.SC_FORBIDDEN,
				"Authentication Invalid"
			);
			return;
		}

		Integer id = null;
		try { id = Integer.valueOf(request.getParameter("id")); }
		catch(Exception ex){ }
		String barcode = request.getParameter("barcode");

		// Aggressively disable cache
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Pragma","no-cache");
		response.setDateHeader("Expires", 0);

		SqlSession sess = IgneousFactory.openSession();
		try {
			List<Inventory> output = null;

			if(id != null){
				output = sess.selectList(
					"gov.alaska.dggs.igneous.Inventory.getByID", id
				);
			} else if(barcode != null){
				output = sess.selectList(
					"gov.alaska.dggs.igneous.Inventory.getByBarcode", barcode
				);
			}

			OutputStreamWriter out = null;
			GZIPOutputStream gos = null;
			try { 
				// If GZIP is supported by the requesting browser, use it.
				String encoding = request.getHeader("Accept-Encoding");
				if(encoding != null && encoding.contains("gzip")){
					response.setHeader("Content-Encoding", "gzip");
					gos = new GZIPOutputStream(response.getOutputStream(), 8196);
					out = new OutputStreamWriter(gos, "utf-8");
				} else {
					out = new OutputStreamWriter(response.getOutputStream(), "utf-8");
				}

				response.setContentType("application/json");
				serializer.serialize(output, out);
			} finally {
				if(out != null){ out.close(); }
				if(gos != null){ gos.close(); }
			}
		} catch(Exception ex){
			response.setStatus(500);
			response.setContentType("text/plain");
			response.getOutputStream().print(ex.getMessage());
		} finally {
			sess.close();	
		}
	}
}
