package com.techcareer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("careers")
public class Career {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private String name;
    private String icon;
    private String description;
    private String status;
    private String themeColor;
    private Integer totalScenes;
    private LocalDateTime createdAt;
    private String growthPath;
}