package com.techcareer.mapper;

import com.techcareer.entity.Career;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface CareerMapper {
    @Select("SELECT * FROM careers")
    List<Career> selectAll();

    // 其他方法根据需要添加，比如根据 id 查询
    @Select("SELECT * FROM careers WHERE id = #{id}")
    Career selectById(Integer id);
}