package com.techcareer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("scenes")
public class Scene {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private Integer careerId;
    private Integer sceneOrder;
    private String sceneName;
    private String sceneSubtitle;
    private String narrativeText;
    private Double cameraPosX;
    private Double cameraPosY;
    private Double cameraPosZ;
    private String sceneConfig;
}