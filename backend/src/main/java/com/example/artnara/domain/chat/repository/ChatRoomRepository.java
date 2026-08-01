package com.example.artnara.domain.chat.repository;

import com.example.artnara.domain.chat.entity.ChatRoom;
import com.example.artnara.domain.chat.entity.ChatRoomStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {

    // 내가 참여 중인 채팅방 목록
    @Query("SELECT r FROM ChatRoom r WHERE r.creatorId = :userId OR r.joinerId = :userId")
    List<ChatRoom> findAllByUserId(@Param("userId") Long userId);

    // 대기 중인 방 목록 (누구든 참여 가능)
    List<ChatRoom> findByStatus(ChatRoomStatus status);

    // 두 사람 사이의 방 (작품 문의는 작가-컬렉터 1:1 이라 중복 생성하지 않는다)
    @Query("SELECT r FROM ChatRoom r WHERE (r.creatorId = :a AND r.joinerId = :b) "
            + "OR (r.creatorId = :b AND r.joinerId = :a)")
    List<ChatRoom> findBetween(@Param("a") Long a, @Param("b") Long b);
}
