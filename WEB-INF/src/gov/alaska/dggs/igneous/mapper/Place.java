package gov.alaska.dggs.igneous.mapper;

import org.apache.ibatis.annotations.Select;

public interface Place {
	@Select("SELECT place_id AS id, name, type FROM place WHERE place_id = #{id}")
	gov.alaska.dggs.igneous.model.Place byID(int id);
}
