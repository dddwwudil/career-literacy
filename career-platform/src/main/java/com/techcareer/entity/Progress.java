package com.techcareer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user_progress")
public class Progress {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private String sessionUuid;
    private Integer careerId;
    private Integer currentSceneId;
    private String questAnswers;
    private Integer totalScore;
    private Boolean isFinished;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}