package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.dto.ApplicationFormRequest;
import com.kuhas.applicant_managementt.dto.ApplicationFormResponse;
import com.kuhas.applicant_managementt.entity.ApplicationForm;
import com.kuhas.applicant_managementt.service.ApplicationFormService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/applications")
@CrossOrigin(origins = "*")
public class ApplicationFormController {

    private final ApplicationFormService applicationFormService;

    @Autowired
    public ApplicationFormController(ApplicationFormService applicationFormService) {
        this.applicationFormService = applicationFormService;
    }

    // 지원서 제출
    @PostMapping
    public ResponseEntity<ApplicationFormResponse> submitApplication(@Valid @RequestBody ApplicationFormRequest request) {
        try {
            ApplicationFormResponse response = applicationFormService.submitApplication(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // 모든 지원서 조회
    @GetMapping
    public ResponseEntity<List<ApplicationFormResponse>> getAllApplications() {
        List<ApplicationFormResponse> applications = applicationFormService.getAllApplications();
        return ResponseEntity.ok(applications);
    }

    // ID로 지원서 조회
    @GetMapping("/{id}")
    public ResponseEntity<ApplicationFormResponse> getApplicationById(@PathVariable Long id) {
        try {
            ApplicationFormResponse response = applicationFormService.getApplicationById(id);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 학번으로 지원서 조회
    @GetMapping("/student/{studentId}")
    public ResponseEntity<ApplicationFormResponse> getApplicationByStudentId(@PathVariable String studentId) {
        try {
            ApplicationFormResponse response = applicationFormService.getApplicationByStudentId(studentId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 상태별 지원서 조회
    @GetMapping("/status/{status}")
    public ResponseEntity<List<ApplicationFormResponse>> getApplicationsByStatus(@PathVariable String status) {
        try {
            ApplicationForm.ApplicationStatus applicationStatus = ApplicationForm.ApplicationStatus.valueOf(status.toUpperCase());
            List<ApplicationFormResponse> applications = applicationFormService.getApplicationsByStatus(applicationStatus);
            return ResponseEntity.ok(applications);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // 키워드로 지원서 검색
    @GetMapping("/search")
    public ResponseEntity<List<ApplicationFormResponse>> searchApplications(@RequestParam String keyword) {
        List<ApplicationFormResponse> applications = applicationFormService.searchApplications(keyword);
        return ResponseEntity.ok(applications);
    }

    // 지원서 상태 변경
    @PutMapping("/{id}/status")
    public ResponseEntity<ApplicationFormResponse> updateApplicationStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        try {
            ApplicationForm.ApplicationStatus applicationStatus = ApplicationForm.ApplicationStatus.valueOf(status.toUpperCase());
            ApplicationFormResponse response = applicationFormService.updateApplicationStatus(id, applicationStatus);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // 지원서 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteApplication(@PathVariable Long id) {
        try {
            applicationFormService.deleteApplication(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 통계 정보 조회
    @GetMapping("/statistics")
    public ResponseEntity<ApplicationFormService.ApplicationStatistics> getStatistics() {
        ApplicationFormService.ApplicationStatistics statistics = applicationFormService.getStatistics();
        return ResponseEntity.ok(statistics);
    }
}