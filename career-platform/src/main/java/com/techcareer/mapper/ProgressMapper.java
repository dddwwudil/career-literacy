package com.techcareer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.techcareer.entity.Progress;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface ProgressMapper extends BaseMapper<Progress> {

    @Select("SELECT * FROM user_progress WHERE session_uuid = #{uuid} AND career_id = #{careerId} ORDER BY id DESC LIMIT 1")
    Progress selectLatestBySession(@Param("uuid") String uuid, @Param("careerId") Integer careerId);
}