package com.example.unitrip.domain.chat.entity;

public enum ChatRoomStatus {
    WAITING,  // 상대방 기다리는 중
    ACTIVE,   // 둘 다 참여 중
    CLOSED    // 종료
}