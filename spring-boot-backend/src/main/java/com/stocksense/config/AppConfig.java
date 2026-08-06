package com.stocksense.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.config.annotation.*;

import java.nio.file.Paths;

@Configuration
@RequiredArgsConstructor
public class AppConfig implements WebMvcConfigurer {

    private final UriInterceptor uriInterceptor;

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    // ObjectMapper is now defined in JacksonConfig.java - removed from here

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(uriInterceptor);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String uploadPath = Paths.get("uploads").toAbsolutePath().toUri().toString();
        registry.addResourceHandler("/uploads/**").addResourceLocations(uploadPath);
        registry.addResourceHandler("/static/**").addResourceLocations("classpath:/static/");
    }
}
