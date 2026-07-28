package com.example.unitrip.domain.chat.repository;

import com.example.unitrip.domain.chat.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    List<ChatMessage> findByChatRoomIdOrderByCreatedAtAsc(Long chatRoomId);

    @Query("SELECT m.id FROM ChatMessage m WHERE m.chatRoom.id = :roomId AND m.senderId != :userId AND m.read = false")
    List<Long> findUnreadMessageIds(@Param("roomId") Long roomId, @Param("userId") Long userId);

    @Modifying
    @Query("UPDATE ChatMessage m SET m.read = true WHERE m.chatRoom.id = :roomId AND m.senderId != :userId AND m.read = false")
    void markAsRead(@Param("roomId") Long roomId, @Param("userId") Long userId);
}