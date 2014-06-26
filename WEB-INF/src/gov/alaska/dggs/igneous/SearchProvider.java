package gov.alaska.dggs.igneous;

import java.util.Map;
import java.util.Set;

public class SearchProvider {
	public static String search(Map params)
	{
		String query = (String)params.remove("_query");
		return query;
	}
}
