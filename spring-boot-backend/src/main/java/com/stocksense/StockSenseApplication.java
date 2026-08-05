package com.stocksense;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;
import java.util.TimeZone;

@SpringBootApplication
@EnableScheduling
public class StockSenseApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(StockSenseApplication.class);
    }

    public static void main(String[] args) {
        // Set JVM timezone to Sri Lanka (UTC+5:30) — must be FIRST before Spring starts
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Colombo"));
        SpringApplication.run(StockSenseApplication.class, args);
    }
}
