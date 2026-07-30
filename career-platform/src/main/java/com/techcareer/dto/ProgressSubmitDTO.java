package com.techcareer.dto;

import lombok.Data;
import java.util.Map;

@Data
public class ProgressSubmitDTO {
    private String sessionUuid;
    private Integer careerId;
    private Integer sceneId;
    private Map<Integer, Integer> questAnswers;
}