package com.example.artnara.domain.chat.repository;

import com.example.artnara.domain.chat.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    List<ChatMessage> findByChatRoomIdOrderByCreatedAtAsc(Long chatRoomId);

    /** 채팅방 목록의 미리보기용 — 방의 가장 최근 메시지 1건 */
    Optional<ChatMessage> findFirstByChatRoomIdOrderByCreatedAtDesc(Long chatRoomId);

    @Query("SELECT m.id FROM ChatMessage m WHERE m.chatRoom.id = :roomId AND m.senderId != :userId AND m.read = false")
    List<Long> findUnreadMessageIds(@Param("roomId") Long roomId, @Param("userId") Long userId);

    @Modifying
    @Query("UPDATE ChatMessage m SET m.read = true WHERE m.chatRoom.id = :roomId AND m.senderId != :userId AND m.read = false")
    void markAsRead(@Param("roomId") Long roomId, @Param("userId") Long userId);
}