package com.example.unitrip.domain.chat.repository;

import com.example.unitrip.domain.chat.entity.Appointment;
import com.example.unitrip.domain.chat.entity.AppointmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    List<Appointment> findByResponderIdAndStatus(Long responderId, AppointmentStatus status);
}