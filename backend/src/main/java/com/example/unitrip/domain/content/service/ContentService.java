package com.example.unitrip.domain.content.service;

import com.example.unitrip.domain.content.dto.ContentDto;
import com.example.unitrip.domain.content.entity.Content;
import com.example.unitrip.domain.content.entity.ContentKnot;
import com.example.unitrip.domain.content.entity.Theme;
import com.example.unitrip.domain.content.repository.ContentRepository;
import com.example.unitrip.domain.user.entity.District;
import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.repository.DistrictRepository;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.global.common.DomainResultCode;
import com.example.unitrip.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ContentService {

    private static final int MAX_KNOTS = 3;
    private static final int MAX_IMAGES = 5;

    private final ContentRepository contentRepository;
    private final UserRepository userRepository;
    private final DistrictRepository districtRepository;

    @Transactional
    public ContentDto.Response create(Long authorId, ContentDto.CreateRequest req) {
        User author = userRepository.findById(authorId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
        validateKnots(req.knots());
        validateImages(req.imageUrls());
        District district = req.districtId() != null ? findDistrict(req.districtId()) : null;

        Content content = Content.builder()
                .author(author)
                .title(req.title())
                .shortIntro(req.shortIntro())
                .description(req.description())
                .theme(req.theme())
                .sido(req.sido())
                .neighborhood(req.neighborhood())
                .district(district)
                .languages(req.languages())
                .imageUrls(req.imageUrls())
                .availableDays(req.availableDays())
                .availableTimeSlots(req.availableTimeSlots())
                .meetingPoint(req.meetingPoint())
                .maxParticipants(req.maxParticipants())
                .pricePerHour(req.pricePerHour())
                .build();
        content.replaceKnots(toKnots(req.knots()));

        return ContentDto.Response.from(contentRepository.save(content));
    }

    public ContentDto.Response get(Long id) {
        return ContentDto.Response.from(find(id));
    }

    public List<ContentDto.Response> listVisible() {
        return contentRepository.findAllByVisibleTrue().stream()
                .map(ContentDto.Response::from).toList();
    }

    public List<ContentDto.Response> listByAuthor(Long authorId) {
        return contentRepository.findAllByAuthorId(authorId).stream()
                .map(ContentDto.Response::from).toList();
    }

    public List<ContentDto.Response> listByTheme(Theme theme) {
        return contentRepository.findAllByThemeAndVisibleTrue(theme).stream()
                .map(ContentDto.Response::from).toList();
    }

    public List<ContentDto.Response> listByDistrict(Long districtId) {
        return contentRepository.findAllByDistrict_IdAndVisibleTrue(districtId).stream()
                .map(ContentDto.Response::from).toList();
    }

    @Transactional
    public ContentDto.Response update(Long id, ContentDto.UpdateRequest req) {
        Content c = find(id);
        validateKnots(req.knots());
        validateImages(req.imageUrls());
        District district = req.districtId() != null ? findDistrict(req.districtId()) : null;

        c.update(req.title(), req.shortIntro(), req.description(), req.theme(),
                req.sido(), req.neighborhood(), district, req.languages(), req.imageUrls(),
                req.availableDays(), req.availableTimeSlots(),
                req.meetingPoint(), req.maxParticipants(), req.pricePerHour());
        if (req.knots() != null) {
            c.replaceKnots(toKnots(req.knots()));
        }
        return ContentDto.Response.from(c);
    }

    @Transactional
    public void setVisible(Long id, boolean visible) {
        find(id).setVisible(visible);
    }

    @Transactional
    public void delete(Long id) {
        contentRepository.delete(find(id));
    }

    private Content find(Long id) {
        return contentRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.CONTENT_NOT_FOUND));
    }

    private District findDistrict(Long id) {
        return districtRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.DISTRICT_NOT_FOUND));
    }

    private List<ContentKnot> toKnots(List<ContentDto.KnotRequest> knotRequests) {
        if (knotRequests == null) return List.of();
        List<ContentKnot> knots = new ArrayList<>();
        for (int i = 0; i < knotRequests.size(); i++) {
            ContentDto.KnotRequest k = knotRequests.get(i);
            knots.add(ContentKnot.builder()
                    .orderIndex(i + 1)
                    .place(k.place())
                    .activity(k.activity())
                    .durationMinutes(k.durationMinutes())
                    .build());
        }
        return knots;
    }

    private void validateKnots(List<ContentDto.KnotRequest> knots) {
        if (knots != null && knots.size() > MAX_KNOTS) {
            throw new GlobalException(DomainResultCode.CONTENT_KNOT_LIMIT_EXCEEDED);
        }
    }

    private void validateImages(List<String> imageUrls) {
        if (imageUrls != null && imageUrls.size() > MAX_IMAGES) {
            throw new GlobalException(DomainResultCode.CONTENT_IMAGE_LIMIT_EXCEEDED);
        }
    }
}
