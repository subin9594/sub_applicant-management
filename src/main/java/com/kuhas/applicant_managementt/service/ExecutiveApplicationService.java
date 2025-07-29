package com.kuhas.applicant_managementt.service;

import com.kuhas.applicant_managementt.dto.ExecutiveApplicationRequest;
import com.kuhas.applicant_managementt.dto.ExecutiveApplicationResponse;
import com.kuhas.applicant_managementt.entity.ExecutiveApplication;
import com.kuhas.applicant_managementt.repository.ExecutiveApplicationRepository;
import com.kuhas.applicant_managementt.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ExecutiveApplicationService {
    private final ExecutiveApplicationRepository repository;
    private final EmailService emailService;

    @Autowired
    public ExecutiveApplicationService(ExecutiveApplicationRepository repository, EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }

    public ExecutiveApplicationResponse submitApplication(ExecutiveApplicationRequest request) {
        ExecutiveApplication entity = new ExecutiveApplication();
        entity.setName(request.getName());
        entity.setStudentId(request.getStudentId());
        entity.setGrade(request.getGrade());
        entity.setEmail(request.getEmail());
        entity.setPhoneNumber(request.getPhoneNumber());
        entity.setLeavePlan(request.getLeavePlan());
        entity.setPeriod(request.getPeriod());
        entity.setMotivation(request.getMotivation());
        entity.setGoal(request.getGoal());
        entity.setCrisis(request.getCrisis());
        entity.setMeeting(request.getMeeting());
        entity.setResolution(request.getResolution());
        entity.setPrivacy(request.getPrivacy());
        ExecutiveApplication saved = repository.save(entity);
        emailService.sendExecutiveApplicationReceivedEmail(saved);
        return new ExecutiveApplicationResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<ExecutiveApplicationResponse> getAll() {
        return repository.findAll().stream().map(ExecutiveApplicationResponse::new).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ExecutiveApplicationResponse getById(Long id) {
        ExecutiveApplication entity = repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Not found: " + id));
        return new ExecutiveApplicationResponse(entity);
    }

    public void updateApplication(Long id, ExecutiveApplicationRequest request) {
        ExecutiveApplication before = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("지원서를 찾을 수 없습니다: " + id));

        // 필수 입력 및 길이 체크
        if (request.getName() == null || request.getName().isBlank() || request.getName().length() > 100)
            throw new IllegalArgumentException("이름은 필수이며 100자 이하여야 합니다.");
        if (request.getStudentId() == null || request.getStudentId().isBlank() || request.getStudentId().length() > 20)
            throw new IllegalArgumentException("학번은 필수이며 20자 이하여야 합니다.");
        if (request.getPhoneNumber() == null || request.getPhoneNumber().isBlank() || request.getPhoneNumber().length() > 20)
            throw new IllegalArgumentException("전화번호는 필수이며 20자 이하여야 합니다.");
        if (request.getEmail() == null || request.getEmail().isBlank() || request.getEmail().length() > 100)
            throw new IllegalArgumentException("이메일은 필수이며 100자 이하여야 합니다.");
        if (request.getMotivation() == null || request.getMotivation().isBlank() || request.getMotivation().length() > 2000)
            throw new IllegalArgumentException("지원동기는 필수이며 2000자 이하여야 합니다.");

        // 실제 수정
        before.setName(request.getName());
        before.setStudentId(request.getStudentId());
        before.setGrade(request.getGrade());
        before.setEmail(request.getEmail());
        before.setPhoneNumber(request.getPhoneNumber());
        before.setLeavePlan(request.getLeavePlan());
        before.setPeriod(request.getPeriod());
        before.setMotivation(request.getMotivation());
        before.setGoal(request.getGoal());
        before.setCrisis(request.getCrisis());
        before.setMeeting(request.getMeeting());
        before.setResolution(request.getResolution());
        before.setPrivacy(request.getPrivacy());
        
        repository.save(before);
        
        // 운영진 지원서 수정 안내 메일 발송
        emailService.sendExecutiveApplicationModifiedEmail(before, request);
    }

    public void deleteApplication(Long id) {
        ExecutiveApplication entity = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("지원서를 찾을 수 없습니다: " + id));
        repository.delete(entity);
    }

    // 지원서 상태 변경
    public ExecutiveApplicationResponse updateApplicationStatus(Long id, ExecutiveApplication.ApplicationStatus newStatus) {
        ExecutiveApplication application = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("지원서를 찾을 수 없습니다: " + id));

        application.setStatus(newStatus);
        ExecutiveApplication updatedApplication = repository.save(application);

        // 결과 이메일 발송
        emailService.sendExecutiveApplicationResultEmail(updatedApplication);

        return new ExecutiveApplicationResponse(updatedApplication);
    }
} 