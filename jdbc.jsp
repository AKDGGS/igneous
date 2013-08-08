<%@ page import="
	javax.naming.InitialContext,
	java.sql.Connection,
	javax.sql.DataSource
"%><%
	DataSource ds = (DataSource)new InitialContext().lookup("java:comp/env/jdbc/igneous");

	Connection conn = ds.getConnection();

	try {
		out.println(conn);
	} finally {
		conn.close();
	}
%>
