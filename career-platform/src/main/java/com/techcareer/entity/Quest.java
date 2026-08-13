package com.techcareer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("quests")
public class Quest {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private Integer sceneId;
    private Integer questOrder;
    private String questType;
    private String npcName;
    private String title;
    private String description;
    private String options;
    private Integer correctIndex;
    private String knowledgePoint;
    private String rewardText;
}