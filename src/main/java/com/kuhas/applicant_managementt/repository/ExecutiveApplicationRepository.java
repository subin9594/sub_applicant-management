package com.kuhas.applicant_managementt.repository;

import com.kuhas.applicant_managementt.entity.ExecutiveApplication;
import org.springframework.data.jpa.repository.JpaRepository;
 
public interface ExecutiveApplicationRepository extends JpaRepository<ExecutiveApplication, Long> {
    boolean existsByStudentId(String studentId);
    boolean existsByEmail(String email);
    boolean existsByPhoneNumber(String phoneNumber);
} 