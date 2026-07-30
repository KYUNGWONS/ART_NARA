package com.example.artnara.domain.booking.controller;

import com.example.artnara.domain.booking.dto.BookingDto;
import com.example.artnara.domain.booking.service.BookingService;
import com.example.artnara.global.common.BaseResponse;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.util.List;

@Tag(name = "Appointment", description = "약속(홈 달력) API")
@RestController
@RequestMapping("/api/appointments")
@RequiredArgsConstructor
public class AppointmentController {

    private final BookingService bookingService;

    @GetMapping
    @Operation(summary = "내 약속 목록 조회(홈 달력)",
            description = "로그인한 사용자 본인의 약속(예약)을 월 단위로 조회합니다. " +
                    "`month`(yyyy-MM)로 해당 월 전체를 조회합니다. " +
                    "상대방(mateName/mateUserId)은 로그인 사용자 기준으로 계산됩니다. 대상은 JWT 신원에서 결정됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공(약속 없으면 빈 배열)"),
            @ApiResponse(responseCode = "400", description = "month 누락/형식 오류"),
            @ApiResponse(responseCode = "401", description = "인증 필요")
    })
    public BaseResponse<List<BookingDto.AppointmentResponse>> list(
            @Parameter(description = "조회 월(yyyy-MM)", example = "2026-07", required = true)
            @RequestParam(required = false) String month,
            Principal principal) {

        Long userId = Long.parseLong(principal.getName());
        YearMonth ym = parseMonth(month);

        return BaseResponse.success("내 약속 목록 조회",
                bookingService.listMyAppointments(userId, ym.atDay(1), ym.atEndOfMonth()));
    }

    private YearMonth parseMonth(String month) {
        if (month == null || month.isBlank()) {
            throw new GlobalException(DomainResultCode.INVALID_DATE_RANGE);
        }
        try {
            return YearMonth.parse(month); // ISO yyyy-MM
        } catch (DateTimeParseException e) {
            throw new GlobalException(DomainResultCode.INVALID_DATE_RANGE);
        }
    }
}
