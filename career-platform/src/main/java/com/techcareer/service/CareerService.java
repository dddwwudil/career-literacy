package com.techcareer.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.techcareer.entity.Career;
import com.techcareer.mapper.CareerMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class CareerService {

    @Autowired
    private CareerMapper careerMapper;

    public List<Career> getAll() {
        LambdaQueryWrapper<Career> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Career::getId);
        return careerMapper.selectAll();
    }

    public Career getById(Integer id) {
        return careerMapper.selectById(id);
    }
}