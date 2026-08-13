package com.techcareer;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
//@MapperScan("com.techcareer.mapper")
@SpringBootApplication
public class CareerPlatformApplication {

	public static void main(String[] args) {
		SpringApplication.run(CareerPlatformApplication.class, args);
	}

}
