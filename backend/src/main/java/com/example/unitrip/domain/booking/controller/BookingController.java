package com.example.unitrip.domain.booking.controller;

import com.example.unitrip.domain.booking.dto.BookingDto;
import com.example.unitrip.domain.booking.service.BookingService;
import com.example.unitrip.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Booking", description = "예약 API")
@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    @Operation(summary = "예약 생성", description = "콘텐츠에 대한 예약을 생성합니다. 동일 날짜에 같은 콘텐츠를 중복 예약할 수 없습니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예약 생성 성공"),
            @ApiResponse(responseCode = "404", description = "콘텐츠 또는 사용자를 찾을 수 없음"),
            @ApiResponse(responseCode = "409", description = "중복 예약")
    })
    public BaseResponse<BookingDto.Response> create(@RequestBody BookingDto.CreateRequest req) {
        return BaseResponse.success("예약 생성", bookingService.create(req));
    }

    @GetMapping("/{id}")
    @Operation(summary = "예약 조회", description = "예약 ID로 예약 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예약 조회 성공"),
            @ApiResponse(responseCode = "404", description = "예약을 찾을 수 없음")
    })
    public BaseResponse<BookingDto.Response> get(
            @Parameter(description = "예약 ID", example = "1") @PathVariable Long id) {
        return BaseResponse.success("예약 조회", bookingService.get(id));
    }

    @GetMapping
    @Operation(summary = "예약 목록 조회", description = "게스트 ID 또는 메이트 ID로 예약 목록을 조회합니다. mateId가 우선 적용됩니다.")
    @ApiResponse(responseCode = "200", description = "예약 목록 조회 성공")
    public BaseResponse<List<BookingDto.Response>> list(
            @Parameter(description = "게스트 사용자 ID") @RequestParam(required = false) Long guestId,
            @Parameter(description = "메이트 사용자 ID") @RequestParam(required = false) Long mateId) {
        if (mateId != null) return BaseResponse.success("메이트 예약 조회", bookingService.listByMate(mateId));
        return BaseResponse.success("게스트 예약 조회", bookingService.listByGuest(guestId));
    }

    @PostMapping("/{id}/confirm")
    @Operation(summary = "예약 확정", description = "예약 상태를 CONFIRMED로 변경합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예약 확정 성공"),
            @ApiResponse(responseCode = "404", description = "예약을 찾을 수 없음")
    })
    public BaseResponse<Void> confirm(
            @Parameter(description = "예약 ID", example = "1") @PathVariable Long id) {
        bookingService.confirm(id);
        return BaseResponse.success("예약 확정", null);
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "예약 취소", description = "예약 상태를 CANCELLED로 변경합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예약 취소 성공"),
            @ApiResponse(responseCode = "404", description = "예약을 찾을 수 없음")
    })
    public BaseResponse<Void> cancel(
            @Parameter(description = "예약 ID", example = "1") @PathVariable Long id) {
        bookingService.cancel(id);
        return BaseResponse.success("예약 취소", null);
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "예약 완료", description = "예약 상태를 COMPLETED로 변경합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예약 완료 성공"),
            @ApiResponse(responseCode = "404", description = "예약을 찾을 수 없음")
    })
    public BaseResponse<Void> complete(
            @Parameter(description = "예약 ID", example = "1") @PathVariable Long id) {
        bookingService.complete(id);
        return BaseResponse.success("예약 완료", null);
    }
}
