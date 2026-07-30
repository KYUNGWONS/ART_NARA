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
}
