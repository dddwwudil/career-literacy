package com.techcareer.service;

import com.techcareer.entity.Scene;
import com.techcareer.mapper.SceneMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class SceneService {

    @Autowired
    private SceneMapper sceneMapper;

    public List<Scene> getByCareerId(Integer careerId) {
        return sceneMapper.selectByCareerId(careerId);
    }

    public Scene getById(Integer id) {
        return sceneMapper.selectById(id);
    }
}