package com.techcareer.controller;

import com.techcareer.dto.ApiResponse;
import com.techcareer.dto.ProgressSubmitDTO;
import com.techcareer.entity.Career;
import com.techcareer.entity.Progress;
import com.techcareer.entity.Quest;
import com.techcareer.entity.Scene;
import com.techcareer.service.CareerService;
import com.techcareer.service.ProgressService;
import com.techcareer.service.QuestService;
import com.techcareer.service.SceneService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")


public class ApiController {

    @GetMapping("/test")
    public String test() {
        return "Backend is running!";
    }

    @Autowired
    private CareerService careerService;

    @Autowired
    private SceneService sceneService;

    @Autowired
    private QuestService questService;

    @Autowired
    private ProgressService progressService;

    @GetMapping("/careers")
    public ApiResponse<List<Career>> getCareers() {
        return ApiResponse.success(careerService.getAll());
    }

    @GetMapping("/scenes")
    public ApiResponse<List<Scene>> getScenes(@RequestParam Integer careerId) {
        return ApiResponse.success(sceneService.getByCareerId(careerId));
    }

    @GetMapping("/quests")
    public ApiResponse<List<Quest>> getQuests(@RequestParam Integer sceneId) {
        return ApiResponse.success(questService.getBySceneId(sceneId));
    }

    @PostMapping("/progress/init")
    public ApiResponse<Map<String, Object>> initProgress(@RequestBody Map<String, Object> params) {
        String sessionUuid = (String) params.get("sessionUuid");
        Integer careerId = (Integer) params.get("careerId");

        if (sessionUuid == null || sessionUuid.isEmpty()) {
            sessionUuid = progressService.getOrCreateSession(null);
        }

        Progress progress = progressService.getLatest(sessionUuid, careerId);
        if (progress == null) {
            progress = progressService.create(careerId, sessionUuid);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("progress", progress);
        result.put("sessionUuid", sessionUuid);
        return ApiResponse.success(result);
    }

    @PostMapping("/progress/submit")
    public ApiResponse<Progress> submitProgress(@RequestBody ProgressSubmitDTO dto) {
        String sessionUuid = progressService.getOrCreateSession(dto.getSessionUuid());
        dto.setSessionUuid(sessionUuid);
        Progress progress = progressService.submitProgress(dto);
        return ApiResponse.success(progress);
    }

    @GetMapping("/progress")
    public ApiResponse<Progress> getProgress(@RequestParam String sessionUuid, @RequestParam Integer careerId) {
        Progress progress = progressService.getLatest(sessionUuid, careerId);
        if (progress == null) {
            return ApiResponse.error("未找到进度记录");
        }
        return ApiResponse.success(progress);
    }

    @GetMapping("/careers/{id}/detail")
    public ApiResponse<Map<String, Object>> getCareerDetail(@PathVariable Integer id) {
        Career career = careerService.getById(id);
        if (career == null) {
            return ApiResponse.error("职业不存在");
        }
        List<Scene> scenes = sceneService.getByCareerId(id);

        Map<String, Object> result = new HashMap<>();
        result.put("career", career);
        result.put("scenes", scenes);
        return ApiResponse.success(result);
    }
}