<%@ page import="
	org.apache.ibatis.session.SqlSession,
	gov.alaska.dggs.igneous.IgneousFactory,
	gov.alaska.dggs.igneous.model.Place
"%><%
	SqlSession sess = IgneousFactory.openSession();
	try {
		Place place = (Place)sess.selectOne("gov.alaska.dggs.igneous.mapper.Place.byID", 101);
		
		out.println(place.getName());
	} finally {
		sess.close();	
	}
%>
