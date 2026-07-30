package com.techcareer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.techcareer.entity.Scene;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface SceneMapper extends BaseMapper<Scene> {

    @Select("SELECT * FROM scenes WHERE career_id = #{careerId} ORDER BY scene_order")
    List<Scene> selectByCareerId(Integer careerId);
}