package gov.alaska.dggs.igneous.api;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import java.text.SimpleDateFormat;

import java.util.Base64;
import java.util.Date;
import java.util.TimeZone;

public class Auth
{
	public static void CheckHeader(String secret, String auth, long authdate, String payload) throws Exception {
		if(authdate < 1){
			throw new Exception("Invalid date");
		}

		// Is the authdate within 30 seconds of now?
		long currdate = System.currentTimeMillis();
		long diff = currdate - authdate;
		if(diff < -30000 || diff > 30000){
			throw new Exception("Invalid date range");
		}

		if(auth == null){
			throw new Exception("No authentication provided");
		}
			
		// Right now this only supports BASE64 encoded HMAC-SHA256
		if(!auth.startsWith("BASE64-HMAC-SHA256 ")){
			throw new Exception("Unsupported authentication type");
		}

		String remotehmac = auth.substring(19);

		SimpleDateFormat sdf = new SimpleDateFormat(
			"EEE, dd MMM yyyy HH:mm:ss zzz"
		);
		sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
		String dt = sdf.format(new Date(authdate));
		String msg = String.format("%s\n%s", dt, payload);

		Mac mac = Mac.getInstance("HmacSHA256");
		SecretKeySpec spec = new SecretKeySpec(
			secret.getBytes(), "HmacSHA256"
		);
		mac.init(spec);
		String localhmac = Base64.getEncoder().encodeToString(
			mac.doFinal(msg.getBytes())
		);

		if(!localhmac.equals(remotehmac)){
			throw new Exception("Invalid authentication");
		}
	}
}
