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
        // 중복 지원 확인 (학번, 이메일, 전화번호 기준)
        StringBuilder duplicateMsg = new StringBuilder();
        if (applicationFormRepository.findByStudentId(request.getStudentId()).isPresent()) {
            duplicateMsg.append("이미 사용 중인 학번입니다.\n");
        }
        if (applicationFormRepository.findByEmail(request.getEmail()).isPresent()) {
            duplicateMsg.append("이미 사용 중인 이메일입니다.\n");
        }
        if (applicationFormRepository.findByPhoneNumber(request.getPhoneNumber()).isPresent()) {
            duplicateMsg.append("이미 사용 중인 전화번호입니다.\n");
        }
        if (duplicateMsg.length() > 0) {
            throw new IllegalArgumentException(duplicateMsg.toString().trim());
        }

        ApplicationForm applicationForm = new ApplicationForm(
                request.getName(),
                request.getStudentId(),
                request.getPhoneNumber(),
                request.getEmail(),
                request.getMotivation()
        );
        // Set new fields
        applicationForm.setOtherActivity(request.getOtherActivity());
        applicationForm.setCurriculumReason(request.getCurriculumReason());
        applicationForm.setWish(request.getWish());
        applicationForm.setCareer(request.getCareer());
        applicationForm.setLanguageExp(request.getLanguageExp());
        applicationForm.setLanguageDetail(request.getLanguageDetail());
        applicationForm.setWishActivities(request.getWishActivities());
        applicationForm.setInterviewDate(request.getInterviewDate());
        applicationForm.setAttendType(request.getAttendType());
        ApplicationForm savedForm = applicationFormRepository.save(applicationForm);

        // 지원 완료 이메일 발송
        System.out.println("이메일 발송 시도 전");
        emailService.sendApplicationReceivedEmail(savedForm);
        System.out.println("이메일 발송 시도 후");

        return new ApplicationFormResponse(savedForm);
    }

    // 모든 지원서 조회
    @Transactional(readOnly = true)
    public List<ApplicationFormResponse> getAllApplications() {
        return applicationFormRepository.findAllByOrderByCreatedAtAsc()
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

    // 관리자 지원서 수정
    public void updateApplicationByAdmin(Long id, String name, String studentId, String phoneNumber, String email, String motivation, String status) {
        ApplicationForm before = applicationFormRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("지원서를 찾을 수 없습니다: " + id));
        // 중복 학번, 이메일, 전화번호 체크 (본인 제외)
        applicationFormRepository.findByStudentId(studentId)
                .filter(form -> !form.getId().equals(id))
                .ifPresent(form -> { throw new IllegalArgumentException("이미 사용 중인 학번입니다."); });

        applicationFormRepository.findByEmail(email)
                .filter(form -> !form.getId().equals(id))
                .ifPresent(form -> { throw new IllegalArgumentException("이미 사용 중인 이메일입니다."); });

        applicationFormRepository.findByPhoneNumber(phoneNumber)
                .filter(form -> !form.getId().equals(id))
                .ifPresent(form -> { throw new IllegalArgumentException("이미 사용 중인 전화번호입니다."); });

        // 필수 입력 및 길이 체크
        if (name == null || name.isBlank() || name.length() > 100)
            throw new IllegalArgumentException("이름은 필수이며 100자 이하여야 합니다.");
        if (studentId == null || studentId.isBlank() || studentId.length() > 20)
            throw new IllegalArgumentException("학번은 필수이며 20자 이하여야 합니다.");
        if (phoneNumber == null || phoneNumber.isBlank() || phoneNumber.length() > 20)
            throw new IllegalArgumentException("전화번호는 필수이며 20자 이하여야 합니다.");
        if (email == null || email.isBlank() || email.length() > 100)
            throw new IllegalArgumentException("이메일은 필수이며 100자 이하여야 합니다.");
        if (motivation == null || motivation.isBlank() || motivation.length() > 2000)
            throw new IllegalArgumentException("지원동기는 필수이며 2000자 이하여야 합니다.");

        // 실제 수정
        before.setName(name);
        before.setStudentId(studentId);
        before.setPhoneNumber(phoneNumber);
        before.setEmail(email);
        before.setMotivation(motivation);
        before.setStatus(ApplicationForm.ApplicationStatus.valueOf(status));
        applicationFormRepository.save(before);

        // 지원서 수정 안내 메일 발송 (수정 전/후 모두 전달)
        emailService.sendApplicationModifiedEmail(before, name, studentId, phoneNumber, email, motivation, status);
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

    public boolean isStudentIdExists(String studentId) {
        return applicationFormRepository.findByStudentId(studentId).isPresent();
    }
    public boolean isEmailExists(String email) {
        return applicationFormRepository.findByEmail(email).isPresent();
    }
    public boolean isPhoneNumberExists(String phoneNumber) {
        return applicationFormRepository.findByPhoneNumber(phoneNumber).isPresent();
    }
}