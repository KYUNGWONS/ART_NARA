package com.example.unitrip.domain.verification.dto;

import com.example.unitrip.domain.verification.entity.Verification;
import com.example.unitrip.domain.verification.entity.VerificationStatus;
import com.example.unitrip.domain.verification.entity.VerificationType;
import io.swagger.v3.oas.annotations.media.Schema;

public class VerificationDto {

    public record SubmitRequest(Long userId, VerificationType type, String documentUrl) {}
    public record RejectRequest(String reason) {}

    @Schema(name = "VerificationResponse")
    public record Response(Long id, Long userId, VerificationType type,
                           VerificationStatus status, String documentUrl, String rejectReason) {
        public static Response from(Verification v) {
            return new Response(v.getId(), v.getUser().getId(), v.getType(),
                    v.getStatus(), v.getDocumentUrl(), v.getRejectReason());
        }
    }
}
