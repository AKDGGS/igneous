package gov.alaska.dggs.igneous.api;

import org.apache.ibatis.session.SqlSession;

import gov.alaska.dggs.igneous.model.Token;
import gov.alaska.dggs.igneous.IgneousFactory;

public class TokenAuth
{
	public static Token Check(String auth) throws Exception
	{
		if(auth == null || auth.length() < 7){
			throw new Exception("Authentication failure: no credentials");
		}
			
		// Only a auth type of "token" is supported
		if(!auth.startsWith("Token ")){
			throw new Exception("Authentication failure: unsupported type");
		}

		String token = auth.substring(6);
		try (SqlSession sess = IgneousFactory.openSession()) {
			Token t = sess.selectOne(
				"gov.alaska.dggs.igneous.Token.getByToken", token
			);
			if(t == null){
				throw new Exception("Authentication failure: invalid token");
			}
			return t;
		}
	}
}
