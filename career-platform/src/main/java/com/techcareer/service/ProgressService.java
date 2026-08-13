package com.techcareer.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.techcareer.dto.ProgressSubmitDTO;
import com.techcareer.entity.Progress;
import com.techcareer.entity.Quest;
import com.techcareer.entity.Scene;
import com.techcareer.mapper.ProgressMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class ProgressService {

    @Autowired
    private ProgressMapper progressMapper;

    @Autowired
    private QuestService questService;

    @Autowired
    private SceneService sceneService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public String getOrCreateSession(String existingUuid) {
        if (existingUuid != null && !existingUuid.isEmpty()) {
            return existingUuid;
        }
        return UUID.randomUUID().toString().replace("-", "").substring(0, 16);
    }

    public Progress create(Integer careerId, String sessionUuid) {
        List<Scene> scenes = sceneService.getByCareerId(careerId);
        Integer firstSceneId = scenes.isEmpty() ? null : scenes.get(0).getId();

        Progress progress = new Progress();
        progress.setSessionUuid(sessionUuid);
        progress.setCareerId(careerId);
        progress.setCurrentSceneId(firstSceneId);
        progress.setQuestAnswers("{}");
        progress.setTotalScore(0);
        progress.setIsFinished(false);
        progressMapper.insert(progress);
        return progress;
    }

    public Progress getLatest(String sessionUuid, Integer careerId) {
        return progressMapper.selectLatestBySession(sessionUuid, careerId);
    }

    @Transactional
    public Progress submitProgress(ProgressSubmitDTO dto) {
        Progress progress = getLatest(dto.getSessionUuid(), dto.getCareerId());
        if (progress == null) {
            progress = create(dto.getCareerId(), dto.getSessionUuid());
        }

        progress.setCurrentSceneId(dto.getSceneId());

        Map<Integer, Integer> existingAnswers = new HashMap<>();
        try {
            if (progress.getQuestAnswers() != null && !progress.getQuestAnswers().isEmpty()) {
                existingAnswers = objectMapper.readValue(progress.getQuestAnswers(), Map.class);
            }
        } catch (Exception ignored) {}

        int score = 0;
        for (Map.Entry<Integer, Integer> entry : dto.getQuestAnswers().entrySet()) {
            Integer questId = entry.getKey();
            Integer selectedIndex = entry.getValue();
            existingAnswers.put(questId, selectedIndex);

            List<Quest> quests = questService.getBySceneId(dto.getSceneId());
            for (Quest quest : quests) {
                if (quest.getId().equals(questId) && quest.getCorrectIndex() != null
                        && quest.getCorrectIndex().equals(selectedIndex)) {
                    score++;
                    break;
                }
            }
        }

        try {
            progress.setQuestAnswers(objectMapper.writeValueAsString(existingAnswers));
        } catch (Exception e) {
            progress.setQuestAnswers("{}");
        }

        progress.setTotalScore(progress.getTotalScore() + score);

        List<Scene> allScenes = sceneService.getByCareerId(dto.getCareerId());
        if (dto.getSceneId() >= allScenes.size()) {
            progress.setIsFinished(true);
        }

        progressMapper.updateById(progress);
        return progress;
    }
}