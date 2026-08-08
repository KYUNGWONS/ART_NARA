package com.example.artnara.global.config;

import jakarta.annotation.PostConstruct;
import org.springframework.boot.jackson.autoconfigure.JsonMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import tools.jackson.core.JsonGenerator;
import tools.jackson.databind.SerializationContext;
import tools.jackson.databind.module.SimpleModule;
import tools.jackson.databind.ser.std.StdSerializer;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.TimeZone;

/**
 * 서버가 내려주는 시각에 시간대를 붙인다.
 *
 * 예전에는 {@link LocalDateTime} 을 그대로 직렬화해 "2026-08-09T01:54:22" 처럼
 * **오프셋 없는 문자열**이 나갔다. 앱은 이걸 기기 시간대 기준으로 읽으므로,
 * 기기와 서버의 시간대가 다르면 시각이 통째로 어긋난다
 * (에뮬레이터가 GMT 라서 01:54 에 보낸 채팅이 화면에 "오전 1:54" 로 떴다 — 기기 시계로는 16:54).
 * 운영 서버를 UTC 로 띄우면 실제 사용자에게도 9시간 어긋난다.
 *
 * 그래서 두 가지를 못박는다.
 * <ul>
 *   <li>JVM 기본 시간대를 Asia/Seoul 로 고정 — 배포 환경이 UTC 여도 저장·조회 기준이 안 흔들린다.</li>
 *   <li>응답에는 오프셋을 붙여 내린다("2026-08-09T01:54:22+09:00") — 앱이 기기 시간대로 변환할 수 있다.</li>
 * </ul>
 *
 * 일반 {@code Module} 빈이 아니라 빌더 커스터마이저로 등록한다 —
 * 모듈로 붙이면 뒤에 등록되는 기본 날짜 모듈이 이겨서 오프셋이 사라진다(실측).
 * 요청 본문 파싱은 건드리지 않는다(기존 형식 그대로 받는다).
 */
@Configuration
public class TimeZoneConfig {

    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");

    @PostConstruct
    public void fixDefaultTimeZone() {
        TimeZone.setDefault(TimeZone.getTimeZone(SERVICE_ZONE));
    }

    @Bean
    public JsonMapperBuilderCustomizer offsetAwareDateTimes() {
        SimpleModule module = new SimpleModule("artnara-offset-datetime");
        module.addSerializer(LocalDateTime.class, new OffsetWriter());
        return builder -> builder.addModule(module);
    }

    private static final class OffsetWriter extends StdSerializer<LocalDateTime> {

        private OffsetWriter() {
            super(LocalDateTime.class);
        }

        @Override
        public void serialize(LocalDateTime value, JsonGenerator gen, SerializationContext context) {
            gen.writeString(value.atZone(SERVICE_ZONE).format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        }
    }
}
