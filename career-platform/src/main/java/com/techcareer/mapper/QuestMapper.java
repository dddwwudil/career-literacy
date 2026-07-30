package com.techcareer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.techcareer.entity.Quest;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface QuestMapper extends BaseMapper<Quest> {

    @Select("SELECT * FROM quests WHERE scene_id = #{sceneId} ORDER BY quest_order")
    List<Quest> selectBySceneId(Integer sceneId);
}