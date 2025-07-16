package com.kuhas.applicant_managementt.repository;

import com.kuhas.applicant_managementt.entity.ApplicationForm;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ApplicationFormRepository extends JpaRepository<ApplicationForm, Long> {

    // 학번으로 지원서 찾기
    Optional<ApplicationForm> findByStudentId(String studentId);

    // 이메일로 지원서 찾기
    Optional<ApplicationForm> findByEmail(String email);

    // 상태별로 지원서 목록 조회
    List<ApplicationForm> findByStatus(ApplicationForm.ApplicationStatus status);

    // 상태별로 지원서 개수 조회
    long countByStatus(ApplicationForm.ApplicationStatus status);

    // 이름으로 검색
    List<ApplicationForm> findByNameContainingIgnoreCase(String name);

    // 학번으로 검색
    List<ApplicationForm> findByStudentIdContaining(String studentId);

    // 이메일로 검색
    List<ApplicationForm> findByEmailContainingIgnoreCase(String email);

    // 전화번호로 지원서 찾기
    Optional<ApplicationForm> findByPhoneNumber(String phoneNumber);

    // 복합 검색 (이름, 학번, 이메일)
    @Query("SELECT a FROM ApplicationForm a WHERE " +
            "LOWER(a.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "a.studentId LIKE CONCAT('%', :keyword, '%') OR " +
            "LOWER(a.email) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<ApplicationForm> findByKeyword(@Param("keyword") String keyword);

    // 최근 지원서 순으로 정렬
    List<ApplicationForm> findAllByOrderByCreatedAtDesc();

    // 상태별 최근 지원서 순으로 정렬
    List<ApplicationForm> findByStatusOrderByCreatedAtDesc(ApplicationForm.ApplicationStatus status);

    // 생성일 오름차순(빠른 순) 지원서 목록 조회
    List<ApplicationForm> findAllByOrderByCreatedAtAsc();
}