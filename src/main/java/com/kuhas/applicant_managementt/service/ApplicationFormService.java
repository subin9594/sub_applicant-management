package com.kuhas.applicant_managementt.service;

import com.kuhas.applicant_managementt.dto.ApplicationFormRequest;
import com.kuhas.applicant_managementt.dto.ApplicationFormResponse;
import com.kuhas.applicant_managementt.entity.ApplicationForm;
import com.kuhas.applicant_managementt.repository.ApplicationFormRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ApplicationFormService {

    private final ApplicationFormRepository applicationFormRepository;
    private final EmailService emailService;

    @Autowired
    public ApplicationFormService(ApplicationFormRepository applicationFormRepository, EmailService emailService) {
        this.applicationFormRepository = applicationFormRepository;
        this.emailService = emailService;
    }

    // 지원서 제출
    public ApplicationFormResponse submitApplication(ApplicationFormRequest request) {
        // 중복 지원 확인 (학번 기준)
        if (applicationFormRepository.findByStudentId(request.getStudentId()).isPresent()) {
            throw new IllegalArgumentException("이미 지원한 학번입니다: " + request.getStudentId());
        }

        // 중복 지원 확인 (이메일 기준)
        if (applicationFormRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalArgumentException("이미 지원한 이메일입니다: " + request.getEmail());
        }

        ApplicationForm applicationForm = new ApplicationForm(
                request.getName(),
                request.getStudentId(),
                request.getPhoneNumber(),
                request.getEmail(),
                request.getMotivation()
        );

        ApplicationForm savedForm = applicationFormRepository.save(applicationForm);

        // 지원 완료 이메일 발송
        emailService.sendApplicationReceivedEmail(savedForm);

        return new ApplicationFormResponse(savedForm);
    }

    // 모든 지원서 조회
    @Transactional(readOnly = true)
    public List<ApplicationFormResponse> getAllApplications() {
        return applicationFormRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(ApplicationFormResponse::new)
                .collect(Collectors.toList());
    }

    // ID로 지원서 조회
    @Transactional(readOnly = true)
    public ApplicationFormResponse getApplicationById(Long id) {
        ApplicationForm applicationForm = applicationFormRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("지원서를 찾을 수 없습니다: " + id));

        return new ApplicationFormResponse(applicationForm);
    }

    // 학번으로 지원서 조회
    @Transactional(readOnly = true)
    public ApplicationFormResponse getApplicationByStudentId(String studentId) {
        ApplicationForm applicationForm = applicationFormRepository.findByStudentId(studentId)
                .orElseThrow(() -> new IllegalArgumentException("지원서를 찾을 수 없습니다: " + studentId));

        return new ApplicationFormResponse(applicationForm);
    }

    // 상태별 지원서 조회
    @Transactional(readOnly = true)
    public List<ApplicationFormResponse> getApplicationsByStatus(ApplicationForm.ApplicationStatus status) {
        return applicationFormRepository.findByStatusOrderByCreatedAtDesc(status)
                .stream()
                .map(ApplicationFormResponse::new)
                .collect(Collectors.toList());
    }

    // 키워드로 지원서 검색
    @Transactional(readOnly = true)
    public List<ApplicationFormResponse> searchApplications(String keyword) {
        return applicationFormRepository.findByKeyword(keyword)
                .stream()
                .map(ApplicationFormResponse::new)
                .collect(Collectors.toList());
    }

    // 지원서 상태 변경
    public ApplicationFormResponse updateApplicationStatus(Long id, ApplicationForm.ApplicationStatus newStatus) {
        ApplicationForm applicationForm = applicationFormRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("지원서를 찾을 수 없습니다: " + id));

        applicationForm.setStatus(newStatus);
        ApplicationForm updatedForm = applicationFormRepository.save(applicationForm);

        // 결과 이메일 발송
        emailService.sendResultEmail(updatedForm, newStatus);

        return new ApplicationFormResponse(updatedForm);
    }

    // 지원서 삭제
    public void deleteApplication(Long id) {
        if (!applicationFormRepository.existsById(id)) {
            throw new IllegalArgumentException("지원서를 찾을 수 없습니다: " + id);
        }

        applicationFormRepository.deleteById(id);
    }

    // 통계 정보 조회
    @Transactional(readOnly = true)
    public ApplicationStatistics getStatistics() {
        long totalApplications = applicationFormRepository.count();
        long pendingCount = applicationFormRepository.countByStatus(ApplicationForm.ApplicationStatus.PENDING);
        long acceptedCount = applicationFormRepository.countByStatus(ApplicationForm.ApplicationStatus.ACCEPTED);
        long rejectedCount = applicationFormRepository.countByStatus(ApplicationForm.ApplicationStatus.REJECTED);

        return new ApplicationStatistics(totalApplications, pendingCount, acceptedCount, rejectedCount);
    }

    // 통계 정보 클래스
    public static class ApplicationStatistics {
        private final long totalApplications;
        private final long pendingCount;
        private final long acceptedCount;
        private final long rejectedCount;

        public ApplicationStatistics(long totalApplications, long pendingCount, long acceptedCount, long rejectedCount) {
            this.totalApplications = totalApplications;
            this.pendingCount = pendingCount;
            this.acceptedCount = acceptedCount;
            this.rejectedCount = rejectedCount;
        }

        // Getter 메서드들
        public long getTotalApplications() { return totalApplications; }
        public long getPendingCount() { return pendingCount; }
        public long getAcceptedCount() { return acceptedCount; }
        public long getRejectedCount() { return rejectedCount; }
    }
}