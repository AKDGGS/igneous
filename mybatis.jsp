<%@ page import="
	org.apache.ibatis.session.SqlSession,
	java.util.ArrayList,
	java.util.List,
	gov.alaska.dggs.igneous.IgneousFactory,
	gov.alaska.dggs.igneous.model.Inventory,
	gov.alaska.dggs.igneous.model.Keyword
"%><%
	SqlSession sess = IgneousFactory.openSession();
	try {
		/*
		ArrayList<Long> ids = new ArrayList<Long>(){{
			add(7104L);
			add(7105L);
			add(7106L);
			add(7107L);
			add(7108L);
		}};
		*/

		long[] ids = new long[]{23843L,4L,6L};

		List<Inventory> items = sess.selectList("gov.alaska.dggs.igneous.Inventory.getResults", ids);

		for(Inventory item : items){
			out.print(item.getID());
			for(Keyword keyword : item.getKeywords()){
				out.print(" ");
				out.print(keyword.getName());
			}
			out.println("<br/>");
		}
	} finally {
		sess.close();	
	}
%>
