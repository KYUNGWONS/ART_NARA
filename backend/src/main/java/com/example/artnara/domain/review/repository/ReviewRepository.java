package com.example.artnara.domain.review.repository;

import com.example.artnara.domain.review.entity.Review;
import org.springframework.data.domain.Limit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    boolean existsByAuthorIdAndArtworkId(Long authorId, Long artworkId);

    /** 작가 리뷰 목록 (최신순). 목록이 무한히 커지지 않도록 호출부에서 상한을 준다. */
    List<Review> findByArtistNameOrderByIdDesc(String artistName, Limit limit);

    long countByArtistName(String artistName);

    /** 작가 평균 평점. 리뷰가 없으면 null. */
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.artistName = :artistName")
    Double averageRatingOf(@Param("artistName") String artistName);
}
