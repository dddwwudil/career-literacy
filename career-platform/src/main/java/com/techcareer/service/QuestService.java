package com.techcareer.service;

import com.techcareer.entity.Quest;
import com.techcareer.mapper.QuestMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class QuestService {

    @Autowired
    private QuestMapper questMapper;

    public List<Quest> getBySceneId(Integer sceneId) {
        return questMapper.selectBySceneId(sceneId);
    }
}