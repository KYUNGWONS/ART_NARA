package com.example.unitrip.global.common;

import org.springframework.http.HttpStatusCode;

public interface ResultCode {
    String getCode();
    String getMessage();
    HttpStatusCode getStatus();
}
