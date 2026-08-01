package com.example.artnara.domain.user.entity;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * 시·도. 앱의 프로필 설정 드롭다운은 한글 명칭("서울특별시")을 그대로 주고받으므로
 * JSON 직렬화는 한글 라벨을 사용한다(역직렬화는 라벨/enum 이름 모두 허용).
 * DB에는 JPA @Enumerated(STRING) 규칙대로 enum 이름(SEOUL …)이 저장된다.
 */
public enum Sido {
    SEOUL("서울특별시"),
    BUSAN("부산광역시"),
    DAEGU("대구광역시"),
    INCHEON("인천광역시"),
    GWANGJU("광주광역시"),
    DAEJEON("대전광역시"),
    ULSAN("울산광역시"),
    SEJONG("세종특별자치시"),
    GYEONGGI("경기도"),
    GANGWON("강원특별자치도"),
    CHUNGBUK("충청북도"),
    CHUNGNAM("충청남도"),
    JEONBUK("전북특별자치도"),
    JEONNAM("전라남도"),
    GYEONGBUK("경상북도"),
    GYEONGNAM("경상남도"),
    JEJU("제주특별자치도");

    private final String label;

    Sido(String label) {
        this.label = label;
    }

    @JsonValue
    public String getLabel() {
        return label;
    }

    @JsonCreator
    public static Sido from(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        for (Sido sido : values()) {
            if (sido.label.equals(value) || sido.name().equalsIgnoreCase(value)) {
                return sido;
            }
        }
        throw new IllegalArgumentException("알 수 없는 시·도입니다: " + value);
    }
}
