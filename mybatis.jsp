<%@ page import="
	org.apache.ibatis.session.SqlSession,
	java.util.ArrayList,
	java.util.List,
	java.util.Map,
	java.util.HashMap,
	gov.alaska.dggs.igneous.IgneousFactory,
	gov.alaska.dggs.igneous.model.Borehole
"%><%
	SqlSession sess = IgneousFactory.openSession();
	try {
		out.println( 
			sess.selectList(
				"gov.alaska.dggs.igneous.Borehole.getIDByWKT",
				"POLYGON((-18090201 7938546,-18090201 11989097,-15194155 11989097,-15194155 7938546,-18090201 7938546))"
			)
		);
	} finally {
		sess.close();	
	}
%>
