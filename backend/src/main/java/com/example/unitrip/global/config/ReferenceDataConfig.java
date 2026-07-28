package com.example.unitrip.global.config;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ScriptUtils;

import javax.sql.DataSource;
import java.sql.Connection;

/**
 * 추천 장소/활동(recommended_places, recommended_activities)은 test.sql의 더미 데이터와 달리
 * 실 서비스 운영에도 필요한 참조 데이터이므로, SQL_INIT_MODE(더미 데이터 on/off 스위치)와
 * 무관하게 모든 환경에서 매 부팅마다 항상 적재한다. INSERT IGNORE로 작성돼 있어 반복 실행해도 안전하다.
 */
@Configuration
@RequiredArgsConstructor
public class ReferenceDataConfig {

    private final DataSource dataSource;

    @Bean
    public ApplicationRunner referenceDataRunner() {
        return args -> {
            try (Connection connection = dataSource.getConnection()) {
                ScriptUtils.executeSqlScript(connection, new ClassPathResource("reference-data.sql"));
            }
        };
    }
}
