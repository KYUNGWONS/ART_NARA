package com.example.unitrip.global.exception;

import com.example.unitrip.global.common.ResultCode;
import lombok.Getter;

@Getter
public class GlobalException extends RuntimeException{
    private final ResultCode resultCode;
    private final String detailMessage;


    public GlobalException(ResultCode resultCode) {
        super(resultCode.getMessage());
        this.resultCode = resultCode;
        this.detailMessage = null;
    }

    public GlobalException(ResultCode resultCode, String detailMessage) {
        super(detailMessage != null ? detailMessage : resultCode.getMessage());
        this.resultCode = resultCode;
        this.detailMessage = detailMessage;
    }

    public String resolveMessage() {
        return (detailMessage != null && !detailMessage.isBlank())
                ? detailMessage
                : resultCode.getMessage();
    }
}
