package gov.alaska.dggs.igneous;

import java.util.Map;
import java.util.List;
import org.apache.ibatis.annotations.SelectProvider;
import org.apache.ibatis.annotations.ResultMap;
import gov.alaska.dggs.igneous.model.Inventory;


public interface SearchMapper {
	@SelectProvider(type = gov.alaska.dggs.igneous.SearchProvider.class, method="search")
	List<Integer> search(Map params);
}
